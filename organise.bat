@echo off
setlocal enabledelayedexpansion

:menu
cls
echo Photo and Video Organizer
echo ========================
echo 1. Organize files in current directory
echo 2. Organize files in a specific directory
echo 3. Change destination directory
echo 4. Exit
echo.

set /p choice="Enter your choice (1-4): "

if "%choice%"=="1" goto organize_current
if "%choice%"=="2" goto organize_specific
if "%choice%"=="3" goto change_destination
if "%choice%"=="4" goto end

echo Invalid choice. Please try again.
pause
goto menu

:organize_current
set "source_dir=%CD%"
goto organize

:organize_specific
set /p source_dir="Enter the full path of the directory to organize: "
if not exist "%source_dir%" (
    echo The specified directory does not exist.
    pause
    goto menu
)
goto organize

:change_destination
set /p dest_dir="Enter the full path for the destination directory: "
if not exist "%dest_dir%" (
    mkdir "%dest_dir%"
    echo Created destination directory: %dest_dir%
) else (
    echo Using existing destination directory: %dest_dir%
)
pause
goto menu

:organize
REM Check if ExifTool is installed
where exiftool >nul 2>nul
if %errorlevel% neq 0 (
    echo ExifTool is not installed or not in PATH. Please install ExifTool and add it to your PATH.
    pause
    goto menu
)

REM Set the destination directory if not already set
if not defined dest_dir set "dest_dir=%source_dir%\Organized"

REM Create the destination directory if it doesn't exist
if not exist "%dest_dir%" mkdir "%dest_dir%"

echo Organizing files from: %source_dir%
echo Destination: %dest_dir%
echo.

REM Loop through all files in the source directory, excluding .bat files
for %%F in ("%source_dir%\*.*") do (
    if /I not "%%~xF"==".bat" (
        REM Get creation date using ExifTool
        for /f "delims=" %%D in ('exiftool -s3 -DateTimeOriginal -d "%%Y-%%m" "%%F"') do (
            set "date=%%D"
        )
        
        REM If date is empty, try using file modification date
        if "!date!"=="" (
            for /f "tokens=1-3 delims=/" %%A in ("%%~tF") do (
                set "date=%%C-%%A"
            )
        )
        
        REM Extract year and month from the date
        for /f "tokens=1,2 delims=-" %%Y in ("!date!") do (
            set "year=%%Y"
            set "month=%%Z"
        )
        
        REM Create year and month folders if they don't exist
        if not exist "%dest_dir%\!year!" mkdir "%dest_dir%\!year!"
        if not exist "%dest_dir%\!year!\!month!" mkdir "%dest_dir%\!year!\!month!"
        
        REM Move the file to the appropriate folder
        move "%%F" "%dest_dir%\!year!\!month!\"
        
        echo Moved %%~nxF to %dest_dir%\!year!\!month!\
    ) else (
        echo Skipped %%~nxF (batch file)
    )
)

echo.
echo Done organizing files.
pause
goto menu

:end
echo Thank you for using the Photo and Video Organizer!
pause
