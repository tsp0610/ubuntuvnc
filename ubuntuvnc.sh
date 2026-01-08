#!/usr/bin/env bash
set -e

# Colors
CYAN="\033[36m"
GREEN="\033[32m"
YELLOW="\033[33m"
RESET="\033[0m"

# Banner
echo -e "${CYAN}┌──────────────────────────────────────────────────────────────┐"
echo -e "│ ████████╗███████╗██████╗     ███╗   ██╗ ██████╗ ██████╗ ███████╗ │"
echo -e "│ ╚══██╔══╝██╔════╝██╔══██╗    ████╗  ██║██╔═══██╗██╔══██╗██╔════╝ │"
echo -e "│    ██║   ███████╗██████╔╝    ██╔██╗ ██║██║   ██║██║  ██║█████╗   │"
echo -e "│    ██║   ╚════██║██╔═══╝     ██║╚██╗██║██║   ██║██║  ██║██╔══╝   │"
echo -e "│    ██║   ███████║██║         ██║ ╚████║╚██████╔╝██████╔╝███████╗│"
echo -e "│    ╚═╝   ╚══════╝╚═╝         ╚═╝  ╚═══╝ ╚═════╝ ╚═════╝ ╚══════╝│"
echo -e "└──────────────────────────────────────────────────────────────┘${RESET}"
echo

# ----------------------------
# Check Docker daemon (REAL check)
# ----------------------------
if command -v docker >/dev/null 2>&1 && docker info >/dev/null 2>&1; then
  echo "[+] Docker daemon detected – using Docker backend"

  docker rm -f ubuntu-desktop >/dev/null 2>&1 || true
  docker pull akarita/docker-ubuntu-desktop

  docker run -d \
    --name ubuntu-desktop \
    --platform=linux/amd64 \
    -p 127.0.0.1:6080:6080 \
    --restart unless-stopped \
    akarita/docker-ubuntu-desktop

  echo
  echo -e "${GREEN}✅ Ubuntu Desktop running via Docker${RESET}"
  echo "➡ http://127.0.0.1:6080"
  exit 0
fi

# ----------------------------
# Native fallback (IDX / sandbox / no Docker)
# ----------------------------
echo -e "${YELLOW}[!] Docker daemon not available — using native VNC fallback${RESET}"

echo "[+] Installing XFCE + TigerVNC..."
sudo apt update
sudo apt install -y xfce4 xfce4-goodies tigervnc-standalone-server dbus-x11

mkdir -p ~/.vnc

cat > ~/.vnc/xstartup <<'EOF'
#!/bin/sh
unset SESSION_MANAGER
unset DBUS_SESSION_BUS_ADDRESS
exec startxfce4 &
EOF

chmod +x ~/.vnc/xstartup

vncserver -kill :1 >/dev/null 2>&1 || true
vncserver :1 -localhost

echo
echo -e "${GREEN}✅ Ubuntu XFCE desktop running (native)${RESET}"
echo "➡ VNC display: :1"
echo "➡ Use IDX port forwarding or a VNC viewer"
