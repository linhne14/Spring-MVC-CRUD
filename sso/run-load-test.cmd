@echo off
echo ==========================================
echo 📊 RUN JMETER LOAD TEST
echo ==========================================
echo.

REM Check if JMeter is installed
where jmeter >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ JMeter is not installed or not in PATH
    echo.
    echo Please install Apache JMeter:
    echo 1. Download from: https://jmeter.apache.org/download_jmeter.cgi
    echo 2. Extract to a folder
    echo 3. Add bin folder to PATH or run from JMeter directory
    echo.
    echo Alternatively, run manually:
    echo   jmeter -n -t jmeter\sso-load-test.jmx -l results\results.jtl
    pause
    exit /b 1
)

echo ✅ JMeter found
echo.

REM Create results directory
if not exist "jmeter\results" mkdir jmeter\results

echo ==========================================
echo 🔧 Test Configuration
echo ==========================================
echo.

set /p THREADS="Number of threads (users) [default: 100]: " || set THREADS=100
set /p RAMP_UP="Ramp-up period in seconds [default: 60]: " || set RAMP_UP=60
set /p DURATION="Test duration in seconds [default: 300]: " || set DURATION=300
set /p HOST="Target host [default: localhost]: " || set HOST=localhost
set /p PORT="Target port [default: 8080]: " || set PORT=8080

echo.
echo Test Parameters:
echo   Threads: %THREADS%
echo   Ramp-up: %RAMP_UP%s
echo   Duration: %DURATION%s
echo   Target: http://%HOST%:%PORT%
echo.

echo ==========================================
echo 🚀 Starting Load Test
echo ==========================================
echo.

echo Test started at: %date% %time%
echo.

REM Run JMeter in non-GUI mode
jmeter -n -t jmeter\sso-load-test.jmx ^
    -l jmeter\results\results.jtl ^
    -e -o jmeter\results\html-report ^
    -JTHREADS=%THREADS% ^
    -JRAMP_UP=%RAMP_UP% ^
    -JDURATION=%DURATION% ^
    -JHOST=%HOST% ^
    -JPORT=%PORT%

if %errorlevel% neq 0 (
    echo.
    echo ❌ Load test failed
    pause
    exit /b 1
)

echo.
echo ==========================================
echo ✅ TEST COMPLETE
echo ==========================================
echo.
echo Test finished at: %date% %time%
echo.

echo 📊 Results:
echo   JTL file: jmeter\results\results.jtl
echo   HTML report: jmeter\results\html-report\index.html
echo.

echo 💡 View HTML Report:
echo   start jmeter\results\html-report\index.html
echo.

echo ==========================================
pause

REM Optionally open the HTML report
choice /C YN /M "Open HTML report now"
if %errorlevel% equ 1 (
    start jmeter\results\html-report\index.html
)