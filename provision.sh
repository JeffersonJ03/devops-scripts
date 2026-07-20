#!/bin/bash
set -euo pipefail

#--Configuracion de variables
USERNAME="${1:-defaultUser}" #Nombre de usuario a crear.
PASSWORD="$2" #Contraseña del usuario
KEY="$3" #Clave publica para agregar al usuario
WEBHOOK_URL="https://webhook.site/943016a5-d602-4fc0-8909-6a8ffd1511d1"

# Función de log con timestamp
log () {
    echo "[$(date +%H:%M:%S)] $1"
}

# Validacion
if id "$USERNAME" &>/dev/null; then
    log "ERROR: El usuario $USERNAME ya existe"
    exit 1
fi

# Crear usuario
log "Creando usuario $USERNAME ..."
useradd -m "$USERNAME"
echo "$USERNAME:$PASSWORD" | chpasswd 
log "Usuario $USERNAME creado con exito."

# Agregar usuario a grupo sudo
log "Agregando usuario $USERNAME al grupo sudo ..."
usermod -aG wheel "$USERNAME"
log "Usuario $USERNAME agregado al grupo sudo."

# Agregar clave publica al usuario
log "Validando ruta de .ssh ..."
mkdir -p "/home/$USERNAME/.ssh"
chown "$USERNAME:$USERNAME" "/home/$USERNAME/.ssh"
chmod 700 "/home/$USERNAME/.ssh"
touch "/home/$USERNAME/.ssh/authorized_keys"
chown "$USERNAME:$USERNAME" "/home/$USERNAME/.ssh/authorized_keys"
chmod 600 "/home/$USERNAME/.ssh/authorized_keys"

log "Agregando clave publica al usuario $USERNAME ..."
if [ ! grep -qF "KEY" "/home/$USERNAME/.ssh/authorized_keys" 2>/dev/null ]; then
    echo "$KEY" >> "/home/$USERNAME/.ssh/authorized_keys"
    log "Clave publica agregada al usuario $USERNAME."
else
    log "La clave publica ya existe para el usuario $USERNAME."
fi

# Aplicando handering de seguridad
log "Aplicando hardening de seguridad ..."
# Deshabilitar el acceso SSH para el usuario root
sed -i 's/^PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config
log "Acceso SSH para el usuario root deshabilitado."
log "Deshabilitando acceso SSH con contraseña para todos los usuarios ..."
sed -i 's/^PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
systemctl restart sshd
log "Acceso SSH con contraseña deshabilitado para todos los usuarios."

# Instalando nginx
log "Verificando si nginx esta instalado ..."
if ! command -v nginx &> /dev/null; then
    log "Instalando nginx ..."
    dnf install -y nginx
    systemctl enable nginx
    systemctl start nginx
    log "nginx instalado y habilitado para iniciar al arranque."
else
    log "nginx ya esta instalado."
fi

# Verificando que nginx este corriendo
if systemctl is-active --quiet nginx; then
    log "nginx esta corriendo correctamente."
else
    log "ERROR: nginx no esta corriendo. Verifica el estado del servicio."
    exit 1
fi
# Verificar que el firewall este corriendo y habilitar el puerto 80
log "Verificando estado del firewall ..."
if systemctl is-active --quiet firewalld; then
    #Verificando si el puerto 80 esta habilitado
    if ! firewall-cmd --list-ports | grep -q "80/tcp"; then
        log "Habilitando puerto 80 en el firewall ..."
        firewall-cmd --permanent --add-service=http
        firewall-cmd --permanent --add-service=https
        firewall-cmd --permanent --add-port=80/tcp
        firewall-cmd --permanent --add-port=443/tcp
        firewall-cmd --reload
        log "Puerto 80 habilitado en el firewall."
    else
        log "Puerto 80 ya esta habilitado en el firewall."
    fi
else
    log "ERROR: Firewall no esta corriendo. Verifica el estado del servicio."
    exit 1
fi

# Instalando a Git
log "Verificando si git esta instalado ..."
if ! command -v git &> /dev/null; then
    log "Instalando git ..."
    dnf install -y git
    log "git instalado."
else
    log "git ya esta instalado."
fi

# Notificar a Webhook
log "Notificando a Webhook ..."
curl -s -X POST "$WEBHOOK_URL" \
    -H "Content-Type: application/json" \
    -d "{\"status\":\"ok\",\"usuario\":\"$USERNAME\"}"
log "Notificacion enviada a Webhook."

#Realizando limpieza de variables sensibles
unset PASSWORD
unset KEY

#Resumen de la ejecucion
log "Resumen de la ejecucion:"
log "Usuario creado: $USERNAME"
log "Acceso SSH para root deshabilitado."
log "Acceso SSH con contraseña deshabilitado para todos los usuarios."
log "nginx instalado y corriendo."
log "Puerto 80 habilitado en el firewall."
log "Fin del script de provisionamiento."
