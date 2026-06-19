#!/bin/bash
set -euo pipefail

# --- Colors ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# --- Script Config ---
SCRIPT_URL="https://raw.githubusercontent.com/Gvte-Kali/Twenty_Tools/main/Twenty_Tools.py"
INSTALL_DIR="/usr/local/bin"
SCRIPT_NAME="twentytools"

# --- Spinner Function (for steps) ---
spinner() {
    local pid=$1
    local delay=0.1
    local spinstr='|/-\'
    while [ "$(ps a | awk '{print $1}' | grep $pid)" ]; do
        local temp=${spinstr#?}
        printf "  [%s]  " "$temp"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b\b"
        done
        printf "    \b\b\b\b"
}

# --- Progress Bar for Download (using pv) ---
download_with_progress() {
    local url=$1
    local output=$2
    echo -e "${CYAN}  Downloading $SCRIPT_NAME...${NC}"
    if command -v pv &>/dev/null; then
        curl -sSL "$url" | pv -N "Downloading" > "$output"
        else
            echo -e "${YELLOW}  Note: Install 'pv' for a progress bar (sudo apt install pv)${NC}"
            curl -sSL "$url" -o "$output"
            fi
}

# --- Error Handling ---
error_exit() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
    exit 1
}

# --- Check Command Existence ---
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# --- Step 1: Install Dependencies (paramiko) ---
echo -e "${BLUE}[1/3] Installing dependencies (paramiko)...${NC}"

# Try apt first (recommended for Debian/Ubuntu)
if command_exists apt; then
    echo -e "  → Attempting with apt (python3-paramiko)..."
    if sudo apt update >/dev/null 2>&1 && sudo apt install -y python3-paramiko >/dev/null 2>&1; then
        echo -e "  ${GREEN}✓ Successfully installed paramiko via apt${NC}"
        else
            echo -e "  ${YELLOW}⚠ apt failed, trying pipx...${NC}"
            
            # Try pipx
            if command_exists pipx; then
                if pipx install paramiko >/dev/null 2>&1; then
                    echo -e "  ${GREEN}✓ Successfully installed paramiko via pipx${NC}"
                    else
                        echo -e "  ${YELLOW}⚠ pipx failed, trying pip --user...${NC}"
                        fi
                        else
                            echo -e "  ${YELLOW}⚠ pipx not found, trying pip --user...${NC}"
                            fi
                            
                            # Try pip --user
                            if ! python3 -m pip install --user paramiko >/dev/null 2>&1; then
                                echo -e "  ${YELLOW}⚠ pip --user failed, trying pip --break-system-packages...${NC}"
                                if ! python3 -m pip install --break-system-packages paramiko >/dev/null 2>&1; then
                                    error_exit "Failed to install paramiko. Try:\n  - sudo apt install python3-paramiko\n  - or create a venv: 'python3 -m venv ~/venv && source ~/venv/bin/activate'"
                                    else
                                        echo -e "  ${GREEN}✓ Successfully installed paramiko via pip --break-system-packages${NC}"
                                        fi
                                        else
                                            echo -e "  ${GREEN}✓ Successfully installed paramiko via pip --user${NC}"
                                            fi
                                            fi
                                            else
                                                error_exit "apt not found. This script is designed for Debian/Ubuntu-based systems."
                                                fi
                                                
                                                # --- Step 2: Download the Python Script ---
                                                echo -e "${BLUE}[2/3] Downloading $SCRIPT_NAME...${NC}"
                                                TEMP_FILE=$(mktemp)
                                                download_with_progress "$SCRIPT_URL" "$TEMP_FILE"
                                                
                                                # Verify it's not HTML
                                                if head -n 1 "$TEMP_FILE" | grep -q "<!DOCTYPE html>"; then
                                                    rm -f "$TEMP_FILE"
                                                    error_exit "Downloaded file appears to be HTML (incorrect URL?). Check $SCRIPT_URL."
                                                    fi
                                                    echo -e "  ${GREEN}✓ Download completed${NC}"
                                                    
                                                    # --- Step 3: Install the Script ---
                                                    echo -e "${BLUE}[3/3] Installing $SCRIPT_NAME to $INSTALL_DIR...${NC}"
                                                    
                                                    # Create install directory if needed
                                                    if [ ! -d "$INSTALL_DIR" ]; then
                                                        sudo mkdir -p "$INSTALL_DIR"
                                                        fi
                                                        
                                                        # Copy, set permissions, and ownership
                                                        sudo cp "$TEMP_FILE" "$INSTALL_DIR/$SCRIPT_NAME" &
                                                        spinner $!
                                                        sudo chmod 755 "$INSTALL_DIR/$SCRIPT_NAME"
                                                        sudo chown root:root "$INSTALL_DIR/$SCRIPT_NAME"
                                                        rm -f "$TEMP_FILE"
                                                        
                                                        # Verify PATH
                                                        if ! command -v "$SCRIPT_NAME" >/dev/null 2>&1; then
                                                            echo -e "${YELLOW}⚠ $SCRIPT_NAME is not in your PATH.${NC}"
                                                            echo -e "  Add $INSTALL_DIR to your PATH with:"
                                                            echo -e "  ${GREEN}export PATH=\"$INSTALL_DIR:\$PATH\"${NC}"
                                                            echo -e "  Then run: ${GREEN}source ~/.bashrc${NC} or ${GREEN}source ~/.zshrc${NC}"
                                                            fi
                                                            
                                                            # --- Success Message ---
                                                            echo -e "\n${GREEN}========================================${NC}"
                                                            echo -e "${GREEN}✅ Installation completed successfully!${NC}"
                                                            echo -e "${GREEN}========================================${NC}"
                                                            echo -e "Run ${GREEN}$SCRIPT_NAME${NC} to start the tool."
                                                            echo -e "${CYAN}Tip: For a progress bar during download, install 'pv':${NC}"
                                                            echo -e "  ${BLUE}sudo apt install pv${NC}"
