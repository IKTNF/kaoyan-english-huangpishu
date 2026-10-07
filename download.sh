#!/usr/bin/env bash
# 下载本仓库 Release 中的考研英语黄皮书 PDF（Linux / macOS / Git Bash）
set -euo pipefail

REPO="${REPO:-IKTNF/kaoyan-english-huangpishu}"
TAG="${TAG:-latest}"
OUTDIR="${OUTDIR:-./pdf}"

if [ "$TAG" = "latest" ]; then
  FROM="releases/latest/download"
else
  FROM="releases/download/$TAG"
fi

ASSETS=(
  "kaoyan-english-2007-2013-jichu.pdf"
  "kaoyan-english-2014-2021-zhencang.pdf"
  "kaoyan-english-2022-2026-jingbian.pdf"
  "kaoyan-english-writing-40.pdf"
)

mkdir -p "$OUTDIR"
echo "输出目录: $OUTDIR"
echo

for name in "${ASSETS[@]}"; do
  url="https://github.com/${REPO}/${FROM}/${name}"
  dest="$OUTDIR/$name"
  echo "==> $name"
  echo "    $url"
  # -C - 断点续传，网络中断后重跑即可
  curl -L --fail --retry 5 --retry-delay 5 -C - -o "$dest" "$url"
  echo "    完成: $(du -h "$dest" | cut -f1)"
  echo
done

echo "全部下载完成 -> $OUTDIR"
