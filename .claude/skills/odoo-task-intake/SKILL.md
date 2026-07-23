---
name: odoo-task-intake
description: >-
  Arranque de una tarea nueva de Odoo. Úsala cuando el usuario pega el contexto de una tarea
  (texto, capturas y/o transcripción de loom) al iniciar el trabajo, o dice frases como "ayúdame a
  desarrollar la siguiente tarea", "desarrolla la tarea", "commit con el número de tarea sin coautor",
  "la tarea debe desarrollarse en la versión de Odoo compatible", "tienes acceso al código fuente de
  odoo". Estructura el trabajo: confirma instancia si falta, define alcance, gestiona rama, exige
  tests + validación local, propone el commit, y solo SUGIERE PR/merge/push.
---

# Arranque de tarea de Odoo

Convierte el preámbulo repetitivo del usuario en un flujo estándar. **El ambiente genérico NO se
re-pregunta** (versión de Odoo, addons paths, código fuente — ya están en `CLAUDE.md` y la memoria).

## Paso 0 — Reconocer la tarea
Cuando el mensaje traiga contexto de tarea (texto/capturas/loom) y/o el preámbulo típico, asume que
el objetivo es **analizar y desarrollar una tarea de Odoo** en la versión de este contenedor (aquí
**17.0**), reutilizando el código fuente y los módulos nativos.

## Paso 1 — Instancia/config objetivo (preguntar SOLO si no se indicó)
El ambiente genérico no se pregunta. Pero **sí** hay que saber **sobre qué instancia** se trabaja,
porque hay varias `.conf` (cada una = BD + addons + puerto).
- Si el usuario **ya dio** la ruta del `.conf` o el nombre de la instancia/BD → úsala, no preguntes.
- Si **no** lo dio → **pregunta** cuál usar, ofreciendo las disponibles:
  ```bash
  ls /workspace/*.conf
  ```
  (p. ej. `odoo.conf`, `odoo-nextpro_operaciones.conf`). Confirma también el **repo/módulo**
  objetivo en `/workspace/custom-addons/` (aquí: `nextpro_operaciones/nextpro`).

## Paso 2 — Alcance
Si del contexto pegado no queda claro **qué** hay que lograr (bug, feature, ajuste visual…), pregunta
el objetivo y el criterio de "listo". Si hay número de tarea, anótalo (irá en el commit).

## Paso 3 — Rama (PREGUNTAR CADA VEZ)
No hay default fijo. Detecta el estado del repo objetivo:
```bash
git -C <repo> rev-parse --abbrev-ref HEAD          # rama actual
git -C <repo> branch -a                            # ramas; base = main/staging/17.0 (excluye mirrors OCA)
```
Luego **pregunta** al usuario, mostrando lo detectado:
- **(a) Crear rama nueva desde producción**: `git -C <repo> fetch` y crear `feat/<tarea>-<slug>` (o
  `fix/<tarea>-<slug>`, `release/<tarea>-<slug>`) **desde la rama base/producción** del repo (p. ej.
  `staging-02` en `nextpro`, o `17.0`/`main` según el repo), o
- **(b) Trabajar en la rama actual** (como suele hacerse: "realiza el cambio en el repositorio actual").

Crea la rama solo tras el OK. Convención de nombres vista en los repos: `feat/`, `fix/`,
`hotfix/<tarea>-<slug>`, `release/<tarea>-<slug>`.

## Paso 4 — Desarrollo + validación LOCAL (obligatorio antes de proponer commit)
a. **Implementa** reutilizando módulos nativos de Odoo y el código fuente en `/workspace/odoo.17.0`
   y `/workspace/enterprise.17.0`. **Bump del manifest** (`version`) del módulo tocado.
b. **Crea tests unitarios**:
   - Backend: `TransactionCase`/`HttpCase` con los tags del módulo.
   - Frontend/OWL (si aplica): **Hoot o QUnit** según tu fuente 17.0 (ver skill `odoo-web-validation`,
     que explica cómo detectar cuál corre y cómo escribir el test).
c. **Aplica localmente** en la instancia/BD del Paso 1: `-i`/`-u` del módulo (BD aislada si aplica).
d. **Valida localmente**: tests en verde; y si el cambio es web/vistas/estilos, usa la skill
   **`odoo-web-validation`** (navegar el Odoo vivo, screenshot, chequeo de overflow/solape).
e. Flujo **data demo → data real**: probar primero con copia demo; recién con el OK, data real.

No des la tarea por terminada sin (b)+(c)+(d). Si algo no se pudo probar, dilo explícitamente.

## Paso 5 — Commit (PROPONER el mensaje; no auto-commitear sin OK)
Presenta una **propuesta de mensaje de commit corto**:
- **Empieza por el número de tarea**: `[NNNNN] descripción corta` (o `NNNNN: descripción`).
- **Sin `Co-Authored-By`** y **sin** footer "Generated with Claude Code". Ver [[commits-sin-coautor]].
- **Idioma**: español en repos de cliente (nextpro/nextpro_operaciones). Respeta el estilo nativo del
  repo (algunos usan Conventional Commits `feat(scope):`).
- Si **aún no hay número**: usa el estilo nativo del repo y, cuando llegue el número, `git commit
  --amend` para anteponer `[nº]` (siempre que **no** esté pusheado).

Haz el `git commit` cuando el usuario lo apruebe.

## Paso 6 — PR / merge / push (SOLO SUGERIR)
Por defecto **no** ejecutar acciones hacia afuera. Tras el commit:
- **Sugiere** el PR y el merge: rama origen → base, título/descr. propuestos, y el comando/URL para
  abrirlo. Deja que el usuario haga el PR y el merge.
- **No hagas** PR, merge ni `git push` hasta que el usuario lo **autorice explícitamente y tras haber
  probado**. Un "ok al commit" **no** es "ok al push". Ver [[pedir-autorizacion-push]].
- Si el usuario pide que Claude haga el PR/merge/push, hazlo solo tras confirmar que ya probó.

## Cierre
Al terminar, considera ofrecer `/aprendizaje-continuo` si surgió algún aprendizaje reutilizable.
