#!/usr/bin/env bash
# PostToolUse(Edit|Write|MultiEdit|NotebookEdit): cuenta ediciones por sesión.
# Lo usa el hook Stop (suggest-learning.py) para el recordatorio de aprendizaje.
set -euo pipefail
input="$(cat)"
sid="$(printf '%s' "$input" | python3 -c 'import sys,json;print(json.load(sys.stdin).get("session_id","default"))' 2>/dev/null || echo default)"
dir=/tmp/claude-learn
mkdir -p "$dir"
f="$dir/$sid.edits"
n=0; [ -f "$f" ] && n="$(cat "$f" 2>/dev/null || echo 0)"
echo $((n+1)) > "$f"
exit 0
