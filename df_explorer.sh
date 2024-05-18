#!/bin/bash

# Function to display help
show_help() {
    echo "Usage: df_explorer.sh [--connection-file PATH]"
    echo ""
    echo "Options:"
    echo "  --connection-file PATH  Path to the Jupyter kernel connection file."
}

# Parse arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --connection-file) KERNEL_CONNECTION_FILE="$2"; shift ;;
        -h|--help) show_help; exit 0 ;;
        *) echo "Unknown parameter: $1" >&2; show_help; exit 1 ;;
    esac
    shift
done

# Function to select a kernel connection file using fzf
select_connection_file() {
    local connection_files=$(ls $(jupyter --runtime-dir)/kernel-*.json)
    local selected_file=$(echo "$connection_files" | fzf --prompt="Select a kernel connection file: ")
    echo "$selected_file"
}

# If no connection file is provided, use fzf to select one
if [ -z "$KERNEL_CONNECTION_FILE" ]; then
    KERNEL_CONNECTION_FILE=$(select_connection_file)
    if [ -z "$KERNEL_CONNECTION_FILE" ]; then
        echo "No kernel connection file selected."
        exit 1
    fi
fi

# Check if the connection file exists
if [ ! -f "$KERNEL_CONNECTION_FILE" ]; then
    echo "Kernel connection file not found."
    exit 1
fi

# Step 1: Select a DataFrame variable using your Python module, jq, and fzf
DF_NAME=$(python ~/dotfiles/var_explorer.py --connection_file="$KERNEL_CONNECTION_FILE" | jq -r '.[] | select(.varType == "DataFrame") | "\(.varName)"' | fzf --prompt="Select a DataFrame: ")

# Check if DF_NAME is empty or not selected
if [ -z "$DF_NAME" ]; then
    echo "No DataFrame selected."
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

