# DevContainer Odoo 19.0

Entorno de desarrollo reproducible para Odoo 19.0 usando DevContainers y Docker.

## Uso rápido con Claude Code (recomendado)

La forma más rápida de levantar este entorno es usando **Claude Code en VS Code**:

1. Abre VS Code en WSL Ubuntu 24.04
2. Abre Claude Code y dile:

```
Clona el repo https://github.com/desarrollonextpro/devcontainers-odoo rama 19.0
en ~/odoo-19 y levanta el entorno DevContainer para Odoo 19
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
├── odoo-18/    <-- clon de la rama 18.0
└── odoo-19/    <-- clon de la rama 19.0 (este repo)
```

Las fuentes de Odoo Community y Enterprise **no se versionan** — se clonan automáticamente
al crear el DevContainer vía `post-create.sh`.

### Pasos

**1. Clonar en la carpeta correcta**

```bash
git clone -b 19.0 https://github.com/desarrollonextpro/devcontainers-odoo.git ~/odoo-19
cd ~/odoo-19
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
  - Clona Odoo Community 19.0
  - Intenta clonar Odoo Enterprise 19.0 (requiere GITHUB_TOKEN o SSH)
  - Instala dependencias Python con `uv`

**4. Levantar Odoo**

```bash
python odoo.19.0/odoo-bin -c odoo.conf
```

Acceder en: http://localhost:9069

---

## Puertos

| Servicio   | Puerto local |
|------------|-------------|
| Odoo       | 9069        |
| debugpy    | 9071        |
| pgAdmin    | 8084        |
| PostgreSQL | 5431        |

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

También puedes hacer attach a un proceso existente con **"Odoo: Attach"** (puerto 5678).

## Addons personalizados

Clonar los repos de tus addons en `custom-addons/` y agregar sus rutas en `odoo.conf`:

```ini
addons_path = /workspace/enterprise.19.0,/workspace/odoo.19.0/addons,/workspace/custom-addons/mi-addon
```

> `custom-addons/` está en `.gitignore` — el código de cliente nunca se sube a este repo.

## Skills de Claude Code incluidos

Este entorno incluye skills de Claude Code para acelerar el desarrollo Odoo:

- Patrones de modelos Odoo 19
- Filtros de dominio
- Herencia de modelos y vistas
- Componentes OWL
- Generador de módulos
- Notificaciones por mail
- Reportes PDF
- Wizards
- Workflows con estados
- Consultas XML-RPC
