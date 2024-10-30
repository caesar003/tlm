#!/bin/bash

# Define variables
BIN_DIR="/usr/local/bin"
CONFIG_DIR="$HOME/.config/tlm"
LAYOUTS_DIR="$CONFIG_DIR/layouts"
MAN_DIR="/usr/share/man/man1"
COMPLETION_DIR="/etc/bash_completion.d"

# Function to create directories
create_directories() {
	echo "Creating necessary directories..."

	mkdir -p "$CONFIG_DIR"
	mkdir -p "$LAYOUTS_DIR"
}

# Function to install the binary
install_binary() {
	echo "Installing Tlm binary..."

	cp bin/tlm "$BIN_DIR/tlm"
	chmod +x "$BIN_DIR/tlm"
}

# Function to install the man page
install_man_page() {
	echo "Installing man page..."

	cp share/man/man1/tlm.1 "$MAN_DIR/"
	mandb # Update the man database
}

# Function to install bash completion
install_bash_completion() {
	echo "Installing bash completion..."

	cp share/bash-completion/completions/tlm "$COMPLETION_DIR/"
}

# Function to display installation summary
show_summary() {
	echo "Installation completed successfully!"
	echo "You can now run 'tlm' from any terminal."
	echo "Configuration files are located at: $CONFIG_DIR"
}

# Execute installation steps
create_directories
install_binary
install_man_page
install_bash_completion
show_summary
