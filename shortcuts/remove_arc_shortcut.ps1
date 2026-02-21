# ================================================
# Description:  Removes leftover Arc browser remnants
# Author:       larroxtv (https://github.com/larroxtv)
# ================================================

Write-Host "Searching for Arc browser remnants..." -ForegroundColor Yellow

$searchPaths = @(
    "$env:APPDATA\Microsoft\Windows\Start Menu",
    "$env:ProgramData\Microsoft\Windows\Start Menu",
    "$env:APPDATA\Microsoft\Internet Explorer\Quick Launch",
    "$env:USERPROFILE\Desktop",
    "$env:PUBLIC\Desktop",
    "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup",
    "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\Startup"
)

$found = @()

foreach ($path in $searchPaths) {
    if (Test-Path $path) {
        $shortcuts = Get-ChildItem -Path $path -Recurse -Filter "*.lnk" -ErrorAction SilentlyContinue | Where-Object { $_.Name -like "*Arc*" }
        foreach ($s in $shortcuts) {
            Write-Host "Found shortcut: $($s.FullName)" -ForegroundColor Cyan
            $found += $s.FullName
        }
    }
}

# Check registry for hotkeys left by Arc
$regPaths = @(
    "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run",
    "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run",
    "HKCU:\SOFTWARE\Classes\AppUserModelId",
    "HKCU:\SOFTWARE\Arc"
)

Write-Host ""
Write-Host "Searching registry..." -ForegroundColor Yellow

foreach ($reg in $regPaths) {
    if (Test-Path $reg) {
        $items = Get-ItemProperty -Path $reg -ErrorAction SilentlyContinue
        $items.PSObject.Properties | Where-Object { $_.Value -like "*Arc*" } | ForEach-Object {
            Write-Host "Found registry entry: [$reg] $($_.Name) = $($_.Value)" -ForegroundColor Cyan
            $found += "REG:$reg|$($_.Name)"
        }
    }
}

# Search deeper for Arc registry keys
$arcRegRoots = @("HKCU:\SOFTWARE", "HKLM:\SOFTWARE")
foreach ($root in $arcRegRoots) {
    Get-ChildItem -Path $root -ErrorAction SilentlyContinue | Where-Object { $_.Name -like "*Arc*" } | ForEach-Object {
        Write-Host "Found registry key: $($_.Name)" -ForegroundColor Cyan
        $found += "REGKEY:$($_.PSPath)"
    }
}

Write-Host ""

if ($found.Count -eq 0) {
    Write-Host "Nothing found. Arc seems clean." -ForegroundColor Green
} else {
    Write-Host "Found $($found.Count) item(s). Delete them? (y/n)" -ForegroundColor Yellow
    $confirm = Read-Host

    if ($confirm -eq "y") {
        foreach ($item in $found) {
            if ($item.StartsWith("REG:")) {
                $parts = $item.Substring(4).Split("|")
                try {
                    Remove-ItemProperty -Path $parts[0] -Name $parts[1] -Force -ErrorAction Stop
                    Write-Host "Deleted registry value: $($parts[1])" -ForegroundColor Green
                } catch {
                    Write-Host "Failed to delete: $item - $_" -ForegroundColor Red
                }
            } elseif ($item.StartsWith("REGKEY:")) {
                $keyPath = $item.Substring(7)
                try {
                    Remove-Item -Path $keyPath -Recurse -Force -ErrorAction Stop
                    Write-Host "Deleted registry key: $keyPath" -ForegroundColor Green
                } catch {
                    Write-Host "Failed to delete: $keyPath - $_" -ForegroundColor Red
                }
            } else {
                try {
                    Remove-Item -Path $item -Force -ErrorAction Stop
                    Write-Host "Deleted: $item" -ForegroundColor Green
                } catch {
                    Write-Host "Failed to delete: $item - $_" -ForegroundColor Red
                }
            }
        }
        Write-Host ""
        Write-Host "Done! All Arc remnants removed." -ForegroundColor Cyan
    } else {
        Write-Host "Aborted. Nothing deleted." -ForegroundColor Yellow
    }
}

pause
