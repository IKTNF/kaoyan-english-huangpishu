#Requires -Version 5.1
<#
.SYNOPSIS
    下载本仓库 Release 中的考研英语黄皮书 PDF。

.DESCRIPTION
    先尝试 github.com 直链；若网络无法访问 github.com（部分网络环境下会被阻断），
    自动改用 api.github.com 资产接口下载，该接口通常仍可访问。

.EXAMPLE
    .\download.ps1
    下载全部 4 个 PDF 到 .\pdf\ 目录。

.EXAMPLE
    .\download.ps1 -Only jingbian,writing -OutDir D:\books
    只下载精编版和写作真题。
#>
[CmdletBinding()]
param(
    [string]   $Repo   = 'IKTNF/kaoyan-english-huangpishu',
    [string]   $Tag    = 'latest',
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
    $bad = @($Only | Where-Object { -not $assets.Contains($_) })
    if ($bad) { throw "未知别名: $($bad -join ', ')。可用: $($assets.Keys -join ', ')" }
}
$keys = if ($Only) { @($Only) } else { @($assets.Keys) }

New-Item -ItemType Directory -Force -Path $OutDir | Out-Null
Write-Host "输出目录: $OutDir`n" -ForegroundColor Cyan

$commitish = if ($Tag -eq 'latest') { 'latest' } else { "tags/$Tag" }
$direct    = if ($Tag -eq 'latest') { "https://github.com/$Repo/releases/latest/download" }
             else                    { "https://github.com/$Repo/releases/download/$Tag" }

if (-not (Get-Command curl.exe -ErrorAction SilentlyContinue)) {
    throw 'curl.exe 不可用（Windows 10 1803+ 自带）。'
}

# 解析资产 id，供 api.github.com 备用通道使用（github.com 被阻断时）
function Get-AssetId([string]$Name) {
    try {
        $rel = Invoke-RestMethod -Uri "https://api.github.com/repos/$Repo/releases/$commitish" `
                   -Headers @{ 'User-Agent' = 'dsh-download'; Accept = 'application/vnd.github+json' } `
                   -TimeoutSec 30
        $hit = @($rel.assets | Where-Object { $_.name -eq $Name })
        if ($hit.Count -gt 0) { return $hit[0].id }
    } catch { }
    return $null
}

foreach ($k in $keys) {
    $a    = $assets[$k]
    $dest = Join-Path $OutDir $a.Name
    Write-Host "==> $($a.Desc)  (~$([math]::Round($a.MB/1024,2)) GB)" -ForegroundColor Yellow

    if ((Test-Path -LiteralPath $dest) -and
        [math]::Abs((Get-Item -LiteralPath $dest).Length / 1MB - $a.MB) -lt 5) {
        Write-Host "    已存在且大小相符，跳过。`n" -ForegroundColor DarkGray
        continue
    }

    # 通道 1: github.com 直链（支持断点续传）
    Write-Host "    通道1 github.com ..."
    & curl.exe -L --fail --retry 3 --retry-delay 5 -C - -o $dest "$direct/$($a.Name)"
    if ($LASTEXITCODE -eq 0 -and (Test-Path -LiteralPath $dest)) {
        Write-Host "    完成: $([math]::Round((Get-Item -LiteralPath $dest).Length/1MB,1)) MB`n" -ForegroundColor Green
        continue
    }

    # 通道 2: api.github.com 资产接口（github.com 不可达时仍可用）
    Write-Host "    通道1 失败 (exit $LASTEXITCODE)，改用 api.github.com ..." -ForegroundColor DarkYellow
    $id = Get-AssetId $a.Name
    if (-not $id) { Write-Warning "    无法解析资产 id，放弃: $($a.Name)"; continue }

    & curl.exe -L --fail --retry 3 --retry-delay 5 -C - -o $dest `
        -H 'Accept: application/octet-stream' `
        "https://api.github.com/repos/$Repo/releases/assets/$id"

    if ($LASTEXITCODE -eq 0 -and (Test-Path -LiteralPath $dest)) {
        Write-Host "    完成(备用通道): $([math]::Round((Get-Item -LiteralPath $dest).Length/1MB,1)) MB`n" -ForegroundColor Green
    } else {
        Write-Warning "    两条通道均失败: $($a.Name)"
    }
}
Write-Host '全部任务结束。' -ForegroundColor Cyan
