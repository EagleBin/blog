# deploy.ps1 — Hugo 博客部署脚本（Windows PowerShell）
# 用法：./deploy.ps1 -Server root@47.107.56.48

param(
    [string]$Server = "root@47.107.56.48",
    [string]$RemotePath = "/var/www/blog",
    [switch]$DryRun
)

$ErrorActionPreference = "Stop"

# 1. 清理旧构建
Write-Host "=== 1. 清理旧构建 ===" -ForegroundColor Cyan
Remove-Item -Recurse -Force "public" -ErrorAction SilentlyContinue

# 2. Hugo 构建
Write-Host "=== 2. Hugo 构建 ===" -ForegroundColor Cyan
$hugo = "D:\Program\Blog\bin\hugo.exe"
if (-not (Test-Path $hugo)) { $hugo = "hugo" }
& $hugo --minify --buildFuture
if ($LASTEXITCODE -ne 0) {
    Write-Error "Hugo 构建失败！"
    exit 1
}
Write-Host "Hugo 构建完成，静态文件在 .\public\" -ForegroundColor Green

# 3. 上传（scp 方式，适合无 rsync 的环境）
Write-Host "=== 3. 上传到服务器 ===" -ForegroundColor Cyan
Write-Host "正在上传到 $Server ..."

if ($DryRun) {
    Write-Host "[DRY RUN] 将执行: scp -r .\public\* $Server`:$RemotePath" -ForegroundColor Yellow
    Write-Host "[DRY RUN] 将执行: ssh $Server 'chown -R www-data:www-data $RemotePath'" -ForegroundColor Yellow
} else {
    # 确保远程目录存在
    ssh $Server "mkdir -p $RemotePath"

    # 使用 scp 上传
    # 注意：scp -r 上传 public 目录下所有内容
    Get-ChildItem -Path "public" | ForEach-Object {
        Write-Host "  上传 $($_.Name) ..."
        scp -r -q $_.FullName "$Server`:$RemotePath/"
    }

    # 修正权限
    ssh $Server "chown -R www-data:www-data $RemotePath"

    Write-Host "部署完成！" -ForegroundColor Green
    Write-Host "博客地址：https://bmg.l2.ink/" -ForegroundColor Green
}
