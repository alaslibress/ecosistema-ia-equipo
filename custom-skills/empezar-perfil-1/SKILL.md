---
name: empezar
description: Onboarding interactivo de 3 minutos del Perfil 1 (IT, Vídeo, RRSS y SEO). Usar cuando el usuario escriba /empezar, "empezar", "cómo funciona esto", "qué puedo hacer", "ayuda inicial", "tutorial", "primeros pasos" o "bienvenida".
---

# /empezar · Perfil 1 — IT, Vídeo, RRSS y SEO

Guía interactiva en español, máximo 3 minutos. Ve paso a paso y espera respuesta entre pasos.

## Always
- Saluda por su rol: "Hola 👋, este es tu entorno de IT, vídeo, redes sociales y SEO".
- Un paso cada vez. Termina cada paso con una pregunta corta ("¿Seguimos?").
- Ofrece ejemplos listos para copiar y pegar.

## Ask First
- Antes de ejecutar de verdad un ejemplo que use internet, cuentas de redes o renderice vídeo.

## Never
- Nunca configures Agent Reach con cuentas corporativas o personales: solo cuentas secundarias (burners).
- Nunca alargues la guía más de 3 minutos ni añadas teoría.

## Flujo

### Paso 1 · Tu entorno en 30 segundos
Explica en 4 viñetas:
- **Modelo según la tarea**: tareas fáciles con un modelo rápido y barato; las difíciles con el más potente. Automático.
- **Ahorro de tokens**: RTK resume lo que sale por la terminal; Caveman Lite quita relleno de las respuestas sin tocar tablas ni informes.
- **Tus skills**: Agent Reach (redes), Agent Browser (navegador), SEO Audit, AI SEO, video-use, Remotion y lemo-opuscar (animaciones con estilo).
- **Regla de oro**: Agent Reach solo con cuentas secundarias.

Pregunta: "¿Probamos el primer ejemplo?"

### Paso 2 · Ejemplo 1 — Auditoría SEO (1 min)
Propón copiar:
```
Haz una auditoría SEO de https://www.ejemplo.com: títulos, meta descripciones,
encabezados, enlaces rotos y rastreabilidad. Después revisa con AI SEO cómo
mejorar su visibilidad en ChatGPT, Perplexity y Google AI Overviews.
Dame una tabla con prioridad Alta/Media/Baja.
```
Explica qué skills se activan: `seo-audit` y `ai-seo`.

### Paso 3 · Ejemplo 2 — Redes sociales (1 min)
Recuerda el aviso de cuentas secundarias. Propón:
```
Con Agent Reach, saca los 20 vídeos más vistos del último mes del canal de
YouTube @canal-ejemplo y resúmeme temas, duración media y ganchos de los títulos.
Si hace falta ver algo en la web, usa Agent Browser.
```

### Paso 4 · Ejemplo 3 — Vídeo (1 min)
Propón:
```
Con Remotion crea un vídeo vertical de 15 segundos (1080x1920, 30 fps) con el
título "Oferta de la semana", 3 rótulos animados y el logo en la esquina.
Luego usa video-use para cortar los silencios de grabacion.mp4.
```
Explica: Remotion = vídeo animado hecho con código (precisión de fotograma); video-use = cortar y editar vídeo real.

Después propón la alternativa con estilo visual:
```
Con lemo-opuscar haz un vídeo de 30 segundos en estilo acuarela sobre
nuestra oferta de la semana.
```
Explica: lemo-opuscar = animaciones de vídeo hechas con código, con 99 estilos listos (acuarela, óleo, neón, ukiyo-e...). Con `/lemo-opuscar:lemo-opuscar` te enseña los estilos y te pregunta qué quieres hacer.
Avisa: no está probada en Surface ARM; su ffmpeg va emulado y puede ir lento.
Si no está instalada (en la instalación se respondió N), dilo y sugiere relanzar el script del perfil.

### Paso 5 · Cierre
- Guía de bolsillo: `guias-equipo/GUIA-PERFIL-1-IT-SEO-VIDEO.md`.
- Comando para relanzar esta guía: `/empezar`.
- Pregunta: "¿Con cuál de los tres empezamos de verdad?"
