#!/bin/bash
# Fail immediately if any command fails or variable is missing
set -euo pipefail

echo "========================================"
echo " Installing Custom Folder Wizard..."
echo "========================================"

echo "=> 1. Installing dependencies (requires sudo)..."
sudo apt update
sudo apt install -y zenity trash-cli gocryptfs python3-nautilus attr

echo "=> 2. Creating local Nautilus directories..."
mkdir -p ~/.local/share/nautilus-python/extensions
mkdir -p ~/.local/share/nautilus/scripts
mkdir -p ~/.local/bin

echo "=> 3. Copying source files..."
cp src/custom_folder_menu.py ~/.local/share/nautilus-python/extensions/
cp "src/Create Custom Folder" ~/.local/share/nautilus/scripts/
cp "src/Toggle Vault Lock" ~/.local/share/nautilus/scripts/
cp src/custom_folder_cleanup.sh ~/.local/bin/

echo "=> 4. Setting execution permissions..."
chmod +x ~/.local/share/nautilus/scripts/Create\ Custom\ Folder
chmod +x ~/.local/share/nautilus/scripts/Toggle\ Vault\ Lock
chmod +x ~/.local/bin/custom_folder_cleanup.sh

echo "=> 5. Configuring background cleanup daemon..."
CRON_JOB="0 * * * * ~/.local/bin/custom_folder_cleanup.sh >/dev/null 2>&1"
# Safely append to crontab without creating duplicates
(crontab -l 2>/dev/null | grep -Fv "custom_folder_cleanup.sh" || true; echo "$CRON_JOB") | crontab -

echo "=> 6. Restarting File Manager..."
nautilus -q || true

echo "========================================"
echo " Installation Complete!"
echo " Right-click on empty space in any folder to begin."
echo "========================================"
