#!/bin/bash

# PC Repair Toolkit - Mac System Reset Module
# This script provides functionality to completely erase and reinstall macOS
# It handles Apple-specific features like FileVault, T2 security, and Recovery Mode

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
        
        echo -e "${CYAN}Would you like to continue with guidance for Mac reset? (y/n)${NC}"
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

# Function to check for Recovery Mode
check_recovery_mode() {
    if [ "$GUIDANCE_MODE" = true ]; then
        echo -e "${YELLOW}In guidance mode - skipping Recovery Mode check${NC}"
        return
    fi
    
    echo -e "${BLUE}Checking if running in Recovery Mode...${NC}"
    
    # Check for Recovery Mode
    if [ -d "/Volumes/Recovery" ] || [ -d "/Volumes/Image Volume" ]; then
        echo -e "${GREEN}Running in Recovery Mode. Good!${NC}"
        RECOVERY_MODE=true
    else
        echo -e "${YELLOW}Not running in Recovery Mode.${NC}"
        echo -e "${YELLOW}Some operations may not be possible.${NC}"
        RECOVERY_MODE=false
    fi
}

# Function to check for T2 security chip or Apple Silicon
check_security_chip() {
    if [ "$GUIDANCE_MODE" = true ]; then
        echo -e "${YELLOW}In guidance mode - skipping security chip check${NC}"
        return
    fi
    
    echo -e "${BLUE}Checking for T2 security chip or Apple Silicon...${NC}"
    
    # Check for Apple Silicon
    if [ "$(uname -m)" = "arm64" ]; then
        echo -e "${GREEN}Apple Silicon detected.${NC}"
        APPLE_SILICON=true
        T2_CHIP=false
    else
        # Check for T2 chip (Intel Macs)
        if system_profiler SPiBridgeDataType 2>/dev/null | grep -q "T2"; then
            echo -e "${GREEN}T2 security chip detected.${NC}"
            T2_CHIP=true
            APPLE_SILICON=false
        else
            echo -e "${YELLOW}No T2 security chip detected.${NC}"
            T2_CHIP=false
            APPLE_SILICON=false
        fi
    fi
}

# Function to check for FileVault encryption
check_filevault() {
    if [ "$GUIDANCE_MODE" = true ]; then
        echo -e "${YELLOW}In guidance mode - skipping FileVault check${NC}"
        return
    fi
    
    echo -e "${BLUE}Checking for FileVault encryption...${NC}"
    
    # Check FileVault status
    if fdesetup status 2>/dev/null | grep -q "FileVault is On"; then
        echo -e "${YELLOW}FileVault is enabled.${NC}"
        FILEVAULT_ENABLED=true
    else
        echo -e "${GREEN}FileVault is not enabled.${NC}"
        FILEVAULT_ENABLED=false
    fi
}

# Function to backup important data
backup_mac_data() {
    echo -e "${BLUE}Would you like to backup important data before proceeding? (y/n)${NC}"
    read BACKUP_CHOICE
    
    if [[ "$BACKUP_CHOICE" =~ ^[Yy]$ ]]; then
        if [ "$GUIDANCE_MODE" = true ]; then
            echo -e "${CYAN}To backup your Mac data:${NC}"
            echo -e "1. Connect an external drive with enough space"
            echo -e "2. Use Time Machine to create a backup:"
            echo -e "   - Open System Preferences > Time Machine"
            echo -e "   - Click 'Select Backup Disk'"
            echo -e "   - Choose your external drive"
            echo -e "   - Click 'Use Disk'"
            echo -e "   - Wait for the backup to complete"
            echo -e ""
            echo -e "3. Alternatively, manually copy important files:"
            echo -e "   - Documents, Pictures, Music, Movies folders"
            echo -e "   - Downloads folder"
            echo -e "   - Desktop items"
            echo -e "   - Application data (if needed)"
            echo -e ""
            echo -e "${YELLOW}Press Enter when backup is complete...${NC}"
            read
        else
            echo -e "${BLUE}Please specify a backup destination (e.g., external drive path):${NC}"
            read BACKUP_DEST
            
            if [ ! -d "$BACKUP_DEST" ]; then
                echo -e "${YELLOW}Backup destination does not exist. Creating directory...${NC}"
                mkdir -p "$BACKUP_DEST"
            fi
            
            echo -e "${BLUE}Backing up important user data...${NC}"
            
            # Create backup directory structure
            BACKUP_DIR="$BACKUP_DEST/MacBackup_$(date +%Y%m%d_%H%M%S)"
            mkdir -p "$BACKUP_DIR"
            
            # Backup user home directories
            echo -e "${CYAN}Backing up user home directories...${NC}"
            for USER_HOME in /Users/*; do
                if [ -d "$USER_HOME" ] && [ "$(basename "$USER_HOME")" != "Shared" ]; then
                    USER=$(basename "$USER_HOME")
                    echo -e "${CYAN}Backing up user: $USER${NC}"
                    
                    # Create user backup directory
                    mkdir -p "$BACKUP_DIR/$USER"
                    
                    # Backup important directories
                    for DIR in Documents Pictures Music Movies Downloads Desktop; do
                        if [ -d "$USER_HOME/$DIR" ]; then
                            echo -e "${CYAN}  Backing up $DIR...${NC}"
                            cp -R "$USER_HOME/$DIR" "$BACKUP_DIR/$USER/"
                        fi
                    done
                    
                    # Backup Safari bookmarks
                    if [ -f "$USER_HOME/Library/Safari/Bookmarks.plist" ]; then
                        mkdir -p "$BACKUP_DIR/$USER/Safari"
                        cp "$USER_HOME/Library/Safari/Bookmarks.plist" "$BACKUP_DIR/$USER/Safari/"
                    fi
                    
                    # Backup Mail data
                    if [ -d "$USER_HOME/Library/Mail" ]; then
                        mkdir -p "$BACKUP_DIR/$USER/Mail"
                        cp -R "$USER_HOME/Library/Mail" "$BACKUP_DIR/$USER/"
                    fi
                    
                    # Backup Contacts
                    if [ -d "$USER_HOME/Library/Application Support/AddressBook" ]; then
                        mkdir -p "$BACKUP_DIR/$USER/Contacts"
                        cp -R "$USER_HOME/Library/Application Support/AddressBook" "$BACKUP_DIR/$USER/Contacts/"
                    fi
                    
                    # Backup Calendar
                    if [ -d "$USER_HOME/Library/Calendars" ]; then
                        mkdir -p "$BACKUP_DIR/$USER/Calendars"
                        cp -R "$USER_HOME/Library/Calendars" "$BACKUP_DIR/$USER/Calendars/"
                    fi
                fi
            done
            
            echo -e "${GREEN}Backup completed to $BACKUP_DIR${NC}"
        fi
    else
        echo -e "${YELLOW}Skipping backup process.${NC}"
    fi
}

# Function to provide guidance for Mac reset
provide_mac_reset_guidance() {
    echo -e "${BLUE}============================================================${NC}"
    echo -e "${CYAN}            MAC RESET GUIDANCE                              ${NC}"
    echo -e "${BLUE}============================================================${NC}"
    
    echo -e "${YELLOW}To completely reset your Mac, follow these steps:${NC}"
    echo -e ""
    echo -e "${CYAN}1. Backup your data${NC}"
    echo -e "   - Use Time Machine or manually copy important files"
    echo -e "   - Ensure you have your Apple ID and passwords"
    echo -e "   - Note any software licenses you'll need to reinstall"
    echo -e ""
    echo -e "${CYAN}2. Sign out of services${NC}"
    echo -e "   - Sign out of iCloud (System Preferences > Apple ID)"
    echo -e "   - Sign out of iMessage (Messages app > Preferences > iMessage)"
    echo -e "   - Sign out of iTunes/App Store (Store menu > Sign Out)"
    echo -e "   - Deauthorize your computer in iTunes (Account > Deauthorize)"
    echo -e ""
    echo -e "${CYAN}3. Boot into Recovery Mode${NC}"
    
    if [ "$APPLE_SILICON" = true ]; then
        echo -e "   - Shut down your Mac"
        echo -e "   - Press and hold the power button until 'Loading startup options' appears"
        echo -e "   - Select Options > Continue"
    else
        echo -e "   - Restart your Mac"
        echo -e "   - Immediately press and hold Command (⌘) + R until the Apple logo appears"
    fi
    
    echo -e ""
    echo -e "${CYAN}4. Use Disk Utility to erase your disk${NC}"
    echo -e "   - Select Disk Utility from the Recovery menu"
    echo -e "   - Select your startup disk (usually Macintosh HD)"
    echo -e "   - If you see both 'Macintosh HD' and 'Macintosh HD - Data':"
    echo -e "     * Select 'Macintosh HD - Data' first and click Erase"
    echo -e "     * Then select 'Macintosh HD' and click Erase"
    echo -e "   - For Format, choose APFS"
    echo -e "   - Click Erase"
    echo -e "   - Quit Disk Utility when done"
    echo -e ""
    echo -e "${CYAN}5. Reinstall macOS${NC}"
    echo -e "   - Select 'Reinstall macOS' from the Recovery menu"
    echo -e "   - Follow the on-screen instructions"
    echo -e "   - The installation may take 30-60 minutes"
    echo -e ""
    echo -e "${CYAN}6. Set up your Mac as new${NC}"
    echo -e "   - When prompted, select 'Set up as new Mac'"
    echo -e "   - Follow the setup assistant to configure your Mac"
    echo -e ""
    
    if [ "$T2_CHIP" = true ] || [ "$APPLE_SILICON" = true ]; then
        echo -e "${YELLOW}Note: Your Mac has a T2 security chip or Apple Silicon.${NC}"
        echo -e "${YELLOW}This provides additional security but requires internet connection during reset.${NC}"
    fi
    
    echo -e "${BLUE}============================================================${NC}"
}

# Function to erase Mac disk
erase_mac_disk() {
    if [ "$GUIDANCE_MODE" = true ] || [ "$RECOVERY_MODE" = false ]; then
        echo -e "${YELLOW}Cannot perform disk erase - not in Recovery Mode or in guidance mode.${NC}"
        provide_mac_reset_guidance
        return
    }
    
    echo -e "${BLUE}Preparing to erase Mac disk...${NC}"
    
    # List available disks
    echo -e "${CYAN}Available disks:${NC}"
    diskutil list
    
    # Ask for confirmation
    echo -e "${RED}WARNING: This will COMPLETELY ERASE your Mac's disk!${NC}"
    echo -e "${RED}ALL DATA WILL BE PERMANENTLY LOST!${NC}"
    echo -e "Are you ABSOLUTELY SURE you want to continue? (yes/no): "
    read CONFIRM
    
    if [ "$CONFIRM" != "yes" ]; then
        echo -e "${YELLOW}Operation cancelled by user.${NC}"
        exit 0
    fi
    
    # Handle FileVault if enabled
    if [ "$FILEVAULT_ENABLED" = true ]; then
        echo -e "${YELLOW}FileVault is enabled. Disabling before erase...${NC}"
        fdesetup disable
    fi
    
    # Determine if we have a volume group (Catalina or later)
    SYSTEM_VOLUME=$(diskutil list | grep "Macintosh HD" | grep -v "Data" | awk '{print $NF}')
    DATA_VOLUME=$(diskutil list | grep "Macintosh HD - Data" | awk '{print $NF}')
    
    if [ -n "$DATA_VOLUME" ]; then
        echo -e "${CYAN}Volume group detected (Catalina or later).${NC}"
        echo -e "${CYAN}Erasing data volume first: $DATA_VOLUME${NC}"
        diskutil apfs deleteVolume "$DATA_VOLUME"
    fi
    
    # Erase the system volume
    if [ -n "$SYSTEM_VOLUME" ]; then
        echo -e "${CYAN}Erasing system volume: $SYSTEM_VOLUME${NC}"
        diskutil eraseDisk APFS "Macintosh HD" $(echo "$SYSTEM_VOLUME" | sed 's/s[0-9]$//')
    else
        echo -e "${RED}Could not identify system volume.${NC}"
        echo -e "${YELLOW}Please use Disk Utility to erase the disk manually.${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}Disk erase completed.${NC}"
}

# Function to reinstall macOS
reinstall_macos() {
    if [ "$GUIDANCE_MODE" = true ] || [ "$RECOVERY_MODE" = false ]; then
        echo -e "${YELLOW}Cannot perform macOS reinstall - not in Recovery Mode or in guidance mode.${NC}"
        provide_mac_reset_guidance
        return
    }
    
    echo -e "${BLUE}Preparing to reinstall macOS...${NC}"
    
    # Check internet connection
    echo -e "${CYAN}Checking internet connection...${NC}"
    if ping -c 1 apple.com >/dev/null 2>&1; then
        echo -e "${GREEN}Internet connection available.${NC}"
    else
        echo -e "${RED}No internet connection detected.${NC}"
        echo -e "${YELLOW}Internet connection is required for macOS reinstallation.${NC}"
        echo -e "${YELLOW}Please connect to a network and try again.${NC}"
        exit 1
    fi
    
    echo -e "${CYAN}Starting macOS reinstallation...${NC}"
    echo -e "${YELLOW}This will launch the macOS installer.${NC}"
    echo -e "${YELLOW}Follow the on-screen instructions to complete installation.${NC}"
    
    # Launch the reinstall process
    if [ "$APPLE_SILICON" = true ]; then
        echo -e "${CYAN}Launching macOS reinstall for Apple Silicon...${NC}"
        /System/Library/CoreServices/Restore\ Reinstall\ for\ Monterey.app/Contents/MacOS/Restore\ Reinstall\ for\ Monterey
    else
        echo -e "${CYAN}Launching macOS reinstall for Intel Mac...${NC}"
        /System/Library/CoreServices/Install\ macOS.app/Contents/Resources/startosinstall --volume "/Volumes/Macintosh HD" --rebootdelay 10
    fi
}

# Main function
main() {
    echo -e "${BLUE}============================================================${NC}"
    echo -e "${CYAN}                MAC SYSTEM RESET UTILITY                    ${NC}"
    echo -e "${BLUE}============================================================${NC}"
    echo -e "${YELLOW}This utility will completely erase your Mac and reinstall macOS.${NC}"
    echo -e "${RED}WARNING: ALL DATA WILL BE PERMANENTLY ERASED!${NC}"
    echo -e "${BLUE}============================================================${NC}"
    
    # Detect if running on a Mac
    detect_mac
    
    # Check for admin privileges
    check_admin
    
    # Check for Recovery Mode
    check_recovery_mode
    
    # Check for T2 security chip or Apple Silicon
    check_security_chip
    
    # Check for FileVault encryption
    check_filevault
    
    # If in guidance mode, provide instructions
    if [ "$GUIDANCE_MODE" = true ]; then
        provide_mac_reset_guidance
        exit 0
    fi
    
    # Backup important data
    backup_mac_data
    
    # If not in Recovery Mode, provide guidance
    if [ "$RECOVERY_MODE" = false ]; then
        echo -e "${YELLOW}Not running in Recovery Mode. Cannot perform disk erase.${NC}"
        provide_mac_reset_guidance
        exit 0
    fi
    
    # Erase Mac disk
    erase_mac_disk
    
    # Reinstall macOS
    reinstall_macos
    
    echo -e "${BLUE}============================================================${NC}"
    echo -e "${GREEN}Mac reset process initiated!${NC}"
    echo -e "${YELLOW}Follow the on-screen instructions to complete installation.${NC}"
    echo -e "${BLUE}============================================================${NC}"
}

# Run the main function
main
