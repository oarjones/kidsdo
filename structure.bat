@echo off
echo Creando estructura de carpetas para KidsDo...

REM Crear estructura principal
mkdir lib\core\constants
mkdir lib\core\errors
mkdir lib\core\network
mkdir lib\core\utils
mkdir lib\core\theme
mkdir lib\core\widgets

mkdir lib\data\datasources\local
mkdir lib\data\datasources\remote
mkdir lib\data\models
mkdir lib\data\repositories

mkdir lib\domain\entities
mkdir lib\domain\repositories
mkdir lib\domain\usecases

mkdir lib\presentation\bloc
mkdir lib\presentation\pages\auth
mkdir lib\presentation\pages\home
mkdir lib\presentation\pages\profile
mkdir lib\presentation\pages\challenges
mkdir lib\presentation\pages\rewards
mkdir lib\presentation\pages\achievements
mkdir lib\presentation\widgets\common
mkdir lib\presentation\widgets\auth
mkdir lib\presentation\widgets\challenges
mkdir lib\presentation\widgets\rewards

mkdir assets\images
mkdir assets\fonts
mkdir assets\animations
mkdir assets\icons

mkdir test\core
mkdir test\data
mkdir test\domain
mkdir test\presentation

echo. > lib\main.dart
echo. > lib\injection_container.dart
echo. > lib\app.dart
echo. > lib\routes.dart

echo Estructura de carpetas creada exitosamente.
pause