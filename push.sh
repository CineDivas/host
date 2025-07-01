#!/bin/bash

# Set directories
SRC_DIR="/mnt/c/Users/91814/Downloads"
DEST_DIR="/mnt/d/Kali-Linux/Wsl/host"

# Step 1: Remove older .jpg files in destination
echo "Removing existing .jpg files in $DEST_DIR..."
find "$DEST_DIR" -type f -iname "*.jpg" -delete

# Step 2: Move and rename new .JPG files
echo "Moving .JPG files from $SRC_DIR to $DEST_DIR with lowercase extensions..."

shopt -s nullglob
for file in "$SRC_DIR"/*.JPG; do
    filename=$(basename "$file")
    newname="${filename%.JPG}.jpg"
    mv "$file" "$DEST_DIR/$newname"
    echo "Moved: $filename -> $newname"
done

# Step 3: Git commit and push
cd "$DEST_DIR" || { echo "Failed to enter $DEST_DIR"; exit 1; }

echo "Adding changes to git..."
git add .

echo "Committing changes..."
git commit -m "Refresh image set with lowercase .jpg files"

echo "Pushing to remote..."
git push origin main

echo "✅ All done. Please use --> https://raw.githubusercontent.com/CineDivas/host/main/*.jpg"

