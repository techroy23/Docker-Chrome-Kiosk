# Docker-Chrome-Kiosk

A lightweight container that runs **Google Chrome in kiosk mode** inside an Openbox desktop, accessible via **VNC** and **noVNC**.  
Supports auto‑restart on crash and optional periodic screenshots uploaded to a Discord webhook.

---

## Environment Variables

- `WEBSITE` — URL to open in Chrome kiosk mode (default: none)
- `DISCORDWEBHOOKURL` — Discord webhook to send screenshots (optional)
- `DISCORDWEBHOOKTIMER` — Interval in seconds between screenshots (default: `300`)
- `VNC_PORT` — Port for the x11vnc server (default: `5910`)
- `NOVNC_PORT` — Port for the noVNC web proxy (default: `6080`)

---

## Run

```bash
docker run -it --rm \
  --name myKiosk \
  --privileged \
  -e WEBSITE="http://www.google.com" \
  -e DISCORDWEBHOOKURL="https://discord.com/api/webhooks/XXX/YYY-ZZZ" \
  -e DISCORDWEBHOOKTIMER="500" \
  -e VNC_PORT=5920 \
  -e NOVNC_PORT=6090 \
  -p 5920:5920 \
  -p 6090:6090 \
  techroy23/docker-chrome-kiosk
```