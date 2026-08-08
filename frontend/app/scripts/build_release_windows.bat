@echo off
setlocal EnableDelayedExpansion

echo ======================================
echo    BUILD RELEASE - APP QUINIELAS
echo    WINDOWS
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
REM Limpiar proyecto y obtener dependencias
REM --------------------------------------
echo --------------------------------------
echo Limpiando proyecto...
echo --------------------------------------

flutter clean
if errorlevel 1 goto error

flutter pub get
if errorlevel 1 goto error

REM --------------------------------------
REM Construir Windows
REM --------------------------------------
echo.
echo --------------------------------------
echo Construyendo Windows...
echo --------------------------------------

flutter build windows --release
if errorlevel 1 goto error

REM --------------------------------------
REM Crear ZIP con la aplicacion
REM --------------------------------------
set BUILD_DIR=build\windows\x64\runner\Release
set ZIP_NAME=build\windows\app_quinielas-%VERSION%.zip

if not exist "%BUILD_DIR%" (
    echo ERROR: No se ha encontrado la carpeta Release de Windows.
    goto error
)

if exist "%ZIP_NAME%" del "%ZIP_NAME%"

echo.
echo --------------------------------------
echo Creando archivo ZIP...
echo --------------------------------------

powershell -NoProfile -Command "Compress-Archive -Path '%BUILD_DIR%\*' -DestinationPath '%ZIP_NAME%' -Force"

if errorlevel 1 goto error

echo.
echo ======================================
echo BUILD WINDOWS COMPLETADO
echo ======================================
echo.
echo Archivo generado:
echo %ZIP_NAME%
echo.
echo NOTA:
echo El ejecutable .exe se encuentra dentro del ZIP.
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
