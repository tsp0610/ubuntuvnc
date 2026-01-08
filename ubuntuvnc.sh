#!/usr/bin/env bash
set -e

# Colors
CYAN="\033[36m"
GREEN="\033[32m"
YELLOW="\033[33m"
RED="\033[31m"
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

# Detect Google IDX
IS_IDX=false
if [[ -n "${IDX_WORKSPACE_ROOT:-}" ]]; then
  IS_IDX=true
fi

# Check Docker daemon (REAL check)
DOCKER_OK=false
if command -v docker >/dev/null 2>&1 && docker info >/dev/null 2>&1; then
  DOCKER_OK=true
fi

# ----------------------------
# Docker backend
# ----------------------------
if $DOCKER_OK; then
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
# IDX fallback
# ----------------------------
if $IS_IDX; then
  echo -e "${YELLOW}[!] Google IDX detected – Docker daemon unavailable${RESET}"
  echo "[+] Installing native XFCE + TigerVNC..."

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
  echo -e "${GREEN}✅ Ubuntu XFCE desktop running on IDX${RESET}"
  echo "➡ VNC display :1"
  echo "➡ Use IDX port forwarding / VNC viewer"
  exit 0
fi

# ----------------------------
# No supported backend
# ----------------------------
echo -e "${RED}❌ Docker daemon not available${RESET}"
echo "This environment does not support Docker or IDX fallback."
exit 1
