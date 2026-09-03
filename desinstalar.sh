#!/usr/bin/env bash
# Quita el docklet de grupos de Plank instalado por install.sh.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=i18n.sh
. "$ROOT/i18n.sh"
ESTADO="${XDG_DATA_HOME:-$HOME/.local/share}/plank-group-docklet/instalacion.txt"
TITULO="$(pg title_remove)"
GUI=0

tiene_pantalla() {
  [[ -n "${DISPLAY:-}${WAYLAND_DISPLAY:-}" ]]
}

if tiene_pantalla && command -v zenity >/dev/null 2>&1; then
  GUI=1
fi

mensaje() {
  if [[ "$GUI" -eq 1 ]]; then
    zenity --info --title="$TITULO" --width=440 --text="$1" || true
  else
    printf '%b\n\n' "$1"
  fi
}

mensaje_error() {
  if [[ "$GUI" -eq 1 ]]; then
    zenity --error --title="$TITULO" --width=440 --text="$1" || true
  else
    printf '\nERROR: %b\n\n' "$1" >&2
  fi
}

preguntar() {
  if [[ "$GUI" -eq 1 ]]; then
    zenity --question --title="$TITULO" --width=440 --text="$1"
  else
    local respuesta=""
    printf '%b\n' "$1"
    read -r -p "$(pg continue_prompt)" respuesta || return 1
    [[ -z "$respuesta" || "$respuesta" =~ ^[sSyY] ]]
  fi
}

como_admin() {
  if [[ "$(id -u)" -eq 0 ]]; then
    "$@"
    return
  fi
  if command -v pkexec >/dev/null 2>&1; then
    pkexec "$@"
  else
    sudo "$@"
  fi
}

quitar_del_dock() {
  local dock="$1"
  local item="$2"
  local ruta="/net/launchpad/plank/docks/$dock/dock-items"
  local actuales nuevo
  actuales="$(dconf read "$ruta" 2>/dev/null || true)"
  [[ -n "$actuales" && "$actuales" != "@as []" ]] || return 0
  nuevo="$(python3 - "$actuales" "$item" <<'PY'
import ast, sys
raw, item = sys.argv[1], sys.argv[2]
try:
    items = ast.literal_eval(raw)
except Exception:
    sys.exit(0)
items = [x for x in items if x != item]
if not items:
    print("@as []")
else:
    print("[" + ", ".join("'" + x.replace("'", "") + "'" for x in items) + "]")
PY
)"
  [[ -n "${nuevo:-}" ]] && dconf write "$ruta" "$nuevo"
}

if [[ "$(id -u)" -eq 0 ]]; then
  mensaje_error "$(pg err_root_remove)"
  exit 1
fi

if ! preguntar "$(pg ask_remove)"; then
  exit 0
fi

DOCKLET=""
if [[ -f "$ESTADO" ]]; then
  DOCKLET="$(awk -F= '/^DOCKLET=/{print $2}' "$ESTADO")"
  while IFS= read -r linea; do
    case "$linea" in
      DOCKITEM=*)
        rm -f "${linea#DOCKITEM=}"
        ;;
      DOCK=*)
        resto="${linea#DOCK=}"
        quitar_del_dock "${resto%%:*}" "${resto#*:}"
        ;;
    esac
  done <"$ESTADO"
fi

if [[ -z "$DOCKLET" ]]; then
  libdir="$(pkg-config --variable=libdir plank 2>/dev/null || echo /usr/lib)"
  DOCKLET="$libdir/plank/docklets/libdocklet-app-group.so"
fi

if [[ -f "$DOCKLET" ]]; then
  if ! como_admin "$ROOT/install.sh" --quitar-modulo "$DOCKLET"; then
    mensaje_error "$(pg err_delete_module)"
    exit 1
  fi
fi

GRUPOS_DIR=""
if [[ -f "$ESTADO" ]]; then
  GRUPOS_DIR="$(awk -F= '/^GRUPOS_DIR=/{print $2}' "$ESTADO")"
fi
GRUPOS_DIR="${GRUPOS_DIR:-$HOME/Aplicaciones-dock}"

if [[ -d "$GRUPOS_DIR" ]] && preguntar "$(pgf ask_delete_folders "$GRUPOS_DIR")"; then
  rm -rf "$GRUPOS_DIR"
fi

rm -f "$ESTADO"

if pgrep -u "$USER" -x plank >/dev/null 2>&1; then
  killall plank >/dev/null 2>&1 || true
  sleep 0.4
  nohup plank >/dev/null 2>&1 &
  disown || true
fi

mensaje "$(pg done_remove)"
exit 0
