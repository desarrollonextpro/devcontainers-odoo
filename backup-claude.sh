#!/usr/bin/env bash
# Respalda el historial/memoria de Claude Code a /workspace (persistente en el host).
#
# Diseño NO destructivo:
#   1) Crea un snapshot INMUTABLE con timestamp en /workspace/.claude-backups/<TS>/
#      (conserva los últimos KEEP snapshots; nunca se sobreescriben entre sí).
#   2) Actualiza el espejo "último" /workspace/.claude-backup en modo MERGE
#      (rsync SIN --delete): así nunca se pierden memorias/transcripts que estén
#      en el backup pero ya no en el vivo.
#
# Correr antes de cualquier operación destructiva (down -v, volume rm, migración
# a otra carpeta/versión). Restaurar con /workspace/restore-claude.sh
set -euo pipefail

SRC="${CLAUDE_CONFIG_DIR:-/home/odoo/.claude}"
MIRROR=/workspace/.claude-backup
SNAPDIR=/workspace/.claude-backups
KEEP=10
TS="$(date +%Y%m%d-%H%M%S)"

if [ ! -d "$SRC" ]; then
    echo "ERROR: no existe $SRC"; exit 1
fi

echo "==> 1) Snapshot inmutable: $SNAPDIR/$TS"
mkdir -p "$SNAPDIR/$TS"
rsync -a "$SRC"/ "$SNAPDIR/$TS"/

echo "==> 2) Espejo (merge, sin --delete): $MIRROR"
mkdir -p "$MIRROR"
rsync -a "$SRC"/ "$MIRROR"/   # SIN --delete: solo agrega/actualiza, nunca borra

echo "==> 3) Poda de snapshots (conservar últimos $KEEP)"
ls -1dt "$SNAPDIR"/*/ 2>/dev/null | tail -n +$((KEEP+1)) | while read -r old; do
    echo "    - podando $old"; rm -rf "$old"
done

echo "==> Resumen"
echo "  snapshot:    $SNAPDIR/$TS ($(du -sh "$SNAPDIR/$TS" 2>/dev/null | cut -f1))"
echo "  espejo:      $MIRROR ($(du -sh "$MIRROR" 2>/dev/null | cut -f1))"
echo "  memorias:    $(ls "$MIRROR"/projects/-workspace/memory/*.md 2>/dev/null | wc -l)"
echo "  transcripts: $(ls "$MIRROR"/projects/-workspace/*.jsonl 2>/dev/null | wc -l)"
echo "Listo. Restaurar con /workspace/restore-claude.sh"
