#!/bin/bash

# PC Repair Toolkit - Bootable USB Creator
# This script creates bootable USB drives for various operating systems
# Supports Windows, macOS, and Linux installation media

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

# Check if running as root
if [ "$(id -u)" -ne 0 ]; then
    echo -e "${RED}This script must be run as root. Please use sudo.${NC}"
    exit 1
fi

# Function to detect USB drives
detect_usb_drives() {
    echo -e "${BLUE}Detecting USB drives...${NC}"
    
    # Get list of USB drives
    USB_DRIVES=$(lsblk -d -o NAME,SIZE,TRAN | grep "usb" | awk '{print $1}')
    
    if [ -z "$USB_DRIVES" ]; then
        echo -e "${RED}No USB drives detected. Please connect a USB drive and try again.${NC}"
        exit 1
    fi
    
    echo -e "${CYAN}Available USB drives:${NC}"
    lsblk -d -o NAME,SIZE,TRAN | grep "usb"
    
    # Ask user to select target USB drive
    echo -e "${YELLOW}WARNING: ALL DATA ON THE SELECTED USB DRIVE WILL BE ERASED!${NC}"
    echo -e "Enter the USB drive name to use (e.g., sdb): "
    read TARGET_USB
    
    # Validate device exists and is a USB drive
    if [ ! -b "/dev/$TARGET_USB" ]; then
        echo -e "${RED}Error: Device /dev/$TARGET_USB does not exist!${NC}"
        exit 1
    fi
    
    if ! lsblk -d -o NAME,TRAN | grep "$TARGET_USB" | grep -q "usb"; then
        echo -e "${RED}Error: Device /dev/$TARGET_USB is not a USB drive!${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}Selected USB drive:${NC} /dev/$TARGET_USB"
    
    # Confirm with user
    echo -e "${RED}WARNING: This will COMPLETELY ERASE all data on /dev/$TARGET_USB!${NC}"
    echo -e "Are you ABSOLUTELY SURE you want to continue? (yes/no): "
    read CONFIRM
    
    if [ "$CONFIRM" != "yes" ]; then
        echo -e "${YELLOW}Operation cancelled by user.${NC}"
        exit 0
    fi
}

# Function to prepare USB drive
prepare_usb() {
    echo -e "${BLUE}Preparing USB drive /dev/$TARGET_USB...${NC}"
    
    # Unmount all partitions from the target USB drive
    echo -e "${CYAN}Unmounting all partitions from /dev/$TARGET_USB...${NC}"
    mount | grep "/dev/$TARGET_USB" | awk '{print $1}' | xargs -I{} umount {} 2>/dev/null
    
    # Create a new partition table
    echo -e "${CYAN}Creating new partition table...${NC}"
    parted -s "/dev/$TARGET_USB" mklabel msdos
    
    # Create a single partition
    echo -e "${CYAN}Creating partition...${NC}"
    parted -s "/dev/$TARGET_USB" mkpart primary fat32 1MiB 100%
    parted -s "/dev/$TARGET_USB" set 1 boot on
    
    # Format the partition
    echo -e "${CYAN}Formatting partition as FAT32...${NC}"
    mkfs.fat -F32 "/dev/${TARGET_USB}1"
    
    echo -e "${GREEN}USB drive prepared successfully.${NC}"
}

# Function to create Windows bootable USB
create_windows_usb() {
    echo -e "${BLUE}Creating Windows bootable USB...${NC}"
    
    # Ask for ISO file
    echo -e "${CYAN}Enter the path to the Windows ISO file:${NC}"
    read ISO_PATH
    
    if [ ! -f "$ISO_PATH" ]; then
        echo -e "${RED}Error: ISO file not found!${NC}"
        exit 1
    fi
    
    # Create mount points
    TEMP_ISO="/tmp/windows_iso"
    TEMP_USB="/tmp/windows_usb"
    mkdir -p "$TEMP_ISO" "$TEMP_USB"
    
    # Mount the ISO and USB
    echo -e "${CYAN}Mounting ISO and USB drive...${NC}"
    mount -o loop "$ISO_PATH" "$TEMP_ISO"
    mount "/dev/${TARGET_USB}1" "$TEMP_USB"
    
    # Copy files
    echo -e "${CYAN}Copying files (this may take a while)...${NC}"
    cp -r "$TEMP_ISO"/* "$TEMP_USB"/
    
    # Unmount
    echo -e "${CYAN}Unmounting ISO and USB drive...${NC}"
    umount "$TEMP_ISO"
    umount "$TEMP_USB"
    
    # Clean up
    rmdir "$TEMP_ISO" "$TEMP_USB"
    
    echo -e "${GREEN}Windows bootable USB created successfully!${NC}"
    echo -e "${YELLOW}Note: This method works for basic Windows installation.${NC}"
    echo -e "${YELLOW}For more reliable results, consider using Microsoft's official Media Creation Tool on a Windows system.${NC}"
}

# Function to create Linux bootable USB
create_linux_usb() {
    echo -e "${BLUE}Creating Linux bootable USB...${NC}"
    
    # Ask for ISO file
    echo -e "${CYAN}Enter the path to the Linux ISO file:${NC}"
    read ISO_PATH
    
    if [ ! -f "$ISO_PATH" ]; then
        echo -e "${RED}Error: ISO file not found!${NC}"
        exit 1
    fi
    
    # Check if dd is available
    if ! command -v dd &> /dev/null; then
        echo -e "${RED}Error: dd command not found!${NC}"
        exit 1
    fi
    
    # Confirm with user
    echo -e "${RED}WARNING: This will directly write the ISO to the USB drive.${NC}"
    echo -e "${RED}ALL DATA on /dev/$TARGET_USB will be COMPLETELY ERASED!${NC}"
    echo -e "Are you ABSOLUTELY SURE you want to continue? (yes/no): "
    read CONFIRM
    
    if [ "$CONFIRM" != "yes" ]; then
        echo -e "${YELLOW}Operation cancelled by user.${NC}"
        exit 0
    fi
    
    # Write ISO to USB
    echo -e "${CYAN}Writing ISO to USB drive (this may take a while)...${NC}"
    dd if="$ISO_PATH" of="/dev/$TARGET_USB" bs=4M status=progress
    
    # Sync to ensure all data is written
    echo -e "${CYAN}Syncing...${NC}"
    sync
    
    echo -e "${GREEN}Linux bootable USB created successfully!${NC}"
}

# Function to create macOS bootable USB
create_macos_usb() {
    echo -e "${BLUE}Creating macOS bootable USB...${NC}"
    echo -e "${YELLOW}Note: Creating a macOS bootable USB typically requires a Mac.${NC}"
    echo -e "${YELLOW}This function provides guidance for the process.${NC}"
    
    # Prepare USB drive
    prepare_usb
    
    echo -e "${CYAN}To create a macOS bootable USB, you need:${NC}"
    echo -e "1. A Mac computer"
    echo -e "2. The macOS installer app from the App Store"
    
    echo -e "${CYAN}On a Mac, use the following command:${NC}"
    echo -e "sudo /Applications/Install\\ macOS\\ [Version].app/Contents/Resources/createinstallmedia --volume /Volumes/[USB_NAME]"
    
    echo -e "${YELLOW}Replace [Version] with the macOS version (e.g., Monterey)${NC}"
    echo -e "${YELLOW}Replace [USB_NAME] with the name of your USB drive${NC}"
    
    echo -e "${GREEN}USB drive prepared. Follow the instructions above on a Mac to complete the process.${NC}"
}

# Function to create recovery USB
create_recovery_usb() {
    echo -e "${BLUE}Creating recovery/repair USB...${NC}"
    
    # Ask for recovery distribution
    echo -e "${CYAN}Select recovery distribution:${NC}"
    echo -e "1. Ubuntu Live USB (good for general recovery)"
    echo -e "2. Clonezilla (disk imaging and cloning)"
    echo -e "3. GParted Live (partition management)"
    echo -e "4. SystemRescue (advanced system recovery)"
    echo -e "Enter your choice [1-4]: "
    read RECOVERY_CHOICE
    
    # Set download URL based on choice
    case $RECOVERY_CHOICE in
        1)
            RECOVERY_NAME="Ubuntu"
            RECOVERY_URL="https://releases.ubuntu.com/22.04/ubuntu-22.04.3-desktop-amd64.iso"
            ;;
        2)
            RECOVERY_NAME="Clonezilla"
            RECOVERY_URL="https://sourceforge.net/projects/clonezilla/files/clonezilla_live_stable/3.1.0-22/clonezilla-live-3.1.0-22-amd64.iso"
            ;;
        3)
            RECOVERY_NAME="GParted Live"
            RECOVERY_URL="https://downloads.sourceforge.net/gparted/gparted-live-1.5.0-1-amd64.iso"
            ;;
        4)
            RECOVERY_NAME="SystemRescue"
            RECOVERY_URL="https://sourceforge.net/projects/systemrescuecd/files/sysresccd-x86/9.06/systemrescue-9.06-amd64.iso"
            ;;
        *)
            echo -e "${RED}Invalid choice. Exiting.${NC}"
            exit 1
            ;;
    esac
    
    # Download the ISO
    echo -e "${CYAN}Downloading $RECOVERY_NAME ISO...${NC}"
    ISO_PATH="/tmp/${RECOVERY_NAME,,}.iso"
    wget -O "$ISO_PATH" "$RECOVERY_URL" || {
        echo -e "${RED}Error: Download failed!${NC}"
        exit 1
    }
    
    # Create bootable USB
    echo -e "${CYAN}Creating bootable USB...${NC}"
    dd if="$ISO_PATH" of="/dev/$TARGET_USB" bs=4M status=progress
    
    # Sync to ensure all data is written
    echo -e "${CYAN}Syncing...${NC}"
    sync
    
    # Clean up
    rm -f "$ISO_PATH"
    
    echo -e "${GREEN}$RECOVERY_NAME recovery USB created successfully!${NC}"
}

# Main function
main() {
    echo -e "${BLUE}============================================================${NC}"
    echo -e "${CYAN}                BOOTABLE USB CREATOR                        ${NC}"
    echo -e "${BLUE}============================================================${NC}"
    echo -e "${YELLOW}This utility creates bootable USB drives for various${NC}"
    echo -e "${YELLOW}operating systems and recovery tools.${NC}"
    echo -e "${RED}WARNING: ALL DATA ON THE SELECTED USB DRIVE WILL BE ERASED!${NC}"
    echo -e "${BLUE}============================================================${NC}"
    
    # Detect USB drives
    detect_usb_drives
    
    # Ask for OS type
    echo -e "${CYAN}Select the type of bootable USB to create:${NC}"
    echo -e "1. Windows installation USB"
    echo -e "2. Linux installation USB"
    echo -e "3. macOS installation USB"
    echo -e "4. Recovery/Repair USB"
    echo -e "Enter your choice [1-4]: "
    read OS_CHOICE
    
    case $OS_CHOICE in
        1)
            create_windows_usb
            ;;
        2)
            create_linux_usb
            ;;
        3)
            create_macos_usb
            ;;
        4)
            create_recovery_usb
            ;;
        *)
            echo -e "${RED}Invalid choice. Exiting.${NC}"
            exit 1
            ;;
    esac
    
    echo -e "${BLUE}============================================================${NC}"
    echo -e "${GREEN}Bootable USB creation completed successfully!${NC}"
    echo -e "${BLUE}============================================================${NC}"
}

# Run the main function
main
