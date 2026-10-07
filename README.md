# 考研英语黄皮书 PDF 资料

考研英语（一）"黄皮书"系列真题解析与练习资料的个人备份仓库。

## 📥 怎么下载

**无需 GitHub 账号、无需登录 —— 仓库是公开的，任何人都可以直接下载。**

Release 页面：<https://github.com/IKTNF/kaoyan-english-huangpishu/releases/latest>

### 方式一：一键脚本（推荐，支持断点续传）

克隆仓库后运行：

```powershell
.\download.ps1                 # Windows PowerShell：下载全部
.\download.ps1 -Only jingbian  # 只下载精编版
```

```bash
./download.sh                  # Linux / macOS / Git Bash
```

脚本会先尝试 `github.com` 直链；**如果所在网络无法访问 `github.com`（例如部分内地网络），
会自动切换到 `api.github.com` 资产接口下载**，无需手动干预。

### 方式二：浏览器点开直接下载

| 资料 | 适用年份 | 大小 | 直接下载 |
|---|---|---|---|
| 历年考研英语真题解析及复习思路（基础版） | 2007–2013 | 784 MB | [下载][a1] |
| 历年考研英语真题解析及复习思路（珍藏版） | 2014–2021 | 897 MB | [下载][a2] |
| 历年考研英语真题解析及复习思路（精编版） | 2022–2026 | 462 MB | [下载][a3] |
| 考研英语(一)真题学霸狂练 · 写作真题40篇 | — | 997 MB | [下载][a4] |

[a1]: https://github.com/IKTNF/kaoyan-english-huangpishu/releases/latest/download/kaoyan-english-2007-2013-jichu.pdf
[a2]: https://github.com/IKTNF/kaoyan-english-huangpishu/releases/latest/download/kaoyan-english-2014-2021-zhencang.pdf
[a3]: https://github.com/IKTNF/kaoyan-english-huangpishu/releases/latest/download/kaoyan-english-2022-2026-jingbian.pdf
[a4]: https://github.com/IKTNF/kaoyan-english-huangpishu/releases/latest/download/kaoyan-english-writing-40.pdf

### 方式三：`github.com` 打不开时的 curl 命令

```bash
# 1) 用 API 查资产 id（api.github.com 通常没被阻断）
#    例如查询基础版的 id：
curl -sSL -H 'Accept: application/vnd.github+json' \
  https://api.github.com/repos/IKTNF/kaoyan-english-huangpishu/releases/latest \
  | grep -o '"id":[0-9]*' | head -1

# 2) 用 id 下载（把 <ID> 换成上一步得到的数字）
curl -L -C - -H 'Accept: application/octet-stream' \
  -o kaoyan-english-2007-2013-jichu.pdf \
  https://api.github.com/repos/IKTNF/kaoyan-english-huangpishu/releases/assets/<ID>
```

## ✅ 完整性校验（SHA-256）

下载后可自行核对，确保文件没有损坏：

| 资产名 | 字节数 | SHA-256 |
|---|---|---|
| `kaoyan-english-2007-2013-jichu.pdf` | 822,600,696 | `bf084656fb92c6462aa5d6e5b1004f36da0a8b0163791dcb5253388b42bdff47` |
| `kaoyan-english-2014-2021-zhencang.pdf` | 940,832,734 | `1cde109c661582de740f3d2b21546bdcd5531b28bfe8651b300f2b7d5e69d645` |
| `kaoyan-english-2022-2026-jingbian.pdf` | 483,999,566 | `2c15906f9db72d26b13232bf3ffa2916d11b39d2036daceacf2e5366dcb6d16c` |
| `kaoyan-english-writing-40.pdf` | 1,045,099,449 | `beaa550c93baca7525fdb411366d1ad36a0121032d91c1ee08c99c66208d8940` |

```powershell
# Windows
Get-FileHash .\kaoyan-english-2007-2013-jichu.pdf -Algorithm SHA256
```
```bash
# Linux / macOS
sha256sum kaoyan-english-2007-2013-jichu.pdf
```

## 文件对照表

Release 资产名使用 ASCII 以便脚本下载，对应原始中文文件名如下：

| 资产名 | 原始文件名 |
|---|---|
| `kaoyan-english-2007-2013-jichu.pdf` | 历年考研英语真题解析及复习思路(基础版)（2007-2013）.pdf |
| `kaoyan-english-2014-2021-zhencang.pdf` | 历年考研英语真题解析及复习思路(珍藏版)  (2014-2021) .pdf |
| `kaoyan-english-2022-2026-jingbian.pdf` | 历年考研英语真题解析及复习思路(精编版)  (2022-2026) .pdf |
| `kaoyan-english-writing-40.pdf` | 考研英语(一)真题学霸狂练 写作真题40篇.pdf |

## ❓ 为什么 PDF 不在仓库里？

每本 460 MB–1 GB，总计约 **3.07 GiB**，远超 GitHub 单文件 100 MB 的硬性限制，
因此它们作为 **Release 资产** 发布，而不是提交进 git 历史。
这样仓库本身只有几 KB，`git clone` 很快，而 PDF 走 Release 下载通道（同样公开可下载）。

## ⚠️ 版权声明

本仓库内容为个人学习备份。上述书籍版权归原作者及出版方（张剑黄皮书系列）所有。
请勿用于商业用途或二次传播，如权利人提出要求将立即删除。
