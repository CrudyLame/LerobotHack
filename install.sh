#!/bin/bash
set -e

echo "=== LeRobot Workshop Setup ==="

# Install Python 3.12 and tkinter if needed
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    echo "Installing Python dependencies..."
    sudo apt update
    sudo apt install -y python3 python3-venv python3-tk unzip
elif [[ "$OSTYPE" == "darwin"* ]]; then
    if ! command -v python3.12 &> /dev/null; then
        echo "Installing Python 3.12..."
        brew install python@3.12
    fi
    brew install python-tk@3.12
    brew install unzip
fi

# Unzip assets if not already present
if [ ! -d "asset" ]; then
    echo "Unzipping assets..."
    unzip -q asset.zip
    echo "Assets extracted"
else
    echo "Assets already present, skipping unzip"
fi

# Create virtual environment with Python 3.12
python3.12 -m venv .venv
source .venv/bin/activate
echo "Virtual environment created with $(python --version)"

# Install all dependencies (including lerobot)
pip install --upgrade pip
pip install --no-cache-dir -r requirements.txt
echo "Dependencies installed"

echo ""
echo "=== Done! ==="
echo "To activate the environment: source .venv/bin/activate"
