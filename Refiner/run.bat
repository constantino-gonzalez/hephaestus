@echo off
setlocal

:: Get the directory where the batch file is located
set "BAT_DIR=%~dp0"

:: Define the application executable name
set "APP_NAME=Refiner.exe"

:: Define the log file name with a date and time stamp
set "LOG_FILE=%BAT_DIR%log_%date:~-10,2%-%date:~-7,2%-%date:~-4,4%_%time:~0,2%-%time:~3,2%-%time:~6,2%.log"

:: Remove any leading spaces from the time (for filenames)
set "LOG_FILE=%LOG_FILE: =0%"

:: Launch the application and redirect output to the log file
"%BAT_DIR%%APP_NAME%" > "%LOG_FILE%" 2>&1

:: Optionally, pause to keep the command window open
:: pause
