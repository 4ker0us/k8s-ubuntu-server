#!/bin/bash

# Colores para mensajes
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Configuración
REPO_USER="4ker0us"
REPO_NAME="k8s-ubuntu-server"
WORK_DIR="/tmp/hello-k8s"

echo -e "${YELLOW}🚀 Iniciando instalación...${NC}"

# 1. Preparar directorio de trabajo
rm -rf $WORK_DIR
mkdir -p $WORK_DIR
cd $WORK_DIR

# 2. Descargar archivos necesarios
echo -e "${YELLOW}📦 Descargando archivos...${NC}"
wget -q https://raw.githubusercontent.com/$REPO_USER/$REPO_NAME/main/Dockerfile
wget -q https://raw.githubusercontent.com/$REPO_USER/$REPO_NAME/main/app/index.html -P app/
wget -q https://raw.githubusercontent.com/$REPO_USER/$REPO_NAME/main/k8s/deployment.yaml -P k8s/
wget -q https://raw.githubusercontent.com/$REPO_USER/$REPO_NAME/main/k8s/service.yaml -P k8s/

# 3. Instalar Docker si no está instalado
if ! command -v docker &> /dev/null; then
    echo -e "${YELLOW}🐳 Instalando Docker...${NC}"
    curl -fsSL https://get.docker.com | sh
    sudo usermod -aG docker $USER
    sudo systemctl start docker
    sudo systemctl enable docker
fi

# 4. Instalar K3s si no está instalado
if ! command -v kubectl &> /dev/null; then
    echo -e "${YELLOW}☸️  Instalando K3s...${NC}"
    curl -sfL https://get.k3s.io | sh -
    sleep 10
fi

# 5. Configurar acceso a kubectl
mkdir -p ~/.kube
sudo cp /etc/rancher/k3s/k3s.yaml ~/.kube/config
sudo chown $USER:$USER ~/.kube/config
sudo chmod 600 ~/.kube/config

# 6. Configurar registro local
echo -e "${YELLOW}📦 Configurando registro Docker local...${NC}"
docker run -d -p 5000:5000 --restart=always --name registry registry:2 2>/dev/null || true

# 7. Construir y desplegar
echo -e "${YELLOW}🏗️  Construyendo y desplegando...${NC}"
docker build -t hello-world .
docker tag hello-world localhost:5000/hello-world
docker push localhost:5000/hello-world

# 8. Desplegar en Kubernetes
kubectl apply -f k8s/

# 9. Esperar a que esté listo
echo -e "${YELLOW}⏳ Esperando a que la aplicación esté lista...${NC}"
sleep 10
kubectl wait --for=condition=ready pod -l app=hello-world --timeout=60s

# 10. Mostrar acceso
NODE_IP=$(hostname -I | awk '{print $1}')
echo -e "${GREEN}✅ Instalación completada!${NC}"
echo -e "${GREEN}🌐 Accede a la aplicación en: http://$NODE_IP:30080${NC}"

# Limpieza
rm -rf $WORK_DIR
