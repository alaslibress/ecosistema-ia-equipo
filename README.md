# Ecosistema IA del equipo

Instaladores, skills y guías para montar el entorno de IA (Claude Code) del equipo en **Windows 11 ARM64 (Microsoft Surface)**, con cuatro perfiles de trabajo.
La arquitectura completa está descrita en [`IA.txt`](IA.txt).

## Perfiles

| Perfil | Rol | Instalador | Guía |
|---|---|---|---|
| 1 | IT, Vídeo, RRSS y SEO | [`setup-perfil-1-it-seo-video.ps1`](setup-perfil-1-it-seo-video.ps1) | [Guía 1](guias-equipo/GUIA-PERFIL-1-IT-SEO-VIDEO.md) |
| 2 | Desarrollo ágil, web y Google Apps Script | [`setup-perfil-2-dev-fast-gas.ps1`](setup-perfil-2-dev-fast-gas.ps1) | [Guía 2](guias-equipo/GUIA-PERFIL-2-DEV-AGIL-GAS.md) |
| 3 | Arquitectura y proyectos grandes (aduana de skills) | [`setup-perfil-3-dev-enterprise.ps1`](setup-perfil-3-dev-enterprise.ps1) | [Guía 3](guias-equipo/GUIA-PERFIL-3-ARQUITECTURA.md) |
| 4 | Generalista operativo: sistemas, redes y auditoría | [`setup-perfil-4-generalista-operativo.ps1`](setup-perfil-4-generalista-operativo.ps1) | [Guía 4](guias-equipo/GUIA-PERFIL-4-GENERALISTA-OPERATIVO.md) |

## Estructura

```
.
├── IA.txt                                   Arquitectura de referencia (Nivel 0 + 4 perfiles)
├── setup-perfil-1-it-seo-video.ps1          Instaladores (uno por perfil)
├── setup-perfil-2-dev-fast-gas.ps1
├── setup-perfil-3-dev-enterprise.ps1
├── setup-perfil-4-generalista-operativo.ps1
├── custom-skills/                           Skills internas que copian los instaladores
│   ├── gas-clasp-automation/                Perfil 2: Apps Script con TypeScript y clasp
│   ├── asistente-operativo-it/              Perfil 4: auditoría Quiter/Drive, redes, utilidades
│   └── empezar-perfil-1 … empezar-perfil-4/ Onboarding /empezar de cada perfil
├── guias-equipo/                            Guías de bolsillo en Markdown
└── documentos-google-skills/                Las mismas guías en .docx para subir a Google Docs
```

## Qué instala cada script

**Nivel 0 (los cuatro perfiles):**
- Dependencias del sistema con `winget` (prioriza `arm64`, con alternativa `x64`): Git, Node.js LTS, Python 3.12, Rustup y ripgrep.
- Claude Code CLI con la suscripción de Claude del equipo (sin API Key):
  - Modelo `opusplan` en `~/.claude/settings.json`: Opus en modo plan, Sonnet para ejecutar.
  - Los subagentes de exploración usan Haiku (comportamiento por defecto de Claude Code).
  - Si encuentra `claude-code-router` de una instalación anterior, lo desinstala y borra `%USERPROFILE%\.claude-code-router\` (guardaba la API Key).
  - Avisa si hay variables `ANTHROPIC_API_KEY`, `ANTHROPIC_AUTH_TOKEN` o `ANTHROPIC_BASE_URL`, porque harían que se cobre por API en vez de usar la suscripción.
- `rtk` (Rust Token Killer) con `rtk init -g`.
- Caveman en modo `Lite` y Context Mode.
- La skill `/empezar` del perfil.

**Por perfil:** las skills externas e internas que indica `IA.txt`. Cada script mueve a cuarentena las skills prohibidas para su perfil.

## Instalación

1. Copia el repositorio completo a la máquina. Los scripts necesitan la carpeta `custom-skills/` a su lado.
2. Ejecuta el instalador del perfil en PowerShell:
   ```powershell
   .\setup-perfil-N-xxx.ps1
   ```
   Se eleva solo a Administrador.
3. Abre una terminal nueva y escribe `claude`. La primera vez elige iniciar sesión con tu cuenta de Claude (suscripción del equipo). No hace falta API Key.
4. Escribe `/empezar`.

### Reparto por Google Drive

En `zips-drive/` hay un `.zip` por persona: Bruno (Perfil 1), Jose (Perfil 2), Alex (Perfil 3) y Javi (Perfil 4). Cada uno lleva el script, las carpetas de `custom-skills/` que usa y un `LEEME.txt` con los pasos. La carpeta no se sube a git: si cambian los scripts o las skills, hay que volver a generar los zips.

Un script descargado de Drive no arranca con doble clic, porque Windows bloquea los scripts descargados de Internet. Ejecútalo así desde la carpeta descomprimida:

```powershell
powershell -ExecutionPolicy Bypass -File .\setup-perfil-N-xxx.ps1
```

### Guías en Word

Los `.docx` de `documentos-google-skills/` se generan desde `guias-equipo/*.md`. Si cambias una guía, vuelve a generarlos:

```powershell
cd tools
npm install
node generar-docx.js
```

### Parámetros opcionales

| Script | Parámetro | Uso |
|---|---|---|
| Todos | `-SkipWinget` | No instala ni actualiza paquetes del sistema |
| Perfil 3 | `-ProjectPath "C:\ruta\repo"` | Ejecuta `graphify hook install` en ese repositorio |

### Comportamiento

- **Idempotentes:** se pueden relanzar para actualizar. Las skills existentes se reemplazan por la versión nueva.
- **Fallos:** un paso que falla no detiene el resto. Al final se muestra una tabla OK / FALLO / OMITIDO.
- **Log:** queda en `%TEMP%\setup-perfil-N-FECHA.log`.
- **Skills prohibidas:** no se borran. Se mueven a `%USERPROFILE%\.claude\skills-cuarentena\FECHA`.

## Gobernanza de skills

- Solo el **Perfil 3** instala `find-skills`.
- Toda skill nueva pasa por **NVIDIA SkillSpector** (`skill-specter`) con una puntuación mínima de **85/100** antes de distribuirla al resto del equipo.

## Estado

- Los scripts están validados sintácticamente, pero todavía no se han ejecutado en una Surface real.
- Las rutas de las skills externas se resuelven buscando su carpeta dentro de cada repositorio. Si una no aparece, ese paso sale como FALLO con el motivo.
- El flujo de vídeo animado del Perfil 1 es el plugin `lemo-opuscar` ([lemomo-ai/lemo-opuscar](https://github.com/lemomo-ai/lemo-opuscar)). Se instala con `claude plugin`; si falla, se copia su skill. Necesita Node 20+, ffmpeg 7+ y Python 3.11+, que el script ya instala con winget. La biblioteca de estilos se descarga en `%USERPROFILE%\lemo-opuscar` al primer uso.
