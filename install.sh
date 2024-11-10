#!/bin/bash

# Colores para outputs
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# URL del repositorio 
REPO_URL="https://github.com/4ker0us/k8s-ubuntu-server.git"
INSTALL_DIR="/opt/hello-k8s"

# Función para verificar errores
check_error() {
    if [ $? -ne 0 ]; then
        echo -e "${RED}❌ Error: $1${NC}"
        exit 1
    fi
}

echo -e "${YELLOW}🚀 Iniciando instalación...${NC}"

# 1. Actualizar sistema e instalar dependencias
echo -e "${YELLOW}📦 Instalando dependencias...${NC}"
sudo apt update && sudo apt upgrade -y
check_error "Error al actualizar el sistema"

sudo apt install -y git curl
check_error "Error al instalar git y curl"

# 2. Instalar Docker si no está instalado
if ! command -v docker &> /dev/null; then
    echo -e "${YELLOW}🐳 Instalando Docker...${NC}"
    curl -fsSL https://get.docker.com -o get-docker.sh
    sudo sh get-docker.sh
    sudo usermod -aG docker $USER
    check_error "Error al instalar Docker"
fi

# 3. Instalar K3s si no está instalado
if ! command -v kubectl &> /dev/null; then
    echo -e "${YELLOW}☸️  Instalando K3s...${NC}"
    curl -sfL https://get.k3s.io | sh -
    check_error "Error al instalar K3s"
    
    # Configurar kubectl
    mkdir -p ~/.kube
    sudo cp /etc/rancher/k3s/k3s.yaml ~/.kube/config
    sudo chown $USER:$USER ~/.kube/config
    sudo chmod 600 ~/.kube/config
fi

# 4. Clonar el repositorio
echo -e "${YELLOW}📥 Clonando repositorio...${NC}"
sudo rm -rf $INSTALL_DIR
sudo git clone $REPO_URL $INSTALL_DIR
check_error "Error al clonar el repositorio"
sudo chown -R $USER:$USER $INSTALL_DIR
cd $INSTALL_DIR
check_error "Error al acceder al directorio de instalación"

# 5. Configurar registro Docker local
echo -e "${YELLOW}📦 Configurando registro Docker local...${NC}"
docker stop registry || true
docker rm registry || true
docker run -d -p 5000:5000 --restart=always --name registry registry:2
check_error "Error al iniciar el registro Docker local"

# 6. Configurar K3s para usar el registro local
echo -e "${YELLOW}⚙️  Configurando K3s...${NC}"
sudo mkdir -p /etc/rancher/k3s/
cat <<EOF | sudo tee /etc/rancher/k3s/registries.yaml
mirrors:
  "localhost:5000":
    endpoint:
      - "http://localhost:5000"
EOF
check_error "Error al configurar K3s"

# 7. Reiniciar K3s
echo -e "${YELLOW}🔄 Reiniciando K3s...${NC}"
sudo systemctl restart k3s
sleep 10  # Esperar a que K3s se reinicie

# 8. Construir y publicar la imagen
echo -e "${YELLOW}🏗️  Construyendo imagen Docker...${NC}"
docker build -t hello-world:latest .
check_error "Error al construir la imagen Docker"

docker tag hello-world:latest localhost:5000/hello-world:latest
docker push localhost:5000/hello-world:latest
check_error "Error al publicar la imagen en el registro local"

# 9. Verificar que los archivos de k8s existen
if [ ! -d "k8s" ]; then
    echo -e "${RED}❌ Error: No se encuentra el directorio k8s${NC}"
    exit 1
fi

# 10. Desplegar en Kubernetes
echo -e "${YELLOW}🚀 Desplegando en Kubernetes...${NC}"
kubectl apply -f k8s/
check_error "Error al desplegar en Kubernetes"

# 11. Esperar a que el pod esté listo
echo -e "${YELLOW}⏳ Esperando a que el pod esté listo...${NC}"
kubectl wait --for=condition=ready pod -l app=hello-world --timeout=120s
check_error "Error: el pod no está listo después de 120 segundos"

# 12. Obtener información de acceso
NODE_IP=$(hostname -I | awk '{print $1}')
NODE_PORT=$(kubectl get svc hello-world -o jsonpath='{.spec.ports[0].nodePort}')

# 13. Mostrar resumen final
echo -e "${GREEN}✅ Instalación completada exitosamente!${NC}"
echo -e "${GREEN}🌐 La aplicación está disponible en: http://$NODE_IP:$NODE_PORT${NC}"

echo -e "\n${YELLOW}📊 Estado actual:${NC}"
echo -e "\n${YELLOW}Pods:${NC}"
kubectl get pods
echo -e "\n${YELLOW}Servicios:${NC}"
kubectl get services

echo -e "\n${YELLOW}📝 Comandos útiles:${NC}"
echo -e "Ver logs: ${GREEN}kubectl logs -l app=hello-world${NC}"
echo -e "Reiniciar aplicación: ${GREEN}kubectl rollout restart deployment hello-world${NC}"
echo -e "Eliminar aplicación: ${GREEN}kubectl delete -f $INSTALL_DIR/k8s/${NC}"
