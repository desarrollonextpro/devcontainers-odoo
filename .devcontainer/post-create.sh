#!/bin/bash
set -euo pipefail
cd /workspace

mkdir -p ~/.ssh 2>/dev/null || true
ssh-keyscan github.com 2>/dev/null >> ~/.ssh/known_hosts 2>/dev/null || true

# --- Odoo Community ---
if [ ! -f "/workspace/odoo.19.0/odoo-bin" ]; then
  echo "==> Clonando Odoo Community 19.0 (shallow)..."
  rm -rf /workspace/odoo.19.0
  git clone --depth 1 --branch 19.0 https://github.com/odoo/odoo.git /workspace/odoo.19.0
else
  echo "==> Odoo Community ya presente, saltando clone."
fi

# --- Odoo Enterprise ---
if [ ! -d "/workspace/enterprise.19.0/.git" ]; then
  echo "==> Intentando clonar Odoo Enterprise 19.0..."
  if [ -n "${GITHUB_TOKEN:-}" ]; then
    git clone --depth 1 --branch 19.0 https://${GITHUB_TOKEN}@github.com/odoo/enterprise.git /workspace/enterprise.19.0
  else
    git clone --depth 1 --branch 19.0 git@github.com:odoo/enterprise.git /workspace/enterprise.19.0
  fi \
    || { echo "WARN: no se pudo clonar enterprise. Creando directorio vacío."; mkdir -p /workspace/enterprise.19.0; }
else
  echo "==> Odoo Enterprise ya presente, saltando clone."
fi

# --- Crear directorios necesarios ---
mkdir -p /workspace/custom-addons

# --- Dependencias Python ---
echo "==> uv sync..."
uv sync

echo "==> Instalando requirements de Odoo (excluyendo paquetes incompatibles en dev)..."
grep -v -E '^(gevent|greenlet)' /workspace/odoo.19.0/requirements.txt | uv pip install -r -

echo ""
echo "==> Setup completo! Levantar Odoo con:"
echo "    python odoo.19.0/odoo-bin -c odoo.conf"
