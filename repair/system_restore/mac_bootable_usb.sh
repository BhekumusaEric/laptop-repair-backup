#!/bin/bash

# PC Repair Toolkit - Mac Bootable USB Creator
# This script creates bootable USB drives for macOS installation
# It supports creating installation media for various macOS versions

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PARENT_DIR="$(dirname "$(dirname "$SCRIPT_DIR")")"

# Source utility functions
if [ -f "$PARENT_DIR/utils/logging.sh" ]; then
    source "$PARENT_DIR/utils/logging.sh"
fi

# Function to detect if running on a Mac
detect_mac() {
    echo -e "${BLUE}Checking if running on a Mac...${NC}"
    
    if [ "$(uname)" != "Darwin" ]; then
        echo -e "${YELLOW}This script is designed to run on macOS.${NC}"
        echo -e "${YELLOW}You appear to be running on $(uname).${NC}"
        
        echo -e "${CYAN}Would you like to continue with guidance for creating a macOS bootable USB? (y/n)${NC}"
        read CONTINUE
        
        if [[ ! "$CONTINUE" =~ ^[Yy]$ ]]; then
            echo -e "${RED}Exiting script.${NC}"
            exit 1
        fi
        
        echo -e "${YELLOW}Continuing with guidance mode...${NC}"
        GUIDANCE_MODE=true
    else
        echo -e "${GREEN}Running on macOS $(sw_vers -productVersion)${NC}"
        GUIDANCE_MODE=false
    fi
}

# Function to check for admin privileges
check_admin() {
    if [ "$GUIDANCE_MODE" = true ]; then
        echo -e "${YELLOW}In guidance mode - skipping admin check${NC}"
        return
    fi
    
    echo -e "${BLUE}Checking for admin privileges...${NC}"
    
    if [ "$(id -u)" -ne 0 ]; then
        echo -e "${RED}This script must be run with admin privileges.${NC}"
        echo -e "${YELLOW}Please run with sudo or as root.${NC}"
        exit 1
    else
        echo -e "${GREEN}Running with admin privileges. Good!${NC}"
    fi
}

# Function to detect USB drives
detect_usb_drives() {
    if [ "$GUIDANCE_MODE" = true ]; then
        echo -e "${YELLOW}In guidance mode - skipping USB detection${NC}"
        return
    fi
    
    echo -e "${BLUE}Detecting USB drives...${NC}"
    
    # Get list of USB drives
    diskutil list external physical
    
    # Ask user to select target USB drive
    echo -e "${YELLOW}WARNING: ALL DATA ON THE SELECTED USB DRIVE WILL BE ERASED!${NC}"
    echo -e "Enter the disk identifier to use (e.g., disk2): "
    read TARGET_USB
    
    # Validate device exists
    if ! diskutil info "$TARGET_USB" >/dev/null 2>&1; then
        echo -e "${RED}Error: Disk $TARGET_USB does not exist!${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}Selected USB drive:${NC} $TARGET_USB"
    
    # Confirm with user
    echo -e "${RED}WARNING: This will COMPLETELY ERASE all data on $TARGET_USB!${NC}"
    echo -e "Are you ABSOLUTELY SURE you want to continue? (yes/no): "
    read CONFIRM
    
    if [ "$CONFIRM" != "yes" ]; then
        echo -e "${YELLOW}Operation cancelled by user.${NC}"
        exit 0
    fi
}

# Function to check for macOS installer
check_macos_installer() {
    if [ "$GUIDANCE_MODE" = true ]; then
        echo -e "${YELLOW}In guidance mode - skipping installer check${NC}"
        return
    fi
    
    echo -e "${BLUE}Checking for macOS installer...${NC}"
    
    # Check for installer in Applications folder
    INSTALLER_COUNT=$(ls -d /Applications/Install\ macOS*.app 2>/dev/null | wc -l)
    
    if [ "$INSTALLER_COUNT" -eq 0 ]; then
        echo -e "${RED}No macOS installer found in Applications folder.${NC}"
        echo -e "${YELLOW}Please download a macOS installer from the App Store first.${NC}"
        echo -e "${YELLOW}For older versions, use the following commands:${NC}"
        echo -e "  softwareupdate --fetch-full-installer --full-installer-version 10.15"
        echo -e "  softwareupdate --fetch-full-installer --full-installer-version 11.0"
        echo -e "  softwareupdate --fetch-full-installer --full-installer-version 12.0"
        exit 1
    fi
    
    # List available installers
    echo -e "${CYAN}Available macOS installers:${NC}"
    ls -d /Applications/Install\ macOS*.app | nl
    
    # Ask user to select installer
    echo -e "Enter the number of the installer to use: "
    read INSTALLER_NUM
    
    # Get selected installer
    INSTALLER_PATH=$(ls -d /Applications/Install\ macOS*.app | sed -n "${INSTALLER_NUM}p")
    
    if [ -z "$INSTALLER_PATH" ]; then
        echo -e "${RED}Invalid selection.${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}Selected installer:${NC} $INSTALLER_PATH"
    
    # Verify createinstallmedia tool exists
    if [ ! -f "$INSTALLER_PATH/Contents/Resources/createinstallmedia" ]; then
        echo -e "${RED}Error: createinstallmedia tool not found in the selected installer.${NC}"
        exit 1
    fi
}

# Function to provide guidance for creating macOS bootable USB
provide_macos_usb_guidance() {
    echo -e "${BLUE}============================================================${NC}"
    echo -e "${CYAN}            MACOS BOOTABLE USB GUIDANCE                     ${NC}"
    echo -e "${BLUE}============================================================${NC}"
    
    echo -e "${YELLOW}To create a bootable macOS USB installer, follow these steps:${NC}"
    echo -e ""
    echo -e "${CYAN}1. Prepare a USB drive (minimum 16GB)${NC}"
    echo -e "   - Connect the USB drive to your Mac"
    echo -e "   - Open Disk Utility"
    echo -e "   - Select the USB drive (not the partition)"
    echo -e "   - Click 'Erase'"
    echo -e "   - Name: 'USB' (or any name you prefer)"
    echo -e "   - Format: Mac OS Extended (Journaled)"
    echo -e "   - Scheme: GUID Partition Map"
    echo -e "   - Click 'Erase' and then 'Done'"
    echo -e ""
    echo -e "${CYAN}2. Download the macOS installer${NC}"
    echo -e "   - Open the App Store"
    echo -e "   - Search for the macOS version you want"
    echo -e "   - Click 'Get' or 'Download'"
    echo -e "   - The installer will download to your Applications folder"
    echo -e ""
    echo -e "${CYAN}3. Create the bootable USB${NC}"
    echo -e "   - Open Terminal"
    echo -e "   - Run the following command (replace as needed):"
    echo -e ""
    echo -e "     sudo /Applications/Install\\ macOS\\ [Version].app/Contents/Resources/createinstallmedia \\"
    echo -e "     --volume /Volumes/[USB_NAME] \\"
    echo -e "     --nointeraction"
    echo -e ""
    echo -e "   - Replace [Version] with the macOS version (e.g., Monterey)"
    echo -e "   - Replace [USB_NAME] with the name you gave your USB drive"
    echo -e "   - Enter your admin password when prompted"
    echo -e "   - Wait for the process to complete (it may take 20-30 minutes)"
    echo -e ""
    echo -e "${CYAN}4. Using the bootable USB${NC}"
    echo -e "   - To boot from the USB on an Intel Mac:"
    echo -e "     * Restart the Mac and hold down the Option (⌥) key"
    echo -e "     * Select the USB drive from the boot menu"
    echo -e ""
    echo -e "   - To boot from the USB on an Apple Silicon Mac:"
    echo -e "     * Shut down the Mac"
    echo -e "     * Press and hold the power button until 'Loading startup options' appears"
    echo -e "     * Select the USB drive and click Continue"
    echo -e ""
    echo -e "${BLUE}============================================================${NC}"
}

# Function to create macOS bootable USB
create_macos_bootable_usb() {
    if [ "$GUIDANCE_MODE" = true ]; then
        provide_macos_usb_guidance
        return
    fi
    
    echo -e "${BLUE}Creating macOS bootable USB...${NC}"
    
    # Unmount the USB drive
    echo -e "${CYAN}Unmounting USB drive...${NC}"
    diskutil unmountDisk "$TARGET_USB"
    
    # Create the bootable USB
    echo -e "${CYAN}Creating bootable USB (this may take 20-30 minutes)...${NC}"
    echo -e "${YELLOW}Do not disconnect the USB drive during this process.${NC}"
    
    "$INSTALLER_PATH/Contents/Resources/createinstallmedia" --volume "/Volumes/$(diskutil info "$TARGET_USB" | grep "Volume Name" | awk '{print $3}')" --nointeraction
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}macOS bootable USB created successfully!${NC}"
    else
        echo -e "${RED}Error creating bootable USB.${NC}"
        exit 1
    fi
}

# Main function
main() {
    echo -e "${BLUE}============================================================${NC}"
    echo -e "${CYAN}                MACOS BOOTABLE USB CREATOR                  ${NC}"
    echo -e "${BLUE}============================================================${NC}"
    echo -e "${YELLOW}This utility creates a bootable USB drive for macOS installation.${NC}"
    echo -e "${RED}WARNING: ALL DATA ON THE SELECTED USB DRIVE WILL BE ERASED!${NC}"
    echo -e "${BLUE}============================================================${NC}"
    
    # Detect if running on a Mac
    detect_mac
    
    # Check for admin privileges
    check_admin
    
    # If in guidance mode, provide instructions
    if [ "$GUIDANCE_MODE" = true ]; then
        provide_macos_usb_guidance
        exit 0
    fi
    
    # Detect USB drives
    detect_usb_drives
    
    # Check for macOS installer
    check_macos_installer
    
    # Create macOS bootable USB
    create_macos_bootable_usb
    
    echo -e "${BLUE}============================================================${NC}"
    echo -e "${GREEN}macOS bootable USB creation completed successfully!${NC}"
    echo -e "${YELLOW}You can now use this USB to install or recover macOS.${NC}"
    echo -e "${BLUE}============================================================${NC}"
}

# Run the main function
main
