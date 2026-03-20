# 📦 Windows 11 – Monthly Automated File Move (PowerShell + Task Scheduler)

## 🔹 Overview
This setup automates moving files from three source folders into a structured archive **once per month at 04:00** using:

- **PowerShell** → handles file movement
- **Task Scheduler** → runs it automatically

It dynamically creates a clean folder structure based on **year and month**:

Q:\001 - Real AI Country\FINNISHED\2026\03\VIDEO  
Q:\001 - Real AI Country\FINNISHED\2026\03\MP3  
Q:\001 - Real AI Country\FINNISHED\2026\03\IMG  

### ✅ Why this is useful
- Fully automated workflow
- Clean archive organization
- No manual file handling
- Scales indefinitely

---

## 🔹 Folder Configuration

### Source folders
J:\My Drive [Bjorn Ove Bremnes]\Real AI Music\VIDEO  
J:\My Drive [Bjorn Ove Bremnes]\Real AI Music\MP3  
J:\My Drive [Bjorn Ove Bremnes]\Real AI Music\IMG  

### Destination base
Q:\001 - Real AI Country\FINNISHED  

Final structure:
[Base]\[YEAR]\[MONTH]\[TYPE]

---

## 🔹 Step-by-Step Guide

### 1. Create script folder
Create:
C:\Scripts

---

### 2. Create PowerShell script

Create file:
C:\Scripts\MonthlyMove.ps1

Paste:

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

$LogFile = "C:\Scripts\MonthlyMove.log"

Start-Transcript -Path $LogFile -Append

foreach ($job in $Jobs) {

    $Source = $job.Source
    $Destination = $job.Destination

    Write-Host "Processing: $Source → $Destination"

    if (-not (Test-Path $Source)) {
        Write-Warning "Source not found: $Source"
        continue
    }

    if (-not (Test-Path $Destination)) {
        New-Item -ItemType Directory -Path $Destination -Force | Out-Null
    }

    Get-ChildItem -Path $Source -File -ErrorAction SilentlyContinue |
        Move-Item -Destination $Destination -Force -ErrorAction Continue
}

Stop-Transcript

---

## 🔹 What the Script Does

- Detects current year and month automatically
- Builds destination folders dynamically
- Creates missing folders
- Moves files (not folders)
- Logs all activity to:
  C:\Scripts\MonthlyMove.log
- Skips errors without stopping execution

---

## 🔹 Test the Script (MANDATORY)

Run manually:

powershell -ExecutionPolicy Bypass -File "C:\Scripts\MonthlyMove.ps1"

Verify:
- Files moved correctly
- Folders created correctly
- Log file updated

---

## 🔹 Create Scheduled Task

### Open Task Scheduler
Win + S → Task Scheduler

---

### Create Task
Click: Create Task

---

### General Tab
- Name: Monthly Real AI Move
- ✔ Run whether user is logged on or not
- ✔ Run with highest privileges

---

### Trigger
- Monthly
- Day: 1
- Time: 04:00

---

### Action
Program/script:
powershell.exe

Arguments:
-ExecutionPolicy Bypass -File "C:\Scripts\MonthlyMove.ps1"

Start in:
C:\Scripts

---

### Conditions
- Disable AC restriction if needed
- Enable wake if PC sleeps

---

### Settings
Enable:
- Run after missed start
- Allow manual run

---

### Save Task
- Click OK
- Enter password

---

### Test Task
- Right-click → Run
- Confirm result = 0x0

---

## 🔹 Commands

Run script manually:
powershell -ExecutionPolicy Bypass -File "C:\Scripts\MonthlyMove.ps1"

Create script folder:
New-Item -ItemType Directory -Path "C:\Scripts" -Force

---

## 🔹 Pro Tips

- Use MM format → ensures sorting (01–12)
- Keep consistent structure:
  FINNISHED\YEAR\MONTH\TYPE
- Enable Task Scheduler history
- Shortcut:
  Win + R → taskschd.msc
- Use logs + history for debugging

---

## 🔹 Warnings

### ⚠️ Mapped Drives (CRITICAL)
J: and Q: may not work in scheduled tasks.

Solutions:
- Use UNC paths (recommended)
- Or map drives inside script:
  net use J: \\server\path
  net use Q: \\server\path

---

### ⚠️ File behavior
- Files are MOVED, not copied
- Source folders will be emptied

---

### ⚠️ File conflicts
- -Force may overwrite files

---

### ⚠️ Locked files
- Files in use may fail to move

---

### ⚠️ Cloud storage
- Ensure files are available offline

---

## 🔹 Optional Enhancements

### Month names instead of numbers
$Month = Get-Date -Format "MMMM"

---

### Move only specific file types
Get-ChildItem -Path $Source -Filter "*.mp3" -File |
Move-Item -Destination $Destination -Force

---

### Move only older files
Get-ChildItem -Path $Source -File |
Where-Object { $_.LastWriteTime -lt (Get-Date).AddDays(-7) } |
Move-Item -Destination $Destination -Force

---

### Use robocopy (more robust)
robocopy "SOURCE" "DESTINATION" /MOV /E /R:2 /W:5

---

### Dry-run mode
Get-ChildItem -Path $Source -File | Select-Object FullName

---

## 🔹 Summary

This setup gives you:

1. A PowerShell script that:
   - builds YEAR/MONTH folders automatically
   - moves files from VIDEO, MP3, IMG
   - logs all activity

2. A scheduled task that:
   - runs monthly at 04:00
   - works automatically in the background

3. A clean archive system:
   FINNISHED\YEAR\MONTH\TYPE

### 🔑 Key point
Ensure mapped drives (J: and Q:) are accessible in scheduled tasks or switch to UNC paths for reliability.