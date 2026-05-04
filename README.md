# 🚀 DEX2OAT OPTIMIZATION BOOST (LuferOS)

<div align="center">

![Version](https://img.shields.io/badge/Versión-v2.0_Stable-blue?style=for-the-badge&logo=android)
[![Magisk](https://img.shields.io/badge/Magisk-v20.4+-00AF9C?style=for-the-badge&logo=magisk)](https://github.com/topjohnwu/Magisk)
[![KernelSU](https://img.shields.io/badge/KernelSU-Compatible-blueviolet?style=for-the-badge&logo=linux)](https://github.com/tiann/KernelSU)

<br>
[![Download Now](https://img.shields.io/badge/¡DESCARGAR_AHORA!-black?style=for-the-badge&logo=github&logoColor=white)](https://github.com/LuferOS/dexoat-Magisk-kernelsu/releases/latest)

</div>

---
## 🧐 ¿Qué hace esta bestia?
**Dex2OAT Optimization Boost** no es el típico script destructivo que compila todo a lo bruto y deja tu dispositivo congelado. Este módulo actúa como un disparador inteligente de optimización post-arranque.
Fuerza al motor ART de Android a recompilar todas las aplicaciones de terceros utilizando el filtro **`speed-profile`**.
* **El equilibrio perfecto:** Solo optimiza las partes del código que realmente usas con frecuencia.
* **Resultado:** Aperturas de apps mucho más rápidas y animaciones más fluidas, sin devorar tu almacenamiento interno.
## 🚀 Arquitectura de Cero Lag (Novedades v2.0)
A diferencia de otros módulos, hemos blindado la ejecución para que ni te des cuenta de que está corriendo:
1.  **🛡️ Control I/O Estricto (`ionice -c 3`):** El proceso solo lee y escribe en la memoria cuando ninguna otra aplicación la está usando. Tu almacenamiento no se asfixiará.
2.  **🧠 Prioridad de CPU Idle (`chrt -i 0` + `nice -n 19`):** El compilador cede el paso a cualquier otra tarea del sistema. Cero congelamientos (lag) mientras usas el móvil.
3.  **🔋 Failover de Batería:** El script audita el nivel de energía (`dumpsys battery`). Si tienes menos del 25%, la optimización se aborta automáticamente para proteger tu autonomía.
4.  **🛑 Ejecución Única Quirúrgica:** Crea un marcador (`.ran_once`) para ejecutarse una sola vez tras la instalación. Tus futuros arranques seguirán siendo instantáneos.
---
## 📲 Guía de Instalación
1.  **Descarga** el archivo `.zip` más reciente desde la sección de [Releases](https://github.com/LuferOS/dexopt-boost-magisk/releases).
2.  Abre **Magisk Manager** o **KernelSU Manager**.
3.  Ve a la pestaña de **Módulos**.
4.  Toca en **"Instalar desde almacenamiento"** y flashea el archivo.
5.  **Reinicia tu dispositivo**.
    * *Nota:* El script esperará pacientemente a que el sistema arranque por completo (`sys.boot_completed`) y pausará otros 60 segundos antes de comenzar la optimización en segundo plano.
---
## 📋 Requisitos del Sistema

| Requisito | Detalle |
| :--- | :--- |
| **Root Manager** | Magisk o KernelSU/APatch. |
| **Android** | Android 9 (Pie) en adelante (Soporte nativo óptimo para perfiles ART). |
| **Batería** | Mínimo 25% de carga requerida para la primera ejecución. |

---
## ⚠️ ¿Cuándo NO deberías instalar esto?
Este módulo es una herramienta de *power user*. **Evítalo si:**
* ❌ **Tienes almacenamiento crítico:** `speed-profile` es eficiente, pero la compilación AOT siempre ocupará más espacio que el código interpretado (JIT).
* ❌ **Usas ROMs fuertemente modificadas:** Si tu Custom ROM ya tiene gestores agresivos de `dexopt` integrados, podrías generar conflictos.
* ❌ **Tu batería está degradada:** El proceso inicial de compilación es exigente para el SoC.
> **💡 Tip Técnico:** Android optimiza aplicaciones de forma nativa mientras el móvil carga y está inactivo por la noche. Este módulo está diseñado para los entusiastas que quieren forzar ese rendimiento de inmediato tras flashear o instalar lotes grandes de apps.
---
## 🛠️ Verificación y Logs
¿Quieres ver cómo el motor compila tus apps en tiempo real?
Abre Termux (o cualquier terminal con root) y ejecuta:
```bash
tail -f /data/local/tmp/luferos_optimizer.log
