#Requires -Version 5.1
<#
.SYNOPSIS
    下载本仓库 Release 中的考研英语黄皮书 PDF。

.EXAMPLE
    .\download.ps1
    下载全部 4 个 PDF 到 .\pdf\ 目录。

.EXAMPLE
    .\download.ps1 -Only jingbian,writing -OutDir D:\books
    只下载精编版和写作真题。
#>
[CmdletBinding()]
param(
    [string]   $Repo  = 'IKTNF/kaoyan-english-huangpishu',
    [string]   $Tag   = 'latest',
    [string]   $OutDir = (Join-Path $PSScriptRoot 'pdf'),
    [string[]] $Only
)

$ErrorActionPreference = 'Continue'
$ProgressPreference    = 'Continue'

$assets = [ordered]@{
    'jichu'    = @{ Name = 'kaoyan-english-2007-2013-jichu.pdf';    MB = 784; Desc = '基础版 2007-2013' }
    'zhencang' = @{ Name = 'kaoyan-english-2014-2021-zhencang.pdf'; MB = 897; Desc = '珍藏版 2014-2021' }
    'jingbian' = @{ Name = 'kaoyan-english-2022-2026-jingbian.pdf'; MB = 462; Desc = '精编版 2022-2026' }
    'writing'  = @{ Name = 'kaoyan-english-writing-40.pdf';         MB = 997; Desc = '写作真题40篇' }
}

if ($Only) {
    $missing = @($Only | Where-Object { -not $assets.Contains($_) })
    if ($missing) { throw "未知的别名: $($missing -join ', ')。可用: $($assets.Keys -join ', ')" }
}
$keys = if ($Only) { @($Only) } else { @($assets.Keys) }

New-Item -ItemType Directory -Force -Path $OutDir | Out-Null
Write-Host "输出目录: $OutDir`n" -ForegroundColor Cyan

$from = if ($Tag -eq 'latest') { 'releases/latest/download' } else { "releases/download/$Tag" }

foreach ($k in $keys) {
    $a    = $assets[$k]
    $url  = "https://github.com/$Repo/$from/$($a.Name)"
    $dest = Join-Path $OutDir $a.Name
    $gb   = [math]::Round($a.MB / 1024, 2)
    Write-Host "==> $($a.Desc)  (~$gb GB)" -ForegroundColor Yellow
    Write-Host "    $url"

    if ((Test-Path -LiteralPath $dest) -and
        [math]::Abs((Get-Item -LiteralPath $dest).Length / 1MB - $a.MB) -lt 5) {
        Write-Host "    已存在且大小相符，跳过。`n" -ForegroundColor DarkGray
        continue
    }

    # git 的远程传输走 git 协议；大文件用 curl 支持断点续传
    $curl = Get-Command curl.exe -ErrorAction SilentlyContinue
    if ($curl) {
        & $curl.Source -L --fail --retry 5 --retry-delay 5 -C - -o $dest $url
    } else {
        Invoke-WebRequest -Uri $url -OutFile $dest
    }

    if ($LASTEXITCODE -eq 0 -and (Test-Path -LiteralPath $dest)) {
        $mb = [math]::Round((Get-Item -LiteralPath $dest).Length / 1MB, 1)
        Write-Host "    完成: $mb MB`n" -ForegroundColor Green
    } else {
        Write-Warning "    下载失败 (exit $LASTEXITCODE): $($a.Name)"
    }
}
Write-Host '全部任务结束。' -ForegroundColor Cyan
