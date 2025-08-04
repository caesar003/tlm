#!/bin/bash

# Tmux Layout Manager - Core Business Logic
# file: /home/caesar/projects/dev-tools/prod/tlm/src/lib/core.sh
# Source the configuration file
source "$(dirname "${BASH_SOURCE[0]}")/config.sh"

# Validate that a layout file has proper JSON structure
validate_layout_file() {
  local layout_file="$1"

  if [[ ! -f "$layout_file" ]]; then
    return $EXIT_ERROR
  fi

  if jq empty "$layout_file" 2>/dev/null; then
    return $EXIT_SUCCESS
  else
    return $EXIT_ERROR
  fi
}

# Generate a session name based on directory or custom name
generate_session_name() {
  local custom_session_name="$1"

  if [[ -n "$custom_session_name" ]]; then
    # Use provided custom name with timestamp
    echo "${custom_session_name}_$(date +$TIMESTAMP_FORMAT)"
  else
    # Extract directory name from current working directory
    local current_dir=$(basename "$PWD")
    # Clean the directory name (remove special characters, replace with underscores)
    local clean_dir_name=$(echo "$current_dir" | sed 's/[^a-zA-Z0-9_-]/_/g')
    echo "${clean_dir_name}_$(date +$TIMESTAMP_FORMAT)"
  fi
}

# Create tmux session and windows based on layout file
create_tmux_session() {
  local layout_file="$1"
  local session_name="$2"

  # Create first window
  local first_window_title=$(jq -r '.[0].title' "$layout_file")
  tmux new-session -d -s "$session_name" -n "$first_window_title"

  # Create additional windows
  local num_windows=$(jq '. | length' "$layout_file")
  for ((i = 1; i < num_windows; i++)); do
    local window_title=$(jq -r ".[$i].title" "$layout_file")
    tmux new-window -a -t "$session_name:" -n "$window_title"

    # Handle window splits if specified
    local window_split=$(jq -r ".[$i].window_split // empty" "$layout_file")
    if [[ -n "$window_split" && "$window_split" -gt 1 ]]; then
      for ((j = 1; j < window_split; j++)); do
        tmux split-window -h -t "$session_name:$(($i + 1))"
        tmux select-layout -t "$session_name:$(($i + 1))" tiled
      done
    fi
  done
}

# Load and execute a specific layout file
load_file() {
  local layout_file="$1"
  local custom_session_name="$2"

  local session_name=$(generate_session_name "$custom_session_name")

  create_tmux_session "$layout_file" "$session_name"

  echo "Created tmux session: $session_name"
  tmux attach -t "$session_name"
}

# Load a layout by name
load_layout() {
  local layout_name="$1"
  local custom_session_name="$2"
  local layout_file="$LAYOUT_DIR/$layout_name.json"

  if [[ ! -f "$layout_file" ]]; then
    echo "Error: Layout file '$layout_file' does not exist." >&2
    return $EXIT_ERROR
  fi

  if ! validate_layout_file "$layout_file"; then
    echo "Error: Layout file '$layout_file' is invalid." >&2
    return $EXIT_ERROR
  fi

  load_file "$layout_file" "$custom_session_name"
}

# Get default layout from config file
get_default_layout() {
  if [[ ! -f "$CONFIG_FILE" ]]; then
    echo "Error: Config file '$CONFIG_FILE' does not exist." >&2
    return $EXIT_ERROR
  fi

  local default_layout=$(grep -E "^DEFAULT_LAYOUT=" "$CONFIG_FILE" | cut -d '=' -f2)
  if [[ -z "$default_layout" ]]; then
    echo "Error: DEFAULT_LAYOUT not defined in config file." >&2
    return $EXIT_ERROR
  fi

  echo "$default_layout"
}

# Main load function that handles layout name resolution
load() {
  local layout_name="$1"
  local custom_session_name="$2"

  if [[ -n "$layout_name" ]]; then
    load_layout "$layout_name" "$custom_session_name"
  else
    local default_layout=$(get_default_layout)
    if [[ $? -ne $EXIT_SUCCESS ]]; then
      return $EXIT_ERROR
    fi
    load_layout "$default_layout" "$custom_session_name"
  fi
}

# List all available layouts
list_layouts() {
  if compgen -G "$LAYOUT_DIR/*.json" >/dev/null; then
    echo "Available layouts:"
    for layout_file in "$LAYOUT_DIR"/*.json; do
      local layout_name=$(basename "$layout_file" .json)
      echo "  - $layout_name"
    done
  else
    echo "No layouts found in $LAYOUT_DIR."
  fi
}

# Display detailed information about a specific layout
show_layout_detail() {
  local layout_name="$1"
  local layout_file="$LAYOUT_DIR/$layout_name.json"

  echo "Layout Details: $layout_name"
  echo "============================================"

  if [[ ! -f "$layout_file" ]]; then
    echo "Error: Layout file '$layout_file' does not exist." >&2
    return $EXIT_ERROR
  fi

  if ! validate_layout_file "$layout_file"; then
    echo "Error: Layout file '$layout_file' is invalid JSON." >&2
    return $EXIT_ERROR
  fi

  echo "File: $layout_file"
  echo "Status: Valid"

  local num_windows=$(jq '. | length' "$layout_file")
  echo "Windows: $num_windows"
  echo ""

  # Display window details
  for ((i = 0; i < num_windows; i++)); do
    local window_title=$(jq -r ".[$i].title" "$layout_file")
    local window_split=$(jq -r ".[$i].window_split // empty" "$layout_file")

    echo "Window $((i + 1)): $window_title"
    if [[ -n "$window_split" && "$window_split" -gt 1 ]]; then
      echo "  - Split into $window_split panes"
    else
      echo "  - Single pane"
    fi
    echo ""
  done

  # Display raw JSON
  echo "Raw Configuration:"
  echo "-------------------"
  jq '.' "$layout_file"
}

# Show details for all layouts or a specific one
show_layout_details() {
  local layout_name="$1"

  # Show system information first
  echo "Tmux Layout Manager - System Information"
  echo "========================================"
  echo "Version: $TLM_VERSION"
  echo "Config Directory: $CONFIG_DIR"
  echo "Layout Directory: $LAYOUT_DIR"
  echo "Config File: $CONFIG_FILE"
  echo ""

  # Show default layout from config
  if [[ -f "$CONFIG_FILE" ]]; then
    local default_layout=$(get_default_layout 2>/dev/null)
    if [[ $? -eq $EXIT_SUCCESS ]]; then
      echo "Default Layout: $default_layout"
    else
      echo "Default Layout: Not configured"
    fi
  else
    echo "Default Layout: Config file not found"
  fi
  echo ""

  if [[ -n "$layout_name" ]]; then
    # Show details for specific layout
    show_layout_detail "$layout_name"
  else
    # Show summary of all layouts
    echo "All Available Layouts:"
    echo "======================"

    if compgen -G "$LAYOUT_DIR/*.json" >/dev/null; then
      for layout_file in "$LAYOUT_DIR"/*.json; do
        local layout_name=$(basename "$layout_file" .json)
        local num_windows=$(jq '. | length' "$layout_file" 2>/dev/null || echo "Invalid")
        local status="Valid"

        if ! validate_layout_file "$layout_file"; then
          status="Invalid JSON"
          num_windows="N/A"
        fi

        printf "  %-15s | %s windows | %s\n" "$layout_name" "$num_windows" "$status"
      done
    else
      echo "  No layouts found in $LAYOUT_DIR"
    fi
    echo ""
    echo "Use '$SCRIPT_NAME -d <layout_name>' for detailed information about a specific layout."
  fi
}
