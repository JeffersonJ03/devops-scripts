# Runbook: aprovisionamiento de servidor Linux
Documento en el que se describen los pasos para dejar listo un servidor linux con su servicio basico arriba. Nota: *Esto se ejecuta sobre un entorno de una equipo virtual aprovisionado previamente en la nube. Para este caso se aprovisiono VM con Linux Red Hat Enterprise Linux 9 (9.4) en Azure. Los pasos descriptos en este Runbook, son posteriores a los pasos de aprovisionamiento previo de la VM [Virtual Machine].*

## Creacion del usuario
### 1-Crear usuaio noRoot con privilegio de administacion
```Bash
sudo adduser ops
```
### 2-Agregar el usuario al grupo "sudo" o "wheel" en el caso de RHEL
```Bash
sudo usermod -aG wheel ops
```

### 3-Agregar password al usaurio creado
```Bash
sudo passwd ops
```

## Configuracion de acceso por SSH
Siempre es recomendable no usar SSH por password. Lo ideal es acceder por la configuracion de pares de llaves.

### 1-Generar par de llaves SSH ed25519 entorno local
```Bash
ssh-keygen -t ed25519 -C "ops-key" -f ~/.ssh/ops-key -N ""
```
Esto genera el par de llaves. Se usa el flag *"-f"* para indicar la carpeta. El flag *-N* para que no solicite el password y se coloque vacio. Ver proceso completamente no iterativo. Util en automatizaciones:
```Bash
ssh-keygen -t ed25519 -C "ops-key-$(date +%Y%m%d)" -f ~/.ssh/ops-key -N "" -q
```
Aqui el flag *-q* es no imprimir la salida de las llaves en consola.

Se generaran dos pares de llaves *"ops-key"* y *"ops-key.pub"* esta ultima es la que se coloca en el servidor.

### 2-Copiar llave publica al servidor
```Bash
ssh-copy-id ops@158.23.61.41
```
Por defecto, solicitara la clave de *ops* para autenticar. Luego se copiara el .pub al servidor y deberia poder conectarse sin password:
```Bash
ssh ops@158.23.61.41
```

En el caso donde el servirdor fue aprovisionado con el "PasswordAuthentication" en "No" por defecto, se debe aregar la llave del usuario de forma manual:
#### 1-Ingrese con el usuario principal creado en el aprovisionamiento inicial de la VM
#### 2-Consulte si el usuario creado (ops) tiene la carpeta .ssh (/home/ops/.ssh):
```Bash
sudo ls -la /home/ops/
```
Si no la tiene debe crearla. Ejecutar:
```Bash
su - ops
mkdir -p .ssh
chmod 700 .ssh
touch authorized_keys
chmod 600 authorized_keys
```
En la PC local ejecute:
```Bash
cat ops-key.pub
```
#### 3-Copie el contenido en el "authorized_keys" ubicado en "/home/ops/.ssh"
```Bash
echo ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKL/1OprdOOkUT4iH76VT5li4wYNp7xIcAMXo7G9EIQL ops-key >> authorized_keys
```
Luego intente iniciar sesion sin el password:
```Bash
ssh -i ~/.ssh/ops-key ops@158.23.61.41
```

## Endurecimiento hardening
Garantizar que el no acceso con root al servidor de prod y sin password como via de autenticacion:

### 1-Edite el archivo sshd_config
```Bash
sudo vi /etc/ssh/sshd_config
```
### 2-Modifique los valores:
```Bash
PermitRootLogin no
PasswordAuthentication no
```
### 3-Reinicie el servicio ssh para aplicar cambios
```Bash
sudo systemctl restart sshd
```

## Instalacion de un servicio
Acontinuacion se instalara y activara el servicio nginx.

### 1-Verificar updates de paquetes:
```Bash
sudo dnf check-update
```
### 2-Intalar el servicio:
```Bash
sudo dnf install nginx -y
```
### 3-Activarlo para que suba automaticamente tras cada reinicio del servidor
```Bash
sudo systemctl enable nginx
```
### 4-Iniciar el servicio
```Bash
sudo systemctl start nginx
```
### 4-Consultar el estado del servicio
```Bash
sudo systemctl status nginx
```
verifica: debe decir "active (running)"

Como este es un servicio web que corre en el puerto 80, es posible que necesite abrir los puertos en el host:
### 5-Consultar si el firewall esta activo:
```Bash
sudo systemctl status firewalld
```
Si aparece *enabled* es porque esta activo. Consulte la tablas de reglas:
```Bash
sudo firewall-cmd --list-all
```
Si en *services:* no aparece http o en "ports" 80 (que es el que escucha nginx por defecto), ejecute:
### 6-Abrir puerto/servcio en el firewall activo del host:
```Bash
sudo firewall-cmd --permanent --add-service=http
sudo firewall-cmd --permanent --add-port=80/tcp
sudo firewall-cmd --reload
```

## Verificacion final
Verificar servicio accediendo a la IP publica del host: http://[ipPublica] > http://158.23.61.41/ Debe ser direccionado a la pagina de inicio de nginx.

### 1-Confirmar que root no puede entrar
```Bash
ssh root@158.23.61.41
```

### 2-Confirmar que password auth esta deshabilitado
```Bash
ssh -o PreferredAuthentications=password ops@158.23.61.41
```

### 3-Confirmar servicio activo
```Bash
sudo systemctl status nginx
```