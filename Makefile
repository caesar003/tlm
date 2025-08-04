# Tmux Layout Manager - Makefile
# Build automation for development and packaging

# Package information
PACKAGE_NAME = tlm
VERSION = $(shell cat VERSION 2>/dev/null | tr -d '"' | tr -d "'" | xargs)
ARCHITECTURE = all
MAINTAINER = caesar003 <caesarmuksid@gmail.com>

# Directories
SRC_DIR = src
LIB_DIR = $(SRC_DIR)/lib
BUILD_DIR = build
PACKAGE_DIR = $(BUILD_DIR)/$(PACKAGE_NAME)_$(VERSION)_$(ARCHITECTURE)
DEB_DIR = $(PACKAGE_DIR)/DEBIAN
USR_BIN_DIR = $(PACKAGE_DIR)/usr/bin
USR_LIB_DIR = $(PACKAGE_DIR)/usr/lib/$(PACKAGE_NAME)
USR_SHARE_DIR = $(PACKAGE_DIR)/usr/share
MAN_DIR = $(USR_SHARE_DIR)/man/man1

# Source files
MAIN_SCRIPT = $(SRC_DIR)/$(PACKAGE_NAME)
LIB_SCRIPTS = $(wildcard $(LIB_DIR)/*.sh)
MAN_PAGE = share/man/man1/$(PACKAGE_NAME).1

# Build targets
.PHONY: all dev build install clean help test version-check

all: version-check build

help:
	@echo "Available targets:"
	@echo "  dev          - Set up development environment"
	@echo "  build        - Build debian package"
	@echo "  install      - Install from debian package"
	@echo "  clean        - Remove build artifacts"
	@echo "  test         - Run basic tests"
	@echo "  version-check- Check version consistency"
	@echo "  bump-version - Update version number"
	@echo "  sync-man-version - Update man page version to match VERSION file"
	@echo "  fix-version  - Fix VERSION file format (remove quotes)"
	@echo "  help         - Show this help message"

version-check:
	@echo "Checking version consistency..."
	@if [ -z "$(VERSION)" ]; then \
		echo "ERROR: VERSION file not found or empty!"; \
		exit 1; \
	fi
	@echo "Current version: $(VERSION)"
	@if ! echo "$(VERSION)" | grep -E '^[0-9]+\.[0-9]+\.[0-9]+$$' > /dev/null; then \
		echo "WARNING: Version format should be X.Y.Z (semantic versioning)"; \
	fi
	@if [ -f "$(MAN_PAGE)" ]; then \
		man_version=$$(grep -oE '\\"[0-9]+\.[0-9]+\.[0-9]+\\"' $(MAN_PAGE) | tr -d '"'); \
		if [ "$$man_version" != "$(VERSION)" ]; then \
			echo "WARNING: Man page version ($$man_version) differs from VERSION file ($(VERSION))"; \
			echo "Run 'make sync-man-version' to fix this"; \
		else \
			echo "Man page version matches VERSION file: $(VERSION)"; \
		fi; \
	else \
		echo "WARNING: Man page not found at $(MAN_PAGE)"; \
	fi

dev: version-check
	@echo "Setting up development environment..."
	@export TLM_DEV_MODE=1
	@chmod +x $(MAIN_SCRIPT)
	@chmod +x $(LIB_SCRIPTS)
	@echo "Development environment ready!"
	@echo "Current version: $(VERSION)"
	@echo "You can now run: TLM_DEV_MODE=1 ./$(MAIN_SCRIPT)"

test: dev
	@echo "Running basic tests..."
	@echo "Testing version command..."
	@TLM_DEV_MODE=1 ./$(MAIN_SCRIPT) --version
	@echo "Testing help command..."
	@TLM_DEV_MODE=1 ./$(MAIN_SCRIPT) --help > /dev/null
	@echo "Testing list command..."
	@TLM_DEV_MODE=1 ./$(MAIN_SCRIPT) --list
	@echo "Basic tests passed!"

build: clean version-check
	@echo "Building debian package for version $(VERSION)..."
	
	# Create package directory structure
	@mkdir -p $(DEB_DIR)
	@mkdir -p $(USR_BIN_DIR)
	@mkdir -p $(USR_LIB_DIR)
	@mkdir -p $(MAN_DIR)
	
	# Copy VERSION file to package
	@cp VERSION $(USR_LIB_DIR)/
	
	# Copy main executable
	@cp $(MAIN_SCRIPT) $(USR_BIN_DIR)/
	@chmod 755 $(USR_BIN_DIR)/$(PACKAGE_NAME)
	
	# Copy library files
	@cp $(LIB_SCRIPTS) $(USR_LIB_DIR)/
	@chmod 644 $(USR_LIB_DIR)/*.sh
	
	# Copy and compress man page if it exists
	@if [ -f "$(MAN_PAGE)" ]; then \
		echo "Copying man page from $(MAN_PAGE)..."; \
		sed "s/__VERSION__/$(VERSION)/g" $(MAN_PAGE) > $(MAN_DIR)/$(PACKAGE_NAME).1; \
		gzip -9 $(MAN_DIR)/$(PACKAGE_NAME).1; \
		echo "Man page processed and compressed"; \
	else \
		echo "Man page not found at $(MAN_PAGE)"; \
	fi
	
	# Generate debian control files
	@$(MAKE) generate-control
	@$(MAKE) generate-postinst
	@$(MAKE) generate-prerm
	
	# Build the package
	@dpkg-deb --build $(PACKAGE_DIR)
	@echo "Package built: $(PACKAGE_DIR).deb"

generate-control:
	@echo "Package: $(PACKAGE_NAME)" > $(DEB_DIR)/control
	@echo "Version: $(VERSION)" >> $(DEB_DIR)/control
	@echo "Section: utils" >> $(DEB_DIR)/control
	@echo "Priority: optional" >> $(DEB_DIR)/control
	@echo "Architecture: $(ARCHITECTURE)" >> $(DEB_DIR)/control
	@echo "Depends: tmux, jq" >> $(DEB_DIR)/control
	@echo "Maintainer: $(MAINTAINER)" >> $(DEB_DIR)/control
	@echo "Description: Tmux Layout Manager" >> $(DEB_DIR)/control
	@echo " A command-line tool for managing tmux session layouts." >> $(DEB_DIR)/control
	@echo " Allows you to define and load predefined tmux layouts" >> $(DEB_DIR)/control
	@echo " with multiple windows and panes." >> $(DEB_DIR)/control

generate-postinst:
	@echo "#!/bin/bash" > $(DEB_DIR)/postinst
	@echo "set -e" >> $(DEB_DIR)/postinst
	@echo "" >> $(DEB_DIR)/postinst
	@echo "# Create user config directory if it doesn't exist" >> $(DEB_DIR)/postinst
	@echo "if [ -n \"\$$SUDO_USER\" ]; then" >> $(DEB_DIR)/postinst
	@echo "    USER_HOME=\$$(getent passwd \"\$$SUDO_USER\" | cut -d: -f6)" >> $(DEB_DIR)/postinst
	@echo "    CONFIG_DIR=\"\$$USER_HOME/.config/tlm\"" >> $(DEB_DIR)/postinst
	@echo "    LAYOUT_DIR=\"\$$CONFIG_DIR/layouts\"" >> $(DEB_DIR)/postinst
	@echo "    " >> $(DEB_DIR)/postinst
	@echo "    sudo -u \"\$$SUDO_USER\" mkdir -p \"\$$CONFIG_DIR\"" >> $(DEB_DIR)/postinst
	@echo "    sudo -u \"\$$SUDO_USER\" mkdir -p \"\$$LAYOUT_DIR\"" >> $(DEB_DIR)/postinst
	@echo "fi" >> $(DEB_DIR)/postinst
	@echo "" >> $(DEB_DIR)/postinst
	@echo "echo \"Tmux Layout Manager v$(VERSION) installed successfully!\"" >> $(DEB_DIR)/postinst
	@echo "echo \"Run 'tlm --help' to get started.\"" >> $(DEB_DIR)/postinst
	@chmod 755 $(DEB_DIR)/postinst

generate-prerm:
	@echo "#!/bin/bash" > $(DEB_DIR)/prerm
	@echo "set -e" >> $(DEB_DIR)/prerm
	@echo "" >> $(DEB_DIR)/prerm
	@echo "# Nothing to do before removal" >> $(DEB_DIR)/prerm
	@echo "exit 0" >> $(DEB_DIR)/prerm
	@chmod 755 $(DEB_DIR)/prerm

install: build
	@echo "Installing package..."
	@sudo dpkg -i $(PACKAGE_DIR).deb
	@echo "Installation complete!"

uninstall:
	@echo "Uninstalling package..."
	@sudo dpkg -r $(PACKAGE_NAME)
	@echo "Uninstall complete!"

clean:
	@echo "Cleaning build artifacts..."
	@rm -rf $(BUILD_DIR)
	@echo "Clean complete!"

# Version management
bump-version:
	@echo "Current version: $(VERSION)"
	@read -p "Enter new version (format: X.Y.Z): " new_version; \
	if echo "$new_version" | grep -E '^[0-9]+\.[0-9]+\.[0-9]+$' > /dev/null; then \
		echo "$new_version" > VERSION; \
		if [ -f "$(MAN_PAGE)" ]; then \
			sed -i "s/\"[0-9]\+\.[0-9]\+\.[0-9]\+\"/\"$new_version\"/g" $(MAN_PAGE); \
			echo "Updated man page version to $new_version"; \
		fi; \
		echo "Version updated to $new_version"; \
		echo "Note: Version is now dynamically loaded from VERSION file"; \
	else \
		echo "ERROR: Invalid version format. Use X.Y.Z (e.g., 1.2.3)"; \
		exit 1; \
	fi

# Development helpers
run: dev
	@TLM_DEV_MODE=1 ./$(MAIN_SCRIPT) $(ARGS)

debug: dev
	@TLM_DEBUG=1 TLM_DEV_MODE=1 ./$(MAIN_SCRIPT) $(ARGS)

# Fix version file format
fix-version:
	@echo "Fixing VERSION file format..."
	@if [ -f VERSION ]; then \
		cat VERSION | tr -d '"' | tr -d "'" | xargs > VERSION.tmp && mv VERSION.tmp VERSION; \
		echo "VERSION file format fixed: $(cat VERSION)"; \
	else \
		echo "VERSION file not found!"; \
		exit 1; \
	fi

# Update version in man page to match VERSION file
sync-man-version:
	@echo "Syncing man page version with VERSION file..."
	@if [ -f "VERSION" ] && [ -f "$(MAN_PAGE)" ]; then \
		current_version=$(cat VERSION | tr -d '"' | tr -d "'" | xargs); \
		sed -i "s/\"[0-9]\+\.[0-9]\+\.[0-9]\+\"/\"$current_version\"/g" $(MAN_PAGE); \
		echo "Man page version updated to $current_version"; \
	else \
		echo "ERROR: VERSION file or man page not found!"; \
		exit 1; \
	fi
