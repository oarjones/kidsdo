@echo off
setlocal enabledelayedexpansion

echo Generando estructura jerárquica de lib...

REM Crear el archivo de salida
set OUTPUT_FILE=kidsdo_structure.md

REM Limpiar archivo si existe
if exist %OUTPUT_FILE% del %OUTPUT_FILE%

echo # Estructura del Proyecto KidsDo > %OUTPUT_FILE%
echo Generada: %date% %time% >> %OUTPUT_FILE%
echo. >> %OUTPUT_FILE%

REM Añadir pubspec.yaml en la raíz
echo ## Archivos de Configuración >> %OUTPUT_FILE%
echo - pubspec.yaml >> %OUTPUT_FILE%
echo. >> %OUTPUT_FILE%

REM Generar estructura jerárquica solo de lib
echo ## Estructura de lib >> %OUTPUT_FILE%
echo. >> %OUTPUT_FILE%

REM Generar la estructura de forma recursiva
set "mainFolder=lib"
call :processFolder "%mainFolder%" 0

goto :eof

:processFolder
REM Parámetros: ruta relativa del directorio, nivel de indentación
set "folderPath=%~1"
set "indent=%~2"

REM Generar indentación
set "spacing="
for /L %%i in (1,1,%indent%) do set "spacing=!spacing!  "

REM Mostrar la carpeta actual
echo !spacing!- **%folderPath:~-255%/** >> %OUTPUT_FILE%

REM Listar archivos .dart en esta carpeta
for %%F in ("%folderPath%\*.dart") do (
    echo !spacing!  - %%~nxF >> %OUTPUT_FILE%
)

REM Procesar subcarpetas
for /D %%D in ("%folderPath%\*") do (
    set "subFolder=%%~nxD"
    call :processFolder "%folderPath%\!subFolder!" %indent%+1
)

exit /b

endlocal