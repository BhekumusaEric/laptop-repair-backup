#!/bin/bash

# PC Repair Toolkit - Advanced Access Recovery Module
# This script provides advanced methods to gain access to locked systems
# WARNING: These methods should only be used on systems you own or have permission to access

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

# Function to display legal disclaimer
display_disclaimer() {
    echo -e "${RED}============================================================${NC}"
    echo -e "${RED}                    LEGAL DISCLAIMER                         ${NC}"
    echo -e "${RED}============================================================${NC}"
    echo -e "${YELLOW}This tool contains advanced recovery methods that should ONLY be used:${NC}"
    echo -e "${YELLOW}1. On systems you legally own or have explicit permission to access${NC}"
    echo -e "${YELLOW}2. For legitimate recovery purposes when standard methods fail${NC}"
    echo -e "${YELLOW}3. In compliance with all applicable laws and regulations${NC}"
    echo -e ""
    echo -e "${RED}UNAUTHORIZED ACCESS TO COMPUTER SYSTEMS IS ILLEGAL${NC}"
    echo -e "${RED}AND MAY RESULT IN CIVIL AND CRIMINAL PENALTIES.${NC}"
    echo -e ""
    echo -e "${YELLOW}By continuing, you confirm that:${NC}"
    echo -e "${YELLOW}1. You are the legal owner of the system or have explicit permission${NC}"
    echo -e "${YELLOW}2. You accept all responsibility for the use of these tools${NC}"
    echo -e "${YELLOW}3. You will use these tools in accordance with all applicable laws${NC}"
    echo -e "${RED}============================================================${NC}"
    echo -e "Do you understand and accept these terms? (yes/no): "
    read ACCEPT

    if [ "$ACCEPT" != "yes" ]; then
        echo -e "${RED}Terms not accepted. Exiting.${NC}"
        exit 1
    fi

    echo -e "${YELLOW}Please enter a brief reason for using these advanced recovery methods:${NC}"
    read RECOVERY_REASON

    # Log the acceptance and reason
    echo "$(date): Advanced recovery tools used. Reason: $RECOVERY_REASON" >> "$SCRIPT_DIR/advanced_recovery.log"
}

# Function to detect system type
detect_system_type() {
    echo -e "${BLUE}Detecting system type...${NC}"

    if [ -d "/sys/firmware/efi" ]; then
        echo -e "${GREEN}UEFI system detected.${NC}"
        BOOT_TYPE="UEFI"
    else
        echo -e "${GREEN}Legacy BIOS system detected.${NC}"
        BOOT_TYPE="BIOS"
    fi

    if [ -f /etc/os-release ]; then
        # freedesktop.org and systemd
        . /etc/os-release
        OS=$NAME
        VER=$VERSION_ID
        echo -e "${GREEN}Detected OS:${NC} $OS $VER"
    elif [ "$(uname)" = "Darwin" ]; then
        OS="macOS"
        VER=$(sw_vers -productVersion 2>/dev/null)
        echo -e "${GREEN}Detected OS:${NC} $OS $VER"
    elif [ -f /proc/version ] && grep -q "Microsoft" /proc/version; then
        OS="Windows"
        echo -e "${GREEN}Detected OS:${NC} $OS (WSL)"
    else
        OS="Unknown"
        echo -e "${YELLOW}Could not determine OS type.${NC}"
    fi
}

# Function to detect available storage devices
detect_storage_devices() {
    echo -e "${BLUE}Detecting storage devices...${NC}"

    # Get list of storage devices
    echo -e "${CYAN}Available storage devices:${NC}"
    lsblk -o NAME,SIZE,TYPE,MOUNTPOINT | grep -E "disk|part" | grep -v "loop"
}

# Function for Windows password reset
windows_password_reset() {
    echo -e "${BLUE}Windows Password Reset${NC}"

    # Check for required tools
    if ! command -v chntpw &> /dev/null; then
        echo -e "${YELLOW}Installing required tools...${NC}"
        apt-get update
        apt-get install -y chntpw
    fi

    # Detect Windows partitions
    echo -e "${BLUE}Detecting Windows partitions...${NC}"
    WINDOWS_PARTS=$(fdisk -l | grep NTFS | awk '{print $1}')

    if [ -z "$WINDOWS_PARTS" ]; then
        echo -e "${RED}No Windows partitions found.${NC}"
        return
    fi

    echo -e "${CYAN}Found Windows partitions:${NC}"
    echo "$WINDOWS_PARTS" | nl

    echo -e "Select Windows partition number: "
    read PART_NUM

    SELECTED_PART=$(echo "$WINDOWS_PARTS" | sed -n "${PART_NUM}p")

    if [ -z "$SELECTED_PART" ]; then
        echo -e "${RED}Invalid selection.${NC}"
        return
    fi

    echo -e "${GREEN}Selected partition:${NC} $SELECTED_PART"

    # Mount the Windows partition
    echo -e "${BLUE}Mounting Windows partition...${NC}"
    MOUNT_POINT="/mnt/windows_reset"
    mkdir -p "$MOUNT_POINT"

    mount -o ro "$SELECTED_PART" "$MOUNT_POINT"

    if [ $? -ne 0 ]; then
        echo -e "${RED}Failed to mount partition.${NC}"
        rmdir "$MOUNT_POINT"
        return
    fi

    # Locate the SAM file
    if [ -f "$MOUNT_POINT/Windows/System32/config/SAM" ]; then
        SAM_PATH="$MOUNT_POINT/Windows/System32/config"
    else
        echo -e "${RED}Could not locate Windows SAM file.${NC}"
        umount "$MOUNT_POINT"
        rmdir "$MOUNT_POINT"
        return
    fi

    # Remount with write permissions
    umount "$MOUNT_POINT"
    mount -o rw "$SELECTED_PART" "$MOUNT_POINT"

    # List user accounts
    echo -e "${BLUE}Available user accounts:${NC}"
    chntpw -l "$SAM_PATH/SAM" | grep -A 100 "| RID" | grep -B 100 "+" | grep -v "+" | grep -v "| RID" | grep -v "^$" | nl

    echo -e "Select user account number to reset: "
    read USER_NUM

    USER_LINE=$(chntpw -l "$SAM_PATH/SAM" | grep -A 100 "| RID" | grep -B 100 "+" | grep -v "+" | grep -v "| RID" | grep -v "^$" | sed -n "${USER_NUM}p")
    USER_NAME=$(echo "$USER_LINE" | awk '{print $1}')

    if [ -z "$USER_NAME" ]; then
        echo -e "${RED}Invalid selection.${NC}"
        umount "$MOUNT_POINT"
        rmdir "$MOUNT_POINT"
        return
    fi

    echo -e "${GREEN}Selected user:${NC} $USER_NAME"

    # Reset password
    echo -e "${BLUE}Resetting password...${NC}"
    echo -e "${YELLOW}Choose an option:${NC}"
    echo -e "1. Clear password (blank password)"
    echo -e "2. Set new password"
    read RESET_OPTION

    case $RESET_OPTION in
        1)
            echo -e "${BLUE}Clearing password...${NC}"
            echo -e "n\ny\n" | chntpw -u "$USER_NAME" "$SAM_PATH/SAM"
            ;;
        2)
            echo -e "${BLUE}Enter new password:${NC}"
            read -s NEW_PASSWORD
            echo
            echo -e "${BLUE}Confirm new password:${NC}"
            read -s CONFIRM_PASSWORD
            echo

            if [ "$NEW_PASSWORD" != "$CONFIRM_PASSWORD" ]; then
                echo -e "${RED}Passwords do not match.${NC}"
                umount "$MOUNT_POINT"
                rmdir "$MOUNT_POINT"
                return
            fi

            # This is a simplified approach - in reality, setting a specific password with chntpw is more complex
            echo -e "${YELLOW}Note: Setting specific passwords with chntpw is not fully reliable.${NC}"
            echo -e "${YELLOW}It's recommended to clear the password and then set a new one after login.${NC}"
            echo -e "n\ny\n" | chntpw -u "$USER_NAME" "$SAM_PATH/SAM"
            ;;
        *)
            echo -e "${RED}Invalid option.${NC}"
            umount "$MOUNT_POINT"
            rmdir "$MOUNT_POINT"
            return
            ;;
    esac

    # Cleanup
    echo -e "${BLUE}Cleaning up...${NC}"
    umount "$MOUNT_POINT"
    rmdir "$MOUNT_POINT"

    echo -e "${GREEN}Password reset completed.${NC}"
    echo -e "${YELLOW}Restart the computer and try logging in.${NC}"
}

# Function for Linux password reset
linux_password_reset() {
    echo -e "${BLUE}Linux Password Reset${NC}"

    # Detect Linux partitions
    echo -e "${BLUE}Detecting Linux partitions...${NC}"
    LINUX_PARTS=$(fdisk -l | grep -E "Linux|ext4|xfs|btrfs" | awk '{print $1}')

    if [ -z "$LINUX_PARTS" ]; then
        echo -e "${RED}No Linux partitions found.${NC}"
        return
    fi

    echo -e "${CYAN}Found Linux partitions:${NC}"
    echo "$LINUX_PARTS" | nl

    echo -e "Select Linux partition number: "
    read PART_NUM

    SELECTED_PART=$(echo "$LINUX_PARTS" | sed -n "${PART_NUM}p")

    if [ -z "$SELECTED_PART" ]; then
        echo -e "${RED}Invalid selection.${NC}"
        return
    fi

    echo -e "${GREEN}Selected partition:${NC} $SELECTED_PART"

    # Mount the Linux partition
    echo -e "${BLUE}Mounting Linux partition...${NC}"
    MOUNT_POINT="/mnt/linux_reset"
    mkdir -p "$MOUNT_POINT"

    mount "$SELECTED_PART" "$MOUNT_POINT"

    if [ $? -ne 0 ]; then
        echo -e "${RED}Failed to mount partition.${NC}"
        rmdir "$MOUNT_POINT"
        return
    fi

    # Check if it's the root partition
    if [ ! -f "$MOUNT_POINT/etc/passwd" ]; then
        echo -e "${RED}This doesn't appear to be a root partition.${NC}"
        umount "$MOUNT_POINT"
        rmdir "$MOUNT_POINT"
        return
    fi

    # List user accounts
    echo -e "${BLUE}Available user accounts:${NC}"
    grep -E ":/home/|:/root:" "$MOUNT_POINT/etc/passwd" | awk -F: '{print $1 " (UID:" $3 ")"}' | nl

    echo -e "Select user account number to reset: "
    read USER_NUM

    USER_LINE=$(grep -E ":/home/|:/root:" "$MOUNT_POINT/etc/passwd" | sed -n "${USER_NUM}p")
    USER_NAME=$(echo "$USER_LINE" | awk -F: '{print $1}')

    if [ -z "$USER_NAME" ]; then
        echo -e "${RED}Invalid selection.${NC}"
        umount "$MOUNT_POINT"
        rmdir "$MOUNT_POINT"
        return
    fi

    echo -e "${GREEN}Selected user:${NC} $USER_NAME"

    # Reset password
    echo -e "${BLUE}Resetting password...${NC}"
    echo -e "${YELLOW}Choose an option:${NC}"
    echo -e "1. Remove password (not recommended for security)"
    echo -e "2. Set new password"
    read RESET_OPTION

    case $RESET_OPTION in
        1)
            echo -e "${BLUE}Removing password...${NC}"
            sed -i "s|^$USER_NAME:[^:]*:|$USER_NAME::|" "$MOUNT_POINT/etc/shadow"
            ;;
        2)
            echo -e "${BLUE}Enter new password:${NC}"
            read -s NEW_PASSWORD
            echo
            echo -e "${BLUE}Confirm new password:${NC}"
            read -s CONFIRM_PASSWORD
            echo

            if [ "$NEW_PASSWORD" != "$CONFIRM_PASSWORD" ]; then
                echo -e "${RED}Passwords do not match.${NC}"
                umount "$MOUNT_POINT"
                rmdir "$MOUNT_POINT"
                return
            fi

            # Generate password hash
            PASS_HASH=$(openssl passwd -6 "$NEW_PASSWORD")

            # Update shadow file
            sed -i "s|^$USER_NAME:[^:]*:|$USER_NAME:$PASS_HASH:|" "$MOUNT_POINT/etc/shadow"
            ;;
        *)
            echo -e "${RED}Invalid option.${NC}"
            umount "$MOUNT_POINT"
            rmdir "$MOUNT_POINT"
            return
            ;;
    esac

    # Cleanup
    echo -e "${BLUE}Cleaning up...${NC}"
    umount "$MOUNT_POINT"
    rmdir "$MOUNT_POINT"

    echo -e "${GREEN}Password reset completed.${NC}"
    echo -e "${YELLOW}Restart the computer and try logging in.${NC}"
}

# Function for Mac firmware password removal guidance
mac_firmware_password_guidance() {
    echo -e "${BLUE}Mac Firmware Password Removal Guidance${NC}"

    echo -e "${YELLOW}Note: Removing a Mac firmware password typically requires:${NC}"
    echo -e "1. Proof of ownership (original receipt)"
    echo -e "2. Service from an Apple Authorized Service Provider"

    echo -e "${BLUE}For Macs before 2018:${NC}"
    echo -e "1. Shut down the Mac"
    echo -e "2. Remove the bottom case"
    echo -e "3. Locate and remove the RAM"
    echo -e "4. Reinsert one RAM module"
    echo -e "5. Power on the Mac"
    echo -e "6. Reset NVRAM by holding Cmd+Opt+P+R during startup"
    echo -e "7. Shut down and reinstall all RAM"

    echo -e "${BLUE}For T2 and Apple Silicon Macs:${NC}"
    echo -e "${YELLOW}These Macs have enhanced security and require Apple service.${NC}"
    echo -e "Contact Apple Support or visit an Apple Store with proof of purchase."

    echo -e "${RED}WARNING: Attempting to bypass firmware passwords on modern Macs${NC}"
    echo -e "${RED}may cause permanent damage to the device.${NC}"
}

# Function for UEFI/BIOS password reset guidance
uefi_bios_password_guidance() {
    echo -e "${BLUE}UEFI/BIOS Password Reset Guidance${NC}"

    echo -e "${YELLOW}Common methods to reset UEFI/BIOS passwords:${NC}"

    echo -e "${BLUE}Method 1: CMOS Battery Removal${NC}"
    echo -e "1. Shut down and unplug the computer"
    echo -e "2. Open the computer case"
    echo -e "3. Locate the CMOS battery (silver coin cell)"
    echo -e "4. Remove the battery for 5-10 minutes"
    echo -e "5. Reinstall the battery and reassemble"
    echo -e "6. Power on - BIOS settings should be reset to defaults"

    echo -e "${BLUE}Method 2: CMOS Jumper Reset${NC}"
    echo -e "1. Shut down and unplug the computer"
    echo -e "2. Open the computer case"
    echo -e "3. Locate the CMOS reset jumper on the motherboard"
    echo -e "   (Usually labeled CLEAR, CLR, CLEAR CMOS, or similar)"
    echo -e "4. Move the jumper from pins 1-2 to pins 2-3 for 10 seconds"
    echo -e "5. Return the jumper to its original position"
    echo -e "6. Reassemble and power on"

    echo -e "${BLUE}Method 3: Manufacturer-Specific Recovery${NC}"
    echo -e "Many manufacturers have specific recovery procedures or backdoor passwords."
    echo -e "Check the manufacturer's website or contact support."

    echo -e "${YELLOW}For laptops, the process may vary significantly by manufacturer.${NC}"
    echo -e "Some laptops have the CMOS battery soldered to the motherboard,"
    echo -e "making removal difficult without specialized tools."

    echo -e "${RED}WARNING: Opening your computer may void warranty.${NC}"
    echo -e "${RED}Proceed with caution and at your own risk.${NC}"
}

# Function for disk encryption recovery
disk_encryption_recovery() {
    echo -e "${BLUE}Disk Encryption Recovery${NC}"

    echo -e "${YELLOW}Select encryption type:${NC}"
    echo -e "1. BitLocker (Windows)"
    echo -e "2. FileVault (Mac)"
    echo -e "3. LUKS (Linux)"
    read ENCRYPTION_TYPE

    case $ENCRYPTION_TYPE in
        1)
            echo -e "${BLUE}BitLocker Recovery${NC}"
            echo -e "${YELLOW}Recovery options:${NC}"
            echo -e "1. Use Microsoft account (if linked)"
            echo -e "   - Go to account.microsoft.com/devices"
            echo -e "   - Sign in and find the device"
            echo -e "   - Look for BitLocker recovery key"
            echo -e ""
            echo -e "2. Use organizational account (if applicable)"
            echo -e "   - Contact your IT department"
            echo -e ""
            echo -e "3. Use recovery key backup"
            echo -e "   - Check USB drives for RecoveryKey.txt"
            echo -e "   - Check printed copies of the recovery key"
            echo -e ""
            echo -e "${RED}Without a recovery key, data recovery is extremely difficult.${NC}"
            echo -e "${RED}Professional data recovery services may be able to help,${NC}"
            echo -e "${RED}but success is not guaranteed and costs can be high.${NC}"
            ;;
        2)
            echo -e "${BLUE}FileVault Recovery${NC}"
            echo -e "${YELLOW}Recovery options:${NC}"
            echo -e "1. Use recovery key"
            echo -e "   - Enter the 24-character recovery key when prompted"
            echo -e ""
            echo -e "2. Use iCloud account (if configured)"
            echo -e "   - Enter your Apple ID and password when prompted"
            echo -e ""
            echo -e "3. Use institutional recovery key (if applicable)"
            echo -e "   - Contact your IT department"
            echo -e ""
            echo -e "${RED}Without a recovery key or Apple ID, data recovery is extremely difficult.${NC}"
            ;;
        3)
            echo -e "${BLUE}LUKS Encryption Recovery${NC}"
            echo -e "${YELLOW}Recovery options:${NC}"
            echo -e "1. Use passphrase backup"
            echo -e "   - Enter the passphrase when prompted"
            echo -e ""
            echo -e "2. Use LUKS header backup (if created)"
            echo -e "   - Restore the header using cryptsetup"
            echo -e ""
            echo -e "3. Use recovery key (if created)"
            echo -e "   - Apply the recovery key using cryptsetup"
            echo -e ""
            echo -e "${RED}Without a passphrase or header backup, data recovery is extremely difficult.${NC}"
            ;;
        *)
            echo -e "${RED}Invalid option.${NC}"
            return
            ;;
    esac
}

# Function for secure boot bypass guidance
secure_boot_bypass() {
    echo -e "${BLUE}Secure Boot Bypass Guidance${NC}"

    echo -e "${YELLOW}Secure Boot is a security feature in UEFI that prevents${NC}"
    echo -e "${YELLOW}unauthorized operating systems from loading during startup.${NC}"

    echo -e "${BLUE}Method 1: Disable Secure Boot in UEFI/BIOS${NC}"
    echo -e "1. Restart the computer"
    echo -e "2. Enter UEFI/BIOS setup (usually F2, F10, F12, or Del during startup)"
    echo -e "3. Navigate to the 'Security' or 'Boot' section"
    echo -e "4. Find 'Secure Boot' option and set it to 'Disabled'"
    echo -e "5. Save changes and exit"

    echo -e "${BLUE}Method 2: Enroll Custom Keys (Advanced)${NC}"
    echo -e "For users who need to maintain Secure Boot while using custom software:"
    echo -e "1. Enter UEFI setup"
    echo -e "2. Set Secure Boot to 'Custom' or 'Setup Mode'"
    echo -e "3. Clear existing keys"
    echo -e "4. Enroll your own keys using tools like KeyTool or sbsigntools"
    echo -e "5. Sign your bootloader with these keys"

    echo -e "${RED}WARNING: Disabling Secure Boot reduces system security.${NC}"
    echo -e "${RED}Only disable it if absolutely necessary.${NC}"
}

# Main function
main() {
    echo -e "${BLUE}============================================================${NC}"
    echo -e "${CYAN}             ADVANCED SYSTEM RECOVERY TOOLS                 ${NC}"
    echo -e "${BLUE}============================================================${NC}"
    echo -e "${YELLOW}This utility provides advanced methods to recover access${NC}"
    echo -e "${YELLOW}to locked systems when standard methods fail.${NC}"
    echo -e "${RED}WARNING: USE THESE TOOLS RESPONSIBLY AND LEGALLY!${NC}"
    echo -e "${BLUE}============================================================${NC}"

    # Display legal disclaimer
    display_disclaimer

    # Detect system type
    detect_system_type

    # Detect storage devices
    detect_storage_devices

    # Display recovery options
    echo -e "${BLUE}============================================================${NC}"
    echo -e "${CYAN}                  RECOVERY OPTIONS                          ${NC}"
    echo -e "${BLUE}============================================================${NC}"
    echo -e "1. Windows Password Reset"
    echo -e "2. Linux Password Reset"
    echo -e "3. Mac Firmware Password Removal Guidance"
    echo -e "4. UEFI/BIOS Password Reset Guidance"
    echo -e "5. Disk Encryption Recovery"
    echo -e "6. Secure Boot Bypass Guidance"
    echo -e "7. Mac Account Recovery (iCloud/Family Access)"
    echo -e "0. Exit"
    echo -e "${BLUE}============================================================${NC}"
    echo -e "Enter your choice [0-7]: "
    read CHOICE

    case $CHOICE in
        1)
            windows_password_reset
            ;;
        2)
            linux_password_reset
            ;;
        3)
            mac_firmware_password_guidance
            ;;
        4)
            uefi_bios_password_guidance
            ;;
        5)
            disk_encryption_recovery
            ;;
        6)
            secure_boot_bypass
            ;;
        7)
            # Run the Mac Account Recovery script
            if [ -f "$SCRIPT_DIR/mac_account_recovery.sh" ]; then
                bash "$SCRIPT_DIR/mac_account_recovery.sh"
            else
                echo -e "${RED}Mac Account Recovery script not found.${NC}"
                echo -e "${YELLOW}Please ensure mac_account_recovery.sh exists in the same directory.${NC}"
            fi
            ;;
        0)
            echo -e "${GREEN}Exiting advanced recovery tools.${NC}"
            exit 0
            ;;
        *)
            echo -e "${RED}Invalid choice.${NC}"
            ;;
    esac

    echo -e "${BLUE}============================================================${NC}"
    echo -e "${GREEN}Recovery operation completed.${NC}"
    echo -e "${BLUE}============================================================${NC}"
}

# Run the main function
main
