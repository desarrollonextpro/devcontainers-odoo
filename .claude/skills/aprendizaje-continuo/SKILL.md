---
name: aprendizaje-continuo
description: >-
  Al terminar una sesión con trabajo sustancial (o cuando el usuario lo pida: "captura aprendizajes",
  "qué aprendimos", "/aprendizaje-continuo"), revisa qué se aprendió y PROPONE —preguntando SIEMPRE,
  nunca de forma autónoma— guardarlo en el sitio correcto: buenas prácticas genéricas de Odoo,
  conocimiento por versión, skill de un componente, o memoria. Sirve para no repetir errores
  recurrentes (estilos, vistas, desarrollo, colas, buenas prácticas) entre sesiones.
---

# Aprendizaje continuo (capturar conocimiento reutilizable)

Objetivo: que cada sesión deje el sistema un poco mejor documentado, **sin escribir nada sin tu OK**.

## Cuándo se activa
- Al cerrar una sesión con ediciones (el hook `Stop` gated puede recordártelo una vez), o
- Cuando el usuario lo invoca explícitamente (`/aprendizaje-continuo`, "captura aprendizajes").

## Proceso
1. **Reflexiona** sobre la sesión y responde: ¿hubo algún aprendizaje reutilizable, un error recurrente
   que evitar, un gotcha de Odoo, una decisión o convención nueva? Si NO hay nada que valga, dilo en una
   línea y termina — no inventes aprendizajes triviales.
2. **Clasifica** cada aprendizaje y decide su destino con esta tabla de routing:

   | Tipo de aprendizaje | Dónde va |
   |---|---|
   | Buena práctica **genérica de Odoo** (aplica a todo proyecto/versión: estilos, vistas, ORM, colas/queue_job, seguridad, performance) | Base de conocimiento: crea o actualiza un `.md` en `/workspace/.claude/knowledge/` (p. ej. los cheat-sheets existentes) |
   | Conocimiento **específico de una versión** de Odoo (API, QUnit vs Hoot, cambios entre versiones…) | Archivo por versión: `/workspace/.claude/knowledge/odoo-*-18.md` (p. ej. `odoo-owl-components-18.md`) |
   | Conocimiento de un **componente/producto** (nextconnector u otros módulos de cliente) — y **dependiente de su versión** | Skill del componente: `/workspace/.claude/skills/<componente>/SKILL.md` (crea la skill si no existe) |
   | Preferencia de **cómo trabajar** con el usuario (commits, push, ramas, estilo) | Memoria tipo `feedback` en `/home/odoo/.claude/projects/-workspace/memory/` + índice `MEMORY.md` |
   | Estado/decisión de un **proyecto/cliente** | Memoria tipo `project` |

3. **PROPÓN, no apliques.** Presenta al usuario:
   - Un resumen de 1 línea por aprendizaje.
   - El **destino** propuesto (archivo exacto) y un **diff/borrador** del cambio (qué línea o bloque
     añadirías/editarías).
   - Pregunta: *"¿Agrego esto? (sí / no / edítalo)"* por cada uno, o en lote si son varios.
4. **Aplica solo lo aprobado.** Tras el OK, escribe el cambio. Si es una skill nueva, usa el formato
   carpeta + `SKILL.md` + frontmatter (`name`, `description`). Si es memoria, sigue el formato de
   frontmatter + `**Why:**`/`**How to apply:**` y añade la línea al `MEMORY.md`.

## Reglas
- **Nunca** escribas en skills/knowledge/memoria sin confirmación explícita del usuario.
- Prefiere **actualizar** un archivo existente antes que crear uno nuevo duplicado.
- Si un aprendizaje corrige algo ya escrito (un patrón viejo equivocado), propón editar/borrar lo viejo.
- Mantén los `.md` concisos: un aprendizaje = pocas líneas accionables, no un ensayo.
- Al crear/editar una skill de componente, marca explícitamente la **versión** a la que aplica.

## Ejemplo de propuesta
> Detecté 2 aprendizajes de esta sesión:
> 1. (por versión) En Odoo 18 las vistas de lista usan `<list>` (no `<tree>`) y los tests de frontend
>    son Hoot → propongo añadir 1 línea a `/workspace/.claude/knowledge/odoo-version-knowledge-18.md`.
> 2. (genérico) Patrón de dominio para filtrar por compañía → propongo añadir a
>    `/workspace/.claude/knowledge/domain-filter-patterns.md`.
>
> ¿Agrego ambos, alguno, o los edito antes?
