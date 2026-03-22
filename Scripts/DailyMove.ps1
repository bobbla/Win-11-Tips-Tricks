$BaseDestination = "Q:\001 - Real AI Country\FINNISHED"

$Year = Get-Date -Format "yyyy"
$Month = Get-Date -Format "MM"

$Jobs = @(
    @{
        Source = "J:\My Drive [Bjorn Ove Bremnes]\Real AI Music\VIDEO"
        Destination = Join-Path $BaseDestination "$Year\$Month\VIDEO"
    },
    @{
        Source = "J:\My Drive [Bjorn Ove Bremnes]\Real AI Music\MP3"
        Destination = Join-Path $BaseDestination "$Year\$Month\MP3"
    },
    @{
        Source = "J:\My Drive [Bjorn Ove Bremnes]\Real AI Music\IMG"
        Destination = Join-Path $BaseDestination "$Year\$Month\IMG"
    }
)

# -----------------------------
# Logging setup
# -----------------------------
$LogFolder = "E:\Scripts\Logs\RealAICountryMusic"
$Timestamp = Get-Date -Format "yyyy-MM-dd"
$LogFile = Join-Path $LogFolder "DailyMove_$Timestamp.log"

if (-not (Test-Path -LiteralPath $LogFolder)) {
    New-Item -ItemType Directory -Path $LogFolder -Force | Out-Null
}

Get-ChildItem -LiteralPath $LogFolder -Filter "*.log" -ErrorAction SilentlyContinue |
    Where-Object { $_.LastWriteTime -lt (Get-Date).AddDays(-30) } |
    Remove-Item -Force -ErrorAction SilentlyContinue

Start-Transcript -Path $LogFile -Append

Write-Host "========================================"
Write-Host " Daily File Move Started"
Write-Host " Time: $(Get-Date)"
Write-Host "========================================"

$TotalMoved = 0

foreach ($job in $Jobs) {
    $Source = $job.Source
    $Destination = $job.Destination
    $MovedCount = 0

    Write-Host ""
    Write-Host "Processing source: $Source"
    Write-Host "Destination: $Destination"

    if (-not (Test-Path -LiteralPath $Source)) {
        Write-Warning "Source folder not found: $Source"
        continue
    }

    if (-not (Test-Path -LiteralPath $Destination)) {
        New-Item -ItemType Directory -Path $Destination -Force | Out-Null
        Write-Host "Created destination folder."
    }

    $Files = Get-ChildItem -LiteralPath $Source -File -ErrorAction SilentlyContinue

    if (-not $Files) {
        Write-Host "No files found in source."
        continue
    }

    foreach ($File in $Files) {
        try {
            $BaseName = [System.IO.Path]::GetFileNameWithoutExtension($File.Name)
            $Extension = $File.Extension
            $DestinationPath = Join-Path $Destination $File.Name

            $Counter = 1

            # Check for duplicates and generate new name
            while (Test-Path -LiteralPath $DestinationPath) {
                $NewName = "{0}_{1}{2}" -f $BaseName, $Counter, $Extension
                $DestinationPath = Join-Path $Destination $NewName
                $Counter++
            }

            Move-Item -LiteralPath $File.FullName -Destination $DestinationPath -ErrorAction Stop

            $MovedCount++
            $TotalMoved++

            Write-Host "Moved: $($File.Name) -> $(Split-Path $DestinationPath -Leaf)"
        }
        catch {
            Write-Warning "Failed to move file: $($File.FullName)"
            Write-Warning "Reason: $($_.Exception.Message)"
        }
    }

    Write-Host "Moved $MovedCount file(s) from this folder."
}

Write-Host ""
Write-Host "========================================"
Write-Host " Total files moved: $TotalMoved"
Write-Host " Completed: $(Get-Date)"
Write-Host "========================================"

Stop-Transcript