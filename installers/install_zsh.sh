#!/bin/bash

# =============================================================================
# installers/install_zsh.sh
# =============================================================================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
RESET='\033[0m'

PACKAGE_NAME="ZSH"

log_ok() { echo -e "  ${GREEN}[✔]${RESET} ${PACKAGE_NAME} — $1"; }
log_warn() { echo -e "  ${YELLOW}[➜]${RESET} ${PACKAGE_NAME} — $1"; }
log_err() {
  echo -e "  ${RED}[✘]${RESET} ${PACKAGE_NAME} — $1"
  exit 1
}

# Resolve the real user's home dir when running under sudo
REAL_USER="${SUDO_USER:-$USER}"
REAL_HOME=$(eval echo "~${REAL_USER}")

# =============================================================================
# 1. CHECK IF ALREADY INSTALLED
#    Also checks if ZSH is the default shell — switches it over if not.
# =============================================================================

if command -v zsh &>/dev/null; then
  log_ok "Already installed — $(zsh --version)"

  CURRENT_SHELL=$(getent passwd "$REAL_USER" | cut -d: -f7)
  ZSH_PATH=$(command -v zsh)

  if [[ "$CURRENT_SHELL" == "$ZSH_PATH" ]]; then
    log_ok "Already the default shell — nothing to change."
  else
    log_warn "Default shell is '${CURRENT_SHELL}', switching to ZSH..."
    chsh -s "$ZSH_PATH" "$REAL_USER" &&
      log_ok "Default shell switched to ZSH." ||
      log_err "Failed to switch default shell."
  fi

  exit 0
fi

log_warn "Not found. Starting installation..."

# =============================================================================
# 2. DEPENDENCIES
# =============================================================================

log_warn "Installing dependencies..."

apt-get update -y >/dev/null 2>&1
apt-get install -y \
  zsh \
  curl \
  git >/dev/null 2>&1 || log_err "Failed to install dependencies."

log_ok "Dependencies ready."

# =============================================================================
# 3. INSTALL PACKAGE
# =============================================================================

log_warn "Installing Oh My Zsh..."

# Run Oh My Zsh installer as the real user (not root) — unattended
sudo -u "$REAL_USER" sh -c \
  "RUNZSH=no CHSH=no $(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" ||
  log_err "Oh My Zsh installation failed."

log_ok "Oh My Zsh installed."

log_warn "Cloning zsh-syntax-highlighting plugin..."
sudo -u "$REAL_USER" git clone https://github.com/zsh-users/zsh-syntax-highlighting.git \
  "${REAL_HOME}/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting" \
  >/dev/null 2>&1 || log_err "Failed to clone zsh-syntax-highlighting."
log_ok "zsh-syntax-highlighting ready."

log_warn "Cloning zsh-autosuggestions plugin..."
sudo -u "$REAL_USER" git clone https://github.com/zsh-users/zsh-autosuggestions \
  "${REAL_HOME}/.oh-my-zsh/custom/plugins/zsh-autosuggestions" \
  >/dev/null 2>&1 || log_err "Failed to clone zsh-autosuggestions."
log_ok "zsh-autosuggestions ready."

# =============================================================================
# 4. ENABLE SETTINGS
#    Only calls chsh if ZSH is not already the default shell.
# =============================================================================

CURRENT_SHELL=$(getent passwd "$REAL_USER" | cut -d: -f7)
ZSH_PATH=$(command -v zsh)

if [[ "$CURRENT_SHELL" == "$ZSH_PATH" ]]; then
  log_ok "Default shell is already ZSH — skipping."
else
  log_warn "Switching default shell from '${CURRENT_SHELL}' to ZSH for '${REAL_USER}'..."
  chsh -s "$ZSH_PATH" "$REAL_USER" &&
    log_ok "Default shell set to ZSH." ||
    log_err "Failed to set ZSH as default shell."
fi

# =============================================================================
# 5. POST-INSTALL — symlink config/zshrc → ~/.zshrc
# =============================================================================

log_warn "Linking dotfile config..."

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ZSHRC_SOURCE="${SCRIPT_DIR}/../config/zshrc"
ZSHRC_TARGET="${REAL_HOME}/.zshrc"

if [[ ! -f "$ZSHRC_SOURCE" ]]; then
  log_warn "No config/zshrc found at ${ZSHRC_SOURCE} — skipping symlink."
  log_warn "Create the file and re-run, or link manually:"
  echo -e "        ln -sf ${ZSHRC_SOURCE} ${ZSHRC_TARGET}"
else
  # Back up any existing .zshrc before replacing it
  if [[ -f "$ZSHRC_TARGET" && ! -L "$ZSHRC_TARGET" ]]; then
    mv "$ZSHRC_TARGET" "${ZSHRC_TARGET}.bak"
    log_warn "Existing .zshrc backed up → ${ZSHRC_TARGET}.bak"
  fi

  sudo -u "$REAL_USER" ln -sf "$ZSHRC_SOURCE" "$ZSHRC_TARGET" ||
    log_err "Failed to create symlink."

  log_ok "Symlink created: ${ZSHRC_TARGET} → ${ZSHRC_SOURCE}"
fi

# =============================================================================
# 6. REPORT
# =============================================================================

echo ""
echo -e "  ${GREEN}${BOLD}${PACKAGE_NAME} installation complete!${RESET}"
printf "  ${BOLD}%-24s${RESET} %s\n" "ZSH version:" "$(zsh --version 2>/dev/null)"
printf "  ${BOLD}%-24s${RESET} %s\n" "Default shell:" "$(getent passwd "$REAL_USER" | cut -d: -f7)"
printf "  ${BOLD}%-24s${RESET} %s\n" "Oh My Zsh:" "${REAL_HOME}/.oh-my-zsh"
printf "  ${BOLD}%-24s${RESET} %s\n" "Syntax highlighting:" "${REAL_HOME}/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting"
printf "  ${BOLD}%-24s${RESET} %s\n" "Autosuggestions:" "${REAL_HOME}/.oh-my-zsh/custom/plugins/zsh-autosuggestions"
printf "  ${BOLD}%-24s${RESET} %s\n" "Config symlink:" "${ZSHRC_TARGET}"
echo ""
echo -e "  ${YELLOW}Note: Log out and back in (or run 'exec zsh') for the shell change to take effect.${RESET}"
echo ""
