#!/bin/bash

# PC Repair Toolkit - Setup Script
# This script sets up the directory structure and prepares the environment for the PC Repair Toolkit

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

echo -e "${BLUE}============================================================${NC}"
echo -e "${CYAN}             PC REPAIR TOOLKIT - SETUP                      ${NC}"
echo -e "${BLUE}============================================================${NC}"
echo ""

# Check if running as root
if [ "$(id -u)" -ne 0 ]; then
    echo -e "${YELLOW}Note: Some operations may require root privileges.${NC}"
    echo -e "You may want to run this script with sudo for full functionality."
    echo ""
    read -p "Continue without root privileges? (y/n): " continue_choice
    if [[ ! $continue_choice =~ ^[Yy]$ ]]; then
        echo -e "${RED}Setup aborted.${NC}"
        exit 1
    fi
fi

# Create directory structure
echo -e "${BLUE}Creating directory structure...${NC}"

directories=(
    "config"
    "diagnostics/boot"
    "diagnostics/hardware"
    "diagnostics/network"
    "diagnostics/os"
    "diagnostics/performance"
    "diagnostics/security"
    "repair/boot"
    "repair/hardware"
    "repair/network"
    "repair/os"
    "repair/performance"
    "repair/security"
    "ui/cli"
    "ui/tui"
    "ui/web"
    "ui/gui"
    "utils"
    "platforms/linux"
    "platforms/windows"
    "platforms/macos"
    "docs"
)

for dir in "${directories[@]}"; do
    mkdir -p "${SCRIPT_DIR}/${dir}"
    echo -e "  Created: ${dir}"
done

# Move existing scripts to appropriate directories
echo -e "${BLUE}Moving existing scripts to appropriate directories...${NC}"

# Move boot repair scripts
if [ -f "${SCRIPT_DIR}/fix_boot.sh" ]; then
    cp "${SCRIPT_DIR}/fix_boot.sh" "${SCRIPT_DIR}/repair/boot/"
    echo -e "  Moved: fix_boot.sh to repair/boot/"
fi

if [ -f "${SCRIPT_DIR}/complete_repair.sh" ]; then
    cp "${SCRIPT_DIR}/complete_repair.sh" "${SCRIPT_DIR}/repair/boot/"
    echo -e "  Moved: complete_repair.sh to repair/boot/"
fi

if [ -f "${SCRIPT_DIR}/launch_installer.sh" ]; then
    cp "${SCRIPT_DIR}/launch_installer.sh" "${SCRIPT_DIR}/repair/boot/"
    echo -e "  Moved: launch_installer.sh to repair/boot/"
fi

# Create utility scripts
echo -e "${BLUE}Creating utility scripts...${NC}"

# Logging utility
cat > "${SCRIPT_DIR}/utils/logging.sh" << 'EOF'
#!/bin/bash

# PC Repair Toolkit - Logging Utility

# Log file
LOG_FILE="${SCRIPT_DIR}/pc-repair.log"

# Function to log messages
log() {
    local message="$1"
    local level="${2:-INFO}"
    local timestamp=$(date "+%Y-%m-%d %H:%M:%S")
    echo -e "${timestamp} - ${level} - ${message}" >> "${LOG_FILE}"
}

# Function to log error messages
log_error() {
    log "$1" "ERROR"
}

# Function to log warning messages
log_warning() {
    log "$1" "WARNING"
}

# Function to log info messages
log_info() {
    log "$1" "INFO"
}

# Function to log debug messages
log_debug() {
    log "$1" "DEBUG"
}
EOF
chmod +x "${SCRIPT_DIR}/utils/logging.sh"
echo -e "  Created: utils/logging.sh"

# System info utility
cat > "${SCRIPT_DIR}/utils/system_info.sh" << 'EOF'
#!/bin/bash

# PC Repair Toolkit - System Information Utility

# Function to gather system information
gather_system_info() {
    # Create a temporary file to store system information
    SYSINFO_FILE="${SCRIPT_DIR}/system_info.txt"
    
    echo "PC Repair Toolkit - System Information" > "${SYSINFO_FILE}"
    echo "=======================================" >> "${SYSINFO_FILE}"
    echo "" >> "${SYSINFO_FILE}"
    
    # Date and time
    echo "Date and Time: $(date)" >> "${SYSINFO_FILE}"
    echo "" >> "${SYSINFO_FILE}"
    
    # OS information
    echo "OS Information:" >> "${SYSINFO_FILE}"
    echo "---------------" >> "${SYSINFO_FILE}"
    if [ -f /etc/os-release ]; then
        cat /etc/os-release >> "${SYSINFO_FILE}"
    else
        echo "OS: $(uname -s)" >> "${SYSINFO_FILE}"
        echo "Kernel: $(uname -r)" >> "${SYSINFO_FILE}"
    fi
    echo "" >> "${SYSINFO_FILE}"
    
    # CPU information
    echo "CPU Information:" >> "${SYSINFO_FILE}"
    echo "---------------" >> "${SYSINFO_FILE}"
    if [ -f /proc/cpuinfo ]; then
        grep "model name" /proc/cpuinfo | head -n 1 >> "${SYSINFO_FILE}"
        grep "cpu cores" /proc/cpuinfo | head -n 1 >> "${SYSINFO_FILE}"
    else
        echo "CPU information not available" >> "${SYSINFO_FILE}"
    fi
    echo "" >> "${SYSINFO_FILE}"
    
    # Memory information
    echo "Memory Information:" >> "${SYSINFO_FILE}"
    echo "------------------" >> "${SYSINFO_FILE}"
    if command -v free >/dev/null 2>&1; then
        free -h >> "${SYSINFO_FILE}"
    else
        echo "Memory information not available" >> "${SYSINFO_FILE}"
    fi
    echo "" >> "${SYSINFO_FILE}"
    
    # Disk information
    echo "Disk Information:" >> "${SYSINFO_FILE}"
    echo "----------------" >> "${SYSINFO_FILE}"
    if command -v lsblk >/dev/null 2>&1; then
        lsblk -o NAME,SIZE,FSTYPE,MOUNTPOINT >> "${SYSINFO_FILE}"
    else
        echo "Disk information not available" >> "${SYSINFO_FILE}"
    fi
    echo "" >> "${SYSINFO_FILE}"
    
    # Network information
    echo "Network Information:" >> "${SYSINFO_FILE}"
    echo "-------------------" >> "${SYSINFO_FILE}"
    if command -v ip >/dev/null 2>&1; then
        ip addr >> "${SYSINFO_FILE}"
    elif command -v ifconfig >/dev/null 2>&1; then
        ifconfig >> "${SYSINFO_FILE}"
    else
        echo "Network information not available" >> "${SYSINFO_FILE}"
    fi
    
    echo "" >> "${SYSINFO_FILE}"
    echo "System information gathered and saved to ${SYSINFO_FILE}"
    
    return 0
}
EOF
chmod +x "${SCRIPT_DIR}/utils/system_info.sh"
echo -e "  Created: utils/system_info.sh"

# Create a basic README in each directory
echo -e "${BLUE}Creating README files in each directory...${NC}"

for dir in "${directories[@]}"; do
    echo "# PC Repair Toolkit - ${dir}" > "${SCRIPT_DIR}/${dir}/README.md"
    echo "" >> "${SCRIPT_DIR}/${dir}/README.md"
    echo "This directory contains modules for the PC Repair Toolkit." >> "${SCRIPT_DIR}/${dir}/README.md"
    echo -e "  Created: ${dir}/README.md"
done

# Update main README
echo -e "${BLUE}Updating main README...${NC}"
if [ -f "${SCRIPT_DIR}/README_new.md" ]; then
    mv "${SCRIPT_DIR}/README_new.md" "${SCRIPT_DIR}/README.md"
    echo -e "  Updated: README.md"
fi

# Make all scripts executable
echo -e "${BLUE}Making scripts executable...${NC}"
find "${SCRIPT_DIR}" -name "*.sh" -exec chmod +x {} \;
echo -e "  Made all scripts executable"

echo ""
echo -e "${GREEN}Setup completed successfully!${NC}"
echo -e "You can now run the PC Repair Toolkit using:"
echo -e "  ${CYAN}sudo ./pc-repair.sh${NC}"
echo ""
echo -e "${YELLOW}Note: Most features are still under development.${NC}"
echo -e "Currently, only boot repair functionality is available."
echo -e "${BLUE}============================================================${NC}"
