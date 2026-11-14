# Guía de bolsillo · Perfil 3 — Arquitectura y proyectos grandes

## 1. Qué hace tu entorno (en 2 frases)
Lleva proyectos complejos de la idea a producción con especificación, plan, tests, revisión de seguridad y entrega.
Además es la aduana del equipo: crea y audita las skills antes de que lleguen a los demás perfiles.

## 2. Cómo lo hace por dentro (sin tecnicismos)
- **Router de modelos**: exploración y subagentes con Haiku; implementación con Sonnet; arquitectura y planes con Opus.
- **Ahorro de tokens**: Graphify da un mapa del repo (no lee archivo a archivo); RTK comprime terminal; Context Mode y Handoff mantienen el contexto limpio.
- **Ciclo de ingeniería (Addy Osmani)**, cada fase con su skill:
  - `/spec` → **qué y por qué**. Escribe la especificación: objetivo, alcance, fuera de alcance y criterios de éxito.
  - `interview-me` → **requisitos sin huecos**. Te hace preguntas hasta cerrar dudas antes de planificar.
  - `/plan` → **en qué orden**. Divide la spec en tareas pequeñas y verificables, con dependencias.
  - `/build` → **implementación incremental**. Una tarea cada vez, compilando y probando en cada paso.
  - `/test` → **TDD**. Test primero, código después; cada criterio de la spec acaba en un test.
  - `/review` → **calidad**. Revisa legibilidad, errores y diseño como lo haría un senior.
  - `/code-simplify` → **menos código**. Quita complejidad sin cambiar el comportamiento.
  - `/ship` → **salida a producción**. Checklist de despliegue, monitorización y vuelta atrás.
  - Apoyo: `source-driven-development` (contrasta con la documentación oficial), `doubt-driven-development` (cuestiona la arquitectura antes de comprometerse), `security-and-hardening` (OWASP), `using-agent-skills` (índice de todas).
- **Principios Karpathy**: pensar antes de codificar, simplicidad primero, cambios quirúrgicos, objetivos verificables.
- **Memoria y contexto**: `graphify` (mapa AST que se actualiza en cada commit) y `handoff` (resumen del estado en Markdown para hacer `/clear` sin perder nada).
- **Web**: `frontend-design` + `web-design-guidelines`.
- **Gobernanza**: `skill-creator` (skills internas), `find-skills` (buscar), `skill-specter` (NVIDIA SkillSpector, mínimo 85/100).

## 3. Cómo usarlo en el día a día
| Tarea | Escribe esto |
|---|---|
| Arrancar | `ccr code` y después `/empezar` |
| Idea nueva | `/spec <descripción>` y luego `interview-me` |
| Plan de tareas | `/plan` |
| Cambiar de fase sin perder estado | `handoff` → `/clear` → `/build` |
| Implementar | `/build` (incremental) + `/test` (TDD) |
| Dudar de una decisión | `Aplica doubt-driven-development a esta arquitectura` |
| Validar contra docs oficiales | `Verifica esta implementación con source-driven-development` |
| Revisar | `/review` y `security-and-hardening` |
| Simplificar | `/code-simplify` |
| Publicar | `/ship` |
| Mapa del repo | `graphify hook install` (una vez por repo) |
| Entender un repo grande | `Con el grafo de graphify, explícame el módulo <X> y sus dependencias` |
| Interfaz | `Diseña con frontend-design y audita con web-design-guidelines` |
| Nueva skill de terceros | `Busca con find-skills <necesidad> y pásala por skill-specter` |
| Skill interna para Perfil 2 | `Con skill-creator crea una skill con las reglas de <proyecto>` |

## 4. Reglas de oro (qué NO hacer)
- ❌ No te saltes `/spec`: sin especificación no hay `/plan` ni `/build`.
- ❌ Ninguna skill llega al equipo sin informe de `skill-specter` ≥ 85/100.
- ❌ No instales `ponytail`, `hola-ai` ni `grill-me` en este perfil.
