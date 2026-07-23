# Guía del proyecto — Odoo 17 dev container (NextPro)

Contenedor de desarrollo de **Odoo 17.0**. Esta guía se carga en cada sesión: define el entorno, las
skills disponibles y cómo trabajar. **No re-preguntes el ambiente genérico** (ya está aquí).

## Entorno
- **Versión: Odoo 17.0.** Código fuente en `/workspace/odoo.17.0` (Community) y `/workspace/enterprise.17.0` (Enterprise).
- **Addons path**: `/workspace/enterprise.17.0,/workspace/odoo.17.0/addons,/workspace/custom-addons`.
- **Python (venv)**: `/workspace/.venv/bin/python`. Arrancar Odoo: `.venv/bin/python odoo.17.0/odoo-bin -c <conf>`.
- **Postgres**: contenedor `pgdb-17` (`postgres:16.0-alpine`); `db_user=odoo`, `db_password=odoo`. (Sin pgvector.)
- **Puertos**: Odoo escucha internamente en `8069`; el host publica `7569` (docker-compose). Dentro del contenedor usa siempre `localhost:8069`.
- **Instancias / configs** (cada `.conf` = BD + puerto; elegir según la tarea):
  | conf | BD | puerto (interno) |
  |---|---|---|
  | `odoo.conf` | (dbfilter libre) | 8069 |
  | `odoo-nextpro_operaciones.conf` | nextpro_operaciones (dbfilter comentado) | 8069 |

## Skills (se auto-sugieren por su descripción; invocables con `/<nombre>`)
- **`odoo-task-intake`** — arranque de una tarea nueva (cuando pegas contexto/loom o el preámbulo típico): confirma instancia si falta, alcance, rama (pregunta cada vez), tests + validación local, commit propuesto, y solo SUGIERE PR/merge/push.
- **`odoo-web-validation`** — validar UI/estilos/flujos: navegar el Odoo vivo con Playwright MCP, screenshots, overflow/solape, tests **Hoot o QUnit** (la skill explica cómo detectar cuál usa tu fuente 17.0).
- **`aprendizaje-continuo`** — al cerrar sesión, PROPONER (preguntando) guardar aprendizajes.

## Base de conocimiento (patrones Odoo 17 — ábrela cuando apliques)
En `/workspace/.claude/knowledge/*.md` (cheat-sheets de referencia, no son skills). **Consúltalas antes de reinventar código:**
- Por versión v17: `odoo-version-knowledge-17.md`, `odoo-model-patterns-17.md` (ORM), `odoo-owl-components-17.md` (OWL 2.x), `odoo-module-generator-17.md`.
- Genéricos: `computed-field-patterns.md`, `domain-filter-patterns.md`, `inheritance-patterns.md`, `mail-notification-patterns.md`, `report-patterns.md` (QWeb PDF), `wizard-patterns.md`, `workflow-state-patterns.md`, `xmlrpc-query-patterns.md`.

## Particularidades de la versión (Odoo 17)
- ⚠️ **17.0 está a caballo entre generaciones.** El release actual de la serie 17.0 usa **Hoot** + URL `/odoo` + `<list>`; algunos **snapshots tempranos** de 17.0 aún usan **QUnit** + `/web` + `<tree>`. **Detecta cuál corre tu fuente** (`ls odoo.17.0/addons/web/static/lib/hoot`; probar `/odoo` vs `/web`). La skill `odoo-web-validation` lo detalla. **OWL 2.x**.
- **Repos de cliente** en `custom-addons/nextpro_operaciones/`: `nextpro` (repo `desarrollonextpro/nextpro`, rama `staging-02`) y `odoomates` (terceros / OCA-like; no es producto NextPro).

## Cómo trabajar (lineamientos)
- **Reutiliza** módulos/herencia nativos de Odoo y el código fuente antes de escribir de cero.
- **Bump del manifest** (`version`) al tocar un módulo.
- **Tests + validación local** antes de dar por hecha una tarea: crea tests (backend + Hoot/QUnit si es frontend), aplica `-i`/`-u` en la instancia objetivo, valida (tests verdes + `odoo-web-validation` para lo visual). Flujo **data demo → data real**.
- **Commits**: número de tarea al inicio `[NNNNN] descripción`, **sin `Co-Authored-By`**, sin footer "Generated with Claude Code"; español en repos de cliente. Ver [[commits-sin-coautor]].
- **Push/PR/merge**: por defecto **solo sugerir**. **Pedir autorización explícita antes de push**; "ok al commit" ≠ "ok al push". Ver [[pedir-autorizacion-push]].
- **Ramas**: preguntar cada vez si crear rama nueva desde producción (`main`/`staging`/`17.0` según repo) o trabajar en la actual.

## Aprendizaje continuo
Al cerrar una sesión con trabajo sustancial, revisa si hubo algún aprendizaje reutilizable (gotcha,
buena práctica, error recurrente) y **ofrece** guardarlo con la skill `aprendizaje-continuo`
(genérico → knowledge; por versión → `*-17.md`; componente → su skill; preferencia → memoria).
**Siempre preguntar antes de escribir.**

## Persistencia de datos
`/home/odoo/.claude` (conversaciones + memoria) es un volumen persistente. Antes de operaciones
destructivas (`down -v`, replicar a otra carpeta) corre `/workspace/backup-claude.sh` (snapshots no
destructivos). El hook `SessionEnd` ya lo corre automáticamente.

## Memoria
Índice en `/home/odoo/.claude/projects/-workspace/memory/MEMORY.md`. Contiene preferencias de trabajo,
infraestructura y estado de proyectos/clientes de este contenedor.
