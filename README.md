# Hello Kubernetes Demo

Una aplicación simple de demostración que muestra cómo desplegar una aplicación web usando Docker y Kubernetes.

## 📋 Requisitos Previos

El script de instalación se encargará de instalar todo lo necesario, pero estos son los requisitos que instalará:

- Docker
- Kubernetes (K3s)
- Git
- curl

## 🚀 Instalación Rápida

```bash
curl -sfL https://raw.githubusercontent.com/tu-usuario/tu-repositorio/main/install.sh | bash
```

## 💻 Instalación Manual

1. Clonar el repositorio:
```bash
git clone https://github.com/tu-usuario/tu-repositorio.git
cd tu-repositorio
```

2. Dar permisos al script de instalación:
```bash
chmod +x install.sh
```

3. Ejecutar el script:
```bash
./install.sh
```

## 🛠️ Comandos Útiles

### Kubernetes
```bash
# Ver estado de los pods
kubectl get pods

# Ver logs de la aplicación
kubectl logs -l app=hello-world

# Ver servicios
kubectl get services

# Reiniciar la aplicación
kubectl rollout restart deployment hello-world

# Eliminar la aplicación
kubectl delete -f k8s/
```

### Docker
```bash
# Reconstruir la imagen
docker build -t hello-world:latest .

# Ver imágenes disponibles
docker images
```

## 📁 Estructura del Proyecto

```
.
├── Dockerfile          # Configuración de la imagen Docker
├── app/
│   └── index.html     # Página web de ejemplo
├── install.sh         # Script de instalación
└── k8s/               # Configuraciones de Kubernetes
    ├── deployment.yaml
    └── service.yaml
```

## 🌐 Acceso a la Aplicación

Una vez instalada, la aplicación estará disponible en:
```
http://[IP-DEL-SERVIDOR]:30080
```

## 🔍 Verificación de la Instalación

Para verificar que todo está funcionando correctamente:

1. Comprobar que los pods están corriendo:
```bash
kubectl get pods
# Debería mostrar el pod 'hello-world' como 'Running'
```

2. Verificar el servicio:
```bash
kubectl get services
# Debería mostrar el servicio 'hello-world' con el NodePort 30080
```

## ⚡ Solución de Problemas

Si encuentras algún problema, aquí hay algunos pasos para solucionarlo:

1. **Los pods no arrancan:**
```bash
kubectl describe pod -l app=hello-world
```

2. **No puedes acceder a la aplicación:**
```bash
# Verificar el servicio
kubectl describe service hello-world

# Verificar los logs
kubectl logs -l app=hello-world
```

3. **Problemas con Docker:**
```bash
# Verificar el estado de Docker
sudo systemctl status docker

# Reiniciar Docker
sudo systemctl restart docker
```

## 🔄 Actualización

Para actualizar a la última versión:

```bash
# 1. Actualizar el repositorio
git pull

# 2. Reconstruir y redeployer
docker build -t hello-world:latest .
kubectl rollout restart deployment hello-world
```
