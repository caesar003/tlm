# Tmux Layout Manager (TLM)

Tmux Layout Manager (TLM) is a command-line tool designed to simplify the management of Tmux layouts. It allows users to load and manage different Tmux session layouts easily.

## Table of Contents

-   [Features](#features)
-   [Installation](#installation)
-   [Usage](#usage)
-   [Options](#options)
-   [Examples](#examples)
-   [Configuration](#configuration)
-   [Contributing](#contributing)
-   [License](#license)
-   [Author](#author)

## Features

-   Load Tmux layouts from JSON files.
-   List available layouts.
-   Display version information.
-   Bash completion support.
-   Manual page for detailed usage instructions.

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
  -i, --init [layout_name]    Load the specified Tmux layout.
  -l, --list                  List available layouts.
  -v, --version               Show the version number.
  -h, --help                  Display this help message.

Examples:
  ./tlm -i node                  Load the layout defined in 'node.json'.
  ./tlm -l                       List all available layouts.
  ./tlm -v                       Show the version number.

For configuration details, ensure your config file is located at:
  $HOME/.config/tlm/setting.conf
```

## Configuration

Tlm uses a configuration file located at `$HOME/.config/tlm/setting.conf`. Ensure this file exists to customize your layouts.

## Bash Completion

Tlm supports bash completion for command-line convenience. Make sure the completion script is installed in the appropriate directory (see the installation section).

## Manual Page

For more detailed usage instructions, you can access the manual page by running:

```bash
man tlm
```

## Contributing

If you'd like to contribute to Tlm, feel free to submit a pull request or open an issue for any suggestions or improvements.

## License

This project is licensed under the MIT License. See the LICENSE file for details.
