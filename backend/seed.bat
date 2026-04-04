@echo off
REM Seed default users for Rental Management System

echo.
echo ════════════════════════════════════════════
echo   Rental Management System - User Seeder
echo ════════════════════════════════════════════
echo.

REM Check if .env file exists
if not exist .env (
    echo [ERROR] .env file not found!
    echo Please create .env file with database credentials.
    echo.
    pause
    exit /b 1
)

echo [1/2] Building seeder...
go build -o seed_users.exe seed_users.go

if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Failed to build seeder!
    pause
    exit /b 1
)

echo.
echo [2/2] Running seeder...
echo.
.\seed_users.exe

echo.
echo ════════════════════════════════════════════
echo Press any key to exit...
pause >nul

REM Clean up
del seed_users.exe 2>nul
