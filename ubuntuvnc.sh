#!/usr/bin/env bash
set -e

# Colors
CYAN="\033[36m"
GREEN="\033[32m"
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

echo "[+] Checking Docker..."
if ! command -v docker >/dev/null 2>&1; then
  echo "❌ Docker not found. Please install Docker first."
  exit 1
fi

echo "[+] Removing existing container (if any)..."
docker rm -f ubuntu-desktop >/dev/null 2>&1 || true

echo "[+] Pulling image..."
docker pull akarita/docker-ubuntu-desktop

echo "[+] Starting Ubuntu Desktop (VNC on localhost)..."
docker run -d \
  --name ubuntu-desktop \
  --platform=linux/amd64 \
  -p 127.0.0.1:6080:6080 \
  --restart unless-stopped \
  akarita/docker-ubuntu-desktop

echo
echo -e "${GREEN}✅ Ubuntu Desktop is running!${RESET}"
echo "➡ Open in browser: http://127.0.0.1:6080"
echo "➡ Or: http://localhost:6080"
