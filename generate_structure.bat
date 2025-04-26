@echo off
setlocal enabledelayedexpansion

echo Generando estructura del proyecto KidsDo...
echo.

REM Crear el archivo de salida
set OUTPUT_FILE=project_structure.txt

REM Limpiar archivo si existe
if exist %OUTPUT_FILE% del %OUTPUT_FILE%

echo Estructura del proyecto KidsDo - Generada el %date% %time% > %OUTPUT_FILE%
echo. >> %OUTPUT_FILE%

REM Directorios a excluir
set "EXCLUDES=.dart_tool build .idea .gradle .git node_modules ios\Pods android\.gradle"

REM Escribir estructura recursiva al archivo
echo Escribiendo estructura de directorios...

echo. >> %OUTPUT_FILE%
echo # ESTRUCTURA DE DIRECTORIOS >> %OUTPUT_FILE%
echo. >> %OUTPUT_FILE%

for /f "tokens=*" %%d in ('dir /ad /b /s') do (
    set "exclude=false"
    
    for %%e in (%EXCLUDES%) do (
        echo %%d | findstr /i /c:"%%e" > nul
        if not errorlevel 1 set "exclude=true"
    )
    
    if "!exclude!"=="false" (
        set "relpath=%%d"
        set "relpath=!relpath:%CD%=!"
        if "!relpath!" NEQ "" echo !relpath! >> %OUTPUT_FILE%
    )
)

echo. >> %OUTPUT_FILE%
echo # LISTADO DE ARCHIVOS >> %OUTPUT_FILE%
echo. >> %OUTPUT_FILE%

REM Listar archivos .dart (puedes ajustar los tipos de archivos)
for /f "tokens=*" %%f in ('dir /s /b *.dart *.yaml *.gradle *.xml *.json *.md') do (
    set "exclude=false"
    
    for %%e in (%EXCLUDES%) do (
        echo %%f | findstr /i /c:"%%e" > nul
        if not errorlevel 1 set "exclude=true"
    )
    
    if "!exclude!"=="false" (
        set "relpath=%%f"
        set "relpath=!relpath:%CD%=!"
        if "!relpath!" NEQ "" echo !relpath! >> %OUTPUT_FILE%
    )
)

echo.
echo Estructura generada en %OUTPUT_FILE%
echo.

endlocal