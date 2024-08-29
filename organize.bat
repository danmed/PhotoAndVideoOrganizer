@echo off
setlocal enabledelayedexpansion

set "photo_extensions=.jpg .jpeg .png .gif .bmp .tiff"
set "video_extensions=.mp4 .avi .mov .wmv .flv .mkv"

:menu
cls
echo.
echo Photo and Video Organizer
echo ========================
echo 1. Organize photos and videos
echo 2. Organize photos only
echo 3. Organize videos only
echo 4. Change source directory
echo 5. Change destination directory
echo 6. Exit
echo.

set /p choice="Enter your choice (1-6): "

if "%choice%"=="1" set "file_type=both" & goto organize
if "%choice%"=="2" set "file_type=photos" & goto organize
if "%choice%"=="3" set "file_type=videos" & goto organize
if "%choice%"=="4" goto change_source
if "%choice%"=="5" goto change_destination
if "%choice%"=="6" goto end

echo Invalid choice. Please try again.
pause
goto menu

:change_source
set /p source_dir="Enter the full path of the source directory: "
if not exist "%source_dir%" (
    echo The specified directory does not exist.
    pause
    goto menu
)
goto menu

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

REM Set the source directory if not already set
if not defined source_dir set "source_dir=%CD%"

REM Set the destination directory if not already set
if not defined dest_dir set "dest_dir=%source_dir%\Organized"

REM Create the destination directory if it doesn't exist
if not exist "%dest_dir%" mkdir "%dest_dir%"

echo Organizing files from: %source_dir%
echo Destination: %dest_dir%
echo File type: %file_type%
echo.

REM Loop through all files in the source directory
for %%F in ("%source_dir%\*.*") do (
    set "process_file=0"
    if /I not "%%~xF"==".bat" (
        if "%file_type%"=="both" set "process_file=1"
        if "%file_type%"=="photos" (
            for %%E in (%photo_extensions%) do (
                if /I "%%~xF"=="%%E" set "process_file=1"
            )
        )
        if "%file_type%"=="videos" (
            for %%E in (%video_extensions%) do (
                if /I "%%~xF"=="%%E" set "process_file=1"
            )
        )
        
        if "!process_file!"=="1" (
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
            echo Skipped %%~nxF (not in selected file type)
        )
    ) else (
        echo Skipped %%~nxF (batch file)
    )
)

echo.
echo Done organizing files.
pause
goto menu

:end
cls
echo.
echo Thank you for using the Photo and Video Organizer!
pause
