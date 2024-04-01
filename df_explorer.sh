#!/bin/bash

# Check if a kernel connection file is provided as an argument; if not, use the most recent one
KERNEL_CONNECTION_FILE="${1:-$(ls -t $(jupyter --runtime-dir)/kernel-*.json | head -n 1)}"

# Step 1: Select a DataFrame variable using your Python module, jq, and fzf
DF_NAME=$(python ~/dotfiles/var_explorer.py --connection_file="$KERNEL_CONNECTION_FILE" | jq -r '.[] | select(.varType == "DataFrame") | "\(.varName)"' | fzf)

# Check if DF_NAME is empty or not selected
if [ -z "$DF_NAME" ]; then
    echo "No DataFrame selected."
    exit 1
fi


if [ ! -f "$KERNEL_CONNECTION_FILE" ]; then
    echo "Kernel connection file not found."
    exit 1
fi

# Generate a temporary directory and filename
TMP_DIR=$(mktemp -d)
FILENAME="${DF_NAME}.feather"

# Ensure the temp directory was created
if [ ! -d "$TMP_DIR" ]; then
    echo "Failed to create a temporary directory."
    exit 1
fi

# Formulating the command to export the selected DataFrame to Feather format
CMD="%to_feather $DF_NAME $FILENAME $TMP_DIR"

# Execute the Jupyter console command with the formulated command
# echo "Exporting $DF_NAME to Feather format to $TMP_DIR/$FILENAME..."
jupyter console --simple-prompt --existing "$KERNEL_CONNECTION_FILE" <<< "$CMD" > /dev/null 2>&1

# Open the resulting Feather file with VisiData
VDATA_FILE="$TMP_DIR/$FILENAME"

if [ -f "$VDATA_FILE" ]; then
    echo "Opening $VDATA_FILE with VisiData..."
    vd "$VDATA_FILE"
else
    echo "The file $VDATA_FILE was not found."
fi

