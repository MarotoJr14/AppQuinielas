@echo off
setlocal EnableExtensions

set "SCRIPT_DIR=%~dp0"
for %%I in ("%SCRIPT_DIR%..") do set "PROJECT_DIR=%%~fI"

for /f "tokens=2 delims=:" %%A in ('findstr /R /C:"^[ ]*version:" "%PROJECT_DIR%\pubspec.yaml"') do set "VERSION_LINE=%%A"
for /f "tokens=1 delims=+ " %%A in ("%VERSION_LINE%") do set "VERSION=%%A"

if not defined VERSION (
    echo ERROR: No se ha podido obtener la version de pubspec.yaml.
    exit /b 1
)

set "EXE_SOURCE=%PROJECT_DIR%\build\windows\x64\runner\Release\app_quinielas.exe"
set "EXE_DESTINATION=%SCRIPT_DIR%app_quinielas-%VERSION%.exe"

echo BUILD RELEASE - APP QUINIELAS WINDOWS
echo Version: %VERSION%
echo.

pushd "%PROJECT_DIR%" || goto error
set "PUSHED_DIR=1"

echo Limpiando proyecto...
call flutter clean || goto error

echo Obteniendo dependencias...
call flutter pub get || goto error

echo Construyendo EXE...
call flutter build windows --release || goto error

if not exist "%EXE_SOURCE%" (
    echo ERROR: No se ha encontrado el EXE generado.
    goto error
)

copy /Y "%EXE_SOURCE%" "%EXE_DESTINATION%" >nul || goto error

popd
echo.
echo EXE generado: %EXE_DESTINATION%
exit /b 0

:error
if defined PUSHED_DIR popd
echo.
echo ERROR DURANTE LA COMPILACION
exit /b 1
