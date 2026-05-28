# DevContainer Odoo 18.0

Entorno de desarrollo reproducible para Odoo 18.0 usando DevContainers y Docker.

## Uso rápido con Claude Code (recomendado)

La forma más rápida de levantar este entorno es usando **Claude Code en VS Code**:

1. Abre VS Code en WSL Ubuntu 24.04
2. Abre Claude Code y dile:

```
Clona el repo https://github.com/desarrollonextpro/devcontainers-odoo rama 18.0
en ~/odoo-18 y levanta el entorno DevContainer para Odoo 18
```

Claude realizará automáticamente todos los pasos de configuración.

---

## Configuración manual

### Requisitos

- WSL 2 con Ubuntu 24.04
- [Docker Desktop](https://www.docker.com/products/docker-desktop/) (con integración WSL habilitada)
- [VS Code](https://code.visualstudio.com/) con la extensión [Dev Containers](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers)

### Estructura de carpetas recomendada en WSL Ubuntu 24.04

Cada versión de Odoo vive en su propia carpeta dentro del home de WSL:

```
/home/ubuntu/
├── odoo-16/    <-- clon de la rama 16.0
├── odoo-17/    <-- clon de la rama 17.0
├── odoo-18/    <-- clon de la rama 18.0 (este repo)
└── odoo-19/    <-- clon de la rama 19.0
```

Las fuentes de Odoo Community y Enterprise **no se versionan** — se clonan automáticamente
al crear el DevContainer vía `post-create.sh`.

### Pasos

**1. Clonar en la carpeta correcta**

```bash
git clone -b 18.0 https://github.com/desarrollonextpro/devcontainers-odoo.git ~/odoo-18
cd ~/odoo-18
```

**2. Configurar el token de GitHub** (necesario para clonar Odoo Enterprise)

```bash
cp .devcontainer/.env.example .devcontainer/.env
# Editar .devcontainer/.env y poner tu GITHUB_TOKEN
```

Generar token en: https://github.com/settings/tokens (scope: `repo`)

**3. Abrir en DevContainer**

- Abrir la carpeta en VS Code
- Aceptar "Reopen in Container" (o `Dev Containers: Reopen in Container`)
- El `post-create.sh` instalará todo automáticamente:
  - Clona Odoo Community 18.0
  - Intenta clonar Odoo Enterprise 18.0 (requiere GITHUB_TOKEN o SSH)
  - Instala dependencias Python con `uv`

**4. Levantar Odoo**

```bash
python odoo.18.0/odoo-bin -c odoo.conf
```

Acceder en: http://localhost:8069

---

## Puertos

| Servicio   | Puerto local |
|------------|-------------|
| Odoo       | 8069        |
| debugpy    | 8071        |
| pgAdmin    | 8085        |
| PostgreSQL | 5432        |

## Configuración `odoo.conf` — decisiones de diseño

| Parámetro | Valor | Motivo |
|-----------|-------|--------|
| `workers = 0` | 0 | Modo single-thread, requerido para debugging con debugpy |
| `max_cron_threads = 0` | 0 | Deshabilita cron en desarrollo para evitar ruido en logs y conflictos al hacer debug |
| `dev_mode` | reload,qweb,werkzeug,xml | Recarga automática de vistas y assets al guardar |
| `limit_time_real = 0` | 0 | Sin timeout, permite sesiones de debug largas |
| `list_db = True` | True | Muestra selector de bases de datos en pantalla de login |

> Para habilitar el cron en desarrollo puntualmente: cambiar `max_cron_threads = 1` y reiniciar Odoo.

## Debugging

Presionar `F5` → seleccionar **"Odoo: Launch"**

## Skills de Claude Code incluidos

Este repositorio incluye skills de Claude Code en `.claude/skills/` que enseñan a Claude los patrones correctos para Odoo 18.0:

| Skill | Descripción |
|-------|-------------|
| `odoo-version-knowledge-18.md` | Python 3.12, SQL() recomendado, novedades v18 |
| `odoo-model-patterns-18.md` | ORM patterns, match/case, type hints opcionales |
| `odoo-module-generator-18.md` | Manifest, vistas sin attrs={}, wizards |
| `odoo-owl-components-18.md` | OWL 2.x, orm service, field widgets |
| `computed-field-patterns.md` | Campos computed, depends, inverse |
| `domain-filter-patterns.md` | Dominios, filtros, búsquedas |
| `inheritance-patterns.md` | Herencia de modelos y vistas |
| `mail-notification-patterns.md` | mail.thread, chatter, notificaciones |
| `report-patterns.md` | Reportes QWeb, PDF, xlsx |
| `wizard-patterns.md` | TransientModel, wizards, confirmaciones |
| `workflow-state-patterns.md` | Máquinas de estado, transiciones |
| `xmlrpc-query-patterns.md` | XML-RPC, API externa, integraciones |

Uso: en el chat de Claude Code escribe `/[nombre-skill]` o cita el skill con `#`.

---

## Addons personalizados

Clonar los repos de tus addons en `custom-addons/` y agregar sus rutas en `odoo.conf`:

```ini
addons_path = /workspace/enterprise.18.0,/workspace/odoo.18.0/addons,/workspace/custom-addons/mi-addon
```

> `custom-addons/` está en `.gitignore` — el código de cliente nunca se sube a este repo.
