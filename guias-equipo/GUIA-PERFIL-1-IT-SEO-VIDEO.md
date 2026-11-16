# Guía de bolsillo · Perfil 1 — IT, Vídeo, RRSS y SEO

## 0. Antes de empezar
- Hola **Bruno**: esta guía es para tu perfil.
- Descarga de Drive el archivo `setup-perfil-1-it-seo-video-Bruno.zip` y descomprímelo.
- Abre la carpeta, pulsa Mayús + clic derecho en un hueco vacío y elige "Abrir en Terminal".
- Escribe `powershell -ExecutionPolicy Bypass -File .\setup-perfil-1-it-seo-video.ps1` y acepta el permiso de Administrador.
- Antes de instalar `lemo-opuscar`, el instalador te avisa de que no está probada en Surface ARM y te pregunta si quieres instalarla (S/N).
- Cuando termine, abre una terminal nueva y escribe `ccr code`.
- Escribe `/empezar` y sigue la guía interactiva de 3 minutos.

## 1. Qué hace tu entorno (en 2 frases)
Audita webs para Google y para buscadores con IA, extrae datos de redes sociales y edita o genera vídeo con precisión de fotograma.
Todo desde una sola conversación en español, con el modelo adecuado para cada tarea y sin gastar de más.

## 2. Cómo lo hace por dentro (sin tecnicismos)
- **Router de modelos**: lo fácil (leer archivos, explorar) va a Haiku; el trabajo diario a Sonnet; lo complejo a Opus. Tú no eliges nada.
- **Ahorro de tokens**: RTK resume lo que sale por la terminal; Context Mode limpia datos enormes; Caveman Lite quita relleno pero respeta tablas e informes SEO.
- **Tus skills**:
  - `agent-reach` → saca datos de X, Reddit, YouTube, Instagram y LinkedIn.
  - `agent-browser` → abre un navegador cuando hace falta ver la web "con ojos".
  - `seo-audit` → SEO técnico clásico (Google). `ai-seo` → visibilidad en ChatGPT, Perplexity, AI Overviews.
  - `video-use` → corta y edita vídeo real. `remotion` → vídeo animado hecho con código.
  - `lemo-opuscar` → crea y edita animaciones de vídeo hechas con código, con 99 estilos listos (acuarela, óleo, neón, ukiyo-e...).

## 3. Cómo usarlo en el día a día
| Tarea | Escribe esto |
|---|---|
| Arrancar | `ccr code` y después `/empezar` |
| Auditoría SEO | `Haz una auditoría SEO de https://web.com con tabla de prioridades` |
| Visibilidad en IA | `Revisa con AI SEO cómo citan los LLM a web.com y qué cambiar` |
| Datos de redes | `Con Agent Reach, saca los 20 posts más vistos de @cuenta este mes` |
| Revisión visual | `Abre con Agent Browser la home de web.com y dime qué falla en móvil` |
| Cortar vídeo | `Con video-use quita silencios y muletillas de grabacion.mp4` |
| Vídeo animado | `Con Remotion crea un vídeo vertical 1080x1920 de 15 s con estos textos` |
| Animación con estilo | `Con lemo-opuscar haz un vídeo de 30 s en estilo acuarela sobre <tema>` |
| Ver estilos | `/lemo-opuscar:lemo-opuscar` (te pregunta qué quieres hacer) |
| Soporte IT | `Revisa por qué este equipo va lento, solo diagnóstico` |

## 4. Reglas de oro (qué NO hacer)
- ❌ **Nunca** conectes Agent Reach a cuentas corporativas o personales: solo cuentas secundarias (burners).
- ❌ No uses Agent Browser si Agent Reach ya da el dato: es más lento y caro.
- ⚠️ `lemo-opuscar` no está probada en Surface ARM: su ffmpeg es para x64 y va emulado, así que puede ir lento. Si falla, avisa y adjunta el log de `%TEMP%`.
- ❌ No instales skills por tu cuenta: pídeselas al Perfil 3 (pasan la aduana de seguridad).
