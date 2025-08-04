#!/bin/bash

# Tmux Layout Manager - Configuration and Constants
# Version: 1.0.4

# Version information
readonly TLM_VERSION="1.0.4"

# Directory and file paths
readonly CONFIG_DIR="$HOME/.config/tlm"
readonly CONFIG_FILE="$CONFIG_DIR/setting.conf"
readonly LAYOUT_DIR="$CONFIG_DIR/layouts"

# Default values
readonly DEFAULT_LAYOUT=""

# Exit codes
readonly EXIT_SUCCESS=0
readonly EXIT_ERROR=1

# Session naming configuration
readonly TIMESTAMP_FORMAT="%s"

# Layout validation settings
readonly REQUIRED_JSON_FIELDS=("title")

# Help text constants
readonly SCRIPT_NAME="$(basename "$0")"
readonly HELP_USAGE="Usage: $SCRIPT_NAME [OPTIONS]"
readonly HELP_OPTIONS="Options:
  -i, --init [layout_name] [session_name]    Load the specified Tmux layout with optional session name.
  -l, --list                                  List available layouts.
  -v, --version                               Show the version number.
  -h, --help                                  Display this help message."

readonly HELP_EXAMPLES="Examples:
  $SCRIPT_NAME -i node                          Load the 'node.json' layout with auto-generated session name.
  $SCRIPT_NAME -i node myproject                Load the 'node.json' layout with session name 'myproject_timestamp'.
  $SCRIPT_NAME -l                               List all available layouts.
  $SCRIPT_NAME -v                               Show the version number."

readonly HELP_SESSION_NAMING="Session Naming:
  - If no session name is provided, the current directory name will be used.
  - For '/home/caesar/projects/wms/OrderService-Frontend', session becomes 'OrderService-Frontend_timestamp'.
  - If a custom session name is provided, it becomes 'custom_name_timestamp'."

readonly HELP_CONFIG_INFO="For configuration details, ensure your config file is located at:
  $CONFIG_FILE"
