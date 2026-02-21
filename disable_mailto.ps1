$registryPaths = @(
    "HKLM:\SOFTWARE\Classes\mailto",
    "HKCU:\SOFTWARE\Classes\mailto"
)

foreach ($path in $registryPaths) {
    if (Test-Path $path) {
        try {
            $shellPath = "$path\shell\open\command"
            if (Test-Path $shellPath) {
                Set-ItemProperty -Path $shellPath -Name "(Default)" -Value "" -Force
                Write-Host "Cleared handler: $path" -ForegroundColor Green
            }
        } catch {
            Write-Host "Error at $path : $_" -ForegroundColor Red
        }
    }
}

$usersHivePath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList"
$userProfiles = Get-ChildItem $usersHivePath

foreach ($profile in $userProfiles) {
    $profilePath = (Get-ItemProperty $profile.PSPath).ProfileImagePath
    $ntuser = "$profilePath\NTUSER.DAT"

    if (Test-Path $ntuser) {
        $sid = $profile.PSChildName
        try {
            $tempHive = "HKU\TEMP_$sid"
            reg load $tempHive $ntuser 2>$null

            $userMailtoPath = "Registry::HKU\TEMP_$sid\SOFTWARE\Microsoft\Windows\Shell\Associations\UrlAssociations\mailto\UserChoice"

            if (Test-Path $userMailtoPath) {
                Remove-Item -Path $userMailtoPath -Force -Recurse
                Write-Host "Removed UserChoice for: $profilePath" -ForegroundColor Green
            }
        } catch {
            Write-Host "Error for user $sid : $_" -ForegroundColor Red
        } finally {
            [gc]::Collect()
            Start-Sleep -Milliseconds 200
            reg unload $tempHive 2>$null
        }
    }
}

$currentUserChoice = "HKCU:\SOFTWARE\Microsoft\Windows\Shell\Associations\UrlAssociations\mailto\UserChoice"
if (Test-Path $currentUserChoice) {
    Remove-Item -Path $currentUserChoice -Force -Recurse
    Write-Host "Removed UserChoice for current user." -ForegroundColor Green
}

$mailtoClassPath = "HKLM:\SOFTWARE\Classes\mailto\shell\open\command"
if (-not (Test-Path $mailtoClassPath)) {
    New-Item -Path $mailtoClassPath -Force | Out-Null
}
Set-ItemProperty -Path $mailtoClassPath -Name "(Default)" -Value "" -Force
Write-Host "System-wide mailto handler disabled." -ForegroundColor Green

Write-Host ""
Write-Host "Done! No more annoying mailto dialog." -ForegroundColor Cyan

pause
