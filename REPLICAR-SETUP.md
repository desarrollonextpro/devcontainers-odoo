# Replicar este setup de Claude Code en otro contenedor Odoo (otra versión)

Este contenedor **Odoo 19** quedó configurado como plantilla con: validación web (Playwright MCP +
chromium), skills reales, base de conocimiento, `CLAUDE.md`, hooks (backup + aprendizaje) y respaldo
no destructivo de datos. Para reproducirlo en tus contenedores **v15/16/17/18**, abre Claude Code
**dentro de ese contenedor** y pega el prompt de abajo.

> Importante sobre datos: **cada contenedor mantiene su propio historial** de conversaciones en su
> propio volumen `claude-code-config`. NO se copian conversaciones entre versiones (son proyectos
> distintos). Lo que se replica es la **configuración**, no el historial.

---

## PROMPT PARA PEGAR (en el Claude Code del otro contenedor)

```
Toma como plantilla el setup de Claude Code del contenedor Odoo 19 (documentado abajo) y REPRODÚCELO
en ESTE contenedor, ADAPTÁNDOLO a la versión de Odoo que corre aquí. No asumas la versión: primero
detéctala. Pregúntame antes de cualquier acción hacia afuera (push/PR) o destructiva. Trabaja así:

FASE 0 — Detectar el entorno de ESTE contenedor (solo lectura) y reportármelo:
- Versión de Odoo: mira las carpetas de addons (p. ej. odoo.<v>.0 / enterprise.<v>.0) y odoo-bin.
- Config del devcontainer: .devcontainer/{Dockerfile,docker-compose.yml,devcontainer.json,post-create.sh}.
- Node instalado (node -v), si hay chromium (which chromium), y el prefijo/permiso de npm.
- Postgres: nombre del contenedor db (pgdb-<v> u otro), host/usuario.
- Las .conf disponibles (ls *.conf) con su db_name/http_port.
- Repos custom en custom-addons/*: para los repos del usuario (org desarrollonextpro), su remote,
  rama base (main o <v>.0), rama actual y formato de commit (git log). Excluye mirrors OCA/terceros.
- Si /home/<user>/.claude es un volumen (findmnt) o efímero.

FASE 1 — Datos primero (no perder historial):
- Copia backup-claude.sh y restore-claude.sh (versión NO destructiva: snapshots con timestamp en
  .claude-backups/ + espejo en modo merge SIN --delete). Corre backup-claude.sh una vez.
- Asegúrate de que devcontainer.json monte el volumen claude-code-config -> /home/<user>/.claude con
  CLAUDE_CONFIG_DIR. Si no lo tiene, propómelo (aplica en rebuild).

FASE 2 — Navegador para validación web:
- Si Node < 20: añade Node 20 (NodeSource) al Dockerfile (quita el npm de Debian si arrastra Node 18).
- Instala @playwright/mcp (npm -g) en el Dockerfile con PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD=1, y añade
  chromium + fonts-liberation si no están.
- Crea /workspace/.mcp.json con el server 'playwright' (--browser chromium --executable-path
  /usr/bin/chromium --headless --no-sandbox --isolated --output-dir /tmp/playwright-mcp).
- Añade el permiso mcp__playwright a .claude/settings.json.

FASE 3 — Skills (formato carpeta + SKILL.md + frontmatter name/description). Copia y ADAPTA:
- odoo-web-validation: IMPORTANTE por versión → Odoo 17-19 usa HOOT (bundle web.assets_unit_tests,
  tag WebSuite.test_unit_desktop[@módulo], toHaveStyle). Odoo <=16 usa QUNIT (bundle
  web.qunit_suite_tests / web.tests, helpers web.test_utils, sin Hoot): reescribe la sección de tests
  para QUnit en esos contenedores. La URL de login es /odoo (v17+) o /web (v16 y anteriores).
- odoo-task-intake: mismo flujo, con la versión y las .conf de ESTE contenedor.
- aprendizaje-continuo: igual (rutas /workspace/.claude/knowledge y skills de ESTE repo).
- Skills de componente: crea una por cada producto "Next" presente aquí (nextconnector, next_flow_ai,
  next_flow_whatsapp, next_billing_flow, next-visit-flow, nextpro_meta_portal…) SEGÚN su versión en
  este contenedor (serie <v>.0.x). Si no está el código, no crees la skill.

FASE 4 — CLAUDE.md (slim, siempre cargado): entorno de ESTA versión (addons paths <v>.0, pgdb-<v>,
tabla de .conf con puertos/BD reales, venv), índice de skills, índice de la base de conocimiento
(mueve los cheat-sheets .md a /workspace/.claude/knowledge/ si están sueltos en skills/), lineamientos
de trabajo y la convención de aprendizaje continuo.

FASE 5 — Base de conocimiento: adapta los cheat-sheets a la versión (los *-19.md → *-<v>.md con las
diferencias reales de esa versión: en v16 <tree> en vez de <list>, OWL 2 vs 3, API cambiada, etc.).
No copies ciegamente el contenido v19.

FASE 6 — Hooks (.claude/settings.json + .claude/hooks/): SessionEnd → backup-claude.sh; PostToolUse
(Edit|Write) → mark-edit.sh; Stop → suggest-learning.py (recordatorio único gated). Prueba los hooks
simulando su stdin antes de darlos por buenos.

FASE 7 — Flujo git (para odoo-task-intake), respetando MIS preferencias:
- Commit: número de tarea al inicio [NNNNN], SIN Co-Authored-By, sin footer; español en repos de
  cliente, inglés en repos de producto; respeta el estilo nativo del repo.
- Ramas: PREGUNTAR cada vez (rama nueva desde producción main/<v>.0, o rama actual).
- PR/merge/push: SOLO SUGERIR; ejecutar solo si lo pido y tras probar. Pedir autorización explícita
  antes de push (dispara sync a producción).

FASE 8 — Verifica lo que puedas en vivo (chromium headless, JSON de configs, hooks, skills en el
listado) y dime QUÉ requiere rebuild + recargar Claude Code para activarse. Al final, resúmeme los
cambios y avísame si hay secretos en .env que deba rotar.

Antes de tocar archivos, muéstrame tu plan de adaptación por versión y espera mi OK.
```

---

## Tabla de equivalencias por versión (para adaptar tokens)

| Elemento | v19 (esta plantilla) | Adaptar a `<v>` |
|---|---|---|
| Addons core / enterprise | `odoo.19.0`, `enterprise.19.0` | `odoo.<v>.0`, `enterprise.<v>.0` |
| Contenedor Postgres | `pgdb-19` | `pgdb-<v>` (según docker-compose) |
| Serie de versión de módulos | `19.0.1.x` | `<v>.0.x` |
| Tests de frontend | **Hoot** (v17-19) | **QUnit** en **v16 y anteriores** |
| URL de login | `/odoo` (v17+) | `/web` en v16 y anteriores |
| OWL | OWL 3.x (v17+) | OWL 2.x / widgets legacy en v16 |
| Puertos / BD | ver tabla en `CLAUDE.md` | los reales de ese contenedor |

## Notas
- **Node 20** es el requisito duro de `@playwright/mcp`; sin él el navegador MCP no arranca.
- **Historial por contenedor**: si quisieras *sembrar* un contenedor nuevo con datos de otro (no
  recomendado entre versiones), copia el volumen: `docker run --rm -v <vol_origen>:/from -v
  <vol_destino>:/to alpine cp -a /from/. /to/`. Normalmente NO lo querrás: cada versión su historial.
- **Seguridad**: revisa que `.devcontainer/.env` no tenga secretos reales versionados (tokens de
  GitHub/Cloudflare). Rótalos si estuvieron expuestos y usa `.env.example` como plantilla.
