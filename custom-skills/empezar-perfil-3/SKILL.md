---
name: empezar
description: Onboarding interactivo de 3 minutos del Perfil 3 (Arquitectura, proyectos grandes y gobernanza de skills del equipo). Usar cuando el usuario escriba /empezar, "empezar", "cómo funciona esto", "qué puedo hacer", "ayuda inicial", "tutorial", "primeros pasos" o "bienvenida".
---

# /empezar · Perfil 3 — Arquitectura y proyectos grandes

Guía interactiva en español, unos 3 minutos. Paso a paso, esperando respuesta entre pasos.

## Always
- Saluda por su rol: "Hola 👋, este es tu entorno de arquitectura y gobernanza de IA del equipo".
- Un paso cada vez, terminando con "¿Seguimos?".
- Ejemplos listos para copiar y pegar.
- Si el usuario ya conoce una parte, sáltala y pasa a la siguiente.

## Ask First
- Antes de ejecutar `/build`, `/ship` o `graphify hook install` en un repositorio real durante la guía.
- Antes de instalar ninguna skill encontrada con `find-skills`.

## Never
- Nunca saltes `/spec` en trabajo nuevo: sin especificación no hay plan.
- Nunca distribuyas una skill sin pasar `skill-specter` (≥ 85/100).
- Nunca instales `ponytail`, `hola-ai` ni `grill-me` en este perfil.

## Flujo

### Paso 1 · Tu entorno en 30 segundos
- **Modelo según la tarea**: el modo plan (`Shift+Tab`) usa Opus y el trabajo normal usa Sonnet; los subagentes de exploración usan Haiku. En tareas complejas (arquitectura, auditorías, cambios grandes) empieza siempre en modo plan: si nadie lo activa, todo va con Sonnet. Para forzar otro modelo, escribe `/model opus`, `/model sonnet` o `/model haiku`.
- **Ahorro de tokens**: RTK comprime terminal; Graphify da un mapa del repo para no leer archivo a archivo; Context Mode limpia payloads grandes.
- **Ciclo de ingeniería** (Addy Osmani): `/spec` → `/plan` → `/build` → `/test` → `/review` → `/ship` (detalle en el Paso 2).
- **Principios Karpathy**: pensar antes de codificar, simplicidad, cambios quirúrgicos, objetivos verificables.
- **Gobernanza**: `skill-creator`, `find-skills` y `skill-specter` (aduana del equipo).

### Paso 2 · Ejemplo 1 — Proyecto nuevo de extremo a extremo (1 min)
Explica cada fase con su ejemplo:

1. **`/spec` → qué y por qué.** Escribe la especificación: objetivo, usuarios, alcance, lo que queda fuera y criterios de éxito. Es la base de todo lo demás.
   ```
   /spec Portal interno de reservas de vehículos de cortesía para los talleres:
   login con Google, calendario por sede, avisos por email.
   ```
2. **`interview-me` → requisitos sin huecos.** La IA te pregunta lo que falta (permisos, casos límite, volumen de datos) hasta que la spec no tiene dudas.
3. **`/plan` → en qué orden.** Divide la spec en tareas pequeñas y verificables, con dependencias y criterio de "hecho" para cada una.
4. **`handoff` → `/clear`.** Guarda el estado (spec + plan) en Markdown y limpia el contexto para construir con la cabeza despejada.
5. **`/build` → implementación incremental.** Una tarea del plan cada vez, compilando y probando en cada paso.
6. **`/test` → TDD.** Test primero, código después; cada criterio de la spec acaba en un test.
7. **`/review` + `/code-simplify` → calidad.** Revisión como un senior y recorte de complejidad sin cambiar comportamiento.
8. **`/ship` → producción.** Checklist de despliegue, monitorización y plan de vuelta atrás.

Menciona las skills de apoyo: `source-driven-development` (contrasta con documentación oficial), `doubt-driven-development` (cuestiona la arquitectura antes de comprometerse) y `security-and-hardening` (OWASP).

### Paso 3 · Ejemplo 2 — Repo grande existente (1 min)
Dentro del repo, una vez:
```
graphify hook install
```
El grafo se actualiza solo en cada commit. Después:
```
Usando el grafo de graphify, explícame la arquitectura del módulo de facturación,
qué depende de qué y dónde están los puntos de riesgo. Luego /review del último PR
con security-and-hardening.
```
Si el cambio toca una decisión de arquitectura:
```
Aplica doubt-driven-development: dame tres razones por las que este diseño podría fallar.
```

### Paso 4 · Ejemplo 3 — Aduana de skills (1 min)
Explica el circuito: buscar → auditar → aprobar → distribuir.
```
Busca con find-skills una skill para generar diagramas de arquitectura,
pásala por skill-specter y dame el informe. Solo si saca 85 o más, instálala.
```
Y para crear skills internas para el Perfil 2:
```
Con skill-creator, crea una skill con las reglas de negocio de facturación
de este proyecto para que la use el Perfil 2.
```
Recuerda: también las skills creadas aquí pasan por `skill-specter` antes de compartirse.

### Paso 5 · Cierre
- Guía de bolsillo: `guias-equipo/GUIA-PERFIL-3-ARQUITECTURA.md`.
- Relanzar esta guía: `/empezar`.
- Pregunta: "¿Con cuál empezamos de verdad?"
