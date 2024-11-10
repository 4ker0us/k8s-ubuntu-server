#!/bin/bash

# Variables de color
GREEN='\033[0;32m'
NC='\033[0m'

echo -e "${GREEN}1. Instalando dependencias básicas...${NC}"
sudo apt update
sudo apt install -y curl wget git vim net-tools

echo -e "${GREEN}2. Configurando Docker...${NC}"
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER

echo -e "${GREEN}3. Configurando módulos del kernel...${NC}"
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter

cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

sudo sysctl --system

echo -e "${GREEN}4. Instalando K3s...${NC}"
curl -sfL https://get.k3s.io | sh -

echo -e "${GREEN}5. Configurando kubectl...${NC}"
mkdir -p ~/.kube
sudo cp /etc/rancher/k3s/k3s.yaml ~/.kube/config
sudo chown $USER:$USER ~/.kube/config
sudo chmod 600 ~/.kube/config

echo -e "${GREEN}6. Instalando herramientas adicionales...${NC}"
# k9s para gestión en terminal
curl -sS https://webinstall.dev/k9s | bash

echo -e "${GREEN}7. Configurando firewall...${NC}"
sudo ufw allow 22/tcp
sudo ufw allow 6443/tcp
sudo ufw allow 30000:32767/tcp
sudo ufw --force enable

echo -e "${GREEN}¡Instalación completada!${NC}"
