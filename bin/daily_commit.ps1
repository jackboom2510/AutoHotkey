#!/usr/bin/env pwsh
<#
  daily_commit.ps1
  - Tự động git add & git commit với:
      + Counter tăng dần mỗi lần chạy trong cùng ngày  
      + Counter tự reset khi bước qua ngày mới  
  - Yêu cầu: PowerShell 7, Git đã thêm vào PATH
#>

param(
    # Thư mục gốc của repo (chứa .git)
    [string]$RepoPath = 'C:\Users\jackb\Documents\AutoHotkey',

    # File lưu trạng thái Counter & Ngày
    [string]$DataFile = 'C:\Users\jackb\Documents\AutoHotkey\.daily_commit_data.json'
)

# 1. Đảm bảo DataFile tồn tại, nếu chưa có thì khởi tạo:
if (-not (Test-Path $DataFile)) {
    $state = [pscustomobject]@{
        Date    = (Get-Date).ToString('yyyy-MM-dd')
        Counter = 0
    }
}
else {
    # Đọc JSON vào PSCustomObject
    $state = Get-Content $DataFile -Raw | ConvertFrom-Json
}

# 2. Nếu ngày lưu trong file != ngày hôm nay → reset counter
$today = (Get-Date).ToString('yyyy-MM-dd')
if ($state.Date -ne $today) {
    $state.Date = $today
    $state.Counter = 0
}

# 3. Tăng counter lên 1 và ghi trở lại DataFile
$state.Counter++
$state | ConvertTo-Json | Set-Content $DataFile

# 4. Chuyển vào folder repo, add & commit nếu có thay đổi
Push-Location $RepoPath
try {
    git add -A

    $hasChange = (git status --porcelain) -ne ''
    if ($hasChange) {
        $ts = Get-Date -Format 'HH:mm - dd/MM/yyyy'
        $msg = "Daily Commit #$($state.Counter) ($ts)"
        git commit -m $msg
        Write-Host "✅ $msg"
    }
    else {
        Write-Host "ℹ️ Không có thay đổi để commit."
    }
}
catch {
    Write-Error "❌ Lỗi khi chạy git: $_"
}
finally {
    Pop-Location
}
