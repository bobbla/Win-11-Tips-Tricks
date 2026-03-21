# 📦 Windows 11 – Daily Automated File Move System (23:59)

## 🔹 Overview
This system automatically moves files from three source folders into a structured archive **every day at 23:59** using:

- **PowerShell** for the file-moving logic
- **Task Scheduler** for the automation

It dynamically creates a destination structure based on the **current year and month**, so files are organized like this:

Q:\001 - Real AI Country\FINNISHED\2026\03\VIDEO  
Q:\001 - Real AI Country\FINNISHED\2026\03\MP3  
Q:\001 - Real AI Country\FINNISHED\2026\03\IMG  

This is useful for:
- daily media archiving
- automated cleanup
- production workflows
- maintaining a structured archive without manual work

---

## 🔹 Source and Destination Layout

### Source folders
J:\My Drive [Bjorn Ove Bremnes]\Real AI Music\VIDEO  
J:\My Drive [Bjorn Ove Bremnes]\Real AI Music\MP3  
J:\My Drive [Bjorn Ove Bremnes]\Real AI Music\IMG  

### Destination base folder
Q:\001 - Real AI Country\FINNISHED  

### Final destination structure
Q:\001 - Real AI Country\FINNISHED\[YEAR]\[MONTH]\VIDEO  
Q:\001 - Real AI Country\FINNISHED\[YEAR]\[MONTH]\MP3  
Q:\001 - Real AI Country\FINNISHED\[YEAR]\[MONTH]\IMG  

---

## 🔹 Step-by-Step Guide

### 1. Create the script folder
Create this folder:

C:\Scripts

You can create it manually in File Explorer or with PowerShell.

---

### 2. Create the PowerShell script
Create this file:

C:\Scripts\DailyMove.ps1

Paste the following script into it:

```powershell
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