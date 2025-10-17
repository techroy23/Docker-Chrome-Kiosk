#!/usr/bin/env bash
set -euo pipefail

log() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*"; }

cleanup() {
    log "Caught signal, shutting down..."
    pkill -TERM -P $$ || true
    wait
    exit 0
}
trap cleanup SIGINT SIGTERM

pick_display() {
    while true; do
        local num=$(( RANDOM % 9000 + 1000 ))
        if [ ! -e "/tmp/.X11-unix/X${num}" ]; then
            echo ":${num}"
            return
        fi
    done
}

DISPLAY_NUM=$(pick_display)
export G_SLICE=always-malloc
export DISPLAY=$DISPLAY_NUM
log "Using display $DISPLAY"
mkdir -p "$HOME/.config/tint2"

# Allow override of ports via env vars
VNC_PORT="${VNC_PORT:-5910}"
NOVNC_PORT="${NOVNC_PORT:-6080}"

log "Starting Xvfb on $DISPLAY (1600x900x24)..."
Xvfb $DISPLAY -screen 0 1600x900x24 &
XVFB_PID=$!

log "Starting x11vnc on $DISPLAY (rfbport $VNC_PORT)..."
x11vnc -display $DISPLAY \
       -nopw -forever -shared \
       -rfbport "$VNC_PORT" -listen 0.0.0.0 \
       -noxdamage -nowf -noscr -cursor arrow -noxkb \
       2>/dev/null &
X11VNC_PID=$!

log "Starting Openbox..."
dbus-launch --exit-with-session openbox-session &
OPENBOX_PID=$!

log "Starting tint2 panel..."
tint2 &
TINT2_PID=$!

log "Starting noVNC proxy on port $NOVNC_PORT..."
/opt/noVNC/utils/novnc_proxy --vnc "localhost:$VNC_PORT" --listen "$NOVNC_PORT" &
NOVNC_PID=$!

if [ -n "${WEBSITE:-}" ]; then
    log "Auto-launching Chrome in kiosk mode with $WEBSITE"
    (
        while true; do
            google-chrome-stable \
                --kiosk \
                --disable-dev-shm-usage \
                --disable-gpu \
                --no-first-run \
                --disable-first-run-ui \
                --disable-infobars \
                --start-maximized \
                "$WEBSITE" \
                > /dev/null 2>&1
            log "Chrome crashed or exited, restarting in 5s..."
            sleep 5
        done
    ) &
    CHROME_PID=$!
fi

if [ -n "${DISCORDWEBHOOKURL:-}" ]; then
    INTERVAL="${DISCORDWEBHOOKTIMER:-300}"
    log "Discord webhook enabled, sending screenshots every $INTERVAL seconds"
    (
        while true; do
            TS=$(date +%Y%m%d_%H%M%S)
            FILE="/tmp/screenshot_${TS}.png"
            scrot "$FILE" -q 100
            curl -s -X POST \
                -H "Content-Type: multipart/form-data" \
                -F "file=@$FILE" \
                "$DISCORDWEBHOOKURL" >/dev/null || log "Failed to send screenshot"
            rm -f "$FILE"
            sleep "$INTERVAL"
        done
    ) &
    SCREENSHOT_PID=$!
fi

wait $XVFB_PID $X11VNC_PID $OPENBOX_PID $TINT2_PID $NOVNC_PID ${CHROME_PID:-} ${SCREENSHOT_PID:-}
