@echo off


where docker >nul 2>nul
if %errorlevel% equ 0 (
    set MOTOR=docker
) else (
    where podman >nul 2>nul
    if %errorlevel% equ 0 (
        set MOTOR=podman
    ) else (
        echo Error: No se encontro Docker ni Podman instalado en este sistema.
        echo Por favor, instale uno de los dos para evaluar este proyecto.
        pause
        exit /b
    )
)

echo Iniciando MariaDB con %MOTOR% y construyendo la DB

%MOTOR% run --name galeria_db -e MYSQL_ROOT_PASSWORD=root -v "%cd%\dbCreate.sql":/docker-entrypoint-initdb.d/01_esquema.sql -v "%cd%\loadData.sql":/docker-entrypoint-initdb.d/02_datos.sql -p 3307:3306 -d mariadb

echo Esperando a que el motor MariaDB arranque...
timeout /t 15 /nobreak > NUL

echo Ejecutando las consultas de prueba...

%MOTOR% exec -i galeria_db mariadb -t -u root -proot TBDGrupo2 < runStatements.sql

echo.
echo Presiona cualquier tecla para limpiar el entorno y salir...
pause > NUL
%MOTOR% rm -f galeria_db
