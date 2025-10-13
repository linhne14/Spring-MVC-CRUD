@echo off
echo ==========================================
echo 🔍 HEALTH CHECK - SSO APPLICATION
echo ==========================================
echo.

echo 📋 1. Kiểm tra Docker Containers:
echo ------------------------------------------
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
echo.

echo 📋 2. Kiểm tra Processes trên Port 8080 và 8081:
echo ------------------------------------------
echo Port 8080:
netstat -ano | findstr :8080
echo Port 8081:
netstat -ano | findstr :8081
echo.

echo 📋 3. Test Keycloak Connectivity:
echo ------------------------------------------
echo Testing Keycloak at http://localhost:8081...
curl -s -o nul -w "Status: %%{http_code}" http://localhost:8081
if %errorlevel% equ 0 (
    echo  ✅ Keycloak is accessible
) else (
    echo  ❌ Keycloak is not accessible
)
echo.

echo 📋 4. Test SSO Application:
echo ------------------------------------------
echo Testing SSO App at http://localhost:8080...
curl -s -o nul -w "Status: %%{http_code}" http://localhost:8080
if %errorlevel% equ 0 (
    echo  ✅ SSO Application is accessible
    echo.
    echo 🎉 SUCCESS: Both services are running!
    echo.
    echo 🔗 Access URLs:
    echo   • Keycloak Admin: http://localhost:8081/admin
    echo   • SSO Application: http://localhost:8080
) else (
    echo  ❌ SSO Application is not accessible
)
echo.

echo 📋 5. Docker Compose Status:
echo ------------------------------------------
docker-compose ps 2>nul
echo.

echo 📋 6. Recommended Actions:
echo ------------------------------------------
echo • If SSO app not running: docker-compose up -d --force-recreate
echo • View logs: docker-compose logs -f
echo • Setup Keycloak: setup-keycloak.cmd
echo • Stop services: docker-compose down
echo.
echo ==========================================
pause