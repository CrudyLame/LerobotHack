#!/bin/bash
set -e

echo "=== LeRobot Workshop Setup ==="

# Create virtual environment
python3 -m venv .venv
source .venv/bin/activate
echo "Virtual environment created and activated"

# Install dependencies manually (NOT via pip install lerobot)
pip install --upgrade pip
pip install -r requirements.txt
echo "Dependencies installed"

# Install lerobot without its deps to avoid overwriting packages
pip install --no-deps "lerobot @ git+https://github.com/huggingface/lerobot.git"
echo "LeRobot installed (--no-deps)"

# Extract simulation assets
cd asset/objaverse && unzip -o plate_11.zip -d plate_11 && cd ../..
echo "Assets extracted"

echo ""
echo "=== Done! ==="
echo "To activate the environment: source .venv/bin/activate"
