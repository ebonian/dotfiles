#!/usr/bin/env bash
# NixOS Generation Cleanup Tool
# Lists generations and allows selective removal

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

clear
echo -e "${BLUE}╔════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║           NixOS Generation Cleanup Tool                        ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════════╝${NC}"
echo

# Get current generation
CURRENT=$(readlink /nix/var/nix/profiles/system | grep -oP 'system-\K\d+')
echo -e "${GREEN}> Current generation: ${CURRENT}${NC}"
echo

# List all generations
echo -e "${YELLOW}Available generations:${NC}"
echo "────────────────────────────────────────────────────────────────────────────"
nixos-rebuild list-generations 2>/dev/null
echo "────────────────────────────────────────────────────────────────────────────"
echo

# Instructions
echo -e "${YELLOW}Options:${NC}"
echo -e "  Delete specific generations:  ${GREEN}229 230 231${NC}"
echo -e "  Delete all old generations:   ${GREEN}old${NC}"
echo -e "  Keep only last N generations: ${GREEN}keep 5${NC}"
echo -e "  Run garbage collection only:  ${GREEN}gc${NC}"
echo -e "  Full clean (delete old + gc): ${GREEN}full${NC}"
echo -e "  Quit without changes:         ${GREEN}q${NC}"
echo
printf "Enter your choice: "
read -r INPUT </dev/tty

echo

if [ "$INPUT" = "q" ] || [ -z "$INPUT" ]; then
    echo -e "${YELLOW}Exiting...${NC}"
    exit 0
fi

if [ "$INPUT" = "gc" ]; then
    echo -e "${YELLOW}> Running garbage collection (keeping all generations)...${NC}"
    sudo nix-store --gc
    echo -e "${GREEN}> Done!${NC}"
    exit 0
fi

if [ "$INPUT" = "full" ]; then
    echo -e "${YELLOW}> Performing full cleanup...${NC}"
    echo -e "${YELLOW}> Deleting all old generations...${NC}"
    sudo nix-env --delete-generations old -p /nix/var/nix/profiles/system
    echo -e "${YELLOW}> Running garbage collection...${NC}"
    sudo nix-collect-garbage -d
    echo
    echo -e "${GREEN}> Full cleanup complete!${NC}"
    echo
    echo -e "${YELLOW}Remaining generations:${NC}"
    nixos-rebuild list-generations 2>/dev/null
    exit 0
fi

if [ "$INPUT" = "old" ]; then
    echo -e "${YELLOW}> Deleting all old generations...${NC}"
    sudo nix-env --delete-generations old -p /nix/var/nix/profiles/system
elif [[ "$INPUT" =~ ^keep\ ([0-9]+)$ ]]; then
    KEEP="${BASH_REMATCH[1]}"
    echo -e "${YELLOW}> Keeping only the last ${KEEP} generations...${NC}"
    
    # Get all generation numbers except header, in reverse order (newest first)
    mapfile -t ALL_GENS < <(nixos-rebuild list-generations 2>/dev/null | tail -n +2 | awk '{print $1}')
    TOTAL=${#ALL_GENS[@]}
    
    if [ $TOTAL -le $KEEP ]; then
        echo -e "${GREEN}> Already have ${TOTAL} generations. Nothing to delete.${NC}"
        exit 0
    fi
    
    # Delete all except the first KEEP (newest) generations
    GENS_TO_DELETE=""
    for ((i=KEEP; i<TOTAL; i++)); do
        GENS_TO_DELETE="$GENS_TO_DELETE ${ALL_GENS[$i]}"
    done
    
    if [ -n "$GENS_TO_DELETE" ]; then
        echo -e "${YELLOW}Deleting generations:${GENS_TO_DELETE}${NC}"
        sudo nix-env --delete-generations $GENS_TO_DELETE -p /nix/var/nix/profiles/system
    fi
else
    # Validate input - should be space-separated numbers
    for NUM in $INPUT; do
        if ! [[ "$NUM" =~ ^[0-9]+$ ]]; then
            echo -e "${RED}> Error: '$NUM' is not a valid generation number${NC}"
            exit 1
        fi
        if [ "$NUM" = "$CURRENT" ]; then
            echo -e "${RED}> Error: Cannot delete current generation ($CURRENT)${NC}"
            exit 1
        fi
    done
    
    echo -e "${YELLOW}> Deleting generations: ${INPUT}${NC}"
    sudo nix-env --delete-generations $INPUT -p /nix/var/nix/profiles/system
fi

# Ask about garbage collection
echo
printf "Run garbage collection to free disk space? [y/N]: "
read -r GC_CHOICE </dev/tty

if [[ "$GC_CHOICE" =~ ^[Yy]$ ]]; then
    echo
    echo -e "${YELLOW}> Running garbage collection (keeping remaining generations)...${NC}"
    sudo nix-store --gc
fi

# Show summary
echo
echo -e "${GREEN}> Cleanup complete!${NC}"
echo
echo -e "${YELLOW}Remaining generations:${NC}"
nixos-rebuild list-generations 2>/dev/null | tail -6
