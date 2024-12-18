#!/bin/bash

#modo depuracion descomentar el set -x
#set -x

# Colores para mensajes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color



git submodule update --init --recursive

# Obtener la nueva IP desde el parámetro
VITE_PORT="$1"
PORT="$2"

#variables
DOCKER_IMAGE="app-launcher-clients-ms app-launcher-client-api-gateway app-launcher-auth-ms app-launcher-orders-ms"

print_message() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}"
}

check_tools(){
    if command -v $2 $1 &>/dev/null; then 
        print_message $GREEN "$1 está instalado."
    else 
        print_message $RED "$1 no está instalado. Por favor, instale $1 e intente nuevamente."
        exit 1
    fi
}

check_tools docker sudo

#crear variables de entorno
print_message $YELLOW "Creando Envs..."
cp .env.template .env
echo "VITE_PORT=$VITE_PORT" >> .env

#eliminar antiguos contenedores en ejecucion
print_message $YELLOW "Eliminando contenedores antiguos..."
docker compose down &>/dev/null || true
sudo docker rmi $DOCKER_IMAGE

####leer version de la aplicacion
if [ -f "./Frontend/package.json" ]; then
    APP_VERSION=$(jq -r '.version' package.json)
    print_message $YELLOW "Versión del frontend: $APP_VERSION"
fi

if [ -f "./Backend/package.json" ]; then
    APP_VERSION=$(jq -r '.version' package.json)
    print_message $YELLOW "Versión del backend: $APP_VERSION"
fi

#Iniciar el contenedor
print_message $YELLOW "Iniciando contenedores..."
sudo docker compose -f docker-compose.prod.yml up -d

# Listar el contenedor
print_message $YELLOW "Listando contenedores..."
sudo docker ps -a

###probar la aplicacion
print_message $YELLOW "Probando la aplicación..."
RETRIES=5
for i in $(seq 1 $RETRIES); do
    if curl -s http://localhost:$PORT > /dev/null; then
        print_message $GREEN "La aplicación está corriendo en http://localhost:$PORT"
        break
    else
        print_message $YELLOW "La aplicación no está disponible aún. Reintentando en 5 segundos... ($i/$RETRIES)"
        sleep 5
    fi
    if [ $i -eq $RETRIES ]; then
        print_message $RED "La aplicación no está corriendo después de varios intentos. Por favor, revise los logs para más detalles."
        exit 1
    fi
done

set +x
