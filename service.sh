#!/system/bin/sh
# Modulo: LuferOS Dex2OAT Optimizer
# Motor reescrito: Cero lag, protección I/O y control de batería.

MODDIR=${0%/*}
LOG_FILE="/data/local/tmp/luferos_optimizer.log"
MARKER_FILE="$MODDIR/.ran_once"
COMPILER_FILTER="speed-profile"
BATTERY_THRESHOLD=25 # Lo subí al 25% por seguridad. Dex2OAT drena mucha energía.

# --- Función de Log Inteligente ---
print_log() {
  # Solo guarda las últimas 500 líneas para no crear un archivo monstruoso (fuga de espacio)
  if [ -f "$LOG_FILE" ] && [ $(stat -c%s "$LOG_FILE") -gt 512000 ]; then
    tail -n 500 "$LOG_FILE" > "$LOG_FILE.tmp"
    mv "$LOG_FILE.tmp" "$LOG_FILE"
  fi
  echo "$(date +"%Y-%m-%d %H:%M:%S") - $1" >> "$LOG_FILE"
  log -p i -t LuferOS_Dex2OAT "$1"
}

# --- 1. Verificación de Ejecución Única Temprana ---
if [ -f "$MARKER_FILE" ]; then
  exit 0 # Salida silenciosa si ya se ejecutó. No gastamos CPU en revisar el boot.
fi

# --- 2. Espera de Arranque Seguro (con Timeout) ---
MAX_WAIT=120
WAIT_COUNT=0
while [ "$(getprop sys.boot_completed)" != "1" ]; do
  sleep 5
  WAIT_COUNT=$((WAIT_COUNT + 5))
  if [ $WAIT_COUNT -ge $MAX_WAIT ]; then
    print_log "ERROR: Timeout esperando el arranque. Abortando para evitar bucle."
    exit 1
  fi
done

# Espera de estabilización para no asfixiar el inicio del sistema
sleep 60

# --- 3. Verificación de Batería (Failover) ---
# Usamos dumpsys como método principal (más exacto), fallback a sysfs.
BATTERY_LEVEL=$(dumpsys battery | grep level | awk '{print $2}')
if [ -z "$BATTERY_LEVEL" ]; then
  BATTERY_LEVEL=$(cat /sys/class/power_supply/battery/capacity 2>/dev/null || echo 100)
fi

if [ "$BATTERY_LEVEL" -lt "$BATTERY_THRESHOLD" ]; then
  print_log "ABORTADO: Batería al $BATTERY_LEVEL%. Se requiere $BATTERY_THRESHOLD% mínimo. Intentará en el próximo reinicio."
  exit 1
fi

# --- Lógica Principal (El motor) ---
print_log "Iniciando optimización Dex2OAT. Filtro: $COMPILER_FILTER. Batería: $BATTERY_LEVEL%"

# Obtenemos paquetes de forma limpia, evitando crear sub-shells innecesarias
PACKAGES=$(pm list packages -3 | sed 's/package://g')

if [ -z "$PACKAGES" ]; then
  print_log "ERROR: Lista de paquetes vacía."
  exit 1
fi

# Contar usando grep de forma más eficiente
TOTAL=$(echo "$PACKAGES" | grep -c "^")
COUNT=0

print_log "Optimizando $TOTAL aplicaciones en segundo plano..."

for pkg in $PACKAGES; do
  COUNT=$((COUNT + 1))
  
  # Verificamos si la app no fue desinstalada durante la espera
  if pm path "$pkg" > /dev/null 2>&1; then
    
    # LA MAGIA: 
    # chrt -i 0: Prioridad de CPU Idle (solo usa CPU cuando nada más lo necesite)
    # ionice -c 3: Prioridad de I/O Idle (evita lag en el almacenamiento interno)
    # nice -n 19: Prioridad mínima del proceso
    chrt -i 0 ionice -c 3 nice -n 19 cmd package compile -m "$COMPILER_FILTER" -f "$pkg" > /dev/null 2>&1
    
    if [ $? -eq 0 ]; then
      print_log "[$COUNT/$TOTAL] ÉXITO: $pkg"
    else
      print_log "[$COUNT/$TOTAL] ERROR/SKIP: $pkg (Quizás sin perfil JIT aún)"
    fi
    
    # Pausa térmica para el Exynos 1580. Dex2OAT es intensivo.
    sleep 1
  else
    print_log "[$COUNT/$TOTAL] OMITIDO: $pkg (No encontrado)"
  fi
done

# --- Finalización ---
print_log "Optimización AOT completada."
touch "$MARKER_FILE"
print_log "Marcador $MARKER_FILE creado. El módulo entra en reposo permanente."

exit 0
