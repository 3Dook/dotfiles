#!/bin/bash

# =============================================================================
# apt_manager.sh
# 1. apt update & upgrade
# 2. Simple apt packages  — check & install
# 3. Custom packages      — check & run dedicated installer scripts
# 4. Final summary        — unified report across all packages
# =============================================================================

# ---- Colour codes -----------------------------------------------------------
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
RESET='\033[0m'

# ---- Script directory (used to resolve installer paths) ---------------------
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# =============================================================================
# CONFIGURATION — edit these two lists to suit your environment
# =============================================================================

# Simple apt packages ---------------------------------------------------------
PACKAGES=(
  git
  build-essential
  curl
  ripgrep
  fd-find
  bpytop
  tmux
  zoxide
  eza
  bat
  nodejs
  zsh
  fzf
)

# Custom packages (cannot be installed with a plain apt-get install) ----------
# Format: "Display Name|version check command|path to installer script"
# The version check command should print a non-empty string when installed.
CUSTOM_PACKAGES=(
  #"Docker|docker --version|${SCRIPT_DIR}/installers/install_docker.sh"
  # "NVM|nvm --version|${SCRIPT_DIR}/installers/install_nvm.sh"
  # "Homebrew|brew --version|${SCRIPT_DIR}/installers/install_brew.sh"
  "ZSH|zsh --version|${SCRIPT_DIR}/installers/install_zsh.sh"

)

# =============================================================================
# HELPER FUNCTIONS
# =============================================================================

print_header() {
  echo -e "\n${CYAN}${BOLD}============================================================${RESET}"
  echo -e "${CYAN}${BOLD}  $1${RESET}"
  echo -e "${CYAN}${BOLD}============================================================${RESET}\n"
}

print_ok() { echo -e "  ${GREEN}[✔]${RESET} $1"; }
print_warn() { echo -e "  ${YELLOW}[➜]${RESET} $1"; }
print_err() { echo -e "  ${RED}[✘]${RESET} $1"; }
print_divider() { echo -e "  ${CYAN}------------------------------------------------------------${RESET}"; }

# =============================================================================
# ROOT CHECK
# =============================================================================

if [[ $EUID -ne 0 ]]; then
  echo -e "${RED}[ERROR]${RESET} This script must be run as root or with sudo."
  echo -e "        Try: ${BOLD}sudo bash apt_manager.sh${RESET}"
  exit 1
fi

# =============================================================================
# RESULT ACCUMULATORS  (populated by steps 2 & 3; read by step 4)
# =============================================================================

# Simple packages
APT_ALREADY=()   # "pkg|version"  — was already installed
APT_INSTALLED=() # "pkg|version"  — freshly installed this run
APT_FAILED=()    # "pkg"          — install attempt failed

# Custom packages
CUSTOM_ALREADY=()   # "name|version" — already present
CUSTOM_INSTALLED=() # "name|version" — installed by script this run
CUSTOM_FAILED=()    # "name|reason"  — script missing or errored

# =============================================================================
# STEP 1 — apt update & upgrade
# =============================================================================

print_header "Step 1 — apt update & upgrade"

echo -e "${YELLOW}  Updating package lists...${RESET}"
if apt-get update -y 2>&1 | sed 's/^/    /'; then
  print_ok "Package lists updated."
else
  print_err "apt-get update failed. Check your network or sources."
  exit 1
fi

echo ""
echo -e "${YELLOW}  Upgrading installed packages...${RESET}"
if apt-get upgrade -y 2>&1 | tail -5 | sed 's/^/    /'; then
  print_ok "All packages upgraded."
else
  print_err "apt-get upgrade encountered errors (continuing anyway)."
fi

# =============================================================================
# STEP 2 — Simple apt packages
# =============================================================================

print_header "Step 2 — Simple apt packages"

for pkg in "${PACKAGES[@]}"; do
  if dpkg-query -W -f='${Status}' "$pkg" 2>/dev/null | grep -q "install ok installed"; then
    ver=$(dpkg-query -W -f='${Version}' "$pkg" 2>/dev/null)
    print_ok "${pkg} — already installed"
    APT_ALREADY+=("${pkg}|${ver}")
  else
    print_warn "${pkg} — not found, installing..."
    if apt-get install -y "$pkg" >/dev/null 2>&1; then
      ver=$(dpkg-query -W -f='${Version}' "$pkg" 2>/dev/null)
      print_ok "${pkg} — installed successfully"
      APT_INSTALLED+=("${pkg}|${ver}")
    else
      print_err "${pkg} — FAILED to install"
      APT_FAILED+=("$pkg")
    fi
  fi
done

# =============================================================================
# STEP 3 — Custom package installers
# =============================================================================

print_header "Step 3 — Custom package installers"

for entry in "${CUSTOM_PACKAGES[@]}"; do
  IFS='|' read -r pkg_name version_cmd installer_script <<<"$entry"

  echo -e "  ${BOLD}Checking:${RESET} ${pkg_name}"

  detected_version=""
  [[ -n "$version_cmd" ]] && detected_version=$(eval "$version_cmd" 2>/dev/null)

  if [[ -n "$detected_version" ]]; then
    print_ok "${pkg_name} — already installed (${detected_version})"
    CUSTOM_ALREADY+=("${pkg_name}|${detected_version}")
  else
    print_warn "${pkg_name} — not detected, running installer script..."

    if [[ ! -f "$installer_script" ]]; then
      print_err "Installer script not found: ${installer_script}"
      CUSTOM_FAILED+=("${pkg_name}|missing installer: ${installer_script}")
      echo ""
      continue
    fi

    [[ ! -x "$installer_script" ]] && chmod +x "$installer_script"

    if bash "$installer_script"; then
      new_ver=$(eval "$version_cmd" 2>/dev/null || echo "installed")
      print_ok "${pkg_name} — installer completed (${new_ver})"
      CUSTOM_INSTALLED+=("${pkg_name}|${new_ver}")
    else
      print_err "${pkg_name} — installer script exited with an error"
      CUSTOM_FAILED+=("${pkg_name}|installer failed")
    fi
  fi
  echo ""
done

# =============================================================================
# STEP 4 — Final unified summary report
# =============================================================================

print_header "Step 4 — Final Summary Report"

TOTAL_OK=$((${#APT_ALREADY[@]} + ${#APT_INSTALLED[@]} + ${#CUSTOM_ALREADY[@]} + ${#CUSTOM_INSTALLED[@]}))
TOTAL_FAIL=$((${#APT_FAILED[@]} + ${#CUSTOM_FAILED[@]}))

echo -e "  ${BOLD}Packages checked  :${RESET} $((${#PACKAGES[@]} + ${#CUSTOM_PACKAGES[@]}))"
echo -e "  ${BOLD}Successful        :${RESET} ${GREEN}${TOTAL_OK}${RESET}"
echo -e "  ${BOLD}Failed            :${RESET} ${RED}${TOTAL_FAIL}${RESET}"
echo ""
print_divider

# ---- APT — already installed ------------------------------------------------
echo ""
echo -e "  ${BOLD}[ APT ] Already installed (${#APT_ALREADY[@]}):${RESET}"
if [[ ${#APT_ALREADY[@]} -eq 0 ]]; then
  echo -e "    (none)"
else
  for entry in "${APT_ALREADY[@]}"; do
    IFS='|' read -r n v <<<"$entry"
    printf "    ${GREEN}%-28s${RESET} v%s\n" "$n" "$v"
  done
fi

# ---- APT — newly installed --------------------------------------------------
echo ""
echo -e "  ${BOLD}[ APT ] Newly installed (${#APT_INSTALLED[@]}):${RESET}"
if [[ ${#APT_INSTALLED[@]} -eq 0 ]]; then
  echo -e "    (none)"
else
  for entry in "${APT_INSTALLED[@]}"; do
    IFS='|' read -r n v <<<"$entry"
    printf "    ${CYAN}%-28s${RESET} v%s\n" "$n" "$v"
  done
fi

# ---- APT — failed -----------------------------------------------------------
echo ""
echo -e "  ${BOLD}[ APT ] Failed (${#APT_FAILED[@]}):${RESET}"
if [[ ${#APT_FAILED[@]} -eq 0 ]]; then
  echo -e "    ${GREEN}(none — all apt packages OK)${RESET}"
else
  for pkg in "${APT_FAILED[@]}"; do
    printf "    ${RED}%-28s${RESET} check apt logs\n" "$pkg"
  done
fi

echo ""
print_divider

# ---- Custom — already installed ---------------------------------------------
echo ""
echo -e "  ${BOLD}[ CUSTOM ] Already installed (${#CUSTOM_ALREADY[@]}):${RESET}"
if [[ ${#CUSTOM_ALREADY[@]} -eq 0 ]]; then
  echo -e "    (none)"
else
  for entry in "${CUSTOM_ALREADY[@]}"; do
    IFS='|' read -r n v <<<"$entry"
    printf "    ${GREEN}%-28s${RESET} %s\n" "$n" "$v"
  done
fi

# ---- Custom — newly installed -----------------------------------------------
echo ""
echo -e "  ${BOLD}[ CUSTOM ] Newly installed (${#CUSTOM_INSTALLED[@]}):${RESET}"
if [[ ${#CUSTOM_INSTALLED[@]} -eq 0 ]]; then
  echo -e "    (none)"
else
  for entry in "${CUSTOM_INSTALLED[@]}"; do
    IFS='|' read -r n v <<<"$entry"
    printf "    ${CYAN}%-28s${RESET} %s\n" "$n" "$v"
  done
fi

# ---- Custom — failed --------------------------------------------------------
echo ""
echo -e "  ${BOLD}[ CUSTOM ] Failed (${#CUSTOM_FAILED[@]}):${RESET}"
if [[ ${#CUSTOM_FAILED[@]} -eq 0 ]]; then
  echo -e "    ${GREEN}(none — all custom packages OK)${RESET}"
else
  for entry in "${CUSTOM_FAILED[@]}"; do
    IFS='|' read -r n reason <<<"$entry"
    printf "    ${RED}%-28s${RESET} %s\n" "$n" "$reason"
  done
fi

echo ""
print_divider
echo ""

if [[ $TOTAL_FAIL -eq 0 ]]; then
  echo -e "  ${GREEN}${BOLD}✔  All packages are installed and up to date.${RESET}"
else
  echo -e "  ${YELLOW}${BOLD}⚠  ${TOTAL_FAIL} package(s) failed — review the errors above.${RESET}"
fi

echo ""
echo -e "  Run ${BOLD}dpkg -l${RESET} to browse the full system package list."
echo ""
