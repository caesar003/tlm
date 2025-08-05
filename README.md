# Tmux Layout Manager (TLM)

Tmux Layout Manager (TLM) is a command-line tool designed to simplify the management of Tmux layouts. It allows users to load, edit, and manage different Tmux session layouts with flexible session naming capabilities.

## Table of Contents

-   [Features](#features)
-   [Installation](#installation)
-   [Usage](#usage)
-   [Options](#options)
-   [Session Naming](#session-naming)
-   [Layout Inspection](#layout-inspection)
-   [Layout Editing](#layout-editing)
-   [Examples](#examples)
-   [Configuration](#configuration)
-   [Contributing](#contributing)
-   [License](#license)
-   [Author](#author)

## Features

-   Load Tmux layouts from JSON files.
-   **Smart session naming** with directory-based auto-naming or custom names.
-   **Edit layouts** directly with your preferred editor.
-   List available layouts.
-   **Detailed layout inspection** with comprehensive configuration analysis.
-   Display version information.
-   Bash completion support with intelligent session name suggestions.
-   Manual page for detailed usage instructions.
-   JSON validation for layout files.
-   Auto-creation of new layout files with templates.

## Installation

**Prerequisites**: Ensure you have **Tmux** installed and running on your system. You can check if Tmux is installed by running `tmux -V` in your terminal. If it's not installed, you can install it using your package manager.

### Method 1: Using the Install Script

To install Tlm, run the provided installation script. This script will set up the necessary directories and copy the files to their respective locations.

1. **Make the install script executable**:

    ```bash
    chmod +x install.sh
    ```

2. **Run the install script**:
    ```bash
    ./install.sh
    ```

**Note**: You may need to run the install script with `sudo` to have the necessary permissions to install the binary and man page in system directories.

### Method 2: Install from .deb Package

For a cleaner installation option, you can also download the `.deb` package from the [releases page](https://github.com/caesar003/tlm/releases).

1. **Download the .deb package** from the latest release.
2. **Install the package** using the following command:
    ```bash
    sudo dpkg -i tlm*.deb
    ```
3. **Fix any dependency issues** (if necessary) with:
    ```bash
    sudo apt-get install -f
    ```

This method will automatically install Tlm and set up the necessary files in the appropriate directories.

## Usage

Once installed, you can use Tlm with the following options:

```
Usage: ./tlm [OPTIONS]

Options:
  -i, --init [layout_name] [session_name]    Load the specified Tmux layout with optional session name.
  -l, --list                                  List available layouts.
  -d, --detail [layout_name]                  Show detailed information about layouts (all or specific).
  -e, --edit [layout_name]                    Edit the specified layout file (or default if none specified).
  -v, --version                               Show the version number.
  -h, --help                                  Display this help message.

Examples:
  ./tlm -i node                          Load the 'node.json' layout with auto-generated session name.
  ./tlm -i node myproject                Load the 'node.json' layout with session name 'myproject_timestamp'.
  ./tlm -l                               List all available layouts.
  ./tlm -d                               Show detailed information about all layouts.
  ./tlm -d node                          Show detailed information about the 'node' layout.
  ./tlm -e                               Edit the default layout in your configured editor.
  ./tlm -e node                          Edit the 'node' layout in your configured editor.
  ./tlm -v                               Show the version number.

For configuration details, ensure your config file is located at:
  $HOME/.config/tlm/setting.conf

Configuration Options:
  DEFAULT_LAYOUT=<layout_name>    Set the default layout to load when none is specified.
  DEFAULT_EDITOR=<editor_command> Set the default editor for editing layout files.
```

## Options

### `-i, --init [layout_name] [session_name]`

Load the specified Tmux layout with optional session name. If no layout name is provided, uses the default layout from configuration.

### `-l, --list`

Display a simple list of all available layouts.

### `-d, --detail [layout_name]`

Show comprehensive information about layouts:

-   **Without layout name**: Shows system information, default configuration, and summary of all layouts
-   **With layout name**: Shows detailed analysis of the specific layout including window structure, pane configuration, and raw JSON

### `-e, --edit [layout_name]`

Edit layout files using your configured editor:

-   **Without layout name**: Edits the default layout from configuration
-   **With layout name**: Edits the specified layout file
-   **Auto-creation**: Creates new layout files with a basic template if they don't exist
-   **Validation**: Automatically validates JSON syntax after editing

### `-v, --version`

Display the current version of TLM.

### `-h, --help`

Show help information with usage examples.

## Session Naming

TLM provides intelligent session naming to make your Tmux sessions easily identifiable:

### Automatic Directory-Based Naming

When no custom session name is provided, TLM uses the current directory name as the session base name:

```bash
# In directory: /home/caesar/projects/wms/OrderService-Frontend
tlm -i node
# Creates session: OrderService-Frontend_1234567890
```

### Custom Session Names

You can specify a custom session name for more control:

```bash
tlm -i node myproject
# Creates session: myproject_1234567890
```

### Naming Rules

-   All session names include a timestamp suffix for uniqueness
-   Directory names are sanitized (special characters replaced with underscores)
-   Session names are tmux-compatible and easy to identify

## Layout Inspection

The `--detail` flag provides powerful layout inspection capabilities for debugging and understanding your configurations:

### System Overview

```bash
tlm -d
```

Shows:

-   Version and system information
-   Configuration directory paths
-   Default layout setting
-   Summary table of all layouts with validation status

### Detailed Layout Analysis

```bash
tlm -d node
```

Provides:

-   Complete window breakdown with titles
-   Pane split configuration for each window
-   JSON validation status
-   Raw configuration display for debugging
-   File path information

### Example Output

```
Layout Details: node
============================================
File: /home/user/.config/tlm/layouts/node.json
Status: Valid
Windows: 2

Window 1: editor
  - Single pane

Window 2: git + npm
  - Split into 2 panes

Raw Configuration:
-------------------
[
  {
    "title": "editor"
  },
  {
    "title": "git + npm",
    "window_split": 2
  }
]
```

## Layout Editing

The `--edit` flag provides a seamless way to create and modify layout files:

### Basic Editing

```bash
# Edit default layout
tlm -e

# Edit specific layout
tlm -e node
```

### Editor Selection

TLM chooses your editor in the following priority:

1. `DEFAULT_EDITOR` from configuration file
2. `$VISUAL` environment variable
3. `$EDITOR` environment variable
4. `vim` as fallback

### Auto-Creation Feature

When editing a non-existent layout, TLM automatically creates it with a basic template:

```json
[
    {
        "title": "main",
        "window_split": 1
    }
]
```

### JSON Validation

After editing, TLM automatically validates the JSON syntax and reports any errors, ensuring your layouts are always functional.

### Example Workflow

```bash
# Create and edit a new layout for Python development
tlm -e python-dev

# TLM creates the file with a template and opens your editor
# After editing and saving, TLM validates the JSON
# If valid: "Layout file saved and validated successfully."
# If invalid: "Warning: Layout file contains invalid JSON."
```

## Examples

### Basic Usage

```bash
# Load default layout with directory-based naming
tlm -i

# Load specific layout with auto-naming
tlm -i react

# Load layout with custom session name
tlm -i django backend-api
```

### Layout Management

```bash
# Create a new layout
tlm -e new-project

# Edit existing layout
tlm -e node

# Edit default layout
tlm -e
```

### Layout Inspection

```bash
# View all layouts and system info
tlm -d

# Inspect specific layout
tlm -d node

# List layouts (simple view)
tlm -l
```

### Real-World Scenarios

```bash
# Working on a Node.js project
cd ~/projects/ecommerce-api
tlm -i node
# Session: ecommerce-api_1234567890

# Need to modify the node layout for this project
tlm -e node
# Opens editor, make changes, save, and validate

# Starting a new feature branch
tlm -i react feature-checkout
# Session: feature-checkout_1234567890

# Create a custom layout for machine learning work
tlm -e ml-workflow
# Creates new file, opens editor for customization

# Multiple instances of the same project
tlm -i python ml-training
tlm -i python ml-testing
# Sessions: ml-training_1234567890, ml-testing_1234567891

# Debug layout configuration
tlm -d python  # Check if layout is valid and understand structure
```

## Configuration

Tlm uses a configuration file located at `$HOME/.config/tlm/setting.conf`. This file should contain:

```bash
DEFAULT_LAYOUT=your_default_layout_name
DEFAULT_EDITOR=vim
```

Layout files are stored in `$HOME/.config/tlm/layouts/` as JSON files.

### Configuration Options

#### `DEFAULT_LAYOUT`

Specifies which layout to use when no layout name is provided to the `--init` flag.

#### `DEFAULT_EDITOR`

Specifies which editor to use for the `--edit` flag. Falls back to `$VISUAL`, `$EDITOR`, or `vim` if not specified.

### Example Layout File (`node.json`)

```json
[
    {
        "title": "editor",
        "window_split": 1
    },
    {
        "title": "server",
        "window_split": 2
    },
    {
        "title": "logs",
        "window_split": 1
    }
]
```

### Layout File Structure

Each layout file is a JSON array containing window objects:

-   **`title`** (required): The name of the tmux window
-   **`window_split`** (optional): Number of horizontal panes to create in the window (defaults to 1)

## Bash Completion

Tlm supports bash completion for command-line convenience, including intelligent session name suggestions:

-   **Commands**: Tab completion for all available flags (`-i`, `-l`, `-d`, `-e`, `-v`, `-h`)
-   **Layout names**: Auto-completion from your layout files (works with `-i`, `-d`, and `-e` flags)
-   **Session names**: Smart suggestions including current directory name and common patterns

Make sure the completion script is installed in the appropriate directory (see the installation section).

## Manual Page

For more detailed usage instructions, you can access the manual page by running:

```bash
man tlm
```

## Contributing

If you'd like to contribute to Tlm, feel free to submit a pull request or open an issue for any suggestions or improvements.

## License

This project is licensed under the MIT License. See the LICENSE file for details.

## Author

Written by [caesar003](https://github.com/caesar003)
