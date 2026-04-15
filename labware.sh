#!/usr/bin/env bash
####################################################################
# labware.sh
####################################################################
# File:         labware.sh
# Author:       Ragdata
# Date:         12/04/2026
# License:      MIT License
# Repository:	https://github.com/Ragdata/.dotfiles
# Copyright:    Copyright © 2026 Redeyed Technologies
####################################################################
# PRE-FLIGHT
####################################################################

set -e

# COLORS (minimal)
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Repository Info
REPO="Ragdata/.labware"
#GITHUB_API_URL="https://api.github.com/repos/${REPO}"
REPO_URL="https://github.com/${REPO}.git"
REPO_DIR="${HOME}/downloads/.labware"

####################################################################
# FUNCTIONS
####################################################################
# Functions to print coloured output
print_status() { echo -e "${GREEN}[INFO] $1${NC}"; }
print_warning() { echo -e "${YELLOW}[WARNING] $1${NC}"; }
print_error() { echo -e "${RED}[ERROR] $1${NC}"; }

detect_platform() {
    local os arch

    # Detect OS & only support Linux
    case "$(uname -s)" in
        Linux*)
            os="Linux"
            ;;
        *)
            print_error "Unsupported operating system: $(uname -s).  This script only supports Linux"
            exit 1
            ;;
    esac

    # Detect Architecture & only support amd64 & arm64
    case "$(uname -m)" in
        x86_64|amd64)
            arch="amd64"
            ;;
        arm64|aarch64)
            arch="arm64"
            ;;
        *)
            print_error "Unsupported architecture: $(uname -m). Only amd64 & arm64 are supported on Linux"
            exit 1
            ;;
    esac
    echo "${os}_${arch}"
}

clone_repo() {
    if [ -d "${HOME}"/downloads/.labware ]; then
        print_status "Updating repository ${REPO_DIR}"
        cd "${HOME}"/downloads/.labware
        if git pull; then
            print_status "Repository Updated!"
        else
            print_error "Failed to update repository ..."
            exit 1
        fi
        cd --
    else
        print_status "Cloning repository ${REPO_URL} to ${REPO_DIR}"
        # Create install directory if it doesn't exist
        mkdir -p "${HOME}/downloads"
        # Clone repository
        if git clone "${REPO_URL}" "${REPO_DIR}"; then
            print_status "Repository Retrieved!"
        else
            print_error "Failed to retrieve repository ..."
            exit 1
        fi
    fi
}
####################################################################
# MAIN PROCESS
####################################################################
PLATFORM=$(detect_platform)
print_status "Detected platform: ${PLATFORM}"

print_status "Retrieving latest version of repository ..."
clone_repo

if [ -f "${REPO_DIR}/install.sh" ]; then
    print_status "Executing repository installer ..."
    chmod 0755 "${REPO_DIR}/install.sh"
    bash -i "${REPO_DIR}/install.sh"
else
    print_error "Repository installer not found"
    exit 1
fi
