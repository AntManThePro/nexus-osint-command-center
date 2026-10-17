#!/bin/bash

# ==========================================
# NEXUS OSINT VAULT MANAGER
# Field node repo manager · DoubleA @ AntManThePro
# ==========================================

VAULT_DIR="$HOME/OSINT_VAULT"
PASS_HASH="8c6976e5b5410415bde908bd4dee15dfb167a9c873fc4bb8a81f6f2ab448a918" # SHA-256 of "admin" — change me

declare -A REPOS=(
    ["Sherlock"]="https://github.com/sherlock-project/sherlock.git"
    ["theHarvester"]="https://github.com/laramies/theHarvester.git"
    ["SpiderFoot"]="https://github.com/smicallef/spiderfoot.git"
    ["Photon"]="https://github.com/s0md3v/Photon.git"
    ["WhatsMyName"]="https://github.com/WebBreacher/WhatsMyName.git"
    ["OSINT-Framework"]="https://github.com/lockfale/OSINT-Framework.git"
    ["PhoneInfoga"]="https://github.com/sundowndev/phoneinfoga.git"
    ["Amass"]="https://github.com/owasp-amass/amass.git"
)

CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
PINK='\033[0;35m'
NC='\033[0m'

# Gate first
echo -e "${CYAN}"
cat << "EOF"
 ███╗   ██╗███████╗██╗  ██╗██╗   ██╗███████╗
 ████╗  ██║██╔════╝╚██╗██╔╝██║   ██║██╔════╝
 ██╔██╗ ██║█████╗   ╚███╔╝ ██║   ██║███████╗
 ██║╚██╗██║██╔══╝   ██╔██╗ ██║   ██║╚════██║
 ██║ ╚████║███████╗██╔╝ ██╗╚██████╔╝███████║
 ╚═╝  ╚═══╝╚══════╝╚═╝  ╚═╝ ╚════╝ ╚══════╝
EOF
echo -e "${GREEN}    OSINT VAULT MANAGER · NEXUS Field Node${NC}\n"

read -sp "Enter Vault Passphrase: " user_pass
echo ""
# Simple hash check (requires openssl or sha256sum)
if command -v sha256sum >/dev/null 2>&1; then
    input_hash=$(echo -n "$user_pass" | sha256sum | awk '{print $1}')
elif command -v shasum >/dev/null 2>&1; then
    input_hash=$(echo -n "$user_pass" | shasum -a 256 | awk '{print $1}')
else
    echo -e "${PINK}sha256sum not found. Skipping hash gate for this session.${NC}"
    input_hash="$PASS_HASH"
fi

if [ "$input_hash" != "$PASS_HASH" ]; then
    echo -e "${PINK}ACCESS DENIED. Session terminated.${NC}"
    exit 1
fi
echo -e "${GREEN}Access Granted. Vault unlocked.${NC}\n"

mkdir -p "$VAULT_DIR"

show_menu() {
    echo -e "Location: ${CYAN}$VAULT_DIR${NC}"
    echo "----------------------------------------"
    echo -e "${YELLOW}[1]${NC} Clone & Install all top repos"
    echo -e "${YELLOW}[2]${NC} Update existing repos (git pull)"
    echo -e "${YELLOW}[3]${NC} List contents of the Vault"
    echo -e "${YELLOW}[4]${NC} Exit"
    echo "----------------------------------------"
    read -p "Select an option: " choice
    handle_choice "$choice"
}

handle_choice() {
    case $1 in
        1)
            echo -e "\n${CYAN}[*] Initializing Vault Cloning Sequence...${NC}"
            for tool in "${!REPOS[@]}"; do
                if [ -d "$VAULT_DIR/$tool" ]; then
                    echo -e "${YELLOW}[-]${NC} $tool already present. Skipping."
                else
                    echo -e "${GREEN}[+]${NC} Cloning $tool..."
                    git clone --depth 1 "${REPOS[$tool]}" "$VAULT_DIR/$tool" 2>/dev/null || echo -e "${PINK}[!] Clone failed for $tool${NC}"
                fi
            done
            echo -e "\nDone. Returning to menu...\n"
            show_menu
            ;;
        2)
            echo -e "\n${CYAN}[*] Updating Vault Repositories...${NC}"
            for dir in "$VAULT_DIR"/*/; do
                if [ -d "$dir/.git" ]; then
                    tool_name=$(basename "$dir")
                    echo -e "${GREEN}[+]${NC} Updating $tool_name..."
                    (cd "$dir" && git pull --ff-only 2>/dev/null) || echo -e "${PINK}[!] Update failed${NC}"
                fi
            done
            echo -e "\nDone. Returning to menu...\n"
            show_menu
            ;;
        3)
            echo -e "\n${CYAN}[*] Current Vault Contents:${NC}"
            ls -1 "$VAULT_DIR" 2>/dev/null || echo "(empty)"
            echo -e "\nReturning to menu...\n"
            show_menu
            ;;
        4)
            echo -e "\n${CYAN}Closing Vault. Session Terminated.${NC}"
            exit 0
            ;;
        *)
            echo -e "\n${YELLOW}Invalid option.${NC} Returning to menu...\n"
            show_menu
            ;;
    esac
}

show_menu
