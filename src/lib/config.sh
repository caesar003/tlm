#!/bin/bash

# Tmux Layout Manager - Configuration and Constants

# Version information
TLM_VERSION="{{VERSION}}"

# Directory and file paths
CONFIG_DIR="$HOME/.config/tlm"
CONFIG_FILE="$CONFIG_DIR/setting.conf"
LAYOUT_DIR="$CONFIG_DIR/layouts"

# Default values
DEFAULT_LAYOUT=""

# Exit codes
EXIT_SUCCESS=0
EXIT_ERROR=1

# Session naming configuration
TIMESTAMP_FORMAT="%s"

# Layout validation settings
REQUIRED_JSON_FIELDS=("title")

# Help text constants
SCRIPT_NAME="$(basename "$0")"
HELP_USAGE="Usage: $SCRIPT_NAME [OPTIONS]"
HELP_OPTIONS="Options:
  -i, --init [layout_name] [session_name]    Load the specified Tmux layout with optional session name.
  -l, --list                                  List available layouts.
  -d, --detail [layout_name]                  Show detailed information about layouts (all or specific).
  -v, --version                               Show the version number.
  -h, --help                                  Display this help message."

HELP_EXAMPLES="Examples:
  $SCRIPT_NAME -i node                          Load the 'node.json' layout with auto-generated session name.
  $SCRIPT_NAME -i node myproject                Load the 'node.json' layout with session name 'myproject_timestamp'.
  $SCRIPT_NAME -l                               List all available layouts.
  $SCRIPT_NAME -d                               Show detailed information about all layouts.
  $SCRIPT_NAME -d node                          Show detailed information about the 'node' layout.
  $SCRIPT_NAME -v                               Show the version number."

HELP_SESSION_NAMING="Session Naming:
  - If no session name is provided, the current directory name will be used.
  - For '/home/caesar/projects/wms/OrderService-Frontend', session becomes 'OrderService-Frontend_timestamp'.
  - If a custom session name is provided, it becomes 'custom_name_timestamp'."

HELP_CONFIG_INFO="For configuration details, ensure your config file is located at:
  $CONFIG_FILE"
