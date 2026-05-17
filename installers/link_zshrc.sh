#!/bin/bash

# =============================================================================
# link_zshrc.sh
# Symlinks dotfiles/config/.zshrc → ~/.zshrc
# =============================================================================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
RESET='\033[0m'

log_ok() { echo -e "  ${GREEN}[✔]${RESET} $1"; }
log_warn() { echo -e "  ${YELLOW}[➜]${RESET} $1"; }
log_err() {
  echo -e "  ${RED}[✘]${RESET} $1"
  exit 1
}

# =============================================================================
# PATHS — adjust DOTFILES_DIR if your repo lives somewhere else
# =============================================================================

DOTFILES_DIR="${DOTFILES_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)}"
SOURCE="${DOTFILES_DIR}/config/.zshrc"
TARGET="${HOME}/.zshrc"

# =============================================================================
# CHECK SOURCE EXISTS
# =============================================================================

echo ""
log_warn "Dotfiles dir : ${DOTFILES_DIR}"
log_warn "Source       : ${SOURCE}"
log_warn "Target       : ${TARGET}"
echo ""

if [[ ! -f "$SOURCE" ]]; then
  log_err "Source file not found: ${SOURCE}"
fi

# =============================================================================
# CHECK IF ALREADY LINKED
# =============================================================================

if [[ -L "$TARGET" && "$(readlink "$TARGET")" == "$SOURCE" ]]; then
  log_ok "Already linked — nothing to do."
  echo ""
  exit 0
fi

# =============================================================================
# BACKUP EXISTING .zshrc
# =============================================================================

if [[ -e "$TARGET" || -L "$TARGET" ]]; then
  BACKUP="${TARGET}.bak.$(date +%Y%m%d_%H%M%S)"
  mv "$TARGET" "$BACKUP" &&
    log_warn "Existing file backed up → ${BACKUP}" ||
    log_err "Could not back up ${TARGET}"
fi

# =============================================================================
# CREATE SYMLINK
# =============================================================================

ln -sf "$SOURCE" "$TARGET" &&
  log_ok "Linked: ${TARGET} → ${SOURCE}" ||
  log_err "Failed to create symlink."

# =============================================================================
# REPORT
# =============================================================================

echo ""
echo -e "  ${GREEN}${BOLD}Done!${RESET}"
printf "  ${BOLD}%-10s${RESET} %s\n" "Link:" "${TARGET}"
printf "  ${BOLD}%-10s${RESET} %s\n" "Source:" "${SOURCE}"
echo ""
echo -e "  Run ${BOLD}source ~/.zshrc${RESET} to reload your config in the current session."
echo ""
