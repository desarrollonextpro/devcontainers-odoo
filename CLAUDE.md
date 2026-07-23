# Guía del proyecto — Odoo 18 dev container (NextPro)

Contenedor de desarrollo de **Odoo 18.0**. Esta guía se carga en cada sesión: define el entorno, las
skills disponibles y cómo trabajar. **No re-preguntes el ambiente genérico** (ya está aquí).

## Entorno
- **Versión: Odoo 18.0.** Código fuente en `/workspace/odoo.18.0` (Community) y `/workspace/enterprise.18.0` (Enterprise).
- **Addons path**: base `/workspace/enterprise.18.0,/workspace/odoo.18.0/addons,/workspace/custom-addons/<cliente>`. Cada `.conf` de cliente arma su propio `addons_path` (p. ej. `odoo-uysa.conf` apunta a `custom-addons/uysa/pe-uysa`, `.../uysa/nextconnector`, etc.).
- **Python (venv)**: `/workspace/.venv/bin/python`. Arrancar Odoo: `.venv/bin/python odoo.18.0/odoo-bin -c <conf>`.
- **Postgres**: contenedor `pgdb-18` (`postgres:17.0-alpine`); `db_user=odoo`, `db_password=odoo`. (Sin pgvector.)
- **Puertos**: Odoo escucha internamente en `8069`; el host publica `18069` (docker-compose). Dentro del contenedor usa siempre `localhost:8069`.
- **Instancias / configs** (cada `.conf` = BD + addons + puerto; elegir según la tarea):
  | conf | BD | puerto (interno) |
  |---|---|---|
  | `odoo.conf` | (dbfilter libre) | 8069 |
  | `odoo-uysa.conf` | uysa_09072026 | 8069 |
  | `odoo-atika.conf` | atika_ea_test | 8069 |
  | `odoo-proriego.conf` | proriego_16052026 | 8069 |
  | `odoo-andes.conf` | (libre) | 8069 |
  | `odoo-icon-supply.conf` | (libre) | 8069 |
  | `odoo-evi-dji.conf` | (libre) | 8069 |
  | `odoo-sisegusa.conf` | (libre) | 8069 |

## Skills (se auto-sugieren por su descripción; invocables con `/<nombre>`)
- **`odoo-task-intake`** — arranque de una tarea nueva (cuando pegas contexto/loom o el preámbulo típico): confirma instancia si falta, alcance, rama (pregunta cada vez), tests + validación local, commit propuesto, y solo SUGIERE PR/merge/push.
- **`odoo-web-validation`** — validar UI/estilos/flujos: navegar el Odoo vivo con Playwright MCP, screenshots, overflow/solape, tests **Hoot** (Odoo 18).
- **`nextconnector`** — el Next Conector (Odoo↔SAP B1, módulos `nextconnector_*`, rama `18.0`; clonado bajo varios clientes de `custom-addons/`).
- **`aprendizaje-continuo`** — al cerrar sesión, PROPONER (preguntando) guardar aprendizajes.

## Base de conocimiento (patrones Odoo 18 — ábrela cuando apliques)
En `/workspace/.claude/knowledge/*.md` (cheat-sheets de referencia, no son skills). **Consúltalas antes de reinventar código:**
- Por versión v18: `odoo-version-knowledge-18.md`, `odoo-model-patterns-18.md` (ORM), `odoo-owl-components-18.md` (OWL 2.x), `odoo-module-generator-18.md`.
- Genéricos: `computed-field-patterns.md`, `domain-filter-patterns.md`, `inheritance-patterns.md`, `mail-notification-patterns.md`, `report-patterns.md` (QWeb PDF), `wizard-patterns.md`, `workflow-state-patterns.md`, `xmlrpc-query-patterns.md`.

## Particularidades de la versión (Odoo 18)
- **URL del cliente web: `/odoo`.** **Tests de frontend: Hoot** (bundle `web.assets_unit_tests`, imports `@odoo/hoot*`). **Vistas de lista con `<list>`** (no `<tree>`). **OWL 2.x**.
- **Repos de cliente** en `custom-addons/`: `uysa/pe-uysa` (rama `staging-10072026`), `andes/pe-andesnutrition` (`staging-02`), `atika` (rama de feature), `design-themes` (`18.0`). El módulo **`nextconnector`** (repo `desarrollonextpro/nextconnector`, rama `18.0`) está clonado bajo `andes`, `evi-dji`, `icon-supply`, `proriego` y `uysa`.

## Cómo trabajar (lineamientos)
- **Reutiliza** módulos/herencia nativos de Odoo y el código fuente antes de escribir de cero.
- **Bump del manifest** (`version`) al tocar un módulo.
- **Tests + validación local** antes de dar por hecha una tarea: crea tests (backend + Hoot si es frontend), aplica `-i`/`-u` en la instancia objetivo, valida (tests verdes + `odoo-web-validation` para lo visual). Flujo **data demo → data real**.
- **Commits**: número de tarea al inicio `[NNNNN] descripción`, **sin `Co-Authored-By`**, sin footer "Generated with Claude Code"; español en repos de cliente. Ver [[commits-sin-coautor]].
- **Push/PR/merge**: por defecto **solo sugerir**. **Pedir autorización explícita antes de push**; "ok al commit" ≠ "ok al push". Ver [[pedir-autorizacion-push]].
- **Ramas**: preguntar cada vez si crear rama nueva desde producción (`main`/`staging`/`18.0` según repo) o trabajar en la actual.

## Aprendizaje continuo
Al cerrar una sesión con trabajo sustancial, revisa si hubo algún aprendizaje reutilizable (gotcha,
buena práctica, error recurrente) y **ofrece** guardarlo con la skill `aprendizaje-continuo`
(genérico → knowledge; por versión → `*-18.md`; componente → su skill; preferencia → memoria).
**Siempre preguntar antes de escribir.**

## Persistencia de datos
`/home/odoo/.claude` (conversaciones + memoria) es un volumen persistente. Antes de operaciones
destructivas (`down -v`, replicar a otra carpeta) corre `/workspace/backup-claude.sh` (snapshots no
destructivos). El hook `SessionEnd` ya lo corre automáticamente.

## Memoria
Índice en `/home/odoo/.claude/projects/-workspace/memory/MEMORY.md`. Contiene preferencias de trabajo,
infraestructura y estado de proyectos/clientes de este contenedor.
