#!/bin/bash
set -euo pipefail

# --Configuracion de variables

ORIGEN="${1:-$HOME/datos_importantes}" #Carpeta a realizar backup.
DESTINO="${2:-$HOME/backups}" #Ruta donde guardar.
WEBHOOK_URL="https://webhook.site/943016a5-d602-4fc0-8909-6a8ffd1511d1"

# Función de log con timestamp
log () {
	echo "[$(date +%H:%M:%S)] $1"
}

# Validacion
if [ ! -d "$ORIGEN" ]; then
	log "ERROR: la carpeta $ORIGEN no existe"
	exit 1
fi

# Backup
mkdir -p "$DESTINO"
FECHA=$(date +%Y%m%d_%H%M%S)
ARCHIVO="backup_${FECHA}.tar.gz"

log "realizando backup de $ORIGEN ..."
tar -czf "$DESTINO/$ARCHIVO" "$ORIGEN"

TAMANO=$(du -h "$DESTINO/$ARCHIVO" | cut -f1)
log "Backup realizado con exito: $DESTINO/$ARCHIVO ($TAMANO)"

# Notificar a Webhook
log "Notificando..."
curl -s -X POST "$WEBHOOK_URL" \
	-H "Content-Type: application/json" \
	-d "{\"status\":\"ok\",\"archivo\":\"$ARCHIVO\",\"tamano\":\"$TAMANO\"}"
log "Listo."
log "Fin."
