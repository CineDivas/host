#!/bin/bash

# Directories
SRC_DIR="/mnt/c/Users/91814/Downloads"
DEST_DIR="/mnt/d/Kali-Linux/Wsl/host"

# Windows Recycle Bin path (applies to all drives)
RECYCLE_BIN="/mnt/c/\$Recycle.Bin"

# Step 1: Remove existing .jpg files in destination
echo "🧹 Removing existing .jpg files in $DEST_DIR..."
find "$DEST_DIR" -type f -iname "*.jpg" -delete

# Step 2: Find image files and move them as .jpg
echo "📦 Moving image files from $SRC_DIR to $DEST_DIR (renamed with .jpg)..."

find "$SRC_DIR" -maxdepth 1 -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" \) | while read -r file; do
    filename=$(basename "$file")
    name_no_ext="${filename%.*}"
    newname="${name_no_ext}.jpg"

    echo "Moving: $filename -> $newname"
    mv "$file" "$DEST_DIR/$newname" || echo "❌ Failed to move: $file"
done

# Step 3: Git commit and push
cd "$DEST_DIR" || { echo "❌ Failed to cd into $DEST_DIR"; exit 1; }

echo "📂 Adding changes to git..."
git add .

echo "📝 Committing changes..."
git commit -m "Refresh image set with lowercase .jpg files"

echo "🚀 Pushing to remote..."
git push origin main

# Step 4: FINAL CLEANUP – delete all .jpg files in destination
echo "🔥 Final cleanup: deleting all .jpg files in $DEST_DIR..."
find "$DEST_DIR" -type f -iname "*.jpg" -delete

# Step 5: Clean .jpg files from Windows Recycle Bin
if [ -d "$RECYCLE_BIN" ]; then
    echo "🗑️ Cleaning .jpg files from Windows Recycle Bin..."
    find "$RECYCLE_BIN" -type f -iname "*.jpg" -delete
else
    echo "⚠️ Recycle Bin path not found, skipping..."
fi

echo "✅ All done."
echo "➡️ Use: https://raw.githubusercontent.com/CineDivas/host/main/s1.jpg"

