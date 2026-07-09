param(
    [int]$IntervalSeconds = 30
)

$projectPath = "C:\Users\seshanand -G6\StudentPortal"
$branch = "main"

Import-Module BurntToast -ErrorAction SilentlyContinue

function Show-Notification {
    param([string]$Title, [string]$Message)
    try {
        New-BurntToastNotification -Text $Title, $Message -Sound Default
    }
    catch {
        Add-Type -AssemblyName System.Windows.Forms
        $n = New-Object System.Windows.Forms.NotifyIcon
        $n.Icon = [System.Drawing.SystemIcons]::Information
        $n.Visible = $true
        $n.ShowBalloonTip(8000, $Title, $Message, [System.Windows.Forms.ToolTipIcon]::Info)
        Start-Sleep -Seconds 8
        $n.Dispose()
    }
}

Write-Host "GitHub Watcher Started!" -ForegroundColor Green
Write-Host "Watching: $branch every $IntervalSeconds seconds" -ForegroundColor Yellow
Write-Host "Mode: NOTIFY ONLY - will not auto pull" -ForegroundColor Cyan
Write-Host "Press Ctrl+C to stop" -ForegroundColor Red
Write-Host ""

Set-Location $projectPath
git fetch origin $branch 2>$null
$lastKnownCommit = git rev-parse origin/$branch 2>$null

while ($true) {
    try {
        Set-Location $projectPath
        git fetch origin $branch 2>$null
        $latestCommit = git rev-parse origin/$branch 2>$null

        if ($latestCommit -ne $lastKnownCommit) {
            $author = git log origin/$branch -1 --format="%an"
            $message = git log origin/$branch -1 --format="%s"
            $time = Get-Date -Format "hh:mm tt"
            $changed = git diff HEAD origin/$branch --name-only

            Write-Host ""
            Write-Host "========================================" -ForegroundColor Yellow
            Write-Host "NEW CODE PUSHED!" -ForegroundColor Yellow
            Write-Host "Time    : $time" -ForegroundColor White
            Write-Host "By      : $author" -ForegroundColor Cyan
            Write-Host "Message : $message" -ForegroundColor White
            Write-Host "Files changed:" -ForegroundColor Yellow
            Write-Host $changed -ForegroundColor White
            Write-Host ""
            Write-Host "Pull when ready: git pull origin main" -ForegroundColor Green
            Write-Host "========================================" -ForegroundColor Yellow
            Write-Host ""

            Show-Notification "$author pushed new code!" "$message - Pull when ready!"

            [System.Console]::Beep(800, 300)
            Start-Sleep -Milliseconds 200
            [System.Console]::Beep(1000, 300)

            $lastKnownCommit = $latestCommit
        }
        else {
            Write-Host "$(Get-Date -Format 'HH:mm:ss') - Watching..." -ForegroundColor DarkGray
        }
    }
    catch {
        Write-Host "Error: $_" -ForegroundColor Red
    }

    Start-Sleep -Seconds $IntervalSeconds
}