#!/bin/bash

# PC Repair Toolkit - Main Script
# A comprehensive solution for diagnosing and fixing computer issues across all platforms
# https://github.com/BhekumusaEric/pc-repair-toolkit

# Version
VERSION="0.2.0"

# Description: This toolkit provides a comprehensive set of tools for diagnosing and
# repairing various computer issues across Windows, macOS, and Linux platforms.
# It addresses boot problems, hardware failures, malware infections, performance issues,
# network connectivity problems, and more.

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Log file
LOG_FILE="${SCRIPT_DIR}/pc-repair.log"

# Check if running as root
if [ "$(id -u)" -ne 0 ]; then
    echo -e "${RED}This script must be run as root. Please use sudo.${NC}"
    exit 1
fi

# Function to log messages
log() {
    local message="$1"
    local timestamp=$(date "+%Y-%m-%d %H:%M:%S")
    echo -e "${timestamp} - ${message}" >> "${LOG_FILE}"
}

# Function to display banner
display_banner() {
    clear
    echo -e "${BLUE}============================================================${NC}"
    echo -e "${CYAN}                   PC REPAIR TOOLKIT                        ${NC}"
    echo -e "${BLUE}============================================================${NC}"
    echo -e "${GREEN}Version:${NC} ${VERSION}"
    echo -e "${GREEN}System:${NC}  $(uname -a)"
    echo -e "${BLUE}============================================================${NC}"
    echo ""
}

# Function to detect operating system
detect_os() {
    if [ -f /etc/os-release ]; then
        # freedesktop.org and systemd
        . /etc/os-release
        OS=$NAME
        VER=$VERSION_ID
    elif type lsb_release >/dev/null 2>&1; then
        # linuxbase.org
        OS=$(lsb_release -si)
        VER=$(lsb_release -sr)
    elif [ -f /etc/lsb-release ]; then
        # For some versions of Debian/Ubuntu without lsb_release command
        . /etc/lsb-release
        OS=$DISTRIB_ID
        VER=$DISTRIB_RELEASE
    elif [ -f /etc/debian_version ]; then
        # Older Debian/Ubuntu/etc.
        OS=Debian
        VER=$(cat /etc/debian_version)
    elif [ -f /etc/SuSe-release ]; then
        # Older SuSE/etc.
        OS=SuSE
        VER=$(cat /etc/SuSe-release)
    elif [ -f /etc/redhat-release ]; then
        # Older Red Hat, CentOS, etc.
        OS=$(cat /etc/redhat-release | cut -d ' ' -f 1)
        VER=$(cat /etc/redhat-release | cut -d ' ' -f 3)
    else
        # Fall back to uname, e.g. "Linux <version>", also works for BSD, etc.
        OS=$(uname -s)
        VER=$(uname -r)
    fi

    echo -e "${GREEN}Detected OS:${NC} $OS $VER"
    log "Detected OS: $OS $VER"
}

# Function to gather system information
gather_system_info() {
    echo -e "${BLUE}Gathering system information...${NC}"

    # CPU info
    CPU_INFO=$(grep "model name" /proc/cpuinfo | head -n 1 | cut -d ':' -f 2 | sed 's/^[ \t]*//')
    CPU_CORES=$(grep -c "processor" /proc/cpuinfo)
    echo -e "${GREEN}CPU:${NC} $CPU_INFO ($CPU_CORES cores)"

    # Memory info
    MEM_TOTAL=$(free -h | grep "Mem:" | awk '{print $2}')
    echo -e "${GREEN}Memory:${NC} $MEM_TOTAL"

    # Disk info
    echo -e "${GREEN}Disk Information:${NC}"
    lsblk -o NAME,SIZE,FSTYPE,MOUNTPOINT | grep -v "loop" | sed 's/^/  /'

    # Network info
    echo -e "${GREEN}Network Interfaces:${NC}"
    ip -o addr show | grep -v "lo" | awk '{print "  " $2 ": " $4}' | cut -d '/' -f 1

    log "System information gathered"
}

# Function to display main menu
display_main_menu() {
    echo -e "${BLUE}============================================================${NC}"
    echo -e "${CYAN}                        MAIN MENU                           ${NC}"
    echo -e "${BLUE}============================================================${NC}"
    echo -e "  ${YELLOW}1.${NC} Run Full System Diagnostics"
    echo -e "  ${YELLOW}2.${NC} Boot Diagnostics and Repair"
    echo -e "  ${YELLOW}3.${NC} Hardware Diagnostics and Repair"
    echo -e "  ${YELLOW}4.${NC} Network Diagnostics and Repair"
    echo -e "  ${YELLOW}5.${NC} OS Diagnostics and Repair"
    echo -e "  ${YELLOW}6.${NC} Performance Optimization"
    echo -e "  ${YELLOW}7.${NC} Security and Malware Removal"
    echo -e "  ${YELLOW}8.${NC} Data Recovery and Backup"
    echo -e "  ${YELLOW}9.${NC} Application Troubleshooting"
    echo -e "  ${YELLOW}10.${NC} System Reset and Reinstallation"
    echo -e "  ${YELLOW}11.${NC} Create Bootable USB"
    echo -e "  ${YELLOW}12.${NC} Automated OS Installation"
    echo -e "  ${YELLOW}13.${NC} Mac-Specific Tools"
    echo -e "  ${YELLOW}14.${NC} Windows-Specific Tools"
    echo -e "  ${YELLOW}15.${NC} Linux-Specific Tools"
    echo -e "  ${YELLOW}16.${NC} Advanced System Access Recovery"
    echo -e "  ${YELLOW}17.${NC} Extreme Data Recovery"
    echo -e "  ${YELLOW}18.${NC} System Information"
    echo -e "  ${YELLOW}19.${NC} Help and Documentation"
    echo -e "  ${YELLOW}0.${NC} Exit"
    echo -e "${BLUE}============================================================${NC}"
    echo -e "Enter your choice [0-19]: "
}

# Function to handle boot diagnostics and repair
boot_diagnostics_repair() {
    echo -e "${BLUE}============================================================${NC}"
    echo -e "${CYAN}               BOOT DIAGNOSTICS AND REPAIR                  ${NC}"
    echo -e "${BLUE}============================================================${NC}"

    # Check if we're running from a live USB/CD
    if mount | grep -q "cdrom"; then
        echo -e "${GREEN}Running from live media. Good!${NC}"
    else
        echo -e "${YELLOW}Warning: Not running from live media. Some repair options may not be available.${NC}"
    fi

    # Boot menu
    echo -e "  ${YELLOW}1.${NC} Check Boot Configuration"
    echo -e "  ${YELLOW}2.${NC} Repair Bootloader (GRUB)"
    echo -e "  ${YELLOW}3.${NC} Fix MBR/GPT"
    echo -e "  ${YELLOW}4.${NC} Reinstall Bootloader"
    echo -e "  ${YELLOW}5.${NC} Back to Main Menu"
    echo -e "${BLUE}============================================================${NC}"
    echo -e "Enter your choice [1-5]: "

    read -r boot_choice

    case $boot_choice in
        1)
            echo -e "${BLUE}Checking boot configuration...${NC}"
            # Call to boot configuration check script
            # source "${SCRIPT_DIR}/diagnostics/boot/check_config.sh"
            echo -e "${YELLOW}This feature is under development.${NC}"
            ;;
        2)
            echo -e "${BLUE}Repairing bootloader...${NC}"
            # Call to bootloader repair script
            source "${SCRIPT_DIR}/fix_boot.sh"
            ;;
        3)
            echo -e "${BLUE}Fixing MBR/GPT...${NC}"
            # Call to MBR/GPT fix script
            # source "${SCRIPT_DIR}/repair/boot/fix_mbr_gpt.sh"
            echo -e "${YELLOW}This feature is under development.${NC}"
            ;;
        4)
            echo -e "${BLUE}Reinstalling bootloader...${NC}"
            # Call to bootloader reinstall script
            source "${SCRIPT_DIR}/complete_repair.sh"
            ;;
        5)
            return
            ;;
        *)
            echo -e "${RED}Invalid choice. Please try again.${NC}"
            boot_diagnostics_repair
            ;;
    esac
}

# Main function
main() {
    display_banner
    detect_os
    gather_system_info

    while true; do
        display_main_menu
        read -r choice

        case $choice in
            1)
                echo -e "${BLUE}Running full system diagnostics...${NC}"
                # Call to full diagnostics script
                # source "${SCRIPT_DIR}/diagnostics/full_diagnostics.sh"
                echo -e "${YELLOW}This feature is under development.${NC}"
                ;;
            2)
                boot_diagnostics_repair
                ;;
            3)
                echo -e "${BLUE}Running hardware diagnostics...${NC}"
                # Call to hardware diagnostics script
                # source "${SCRIPT_DIR}/diagnostics/hardware/hardware_diagnostics.sh"
                echo -e "${YELLOW}This feature is under development. See hardware_diagnostics_spec.md for details.${NC}"
                ;;
            4)
                echo -e "${BLUE}Running network diagnostics...${NC}"
                # Call to network diagnostics script
                # source "${SCRIPT_DIR}/diagnostics/network/network_diagnostics.sh"
                echo -e "${YELLOW}This feature is under development.${NC}"
                ;;
            5)
                echo -e "${BLUE}Running OS diagnostics...${NC}"
                # Call to OS diagnostics script
                # source "${SCRIPT_DIR}/diagnostics/os/os_diagnostics.sh"
                echo -e "${YELLOW}This feature is under development.${NC}"
                ;;
            6)
                echo -e "${BLUE}Running performance optimization...${NC}"
                # Call to performance optimization script
                # source "${SCRIPT_DIR}/repair/performance/optimize.sh"
                echo -e "${YELLOW}This feature is under development.${NC}"
                ;;
            7)
                echo -e "${BLUE}Running security scan and malware removal...${NC}"
                # Call to security scan script
                # source "${SCRIPT_DIR}/diagnostics/security/security_scan.sh"
                echo -e "${YELLOW}This feature is under development. See malware_removal_spec.md for details.${NC}"
                ;;
            8)
                echo -e "${BLUE}Running data recovery and backup tools...${NC}"
                # Call to data recovery script
                # source "${SCRIPT_DIR}/repair/data/data_recovery.sh"
                echo -e "${YELLOW}This feature is under development.${NC}"
                ;;
            9)
                echo -e "${BLUE}Running application troubleshooting...${NC}"
                # Call to application troubleshooting script
                # source "${SCRIPT_DIR}/repair/applications/app_troubleshooting.sh"
                echo -e "${YELLOW}This feature is under development.${NC}"
                ;;
            10)
                echo -e "${BLUE}Running System Reset and Reinstallation...${NC}"
                echo -e "${CYAN}Select system type:${NC}"
                echo -e "1. Windows/Linux System"
                echo -e "2. Mac System"
                echo -e "Enter your choice [1-2]: "
                read reset_choice

                case $reset_choice in
                    1)
                        # Call to general system reset script
                        source "${SCRIPT_DIR}/repair/system_restore/system_reset.sh"
                        ;;
                    2)
                        # Call to Mac-specific reset script
                        source "${SCRIPT_DIR}/repair/system_restore/mac_reset.sh"
                        ;;
                    *)
                        echo -e "${RED}Invalid choice. Returning to main menu.${NC}"
                        ;;
                esac
                ;;
            11)
                echo -e "${BLUE}Creating Bootable USB...${NC}"
                echo -e "${CYAN}Select system type:${NC}"
                echo -e "1. Windows/Linux Bootable USB"
                echo -e "2. Mac Bootable USB"
                echo -e "Enter your choice [1-2]: "
                read usb_choice

                case $usb_choice in
                    1)
                        # Call to general bootable USB creator script
                        source "${SCRIPT_DIR}/repair/system_restore/create_bootable_usb.sh"
                        ;;
                    2)
                        # Call to Mac-specific bootable USB creator script
                        source "${SCRIPT_DIR}/repair/system_restore/mac_bootable_usb.sh"
                        ;;
                    *)
                        echo -e "${RED}Invalid choice. Returning to main menu.${NC}"
                        ;;
                esac
                ;;
            12)
                echo -e "${BLUE}Creating Automated OS Installation...${NC}"
                # Call to automated OS installation script
                source "${SCRIPT_DIR}/repair/system_restore/auto_install.sh"
                ;;
            13)
                echo -e "${BLUE}Running Mac-specific tools...${NC}"
                echo -e "${CYAN}Select Mac tool:${NC}"
                echo -e "1. Mac System Reset"
                echo -e "2. Mac Bootable USB Creation"
                echo -e "3. Mac Account Recovery (iCloud/Family Access)"
                echo -e "Enter your choice [1-3]: "
                read mac_choice

                case $mac_choice in
                    1)
                        # Call to Mac reset script
                        source "${SCRIPT_DIR}/repair/system_restore/mac_reset.sh"
                        ;;
                    2)
                        # Call to Mac bootable USB creator script
                        source "${SCRIPT_DIR}/repair/system_restore/mac_bootable_usb.sh"
                        ;;
                    3)
                        # Call to Mac account recovery script
                        source "${SCRIPT_DIR}/repair/advanced_recovery/mac_account_recovery.sh"
                        ;;
                    *)
                        echo -e "${RED}Invalid choice. Returning to main menu.${NC}"
                        ;;
                esac
                ;;
            14)
                echo -e "${BLUE}Running Windows-specific tools...${NC}"
                # Call to Windows-specific tools script
                # source "${SCRIPT_DIR}/platforms/windows/windows_tools.sh"
                echo -e "${YELLOW}This feature is under development.${NC}"
                ;;
            15)
                echo -e "${BLUE}Running Linux-specific tools...${NC}"
                # Call to Linux-specific tools script
                # source "${SCRIPT_DIR}/platforms/linux/linux_tools.sh"
                echo -e "${YELLOW}This feature is under development.${NC}"
                ;;
            16)
                echo -e "${BLUE}Running Advanced System Access Recovery...${NC}"
                echo -e "${RED}WARNING: These tools should only be used on systems you own or have permission to access.${NC}"
                echo -e "${YELLOW}Do you want to continue? (yes/no):${NC}"
                read CONTINUE

                if [ "$CONTINUE" = "yes" ]; then
                    # Call to advanced access recovery script
                    source "${SCRIPT_DIR}/repair/advanced_recovery/advanced_access.sh"
                else
                    echo -e "${YELLOW}Advanced recovery cancelled.${NC}"
                fi
                ;;
            17)
                echo -e "${BLUE}Running Extreme Data Recovery...${NC}"
                echo -e "${RED}WARNING: These are last-resort methods for severely damaged systems.${NC}"
                echo -e "${YELLOW}Do you want to continue? (yes/no):${NC}"
                read CONTINUE

                if [ "$CONTINUE" = "yes" ]; then
                    # Call to extreme data recovery script
                    source "${SCRIPT_DIR}/repair/advanced_recovery/extreme_data_recovery.sh"
                else
                    echo -e "${YELLOW}Extreme recovery cancelled.${NC}"
                fi
                ;;
            18)
                gather_system_info
                ;;
            19)
                echo -e "${BLUE}Displaying help and documentation...${NC}"
                # Display help information
                echo -e "${CYAN}PC Repair Toolkit Help${NC}"
                echo -e "This toolkit helps diagnose and fix various computer issues across all platforms."
                echo -e "It provides tools for boot repair, hardware diagnostics, malware removal,"
                echo -e "performance optimization, data recovery, and more."
                echo -e "For more information, visit: https://github.com/BhekumusaEric/pc-repair-toolkit"
                ;;
            0)
                echo -e "${GREEN}Thank you for using PC Repair Toolkit. Goodbye!${NC}"
                exit 0
                ;;
            *)
                echo -e "${RED}Invalid choice. Please try again.${NC}"
                ;;
        esac

        echo ""
        echo -e "${YELLOW}Press Enter to continue...${NC}"
        read -r
        display_banner
    done
}

# Run the main function
main
