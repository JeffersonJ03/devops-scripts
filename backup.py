#!/usr/bin/env python3
import os
import subprocess
import datetime
import requests

ORIGEN = os.path.expanduser("~/datos_importantes")
DESTINO = os.path.expanduser("~/backups")
WEBHOOK_URL = "https://webhook.site/943016a5-d602-4fc0-8909-6a8ffd1511d1"

def log(mensaje):
    hora = datetime.datetime.now().strftime("%H:%M:%S")
    print(f"[{hora}] {mensaje}")

def main():
    if not os.path.isdir(ORIGEN):
        log(f"ERROR: la carpeta {ORIGEN} no existe")
        return 1

    os.makedirs(DESTINO, exist_ok=True)
    fecha = datetime.datetime.now().strftime("%Y%m%d_%H%M%S")
    archivo = f"backup_{fecha}.tar.gz"
    ruta = os.path.join(DESTINO, archivo)

    log(f"Respaldando {ORIGEN} ...")
    subprocess.run(["tar", "-czf", ruta, ORIGEN], check=True)

    tamano_mb = round(os.path.getsize(ruta) / 1024 / 1024, 2)
    log(f"Backup creado: {ruta} ({tamano_mb} MB)")

    payload = {"status": "ok", "archivo": archivo, "tamano_mb": tamano_mb}
    try:
        r = requests.post(WEBHOOK_URL, json=payload, timeout=10)
        r.raise_for_status()
        log("Notificación enviada.")
    except requests.RequestException as e:
        log(f"Fallo al notificar: {e}")

    return 0

if __name__ == "__main__":
    exit(main())

