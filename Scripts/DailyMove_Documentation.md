# 📦 Windows 11 – Daily Automated File Move Documentation

## 🔹 Overview
This setup moves files every day at **23:59** from these source folders:

- `J:\My Drive [Bjorn Ove Bremnes]\Real AI Music\VIDEO`
- `J:\My Drive [Bjorn Ove Bremnes]\Real AI Music\MP3`
- `J:\My Drive [Bjorn Ove Bremnes]\Real AI Music\IMG`

Into these destination folders:

- `Q:\001 - Real AI Country\FINNISHED\[YEAR]\[MONTH]\VIDEO`
- `Q:\001 - Real AI Country\FINNISHED\[YEAR]\[MONTH]\MP3`
- `Q:\001 - Real AI Country\FINNISHED\[YEAR]\[MONTH]\IMG`

The script:
- keeps the source folders
- moves only files
- writes one log file per day
- appends multiple runs on the same day to the same log
- deletes log files older than 30 days
- counts files moved per folder and in total

---

## 🔹 Step-by-Step Guide

### 1. Save the script
Save the PowerShell script as:

```text
E:\Scripts\DailyMove.ps1
```

If the `E:\Scripts` folder does not exist, create it first.

---

### 2. Use this PowerShell script

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

# -----------------------------
# Logging setup
# -----------------------------
$LogFolder = "E:\Scripts\Logs\RealAICountryMusic"
$Timestamp = Get-Date -Format "yyyy-MM-dd"
$LogFile = Join-Path $LogFolder "DailyMove_$Timestamp.log"

# Ensure log folder exists
if (-not (Test-Path $LogFolder)) {
    New-Item -ItemType Directory -Path $LogFolder -Force | Out-Null
}

# Remove logs older than 30 days
Get-ChildItem -Path $LogFolder -Filter "*.log" -ErrorAction SilentlyContinue |
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

    # Ensure source folder exists
    if (-not (Test-Path $Source)) {
        Write-Warning "Source folder not found: $Source"
        continue
    }

    # Ensure destination folder exists
    if (-not (Test-Path $Destination)) {
        New-Item -ItemType Directory -Path $Destination -Force | Out-Null
        Write-Host "Created destination folder."
    }

    # Get files only - this keeps the source folders intact
    $Files = Get-ChildItem -Path $Source -File -ErrorAction SilentlyContinue

    if (-not $Files) {
        Write-Host "No files found in source."
        continue
    }

    foreach ($File in $Files) {
        try {
            Move-Item -Path $File.FullName -Destination $Destination -Force -ErrorAction Stop
            $MovedCount++
            $TotalMoved++
            Write-Host "Moved: $($File.Name)"
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
```

---

## 🔹 What the script does

### Folder handling
- Reads the current year and month
- Builds destination folders dynamically
- Creates destination folders if missing
- Leaves source folders untouched

### File handling
- Moves **files only**
- Does **not** move subfolders
- Does **not** delete source folders

### Logging
- Uses a **daily log file**
- Example log name:

```text
DailyMove_2026-03-21.log
```

- If the script runs more than once on the same day, it appends to the same file
- Old log files older than 30 days are automatically removed

### Counters
The script records:
- files moved from VIDEO
- files moved from MP3
- files moved from IMG
- total files moved

---

## 🔹 Test the script manually

Open PowerShell and run:

```powershell
powershell -ExecutionPolicy Bypass -File "E:\Scripts\DailyMove.ps1"
```

Then check:
- files moved to the correct year/month folders
- source folders still exist
- the log file was created in:

```text
E:\Scripts\Logs\RealAICountryMusic
```

---

## 🔹 Set up the scheduled task

### GUI method
1. Press **Win + S**
2. Search for **Task Scheduler**
3. Open **Task Scheduler**
4. Click **Create Task**

### General tab
Set:
- **Name:** `Daily Real AI Move`
- **Run whether user is logged on or not**
- **Run with highest privileges**

### Triggers tab
Create a new trigger:
- **Begin the task:** On a schedule
- **Settings:** Daily
- **Start:** `23:59:00`
- **Recur every:** `1 day`
- **Enabled:** checked

### Actions tab
Use:
- **Program/script:**

```text
powershell.exe
```

- **Add arguments:**

```text
-ExecutionPolicy Bypass -File "E:\Scripts\DailyMove.ps1"
```

- **Start in:**

```text
E:\Scripts
```

### Conditions tab
Recommended:
- disable AC-only restriction if needed
- enable wake if the PC may be asleep at 23:59

### Settings tab
Recommended:
- allow task to be run on demand
- run as soon as possible after a missed start
- do not start a new instance if already running

---

## 🔹 Commands (if applicable)

### Create the script folder
```powershell
New-Item -ItemType Directory -Path "E:\Scripts" -Force
```

### Create the log folder
```powershell
New-Item -ItemType Directory -Path "E:\Scripts\Logs\RealAICountryMusic" -Force
```

### Manual test run
```powershell
powershell -ExecutionPolicy Bypass -File "E:\Scripts\DailyMove.ps1"
```

### Optional PowerShell task registration
```powershell
$action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument '-ExecutionPolicy Bypass -File "E:\Scripts\DailyMove.ps1"'
$trigger = New-ScheduledTaskTrigger -Daily -At 11:59PM
$settings = New-ScheduledTaskSettingsSet -StartWhenAvailable
Register-ScheduledTask -TaskName "Daily Real AI Move" -Action $action -Trigger $trigger -Settings $settings
```

---

## 🔹 Pro Tips

- Using `yyyy-MM-dd` in the filename makes log files sort correctly
- Using `-Append` lets you keep one log per day instead of one file per run
- Keeping logs on `E:` is more reliable than using a mapped drive such as `J:`
- Keep the archive structure consistent as:

```text
FINNISHED\YEAR\MONTH\TYPE
```

- Keep using `Get-ChildItem -File` if you want to preserve the source folders

---

## 🔹 Warnings

- This script **moves** files. It does not copy them.
- If a file with the same name already exists in the destination, `-Force` may overwrite it.
- If `J:` or `Q:` are not available in the task context, the move will fail.
- If `E:` is not available, logging will fail.
- Locked files may fail to move and will be written to the log.

---

## 🔹 Optional Enhancements

### Use month names instead of numbers
Replace:

```powershell
$Month = Get-Date -Format "MM"
```

With:

```powershell
$Month = Get-Date -Format "MMMM"
```

### Move only certain file types
Example:

```powershell
Get-ChildItem -Path $Source -Filter "*.mp3" -File |
    Move-Item -Destination $Destination -Force
```

### Move only older files
Example:

```powershell
Get-ChildItem -Path $Source -File |
    Where-Object { $_.LastWriteTime -lt (Get-Date).AddDays(-1) } |
    Move-Item -Destination $Destination -Force
```

### Preview files without moving them
Example:

```powershell
Get-ChildItem -Path $Source -File | Select-Object FullName
```

---

## 🔹 Summary
This version uses the **daily log adjustment**:

- one log file per day
- appends repeated runs on the same day
- cleans up logs older than 30 days

It is a good balance between:
- readable logging
- lower file clutter
- easier long-term maintenance
