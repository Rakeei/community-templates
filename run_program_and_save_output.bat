@echo off
setlocal enabledelayedexpansion

REM Get computer name and IP address
for /f "tokens=2 delims=:" %%a in ('ipconfig ^| findstr /i "IPv4"') do (
    set "IP=%%a"
    set "IP=!IP: =!"
    goto :found_ip
)
:found_ip

REM Get computer name
set "COMPUTER_NAME=%COMPUTERNAME%"

REM Set shared path - change this to your desired shared folder
set "SHARED_PATH=\\server\shared\outputs"

REM Create timestamp for unique file names
for /f "tokens=1-3 delims=/ " %%a in ('date /t') do set "DATE=%%a%%b%%c"
for /f "tokens=1-2 delims=: " %%a in ('time /t') do set "TIME=%%a%%b"

REM Set output file names
set "OUTPUT_BY_NAME=%SHARED_PATH%\%COMPUTER_NAME%_%DATE%_%TIME%.txt"
set "OUTPUT_BY_IP=%SHARED_PATH%\%IP%_%DATE%_%TIME%.txt"

REM Create shared directory if it doesn't exist
if not exist "%SHARED_PATH%" (
    echo Creating shared directory: %SHARED_PATH%
    mkdir "%SHARED_PATH%"
)

REM Run the program and save output by computer name
echo Running program and saving output by computer name...
echo Program started at %DATE% %TIME% on %COMPUTER_NAME% > "%OUTPUT_BY_NAME%"

REM Replace "your_program.exe" with the actual program you want to run
REM Add any command line arguments after the program name
your_program.exe >> "%OUTPUT_BY_NAME%" 2>&1

REM Also save output by IP address
echo Program started at %DATE% %TIME% on %IP% > "%OUTPUT_BY_IP%"
your_program.exe >> "%OUTPUT_BY_IP%" 2>&1

echo Output saved to:
echo   By name: %OUTPUT_BY_NAME%
echo   By IP: %OUTPUT_BY_IP%

pause