#!/usr/bin/env bash
# 下载本仓库 Release 中的考研英语黄皮书 PDF（Linux / macOS / Git Bash）
#
# 先走 github.com 直链；若该域名不可达（部分网络会阻断），
# 自动改用 api.github.com 资产接口，该接口通常仍可访问。
set -uo pipefail

REPO="${REPO:-IKTNF/kaoyan-english-huangpishu}"
TAG="${TAG:-latest}"
OUTDIR="${OUTDIR:-./pdf}"

if [ "$TAG" = "latest" ]; then
  COMMITISH="latest"
  DIRECT="https://github.com/${REPO}/releases/latest/download"
else
  COMMITISH="tags/${TAG}"
  DIRECT="https://github.com/${REPO}/releases/download/${TAG}"
fi

ASSETS=(
  "kaoyan-english-2007-2013-jichu.pdf"
  "kaoyan-english-2014-2021-zhencang.pdf"
  "kaoyan-english-2022-2026-jingbian.pdf"
  "kaoyan-english-writing-40.pdf"
)

# 通过 API 查出资产 id，供备用通道使用。
# GitHub 返回紧凑 JSON（"name":"x"）。这里把冒号后的空格统一去掉，
# 以便用 grep -F 精确匹配；tr '{' 把每个 JSON 对象切成一行，
# 因此资产的 "id" 与 "name" 会落在同一行上。
asset_id() {
  local name="$1"
  curl -sSL --max-time 30 \
    -H 'Accept: application/vnd.github+json' \
    -H 'User-Agent: dsh-download' \
    "https://api.github.com/repos/${REPO}/releases/${COMMITISH}" \
  | sed 's/: */:/g' \
  | tr '{' '\n' \
  | grep -F "\"name\":\"${name}\"" \
  | grep -o '"id":[0-9]*' \
  | head -1 \
  | grep -o '[0-9]*'
}

mkdir -p "$OUTDIR"
echo "输出目录: $OUTDIR"
echo

fail=0
for name in "${ASSETS[@]}"; do
  dest="$OUTDIR/$name"
  echo "==> $name"

  # 通道 1: github.com 直链（-C - 断点续传）
  if curl -L --fail --retry 3 --retry-delay 5 -C - -o "$dest" "$DIRECT/$name"; then
    echo "    完成: $(du -h "$dest" | cut -f1)"
    echo
    continue
  fi

  # 通道 2: api.github.com 资产接口
  echo "    通道1 失败，改用 api.github.com ..."
  id="$(asset_id "$name")"
  if [ -z "$id" ]; then
    echo "    !! 无法解析资产 id: $name" >&2
    fail=1
    echo
    continue
  fi

  if curl -L --fail --retry 3 --retry-delay 5 -C - -o "$dest" \
       -H 'Accept: application/octet-stream' \
       "https://api.github.com/repos/${REPO}/releases/assets/${id}"; then
    echo "    完成(备用通道): $(du -h "$dest" | cut -f1)"
  else
    echo "    !! 两条通道均失败: $name" >&2
    fail=1
  fi
  echo
done

if [ "$fail" -eq 0 ]; then
  echo "全部下载完成 -> $OUTDIR"
else
  echo "部分文件下载失败，请重试（支持断点续传）。" >&2
  exit 1
fi
