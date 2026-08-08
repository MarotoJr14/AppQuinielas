@echo off
setlocal EnableDelayedExpansion

echo ======================================
echo    BUILD RELEASE - APP QUINIELAS
echo    ANDROID
echo ======================================
echo.

REM --------------------------------------
REM Obtener version desde pubspec.yaml
REM --------------------------------------
for /f "tokens=2 delims=: " %%A in ('findstr /B "version:" pubspec.yaml') do set VERSION_LINE=%%A

REM Eliminar el build number (+1)
for /f "tokens=1 delims=+" %%A in ("%VERSION_LINE%") do set VERSION=%%A

echo Version: %VERSION%
echo.

REM --------------------------------------
REM Limpiar y obtener dependencias
REM --------------------------------------
echo --------------------------------------
echo Limpiando proyecto...
echo --------------------------------------

flutter clean
if errorlevel 1 goto error

flutter pub get
if errorlevel 1 goto error

REM --------------------------------------
REM Construir APK
REM --------------------------------------
echo.
echo --------------------------------------
echo Construyendo Android...
echo --------------------------------------

flutter build apk --release
if errorlevel 1 goto error

REM --------------------------------------
REM Renombrar APK
REM --------------------------------------
set ORIGEN=build\app\outputs\flutter-apk\app-release.apk
set DESTINO=build\app\outputs\flutter-apk\app_quinielas-%VERSION%.apk

if not exist "%ORIGEN%" (
    echo ERROR: No se ha encontrado el APK generado.
    goto error
)

if exist "%DESTINO%" del "%DESTINO%"

rename "%ORIGEN%" "app_quinielas-%VERSION%.apk"

echo.
echo ======================================
echo BUILD ANDROID COMPLETADO
echo ======================================
echo.
echo Archivo generado:
echo %DESTINO%
echo.

pause
exit /b 0

:error
echo.
echo ======================================
echo ERROR DURANTE LA COMPILACION
echo ======================================
echo.

pause
exit /b 1
