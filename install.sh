#!/bin/bash
set -e

echo "=== LeRobot Workshop Setup ==="

# Unzip assets if not already present
if [ ! -d "asset" ]; then
    echo "Unzipping assets..."
    unzip -q asset.zip
    echo "Assets extracted"
else
    echo "Assets already present, skipping unzip"
fi

# Create virtual environment
python3 -m venv .venv
source .venv/bin/activate
echo "Virtual environment created and activated"

# Install dependencies manually (NOT via pip install lerobot)
pip install --upgrade pip
pip install -r requirements.txt
echo "Dependencies installed"

# Install lerobot without its deps to avoid overwriting packages
pip install --no-deps "lerobot @ git+https://github.com/huggingface/lerobot.git@10b7b3532543b4adfb65760f02a49b4c537afde7"
echo "LeRobot installed (--no-deps)"

echo ""
echo "=== Done! ==="
echo "To activate the environment: source .venv/bin/activate"
