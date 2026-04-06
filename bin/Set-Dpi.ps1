param([int]$Scale = 125)

try {
    $dpi = [int](96 * ($Scale / 100))
    Set-ItemProperty -Path 'HKCU:\Control Panel\Desktop\WindowMetrics' -Name 'AppliedDPI' -Value $dpi -ErrorAction Stop

    # Restart explorer to apply changes
    Stop-Process -Name explorer -Force -ErrorAction SilentlyContinue
    Start-Process explorer.exe

    Exit 0
} catch {
    Write-Error $_.Exception.Message
    Exit 1
}