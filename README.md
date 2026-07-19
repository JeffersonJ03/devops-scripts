# Scripts básicos para prácticas DevOps
Este repositorio tiene por objetivo almacenar Scripts de utilidad que pueden usarse en el día a día de un DevOps.

## Scripts Backups
Estos Scripts básicos realizan el backup de una carpeta objetivo. Se pueden usar para automatizar (Configurando un cron) un backup. Agregué dos: Uno en bash y otro en python, técnicamente ambos hacen lo mismo, pero desde el punto de vista de desarrollo, python (como el script usa un webhook) es mejor estructurado para manejar request HTTP y archivos .json.

## Script provision.sh
Se agrega un Runbook.md desarrollado en su momento como los primeros pasos para aprovisionar un servidor de producción. Este Script es la automatización de ese runbook.

### Parametros de entrada
USERNAME=[dev] por defecto: defaultUser
PASSWORD=[Clave] parámetro obligatorio
KEY=[Clave publica para agregar al usuario] Llave ssh pública para conectar al servidor prod. Parámetro obligatorio.

#### Ejemplo de uso
chmod +x provision.sh
./provision.sh dev Holamundo123 llaveSSHpublica
