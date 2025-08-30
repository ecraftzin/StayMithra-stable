@echo off
echo Starting StayMithra Password Reset Server...
echo.

REM Check if Node.js is available
node --version >nul 2>&1
if %errorlevel% == 0 (
    echo Using Node.js server...
    node server.js
) else (
    REM Check if Python is available
    python --version >nul 2>&1
    if %errorlevel% == 0 (
        echo Using Python server...
        python server.py
    ) else (
        echo Error: Neither Node.js nor Python found!
        echo Please install Node.js or Python to run the server.
        pause
    )
)
