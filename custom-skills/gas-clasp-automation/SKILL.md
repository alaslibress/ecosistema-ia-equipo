---
name: gas-clasp-automation
description: Desarrollo profesional de Google Apps Script (GAS) en local con TypeScript, clasp y @types/google-apps-script. Usar siempre que se hable de Apps Script, GAS, clasp, clasp push, Google Sheets, SpreadsheetApp, hojas de cálculo de Google, Drive, Gmail, Calendar, Forms, triggers, disparadores, macros de Google, automatizaciones de Google Workspace, cuotas, "Exceeded maximum execution time", límite de 6 minutos, getValues, setValues o PropertiesService.
---

# GAS + clasp: automatización segura y rápida

Objetivo: código GAS versionado en local, tipado, desplegado con `clasp push`, que nunca agota cuotas ni choca con el límite de 6 minutos.

## Always
- Trabaja en local: `src/*.ts` + `appsscript.json` + `.clasp.json` (con `"rootDir": "src"`). Nunca edites en el editor web.
- Usa TypeScript con `@types/google-apps-script` (`npm i -D @types/google-apps-script typescript`).
- Despliega con `clasp push` (y `clasp push --watch` mientras desarrollas). Versión estable: `clasp version "mensaje"` + `clasp deploy`.
- Lee y escribe por lotes: una llamada `getValues()` por rango y una `setValues()` con la matriz completa.
- Procesa en memoria (arrays) y escribe una sola vez al final.
- En procesos largos: guarda el progreso en `PropertiesService` y crea un trigger de continuación antes de los 5 minutos.
- Usa `LockService` si el script puede ejecutarse dos veces a la vez.
- Registra con `console.log` / `console.error` (visible en `clasp logs` y en Ejecuciones).

## Ask First
- Antes de `clasp deploy` sobre un despliegue en producción (web app o complemento usado por otros).
- Antes de cambiar `oauthScopes` en `appsscript.json` (los usuarios deberán reautorizar).
- Antes de borrar triggers que no ha creado este script.
- Antes de escribir sobre hojas con datos reales sin copia previa.

## Never
- Nunca llames a `getValue()`, `setValue()`, `getRange()` o `appendRow()` dentro de un bucle.
- Nunca uses `SpreadsheetApp.flush()` dentro de un bucle.
- Nunca guardes credenciales en el código: usa `PropertiesService.getScriptProperties()`.
- Nunca dejes triggers de continuación huérfanos al terminar el proceso.
- Nunca subas `.clasprc.json` (credenciales de clasp) al repositorio.

## Flujo paso a paso
1. **Preparar proyecto**
   ```powershell
   clasp login
   mkdir mi-gas; cd mi-gas
   clasp create --type sheets --title "Mi automatización" --rootDir src
   npm init -y
   npm i -D typescript @types/google-apps-script
   ```
2. **tsconfig.json** mínimo:
   ```json
   {
     "compilerOptions": {
       "target": "ES2019",
       "lib": ["ES2019"],
       "types": ["google-apps-script"],
       "strict": true,
       "noEmit": true
     },
     "include": ["src/**/*.ts"]
   }
   ```
   `clasp` (v2) transpila `.ts` al hacer push. Valida antes con `npx tsc`.
3. **Escribir el código** en `src/` siguiendo los patrones de abajo.
4. **Validar**: `npx tsc` sin errores.
5. **Desplegar**: `clasp push`. Probar con `clasp run nombreFuncion` o desde el editor.
6. **Revisar logs**: `clasp logs` o panel Ejecuciones.
7. **Commit** en git (con `.clasp.json`, sin `.clasprc.json`).

## Patrón 1: lectura y escritura por lotes
```ts
function normalizarEmails(): void {
  const sheet = SpreadsheetApp.getActive().getSheetByName('Clientes');
  if (!sheet) throw new Error('Falta la hoja Clientes');
  const lastRow = sheet.getLastRow();
  if (lastRow < 2) return;
  const range = sheet.getRange(2, 1, lastRow - 1, 3);
  const data = range.getValues();               // 1 lectura
  const out = data.map(([nombre, email, alta]) => [
    String(nombre).trim(),
    String(email).trim().toLowerCase(),
    alta,
  ]);
  range.setValues(out);                         // 1 escritura
}
```

## Patrón 2: límite de 6 minutos con trigger de continuación
```ts
const MAX_MS = 4.5 * 60 * 1000;
const KEY = 'procesarFilas_cursor';
const BATCH = 500;

function procesarFilas(): void {
  const lock = LockService.getScriptLock();
  if (!lock.tryLock(10000)) return;
  try {
    const start = Date.now();
    const props = PropertiesService.getScriptProperties();
    let cursor = Number(props.getProperty(KEY) ?? '2');
    const sheet = SpreadsheetApp.getActive().getSheetByName('Datos')!;
    const lastRow = sheet.getLastRow();

    while (cursor <= lastRow) {
      if (Date.now() - start > MAX_MS) {
        props.setProperty(KEY, String(cursor));
        programarContinuacion('procesarFilas');
        return;
      }
      const n = Math.min(BATCH, lastRow - cursor + 1);
      const range = sheet.getRange(cursor, 1, n, 4);
      const rows = range.getValues();
      range.setValues(rows.map(transformarFila));
      cursor += n;
    }
    props.deleteProperty(KEY);
    limpiarTriggers('procesarFilas');
    console.log('Proceso completado');
  } finally {
    lock.releaseLock();
  }
}

function transformarFila(row: unknown[]): unknown[] {
  const [id, importe, iva] = row as [string, number, number];
  return [id, importe, iva, Math.round(Number(importe) * (1 + Number(iva)) * 100) / 100];
}

function programarContinuacion(fn: string): void {
  limpiarTriggers(fn);
  ScriptApp.newTrigger(fn).timeBased().after(60 * 1000).create();
}

function limpiarTriggers(fn: string): void {
  ScriptApp.getProjectTriggers()
    .filter(t => t.getHandlerFunction() === fn)
    .forEach(t => ScriptApp.deleteTrigger(t));
}
```

## Checklist antes de entregar
| Comprobación | Estado |
|---|---|
| `npx tsc` sin errores | ✅/❌ |
| Cero llamadas a servicios de Google dentro de bucles | ✅/❌ |
| Procesos >4 min con cursor en `PropertiesService` + trigger | ✅/❌ |
| Triggers de continuación se borran al terminar | ✅/❌ |
| Secretos en Script Properties, no en código | ✅/❌ |
| `clasp push` hecho y probado | ✅/❌ |
