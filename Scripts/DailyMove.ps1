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

$LogFile = "C:\Scripts\DailyMove.log"

Start-Transcript -Path $LogFile -Append

foreach ($job in $Jobs) {
    $Source = $job.Source
    $Destination = $job.Destination

    Write-Host "Processing source: $Source"
    Write-Host "Destination: $Destination"

    if (-not (Test-Path $Source)) {
        Write-Warning "Source folder not found: $Source"
        continue
    }

    if (-not (Test-Path $Destination)) {
        New-Item -ItemType Directory -Path $Destination -Force | Out-Null
    }

    Get-ChildItem -Path $Source -File -ErrorAction SilentlyContinue |
        Move-Item -Destination $Destination -Force -ErrorAction Continue
}

Stop-Transcript