# Guía del proyecto — Odoo 19 dev container (NextPro)

Contenedor de desarrollo de **Odoo 19.0**. Esta guía se carga en cada sesión: define el entorno, las
skills disponibles y cómo trabajar. **No re-preguntes el ambiente genérico** (ya está aquí).

## Entorno
- **Versión: Odoo 19.0.** Código fuente en `/workspace/odoo.19.0` (Community) y `/workspace/enterprise.19.0` (Enterprise).
- **Addons path**: `/workspace/enterprise.19.0,/workspace/odoo.19.0/addons,/workspace/custom-addons`.
- **Python (venv)**: `/workspace/.venv/bin/python`. Arrancar Odoo: `.venv/bin/python odoo.19.0/odoo-bin -c <conf>`.
- **Postgres**: contenedor `pgdb-19` (pgvector pg17); `db_user=odoo`, `db_password=odoo`. El módulo `ai` requiere extensión `vector`. Ver [[pgdb-19-pgvector]].
- **Instancias / configs** (cada `.conf` = BD + puerto; elegir según la tarea):
  | conf | BD | puerto |
  |---|---|---|
  | `odoo.conf` | (dbfilter libre) | 8069 |
  | `nextpro-operaciones.conf` | nextpro_operaciones | 8069 |
  | `nextpro-helpdesk-ai.conf` | nextpro_v19_test | 8072 |
  | `nextpro-v19-test.conf` | nextpro_v19_test | 8075 |
  | `nextpro-comercial-demo.conf` | nextpro_comercial_demo | 8069 |
  | `nextpro_whatsapp_ai.conf` | nextpro_whatsapp_ai | 8069 |
  | `molinorte-visit-flow.conf` | molinorte_29062026 | 8069 |
  | `sisegura-billing-flow.conf` | sisegusa_billing_flow_06072026 | 8069 |
- **BD de test v19**: credenciales de login guardadas en la memoria del contenedor (`[[nextpro-v19-test-db]]`), no versionadas aquí.

## Skills (se auto-sugieren por su descripción; invocables con `/<nombre>`)
- **`odoo-task-intake`** — arranque de una tarea nueva (cuando pegas contexto/loom o el preámbulo típico): confirma instancia si falta, alcance, rama (pregunta cada vez), tests + validación local, commit propuesto, y solo SUGIERE PR/merge/push.
- **`odoo-web-validation`** — validar UI/estilos/flujos: navegar el Odoo vivo con Playwright MCP, screenshots, overflow/solape, tests Hoot (v17-19)/QUnit (≤16). Ver [[hoot-tests-odoo19]].
- **`nextconnector`** — el Next Conector (Odoo↔SAP B1, módulos `nextconnector_*`).
- **`aprendizaje-continuo`** — al cerrar sesión, PROPONER (preguntando) guardar aprendizajes.
- **`registrar-soporte`** — documentar tickets de soporte (bajo `soporte-arq-kb/`).

## Base de conocimiento (patrones Odoo 19 — ábrela cuando apliques)
En `/workspace/.claude/knowledge/*.md` (cheat-sheets de referencia, no son skills). **Consúltalas antes de reinventar código:**
- Por versión v19: `odoo-version-knowledge-19.md` (cambios de versión, `<list>` vs `<tree>`…), `odoo-model-patterns-19.md` (ORM), `odoo-owl-components-19.md` (OWL 3.x), `odoo-module-generator-19.md`.
- Genéricos: `computed-field-patterns.md`, `domain-filter-patterns.md`, `inheritance-patterns.md`, `mail-notification-patterns.md`, `report-patterns.md` (QWeb PDF), `wizard-patterns.md`, `workflow-state-patterns.md`, `xmlrpc-query-patterns.md`.

## Cómo trabajar (lineamientos)
- **Reutiliza** módulos/herencia nativos de Odoo y el código fuente antes de escribir de cero.
- **Bump del manifest** (`version`) al tocar un módulo.
- **Tests + validación local** antes de dar por hecha una tarea: crea tests (backend + Hoot/QUnit si es frontend), aplica `-i`/`-u` en la instancia objetivo, valida (tests verdes + `odoo-web-validation` para lo visual). Flujo **data demo → data real**.
- **Commits**: número de tarea al inicio `[NNNNN] descripción`, **sin `Co-Authored-By`**, sin footer "Generated with Claude Code"; español en repos de cliente, inglés en repos de producto. Ver [[commits-sin-coautor]].
- **Push/PR/merge**: por defecto **solo sugerir**. **Pedir autorización explícita antes de push** (dispara sync a producción); "ok al commit" ≠ "ok al push". Ver [[pedir-autorizacion-push]].
- **Ramas**: preguntar cada vez si crear rama nueva desde producción (`main`/`19.0` según repo) o trabajar en la actual.

## Aprendizaje continuo
Al cerrar una sesión con trabajo sustancial, revisa si hubo algún aprendizaje reutilizable (gotcha,
buena práctica, error recurrente) y **ofrece** guardarlo con la skill `aprendizaje-continuo`
(genérico → knowledge; por versión → `*-19.md`; componente → su skill; preferencia → memoria).
**Siempre preguntar antes de escribir.**

## Persistencia de datos
`/home/odoo/.claude` (conversaciones + memoria) es un volumen persistente. Antes de operaciones
destructivas (`down -v`, replicar a otra carpeta) corre `/workspace/backup-claude.sh` (snapshots no
destructivos). El hook `SessionEnd` ya lo corre automáticamente. Ver [[devcontainer-persistencia]].

## Memoria
Índice en `/home/odoo/.claude/projects/-workspace/memory/MEMORY.md`. Contiene preferencias de trabajo,
infraestructura y estado de proyectos/clientes (SISEGUSA, MOLINORTE, nextpro-operaciones, etc.).
