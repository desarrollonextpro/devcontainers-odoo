# Guía del proyecto — Odoo 16 dev container (NextPro)

Contenedor de desarrollo de **Odoo 16.0**. Esta guía se carga en cada sesión: define el entorno, las
skills disponibles y cómo trabajar. **No re-preguntes el ambiente genérico** (ya está aquí).

## Entorno
- **Versión: Odoo 16.0.** Código fuente en `/workspace/odoo.16.0` (Community) y `/workspace/enterprise.16.0` (Enterprise).
- **Addons path**: `/workspace/enterprise.16.0,/workspace/odoo.16.0/addons,/workspace/custom-addons`.
- **Python (venv)**: `/workspace/.venv/bin/python`. Arrancar Odoo: `.venv/bin/python odoo.16.0/odoo-bin -c <conf>`.
- **Postgres**: contenedor `pgdb-16` (`postgres:15.0-alpine`); `db_user=odoo`, `db_password=odoo`. (Sin pgvector; el RAG de IA es de Odoo 17+/19.)
- **Puertos**: Odoo escucha internamente en `8069`; el host publica `7069` (docker-compose). Dentro del contenedor usa siempre `localhost:8069`.
- **Instancias / configs** (cada `.conf` = BD + puerto; elegir según la tarea):
  | conf | BD | puerto (interno) |
  |---|---|---|
  | `odoo.conf` | (dbfilter libre) | 8069 |
  | `odoo-sego.conf` | sego_26052026 | 8069 |
  | `odoo-ec-marriott.conf` | (list_db libre) | 8069 |

## Skills (se auto-sugieren por su descripción; invocables con `/<nombre>`)
- **`odoo-task-intake`** — arranque de una tarea nueva (cuando pegas contexto/loom o el preámbulo típico): confirma instancia si falta, alcance, rama (pregunta cada vez), tests + validación local, commit propuesto, y solo SUGIERE PR/merge/push.
- **`odoo-web-validation`** — validar UI/estilos/flujos: navegar el Odoo vivo con Playwright MCP, screenshots, overflow/solape, tests **QUnit** (Odoo 16 no tiene Hoot).
- **`aprendizaje-continuo`** — al cerrar sesión, PROPONER (preguntando) guardar aprendizajes.

## Base de conocimiento (patrones Odoo 16 — ábrela cuando apliques)
En `/workspace/.claude/knowledge/*.md` (cheat-sheets de referencia, no son skills). **Consúltalas antes de reinventar código:**
- Por versión v16: `odoo-version-knowledge-16.md` (cambios de versión, `<tree>`…), `odoo-model-patterns-16.md` (ORM), `odoo-owl-components-16.md` (OWL 2.x), `odoo-module-generator-16.md`.
- Genéricos: `computed-field-patterns.md`, `domain-filter-patterns.md`, `inheritance-patterns.md`, `mail-notification-patterns.md`, `report-patterns.md` (QWeb PDF), `wizard-patterns.md`, `workflow-state-patterns.md`, `xmlrpc-query-patterns.md`.

## Particularidades de la versión (Odoo 16)
- **URL del cliente web: `/web`** (en v17+ es `/odoo`).
- **Tests de frontend: QUnit** (bundle `web.qunit_suite_tests`, helpers `web.test_utils`). Hoot llega en v17+.
- **Vistas de lista con `<tree>`** (en v17+ se renombran a `<list>`). **OWL 2.x**.
- **Repos de cliente** en `custom-addons/`: `sego` (rama `staging`) y `ec-b2b-marriott`. Ambos **embeben un módulo `nextconnector`** (no es el repo standalone del conector; es parte del repo de cada cliente).

## Cómo trabajar (lineamientos)
- **Reutiliza** módulos/herencia nativos de Odoo y el código fuente antes de escribir de cero.
- **Bump del manifest** (`version`) al tocar un módulo.
- **Tests + validación local** antes de dar por hecha una tarea: crea tests (backend + QUnit si es frontend), aplica `-i`/`-u` en la instancia objetivo, valida (tests verdes + `odoo-web-validation` para lo visual). Flujo **data demo → data real**.
- **Commits**: número de tarea al inicio `[NNNNN] descripción`, **sin `Co-Authored-By`**, sin footer "Generated with Claude Code"; español en repos de cliente. Ver [[commits-sin-coautor]].
- **Push/PR/merge**: por defecto **solo sugerir**. **Pedir autorización explícita antes de push**; "ok al commit" ≠ "ok al push". Ver [[pedir-autorizacion-push]].
- **Ramas**: preguntar cada vez si crear rama nueva desde producción (`main`/`staging`/`16.0` según repo) o trabajar en la actual.

## Aprendizaje continuo
Al cerrar una sesión con trabajo sustancial, revisa si hubo algún aprendizaje reutilizable (gotcha,
buena práctica, error recurrente) y **ofrece** guardarlo con la skill `aprendizaje-continuo`
(genérico → knowledge; por versión → `*-16.md`; componente → su skill; preferencia → memoria).
**Siempre preguntar antes de escribir.**

## Persistencia de datos
`/home/odoo/.claude` (conversaciones + memoria) es un volumen persistente. Antes de operaciones
destructivas (`down -v`, replicar a otra carpeta) corre `/workspace/backup-claude.sh` (snapshots no
destructivos). El hook `SessionEnd` ya lo corre automáticamente.

## Memoria
Índice en `/home/odoo/.claude/projects/-workspace/memory/MEMORY.md`. Contiene preferencias de trabajo,
infraestructura y estado de proyectos/clientes de este contenedor.
