---
name: empezar
description: Onboarding interactivo de 3 minutos del Perfil 2 (Desarrollador ágil, web y Google Apps Script). Usar cuando el usuario escriba /empezar, "empezar", "cómo funciona esto", "qué puedo hacer", "ayuda inicial", "tutorial", "primeros pasos" o "bienvenida".
---

# /empezar · Perfil 2 — Desarrollo ágil, web y GAS

Guía interactiva en español, máximo 3 minutos. Paso a paso, esperando respuesta entre pasos.

## Always
- Saluda por su rol: "Hola 👋, este es tu entorno de desarrollo rápido, web y Apps Script".
- Un paso cada vez, terminando con "¿Seguimos?".
- Ejemplos listos para copiar y pegar.

## Ask First
- Antes de ejecutar `clasp push` o tocar un proyecto real durante la guía.

## Never
- Nunca uses `/pair` con Ponytail activo: primero `/ponytail off`.
- Nunca alargues la guía más de 3 minutos.

## Flujo

### Paso 1 · Tu entorno en 30 segundos
- **Modelo según la tarea**: tareas simples con modelo rápido, código diario con Sonnet, planificación con Opus. Automático.
- **Ahorro de tokens**: RTK comprime la salida de tests y logs; Caveman Lite quita relleno de las respuestas.
- **Dos modos de trabajo**:
  - *Ponytail* → arreglos directos en un solo diff (`/ponytail-review`, `/ponytail-audit`).
  - *hola-ai* → desarrollo estilo XP en 3 pasos, solo cuando tú escribes el comando: `/backlog` → `/story` → `/pair` (detalle en el Paso 3).
- **Web**: `frontend-design`, `web-design-guidelines`, `canvas-design`.
- **GAS**: `gas-clasp-automation` (TypeScript + `clasp push`, lotes y límite de 6 min).

### Paso 2 · Ejemplo 1 — Arreglo rápido con Ponytail (1 min)
```
El botón "Enviar" del formulario de contacto no valida el email.
Arréglalo con el cambio mínimo en un solo diff.
```
Después sugiere `/ponytail-audit` para ver deuda técnica del repo.

### Paso 3 · Ejemplo 2 — Funcionalidad paso a paso con hola-ai (1 min)
Explica primero la regla de convivencia: Ponytail recorta cambios y choca con el ritmo de `/pair`, así que se apaga antes:
```
/ponytail off
```
Después explica cada comando con su ejemplo:

1. **`/backlog` → qué construir.** Convierte una idea en una lista ordenada de funcionalidades pequeñas. Úsalo al empezar algo nuevo o para decidir qué va primero.
   ```
   /backlog Exportar pedidos a CSV desde el panel de administración
   ```
2. **`/story` → qué exactamente.** Toma un elemento del backlog y lo detalla: qué debe pasar, casos límite y criterios de aceptación ("está terminado cuando..."). Así la IA no se inventa requisitos.
   ```
   /story
   ```
3. **`/pair` → cómo.** Programación en pareja guiada por test: la IA escribe un test que falla (rojo), el código mínimo para que pase (verde) y **se para** para que revises. Escribe `sigue` para el siguiente test, hasta cumplir todos los criterios de la story.
   ```
   /pair
   ```

Al terminar la sesión vuelve al modo rápido: `/ponytail on`.

### Paso 4 · Ejemplo 3 — Apps Script (1 min)
```
Crea en local con TypeScript y clasp un script para la hoja "Pedidos" que
marque en rojo las filas con fecha de entrega vencida y envíe un resumen por
email cada lunes. Usa lectura/escritura por lotes y despliega con clasp push.
```
Recuerda: primera vez `clasp login`.

### Paso 5 · Cierre
- Guía de bolsillo: `guias-equipo/GUIA-PERFIL-2-DEV-AGIL-GAS.md`.
- Relanzar esta guía: `/empezar`.
- Pregunta: "¿Con cuál empezamos de verdad?"
