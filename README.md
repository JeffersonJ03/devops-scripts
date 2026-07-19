# Scripts básicos para prácticas DevOps
Este repositorio tiene por objetivo almacenar Scripts de utilidad que pueden usarse en el día a día de un DevOps.

## Scripts Backups
Estos Scripts básicos realizan el backup de una carpeta objetivo. Se pueden usar para automatizar (Configurando un cron) un backup. Agregué dos: Uno en bash y otro en python, técnicamente ambos hacen lo mismo, pero desde el punto de vista de desarrollo, python (como el script usa un webhook) es mejor estructurado para manejar request HTTP y archivos .json.

### Parametros de entrada

ORIGEN=[Ruta a realizar backup]

DESTINO=[Ruta de destino a donde se almacenaran los archivos .tar.gz]

#### Ejemplo de uso

chmod +x backup.sh

./backup.sh /home/jeff/datos_importantes/ /home/jeff/backups/

## Script provision.sh
Se agrega un Runbook.md desarrollado en su momento como los primeros pasos para aprovisionar un servidor de producción. Este Script es la automatización de ese runbook.

### Parametros de entrada

USERNAME=[dev] por defecto: defaultUser

PASSWORD=[Clave] parámetro obligatorio

KEY=[Clave publica para agregar al usuario] Llave ssh pública para conectar al servidor prod. Parámetro obligatorio.

#### Ejemplo de uso

chmod +x provision.sh

./provision.sh dev Holamundo123 llaveSSHpublica

## Script de Monitoreo
Este nuevo Script es de extrema utilidad, desarrollado en python e integrado a un Webhook realiza cada 60 segundos (1 minuto) un Health check a cualquier URL que se le pase como parámetro.

### Parametros de entrada

url=[https://google.com]

#### Ejemplo de uso

chmod +x monitor.py

(Es recomendable ejecutar siempre scripts de python en un entorno virtual separado para evitar ligar dependencias de otros proyectos)

python3 -m venv venv

source venv/bin/activate

pip install requeriments.txt

python3 monitor.py https://www.google.com

[Se activará bucle de 60 segundos, puede detenerlo con Ctrl+c].
