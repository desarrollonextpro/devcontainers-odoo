#!/usr/bin/env bash
# Restaura el historial/memoria de Claude Code a /home/odoo/.claude (el volumen
# persistente 'claude-code-config'). Uso típico: tras crear/rebuildear un contenedor
# cuyo volumen de Claude nació vacío (p. ej. al replicar a otra carpeta/versión).
#
# MERGE seguro: copia el backup ENCIMA del destino sin borrar lo que ya exista
# en el destino (no usa --delete). Si un archivo existe en ambos, gana el backup.
#
# Fuente por defecto: el snapshot más reciente de /workspace/.claude-backups, y si
# no hay, el espejo /workspace/.claude-backup. Se puede pasar una ruta explícita:
#   ./restore-claude.sh /workspace/.claude-backups/20260722-232524
set -euo pipefail

DEST="${CLAUDE_CONFIG_DIR:-/home/odoo/.claude}"
SNAPDIR=/workspace/.claude-backups
MIRROR=/workspace/.claude-backup

if [ "${1:-}" != "" ]; then
    SRC="$1"
else
    SRC="$(ls -1dt "$SNAPDIR"/*/ 2>/dev/null | head -n1 || true)"
    [ -z "$SRC" ] && SRC="$MIRROR"
fi

if [ ! -d "$SRC" ]; then
    echo "ERROR: no existe el backup $SRC"; exit 1
fi

echo "Restaurando (merge) $SRC -> $DEST ..."
mkdir -p "$DEST"
if command -v rsync >/dev/null 2>&1; then
    rsync -a "$SRC"/ "$DEST"/     # SIN --delete
else
    cp -a "$SRC"/. "$DEST"/
fi

echo "Verificación:"
echo "  origen:      $SRC"
echo "  memorias:    $(ls "$DEST"/projects/-workspace/memory/*.md 2>/dev/null | wc -l)"
echo "  transcripts: $(ls "$DEST"/projects/-workspace/*.jsonl 2>/dev/null | wc -l)"

if findmnt "$DEST" >/dev/null 2>&1; then
    echo "OK: $DEST ES un volumen persistente (rebuilds futuros seguros)."
else
    echo "AVISO: $DEST NO es un volumen. Verifica que el devcontainer.json monte"
    echo "       'claude-code-config' -> $DEST y que el contenedor se haya (re)creado con él."
fi
echo "Listo."
