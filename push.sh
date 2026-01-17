#!/usr/bin/env bash
set -e

####################################
# CONFIG
####################################
SRC="/mnt/c/Users/91814/Downloads"
DEST="/mnt/d/Kali-Linux/Wsl/host"
BRANCH="main"
COMMIT_MSG="Refresh image set with lowercase .jpg files"

####################################
# ENV DETECTION
####################################
INTERACTIVE=true
[[ ! -t 1 ]] && INTERACTIVE=false

####################################
# COLORS
####################################
RESET="\e[0m"
CYAN="\e[36m"
GREEN="\e[32m"
YELLOW="\e[33m"
RED="\e[31m"
MAGENTA="\e[35m"

####################################
# ANIMATIONS
####################################

sleep_if() { $INTERACTIVE && sleep "$1"; }

typewriter() {
  $INTERACTIVE || { echo "$1"; return; }
  for ((i=0;i<${#1};i++)); do
    printf "%s" "${1:$i:1}"
    sleep 0.02
  done
  echo
}

banner() {
  $INTERACTIVE || return
  clear
  local b=(
" ██████╗ ██╗███╗   ██╗███████╗"
"██╔════╝ ██║████╗  ██║██╔════╝"
"██║  ███╗██║██╔██╗ ██║█████╗  "
"██║   ██║██║██║╚██╗██║██╔══╝  "
"╚██████╔╝██║██║ ╚████║███████╗"
" ╚═════╝ ╚═╝╚═╝  ╚═══╝╚══════╝"
"      CineDivas Image Uploader"
  )
  for l in "${b[@]}"; do
    echo -e "${CYAN}$l${RESET}"
    sleep 0.06
  done
  echo
}

pulse() {
  $INTERACTIVE || return
  for c in "$CYAN" "$MAGENTA" "$GREEN"; do
    echo -ne "${c}$1${RESET}\r"
    sleep 0.15
  done
  echo -e "$1"
}

progress() {
  $INTERACTIVE || return
  local i
  for i in {1..20}; do
    printf "\r${GREEN}Loading [%-20s]${RESET}" "$(printf '█%.0s' $(seq 1 $i))"
    sleep 0.03
  done
  echo
}

spinner() {
  local pid=$1
  local spin='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'
  local i=0
  while kill -0 "$pid" 2>/dev/null; do
    i=$(( (i+1) % ${#spin} ))
    printf "\r${CYAN}⚡ Working ${spin:$i:1}${RESET}"
    sleep 0.1
  done
  printf "\r${GREEN}✅ Done${RESET}           \n"
}

####################################
# START
####################################

banner
pulse "🚀 Initializing CineDivas pipeline..."
progress

typewriter "🧹 Cleaning old images..."
rm -f "$DEST"/*.jpg 2>/dev/null || true

typewriter "📦 Moving new images..."
(
  shopt -s nullglob
  for f in "$SRC"/*.{jpg,JPG,jpeg,JPEG,png,PNG}; do
    base=$(basename "$f")
    mv "$f" "$DEST/${base%.*}.jpg"
  done
) & spinner $!

cd "$DEST"

typewriter "📂 Git add..."
git add . >/dev/null 2>&1

typewriter "📝 Git commit..."
git commit -m "$COMMIT_MSG" >/dev/null 2>&1 || true

typewriter "🚀 Pushing to GitHub..."
if git push origin "$BRANCH" >/dev/null 2>&1; then
  echo -e "${GREEN}✅ Push successful${RESET}"
else
  echo -e "${RED}❌ Push failed — files kept${RESET}"
  exit 1
fi

typewriter "🔥 Final cleanup..."
rm -f "$DEST"/*.jpg 2>/dev/null || true

FIRST=$(git show --name-only --pretty="" | head -n 1)

echo
pulse "✨ All tasks completed!"
echo -e "${CYAN}➡️ Image URL:${RESET}"
echo "https://raw.githubusercontent.com/CineDivas/host/main/s1.jpg"

echo
typewriter "🎬 CineDivas — Upload Complete"

