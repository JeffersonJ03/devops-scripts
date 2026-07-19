#!/usr/bin/python3
import time
import requests

# Solicitando URL a realizar healthcheck
url = input("Ingrese la URL a monitorear: ")

# Definiendo la URL del webhook para notificaciones
WEBHOOK_URL = "https://webhook.site/943016a5-d602-4fc0-8909-6a8ffd1511d1"

# Funcion log para imprimir mensajes con timestamp
def log(mensaje):
    hora = time.strftime("%H:%M:%S")
    print(f"[{hora}] {mensaje}")

# funcion para enviar notificaciones al webhook
def enviar_notificacion(status, mensaje):
    payload = {"status": status, "mensaje": mensaje}
    try:
        r = requests.post(WEBHOOK_URL, json=payload, timeout=10)
        r.raise_for_status()
        log("Notificación enviada.")
    except requests.RequestException as e:
        log(f"Fallo al notificar: {e}")

# Bucle principal para monitorear la URL
while True:
    try:
        response = requests.get(url, timeout=5)
        if response.status_code == 200:
            log(f"URL {url} está activa.")
            enviar_notificacion("ok", f"URL {url} está activa.")
        else:
            log(f"URL {url} respondió con código {response.status_code}.")
            enviar_notificacion("error", f"URL {url} respondió con código {response.status_code}.")
    except requests.RequestException as e:
        log(f"Error al acceder a la URL {url}: {e}")
        enviar_notificacion("error", f"Error al acceder a la URL {url}: {e}")

    # Esperar 60 segundos antes de la siguiente verificación
    time.sleep(60)
    # Nota: Para detener el script, presione Ctrl+C en la terminal.

