#!/usr/bin/env bash
if command -v docker &> /dev/null; then
    MOTOR="docker"
elif command -v podman &> /dev/null; then
    MOTOR="podman"
else
    echo "Error: No se encontró Docker ni Podman instalado en este sistema."
    echo "Por favor, instala uno de los dos para evaluar este proyecto."
    exit 1
fi

echo "Iniciando con $MOTOR y construyendo la base de datos..."
$MOTOR run --name galeria_db -e MYSQL_ROOT_PASSWORD=root -v "$(pwd)/dbCreate.sql":/docker-entrypoint-initdb.d/01_esquema.sql -v "$(pwd)/loadData.sql":/docker-entrypoint-initdb.d/02_datos.sql -p 3307:3306 -d mariadb

echo "Esperando a que el motor MariaDB arranque (Esto puede tardar unos segundos)..."
sleep 15

echo "Ejecutando las consultas de prueba..."
$MOTOR exec -i galeria_db mariadb -t -u root -proot TBDGrupo2 < runStatements.sql

echo ""
read -p "Presiona Enter para limpiar el entorno y salir..."
$MOTOR rm -f galeria_db
