#!/bin/bash

FOREGROUND_COLOUR=45
VERBOSE=false

# Function to display an error message and exit
error_exit() {
    echo "$(gum style --foreground 196 "$1")" 1>&2
    exit 1
}

# Function to run a command with a spinner
run_with_spinner() {
    local TITLE=$1
    shift
    local SHOW_OUTPUT_FLAG=""
    if [ "$VERBOSE" = true ]; then
        SHOW_OUTPUT_FLAG="--show-output"
    fi
    gum spin --spinner dot --title "$TITLE" --spinner.foreground $FOREGROUND_COLOUR --title.foreground $FOREGROUND_COLOUR $SHOW_OUTPUT_FLAG -- "$@"
    if [ $? -ne 0 ]; then
        error_exit "Failed to $TITLE"
    fi
}

# Parse command-line options
while [[ "$#" -gt 0 ]]; do
    case $1 in
        -v|--verbose) VERBOSE=true ;;
        -h|--help) 
            echo "Usage: $0 [-v|--verbose]"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            echo "Usage: $0 [-v|--verbose]"
            exit 1
            ;;
    esac
    shift
done

# Check if gum is installed
if ! command -v gum &> /dev/null; then
    error_exit "gum could not be found. Please install it from https://github.com/charmbracelet/gum."
fi

# Ask for Python version interactively
PYTHON_VERSION=$(gum input --prompt.foreground $FOREGROUND_COLOUR --prompt "Enter Python version (e.g., 3.9, 3.10): " --value "3.11" --width 80)
if [ -z "$PYTHON_VERSION" ]; then
    error_exit "No Python version provided. Exiting."
fi

# Check if pyproject.toml exists
if [ -f "pyproject.toml" ]; then
    # Extract extras from pyproject.toml using setuptools format
    EXTRAS=$(sed -n '/^\[project.optional-dependencies\]/,/^$/p' pyproject.toml | grep '^[a-zA-Z0-9_-]\+ *=' | sed 's/=.*//' | tr -d ' ' | tr '\n' ' ')
    
    # Check if any extras were found
    if [ -z "$EXTRAS" ]; then
        EXTRAS="none"
    else
        EXTRAS=$(echo $EXTRAS | tr ' ' '\n')  # Convert space-separated list to newline-separated
    fi
    
    # Ask for extras interactively if pyproject.toml exists
    SELECTED_EXTRAS=$(gum choose --no-limit --cursor.foreground $FOREGROUND_COLOUR --item.foreground $FOREGROUND_COLOUR $EXTRAS)
    if [ -z "$SELECTED_EXTRAS" ]; then
        SELECTED_EXTRAS="none"
    else
        SELECTED_EXTRAS=$(echo $SELECTED_EXTRAS | tr ' ' ',')  # Convert space-separated list to comma-separated
    fi
else
    # Ask for a list of packages to install if pyproject.toml does not exist
    PACKAGES=$(gum input --prompt.foreground $FOREGROUND_COLOUR --prompt 'Enter a list of packages to install (comma-separated): ' --width 80 )
    if [ -z "$PACKAGES" ]; then
        SELECTED_EXTRAS="none"
    else
        SELECTED_EXTRAS=$PACKAGES
    fi
fi

# Confirm with the user using gum
gum confirm --affirmative "Yes" --negative "No" "Are you sure you want to create a new virtual environment and install the specified packages/extras?" || error_exit "Aborted by user."

# Set the directory for your virtual environment
VENV_DIR="venv"

# Create a virtual environment with the selected Python version
run_with_spinner "Creating virtual environment" python$PYTHON_VERSION -m venv $VENV_DIR

# Upgrade pip and setuptools
run_with_spinner "Upgrading pip and setuptools" $VENV_DIR/bin/pip install --upgrade pip setuptools

# Install packages with the provided extras or specified packages
if [ -f "pyproject.toml" ]; then
    if [ "$SELECTED_EXTRAS" != "none" ]; then
        run_with_spinner "Installing packages with extras [$SELECTED_EXTRAS]" $VENV_DIR/bin/pip install -e ".[$SELECTED_EXTRAS]"
    fi
else
    IFS=',' read -r -a PACKAGES_ARRAY <<< "$PACKAGES"
    for PACKAGE in "${PACKAGES_ARRAY[@]}"; do
        run_with_spinner "Installing package $PACKAGE" $VENV_DIR/bin/pip install "$PACKAGE"
    done
fi

# Install IPython Kernel and any other necessary packages
run_with_spinner "Installing IPython Kernel and additional packages" $VENV_DIR/bin/pip install jupyter-console ipykernel visidata pandas

# Ask for a custom kernel name
KERNEL_NAME=$(gum input --width 80 --prompt.foreground $FOREGROUND_COLOUR --prompt 'Enter a name for the Jupyter kernel: ' --value "$(basename "$PWD")")
if [ -z "$KERNEL_NAME" ]; then
    KERNEL_NAME=$(basename "$PWD")
fi

# Create a Jupyter kernel for the virtual environment
run_with_spinner "Creating Jupyter kernel" $VENV_DIR/bin/python -m ipykernel install --user --name="$KERNEL_NAME" --display-name "Python ($KERNEL_NAME)"

if [ "$SELECTED_EXTRAS" != "none" ]; then
    echo "$(gum style --foreground $FOREGROUND_COLOUR "Kernel $KERNEL_NAME has been created with extras [$SELECTED_EXTRAS]. You can use it in Jupyter interfaces.")"
else
    echo "$(gum style --foreground $FOREGROUND_COLOUR "Kernel $KERNEL_NAME has been created with no extras. You can use it in Jupyter interfaces.")"
fi

