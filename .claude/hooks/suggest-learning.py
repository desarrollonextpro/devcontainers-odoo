#!/usr/bin/env python3
"""Stop hook: recordatorio ÚNICO por sesión para ofrecer la skill 'aprendizaje-continuo'.

Se dispara como máximo UNA vez por sesión, y solo si hubo >= THRESHOLD ediciones (trabajo
sustancial). No repite, no fuerza nada más. Para desactivarlo: quita el bloque "Stop" de
/workspace/.claude/settings.json. Umbral ajustable con la env CLAUDE_LEARN_THRESHOLD.
"""
import sys, json, os

THRESHOLD = int(os.environ.get("CLAUDE_LEARN_THRESHOLD", "6"))

try:
    data = json.load(sys.stdin)
except Exception:
    sys.exit(0)

# Evitar bucles: si este Stop ya lo disparó un hook previo, salir.
if data.get("stop_hook_active"):
    sys.exit(0)

sid = data.get("session_id", "default")
d = "/tmp/claude-learn"
os.makedirs(d, exist_ok=True)
reminded = os.path.join(d, sid + ".reminded")
if os.path.exists(reminded):
    sys.exit(0)

edits = 0
try:
    with open(os.path.join(d, sid + ".edits")) as fh:
        edits = int((fh.read().strip() or "0"))
except Exception:
    edits = 0

if edits < THRESHOLD:
    sys.exit(0)

# Marcar como recordado (una sola vez) y pedir a Claude una reflexión breve.
open(reminded, "w").close()
reason = (
    "Antes de terminar: esta sesion tuvo trabajo sustancial (%d ediciones). "
    "Revisa si hubo algun aprendizaje reutilizable (gotcha, buena practica, error recurrente, "
    "convencion nueva). Si lo hay, OFRECE ejecutar la skill 'aprendizaje-continuo' y PREGUNTA "
    "antes de escribir nada en skills/knowledge/memoria. Si no hay nada relevante, dilo en una "
    "linea y termina. (Recordatorio unico por sesion.)" % edits
)
print(json.dumps({"decision": "block", "reason": reason}))
sys.exit(0)
