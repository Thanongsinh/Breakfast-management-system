@echo off
REM Start Rental Backend with Docker Compose

echo Starting Rental Management System...
echo.

REM Check if Docker is running
docker info >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Docker is not running!
    echo Please start Docker Desktop and try again.
    pause
    exit /b 1
)

echo [1/3] Stopping any existing containers...
docker-compose down

echo.
echo [2/3] Building and starting services...
docker-compose up -d --build

echo.
echo [3/3] Waiting for services to be healthy...
timeout /t 10 /nobreak >nul

echo.
echo ========================================
echo Services started successfully!
echo ========================================
echo.
echo Backend API:     http://localhost:8080
echo Health Check:    http://localhost:8080/health
echo MinIO Console:   http://localhost:9001
echo PostgreSQL:      localhost:5432
echo Redis:           localhost:6379
echo.
echo ========================================
echo View logs with: docker-compose logs -f
echo Stop services:   docker-compose down
echo ========================================
echo.

REM Show service status
docker-compose ps

echo.
echo Press any key to view backend logs (Ctrl+C to exit)...
pause >nul

docker-compose logs -f backend
