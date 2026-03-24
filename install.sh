#!/bin/bash
set -e

echo "=== LeRobot Workshop Setup ==="

# Install Python 3.10 and tkinter if needed
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    if ! command -v python3.10 &> /dev/null; then
        echo "Installing Python 3.10..."
        sudo apt update
        sudo apt install -y python3.10 python3.10-venv python3.10-tk unzip
    else
        echo "Installing python3.10-tk and unzip..."
        sudo apt install -y python3.10-tk unzip
    fi
elif [[ "$OSTYPE" == "darwin"* ]]; then
    if ! command -v python3.10 &> /dev/null; then
        echo "Installing Python 3.10..."
        brew install python@3.10
    fi
    brew install python-tk@3.10
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

# Create virtual environment with Python 3.10
python3.10 -m venv .venv
source .venv/bin/activate
echo "Virtual environment created with $(python --version)"

# Install all dependencies (including lerobot)
pip install --upgrade pip
pip install --no-cache-dir -r requirements.txt
echo "Dependencies installed"

echo ""
echo "=== Done! ==="
echo "To activate the environment: source .venv/bin/activate"
