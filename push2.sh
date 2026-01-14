#!/bin/bash
set -e

# ---------------- CONFIG ----------------
SRC_DIR="/mnt/c/Users/91814/Downloads"
DEST_DIR="/mnt/d/Kali-Linux/Wsl/host"
WEBHOOK_URL="https://hook.eu2.make.com/cv4vl9ww7pnqq6bfex7n26goemtgmi3e"
GITHUB_RAW_BASE="https://raw.githubusercontent.com/CineDivas/host/main"
CAPTION="New carousel post ✨"
RECYCLE_BIN="/mnt/c/\$Recycle.Bin"
# ---------------------------------------

echo "🧹 Cleaning destination..."
find "$DEST_DIR" -type f -iname "*.jpg" -delete

echo "📦 Moving images..."

i=1
FILES=()

while IFS= read -r file; do
  mv "$file" "$DEST_DIR/s$i.jpg"
  FILES+=("$GITHUB_RAW_BASE/s$i.jpg")
  echo "Moved -> s$i.jpg"
  ((i++))
done < <(find "$SRC_DIR" -maxdepth 1 -type f \
        \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" \) \
        | sort)

IMAGE_COUNT=${#FILES[@]}

if [ "$IMAGE_COUNT" -eq 0 ]; then
  echo "❌ No images found"
  exit 1
fi

echo "🖼️ Total images: $IMAGE_COUNT"

cd "$DEST_DIR"

echo "🚀 Pushing to GitHub..."
git add .
git commit -m "Auto carousel upload ($IMAGE_COUNT images)"
git push origin main

# ---------------- BUILD JSON ----------------
JSON_FILES=$(printf ',{"photo_url":"%s"}' "${FILES[@]}")
JSON_FILES="[${JSON_FILES:1}]"

PAYLOAD=$(cat <<EOF
{
  "files": $JSON_FILES,
  "caption": "$CAPTION"
}
EOF
)

# ---------------- TRIGGER MAKE ----------------
echo "📡 Triggering Instagram carousel..."
curl -s -X POST "$WEBHOOK_URL" \
  -H "Content-Type: application/json" \
  -d "$PAYLOAD"

echo "✅ Instagram carousel triggered"

# ---------------- CLEANUP ----------------
echo "🔥 Cleaning destination..."
find "$DEST_DIR" -type f -iname "*.jpg" -delete

if [ -d "$RECYCLE_BIN" ]; then
  echo "🗑️ Cleaning recycle bin..."
  find "$RECYCLE_BIN" -type f -iname "*.jpg" -delete
fi

echo "🎉 Done. Posted $IMAGE_COUNT images."

