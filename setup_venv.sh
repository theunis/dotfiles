#!/bin/bash

# Check if the user provided an argument for extras
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 '<extras>'"
    echo "Example: $0 'dev,test,spark'"
    exit 1
fi

# Confirm with the user
read -p "Are you sure you want to create a new virtual environment and install the specified extras? (y/n) " -n 1 -r
echo    # Move to a new line

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Aborted by user."
    exit 1
fi

# Set the directory for your virtual environment
VENV_DIR="venv"

# Extract the extras from the first argument
EXTRAS=$1

# Create a virtual environment with Python 3.9
python3.9 -m venv $VENV_DIR

# Upgrade pip and setuptools
$VENV_DIR/bin/pip install --upgrade pip setuptools

# Install packages with the provided extras
$VENV_DIR/bin/pip install -e ".[$EXTRAS]"

# Install IPython Kernel and any other necessary packages
$VENV_DIR/bin/pip install ipykernel visidata pandas

# Determine the name of the current directory to use as the kernel name
KERNEL_NAME=$(basename "$PWD")

# Create a Jupyter kernel for the virtual environment
$VENV_DIR/bin/python -m ipykernel install --user --name="$KERNEL_NAME" --display-name "Python ($KERNEL_NAME)"

echo "Kernel $KERNEL_NAME has been created with extras [$EXTRAS]. You can use it in Jupyter interfaces."
