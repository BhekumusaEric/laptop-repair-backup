#!/bin/bash

# PC Repair Toolkit - System Reset Module
# This script provides functionality to completely erase and reinstall an operating system
# It supports Windows, macOS, and Linux platforms

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

# Function to detect operating system
detect_os() {
    echo -e "${BLUE}Detecting operating system...${NC}"
    
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
    
    # Check if running from live media
    if mount | grep -q "cdrom"; then
        echo -e "${GREEN}Running from live media. Good!${NC}"
        LIVE_MEDIA=true
    else
        echo -e "${YELLOW}Warning: Not running from live media. Some operations may not be possible.${NC}"
        LIVE_MEDIA=false
    fi
}

# Function to detect storage devices
detect_storage() {
    echo -e "${BLUE}Detecting storage devices...${NC}"
    
    # Get list of storage devices
    echo -e "${CYAN}Available storage devices:${NC}"
    lsblk -o NAME,SIZE,TYPE,MOUNTPOINT | grep -E "disk|part" | grep -v "loop"
    
    # Ask user to select target device
    echo -e "${YELLOW}WARNING: ALL DATA ON THE SELECTED DEVICE WILL BE ERASED!${NC}"
    echo -e "Enter the device name to reset (e.g., sda, nvme0n1): "
    read TARGET_DEVICE
    
    # Validate device exists
    if [ ! -b "/dev/$TARGET_DEVICE" ]; then
        echo -e "${RED}Error: Device /dev/$TARGET_DEVICE does not exist!${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}Selected device:${NC} /dev/$TARGET_DEVICE"
    
    # Confirm with user
    echo -e "${RED}WARNING: This will COMPLETELY ERASE all data on /dev/$TARGET_DEVICE!${NC}"
    echo -e "Are you ABSOLUTELY SURE you want to continue? (yes/no): "
    read CONFIRM
    
    if [ "$CONFIRM" != "yes" ]; then
        echo -e "${YELLOW}Operation cancelled by user.${NC}"
        exit 0
    fi
}

# Function to backup important data
backup_data() {
    echo -e "${BLUE}Would you like to backup important data before proceeding? (y/n)${NC}"
    read BACKUP_CHOICE
    
    if [[ "$BACKUP_CHOICE" =~ ^[Yy]$ ]]; then
        echo -e "${BLUE}Please specify a backup destination (e.g., external drive path):${NC}"
        read BACKUP_DEST
        
        if [ ! -d "$BACKUP_DEST" ]; then
            echo -e "${YELLOW}Backup destination does not exist. Creating directory...${NC}"
            mkdir -p "$BACKUP_DEST"
        fi
        
        echo -e "${BLUE}Attempting to mount partitions and backup data...${NC}"
        
        # Create temporary mount point
        TEMP_MOUNT="/tmp/system_reset_mount"
        mkdir -p "$TEMP_MOUNT"
        
        # Get list of partitions
        PARTITIONS=$(lsblk -ln -o NAME,TYPE | grep -w "part" | grep "$TARGET_DEVICE" | awk '{print $1}')
        
        for PART in $PARTITIONS; do
            echo -e "${CYAN}Attempting to mount /dev/$PART...${NC}"
            
            # Try to mount the partition
            mount "/dev/$PART" "$TEMP_MOUNT" 2>/dev/null
            
            if [ $? -eq 0 ]; then
                echo -e "${GREEN}Successfully mounted /dev/$PART${NC}"
                
                # Check for common user data directories
                if [ -d "$TEMP_MOUNT/home" ]; then
                    echo -e "${BLUE}Backing up user home directories...${NC}"
                    mkdir -p "$BACKUP_DEST/home_backup"
                    cp -r "$TEMP_MOUNT/home" "$BACKUP_DEST/home_backup"
                fi
                
                if [ -d "$TEMP_MOUNT/Users" ]; then
                    echo -e "${BLUE}Backing up Windows user profiles...${NC}"
                    mkdir -p "$BACKUP_DEST/users_backup"
                    cp -r "$TEMP_MOUNT/Users" "$BACKUP_DEST/users_backup"
                fi
                
                # Unmount after backup
                umount "$TEMP_MOUNT"
            else
                echo -e "${YELLOW}Could not mount /dev/$PART, skipping...${NC}"
            fi
        done
        
        echo -e "${GREEN}Backup process completed. Data saved to $BACKUP_DEST${NC}"
        rmdir "$TEMP_MOUNT"
    else
        echo -e "${YELLOW}Skipping backup process.${NC}"
    fi
}

# Function to completely erase the disk
erase_disk() {
    echo -e "${BLUE}Completely erasing disk /dev/$TARGET_DEVICE...${NC}"
    
    # Unmount all partitions from the target device
    echo -e "${CYAN}Unmounting all partitions from /dev/$TARGET_DEVICE...${NC}"
    mount | grep "/dev/$TARGET_DEVICE" | awk '{print $1}' | xargs -I{} umount {} 2>/dev/null
    
    # Erase the beginning of the disk to remove partition table
    echo -e "${CYAN}Erasing partition table...${NC}"
    dd if=/dev/zero of="/dev/$TARGET_DEVICE" bs=1M count=10
    
    # Create a new partition table
    echo -e "${CYAN}Creating new partition table...${NC}"
    parted -s "/dev/$TARGET_DEVICE" mklabel gpt
    
    echo -e "${GREEN}Disk has been completely erased.${NC}"
}

# Function to create new partitions
create_partitions() {
    echo -e "${BLUE}Creating new partitions on /dev/$TARGET_DEVICE...${NC}"
    
    # Ask for OS type to install
    echo -e "${CYAN}Select OS type to prepare partitions for:${NC}"
    echo -e "1. Windows"
    echo -e "2. macOS"
    echo -e "3. Linux"
    echo -e "4. Dual-boot (Windows/Linux)"
    echo -e "Enter your choice [1-4]: "
    read OS_CHOICE
    
    case $OS_CHOICE in
        1) # Windows partitioning
            echo -e "${CYAN}Creating Windows partitions...${NC}"
            parted -s "/dev/$TARGET_DEVICE" \
                mklabel gpt \
                mkpart "EFI" fat32 1MiB 301MiB \
                set 1 esp on \
                mkpart "MSR" 301MiB 401MiB \
                set 2 msftres on \
                mkpart "Windows" ntfs 401MiB 100%
            
            # Format partitions
            echo -e "${CYAN}Formatting partitions...${NC}"
            mkfs.fat -F32 "/dev/${TARGET_DEVICE}1"
            mkfs.ntfs -f "/dev/${TARGET_DEVICE}3"
            
            echo -e "${GREEN}Windows partitions created and formatted.${NC}"
            ;;
            
        2) # macOS partitioning
            echo -e "${CYAN}Creating macOS partitions...${NC}"
            parted -s "/dev/$TARGET_DEVICE" \
                mklabel gpt \
                mkpart "EFI" fat32 1MiB 301MiB \
                set 1 esp on \
                mkpart "macOS" hfs+ 301MiB 100%
            
            # Format partitions
            echo -e "${CYAN}Formatting partitions...${NC}"
            mkfs.fat -F32 "/dev/${TARGET_DEVICE}1"
            
            echo -e "${YELLOW}Note: HFS+/APFS formatting requires macOS tools.${NC}"
            echo -e "${GREEN}macOS partitions created. EFI partition formatted.${NC}"
            ;;
            
        3) # Linux partitioning
            echo -e "${CYAN}Creating Linux partitions...${NC}"
            parted -s "/dev/$TARGET_DEVICE" \
                mklabel gpt \
                mkpart "EFI" fat32 1MiB 301MiB \
                set 1 esp on \
                mkpart "swap" linux-swap 301MiB 4301MiB \
                mkpart "root" ext4 4301MiB 100%
            
            # Format partitions
            echo -e "${CYAN}Formatting partitions...${NC}"
            mkfs.fat -F32 "/dev/${TARGET_DEVICE}1"
            mkswap "/dev/${TARGET_DEVICE}2"
            mkfs.ext4 "/dev/${TARGET_DEVICE}3"
            
            echo -e "${GREEN}Linux partitions created and formatted.${NC}"
            ;;
            
        4) # Dual-boot partitioning
            echo -e "${CYAN}Creating dual-boot partitions...${NC}"
            parted -s "/dev/$TARGET_DEVICE" \
                mklabel gpt \
                mkpart "EFI" fat32 1MiB 301MiB \
                set 1 esp on \
                mkpart "MSR" 301MiB 401MiB \
                set 2 msftres on \
                mkpart "Windows" ntfs 401MiB 50% \
                mkpart "swap" linux-swap 50% 54000MiB \
                mkpart "Linux" ext4 54000MiB 100%
            
            # Format partitions
            echo -e "${CYAN}Formatting partitions...${NC}"
            mkfs.fat -F32 "/dev/${TARGET_DEVICE}1"
            mkfs.ntfs -f "/dev/${TARGET_DEVICE}3"
            mkswap "/dev/${TARGET_DEVICE}4"
            mkfs.ext4 "/dev/${TARGET_DEVICE}5"
            
            echo -e "${GREEN}Dual-boot partitions created and formatted.${NC}"
            ;;
            
        *)
            echo -e "${RED}Invalid choice. Exiting.${NC}"
            exit 1
            ;;
    esac
}

# Function to prepare for OS installation
prepare_installation() {
    echo -e "${BLUE}Preparing for OS installation...${NC}"
    
    case $OS_CHOICE in
        1) # Windows installation
            echo -e "${CYAN}Preparing for Windows installation...${NC}"
            echo -e "${YELLOW}To complete Windows installation:${NC}"
            echo -e "1. Boot from a Windows installation media"
            echo -e "2. Select 'Custom: Install Windows only' during installation"
            echo -e "3. Select the partition labeled 'Windows' (should be partition 3)"
            echo -e "4. Follow the on-screen instructions to complete installation"
            ;;
            
        2) # macOS installation
            echo -e "${CYAN}Preparing for macOS installation...${NC}"
            echo -e "${YELLOW}To complete macOS installation:${NC}"
            echo -e "1. Boot from a macOS installation media"
            echo -e "2. Use Disk Utility to format the macOS partition as APFS"
            echo -e "3. Install macOS on the formatted partition"
            echo -e "4. Follow the on-screen instructions to complete installation"
            ;;
            
        3) # Linux installation
            echo -e "${CYAN}Preparing for Linux installation...${NC}"
            echo -e "${YELLOW}To complete Linux installation:${NC}"
            echo -e "1. Boot from a Linux installation media"
            echo -e "2. During installation, choose 'Something else' or 'Manual partitioning'"
            echo -e "3. Set mount points:"
            echo -e "   - /dev/${TARGET_DEVICE}1 as /boot/efi (EFI partition)"
            echo -e "   - /dev/${TARGET_DEVICE}2 as swap"
            echo -e "   - /dev/${TARGET_DEVICE}3 as / (root)"
            echo -e "4. Follow the on-screen instructions to complete installation"
            ;;
            
        4) # Dual-boot installation
            echo -e "${CYAN}Preparing for dual-boot installation...${NC}"
            echo -e "${YELLOW}To complete dual-boot installation:${NC}"
            echo -e "1. Install Windows first:"
            echo -e "   - Boot from Windows installation media"
            echo -e "   - Select 'Custom: Install Windows only'"
            echo -e "   - Select the partition labeled 'Windows' (partition 3)"
            echo -e "2. Then install Linux:"
            echo -e "   - Boot from Linux installation media"
            echo -e "   - Choose 'Something else' or 'Manual partitioning'"
            echo -e "   - Set mount points:"
            echo -e "     - /dev/${TARGET_DEVICE}1 as /boot/efi (EFI partition)"
            echo -e "     - /dev/${TARGET_DEVICE}4 as swap"
            echo -e "     - /dev/${TARGET_DEVICE}5 as / (root)"
            echo -e "3. Linux installer should detect Windows and configure dual-boot"
            ;;
    esac
    
    echo -e "${GREEN}System is now prepared for OS installation.${NC}"
}

# Main function
main() {
    echo -e "${BLUE}============================================================${NC}"
    echo -e "${CYAN}                SYSTEM RESET UTILITY                        ${NC}"
    echo -e "${BLUE}============================================================${NC}"
    echo -e "${YELLOW}This utility will completely erase a storage device and prepare${NC}"
    echo -e "${YELLOW}it for a fresh operating system installation.${NC}"
    echo -e "${RED}WARNING: ALL DATA WILL BE PERMANENTLY ERASED!${NC}"
    echo -e "${BLUE}============================================================${NC}"
    
    # Detect operating system
    detect_os
    
    # Check if running from live media
    if [ "$LIVE_MEDIA" = false ]; then
        echo -e "${RED}Warning: It is strongly recommended to run this utility from a live USB/CD.${NC}"
        echo -e "Do you want to continue anyway? (yes/no): "
        read CONTINUE
        
        if [ "$CONTINUE" != "yes" ]; then
            echo -e "${YELLOW}Operation cancelled. Please boot from a live USB/CD and try again.${NC}"
            exit 0
        fi
    fi
    
    # Detect storage devices
    detect_storage
    
    # Backup important data
    backup_data
    
    # Erase disk
    erase_disk
    
    # Create new partitions
    create_partitions
    
    # Prepare for OS installation
    prepare_installation
    
    echo -e "${BLUE}============================================================${NC}"
    echo -e "${GREEN}System reset completed successfully!${NC}"
    echo -e "${YELLOW}Follow the instructions above to complete OS installation.${NC}"
    echo -e "${BLUE}============================================================${NC}"
}

# Run the main function
main
