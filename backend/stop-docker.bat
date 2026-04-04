@echo off
REM Stop Rental Backend Docker Services

echo Stopping Rental Management System...
echo.

docker-compose down

echo.
echo Services stopped successfully!
echo.
echo To remove all data (volumes), run:
echo   docker-compose down -v
echo.
pause
