# Guía de bolsillo · Perfil 2 — Desarrollo ágil, web y GAS

## 1. Qué hace tu entorno (en 2 frases)
Arregla y crea webs y automatizaciones de Google Apps Script muy rápido, con un cambio mínimo o paso a paso guiado por tests.
Tú eliges el ritmo: diff directo con Ponytail o desarrollo controlado con hola-ai.

## 2. Cómo lo hace por dentro (sin tecnicismos)
- **Router de modelos**: explorar el código va a Haiku; programar a Sonnet; planificar a Opus. Automático.
- **Ahorro de tokens**: RTK resume la salida de tests y logs; Caveman Lite quita relleno; Context Mode limpia datos grandes.
- **Tus skills**:
  - `ponytail` → el cambio más pequeño posible, reutilizando lo que ya existe.
  - `hola-ai` → desarrollo estilo XP (programación extrema) en 3 pasos. Solo se activa cuando tú escribes el comando:
    - `/backlog` → **qué construir**. Convierte una idea en una lista ordenada de funcionalidades pequeñas. Úsalo al empezar algo nuevo o para decidir qué va primero.
    - `/story` → **qué exactamente**. Elige un elemento del backlog y lo detalla: qué debe pasar, casos límite y criterios de aceptación ("está terminado cuando..."). Así la IA no se inventa requisitos.
    - `/pair` → **cómo**. Programación en pareja guiada por test: la IA escribe un test que falla (rojo), el código mínimo para que pase (verde) y **se para** para que lo revises. Tú dices "sigue" para el siguiente test. Avanza a tu ritmo y no se sale del guion.
  - `frontend-design` · `web-design-guidelines` · `canvas-design` → interfaces cuidadas, auditoría UX/accesibilidad, carteles y PDFs visuales.
  - `gas-clasp-automation` → Apps Script en TypeScript, `clasp push`, lotes y límite de 6 min.

## 3. Cómo usarlo en el día a día
| Tarea | Escribe esto |
|---|---|
| Arrancar | `ccr code` y después `/empezar` |
| Arreglo rápido | `Arregla <bug> con el cambio mínimo en un solo diff` |
| Revisar un diff | `/ponytail-review` |
| Deuda técnica | `/ponytail-audit` |
| Preparar sesión guiada | `/ponytail off` |
| Trocear una idea | `/backlog Exportar pedidos a CSV desde el panel de administración` |
| Detallar una tarea | `/story` (elige un elemento del backlog y fija criterios de aceptación) |
| Programar con tests | `/pair` → revisa → `sigue` (un test cada vez, hasta cumplir la story) |
| Volver al modo rápido | `/ponytail on` |
| Interfaz nueva | `Diseña con frontend-design la página de precios` |
| Auditoría UX | `Revisa src/ con web-design-guidelines` |
| Cartel o PDF visual | `Con canvas-design crea un cartel A4 para <evento>` |
| Apps Script | `Crea con clasp y TypeScript un script para la hoja <X> que...` |
| Subir a Google | `clasp push` (primera vez: `clasp login`) |

## 4. Reglas de oro (qué NO hacer)
- ❌ No uses `/pair` con Ponytail activo: **siempre** `/ponytail off` antes y `/ponytail on` después.
- ❌ En GAS nunca leas/escribas celdas dentro de un bucle: todo con `getValues()` / `setValues()`.
- ❌ No edites Apps Script en el editor web: todo en local y `clasp push`.
