# 1. Tạo Action chạy PS7
$action = New-ScheduledTaskAction `
    -Execute 'pwsh.exe' `
    -Argument '-NoProfile -WindowStyle Hidden -File "C:\Users\jackb\Documents\AutoHotkey\bin\daily_commit.ps1"'

# 2. Tạo Trigger: mỗi ngày lúc 22:00
$trigger = New-ScheduledTaskTrigger -Daily -At 22:00

# 3. Đăng ký (hoặc cập nhật) Task
if (Get-ScheduledTask -TaskName 'Git Daily Commit' -ErrorAction SilentlyContinue) {
    Set-ScheduledTask -TaskName 'Git Daily Commit' -Trigger $trigger
}
else {
    Register-ScheduledTask `
        -TaskName    'Git Daily Commit' `
        -Description 'Auto git add & commit hàng ngày với Counter' `
        -Action      $action `
        -Trigger     $trigger `
        -User        $env:USERNAME `
        -RunLevel    Highest
}
