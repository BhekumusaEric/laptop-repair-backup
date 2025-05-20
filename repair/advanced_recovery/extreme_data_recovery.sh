#!/bin/bash

# PC Repair Toolkit - Extreme Data Recovery Module
# This script provides advanced methods for recovering data from severely damaged systems
# WARNING: These methods should only be used as a last resort

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
    echo -e "${YELLOW}This tool contains extreme data recovery methods that:${NC}"
    echo -e "${YELLOW}1. Should ONLY be used on systems you legally own${NC}"
    echo -e "${YELLOW}2. Should ONLY be used when all other recovery methods have failed${NC}"
    echo -e "${YELLOW}3. May cause further damage to already compromised systems${NC}"
    echo -e "${YELLOW}4. Provide NO GUARANTEE of successful data recovery${NC}"
    echo -e ""
    echo -e "${RED}IMPROPER USE MAY RESULT IN PERMANENT DATA LOSS${NC}"
    echo -e ""
    echo -e "${YELLOW}By continuing, you confirm that:${NC}"
    echo -e "${YELLOW}1. You are the legal owner of the data you are attempting to recover${NC}"
    echo -e "${YELLOW}2. You accept all risks associated with these recovery methods${NC}"
    echo -e "${YELLOW}3. You understand that these methods may not be successful${NC}"
    echo -e "${RED}============================================================${NC}"
    echo -e "Do you understand and accept these terms? (yes/no): "
    read ACCEPT
    
    if [ "$ACCEPT" != "yes" ]; then
        echo -e "${RED}Terms not accepted. Exiting.${NC}"
        exit 1
    fi
    
    echo -e "${YELLOW}Please enter a brief description of the data loss situation:${NC}"
    read DATA_LOSS_DESCRIPTION
    
    # Log the acceptance and description
    echo "$(date): Extreme data recovery used. Situation: $DATA_LOSS_DESCRIPTION" >> "$SCRIPT_DIR/extreme_recovery.log"
}

# Function to detect available storage devices
detect_storage_devices() {
    echo -e "${BLUE}Detecting storage devices...${NC}"
    
    # Get list of storage devices
    echo -e "${CYAN}Available storage devices:${NC}"
    lsblk -o NAME,SIZE,TYPE,MOUNTPOINT | grep -E "disk|part" | grep -v "loop"
    
    # Check for damaged devices that might not show up in lsblk
    echo -e "${BLUE}Checking for additional devices...${NC}"
    ls -la /dev/sd* /dev/nvme* /dev/mmcblk* 2>/dev/null
}

# Function for raw disk imaging
raw_disk_imaging() {
    echo -e "${BLUE}Raw Disk Imaging${NC}"
    
    # Detect storage devices
    detect_storage_devices
    
    # Select source device
    echo -e "${YELLOW}Enter the source device to recover (e.g., /dev/sda):${NC}"
    read SOURCE_DEVICE
    
    if [ ! -b "$SOURCE_DEVICE" ]; then
        echo -e "${RED}Invalid device: $SOURCE_DEVICE${NC}"
        return
    fi
    
    # Get device size
    DEVICE_SIZE=$(blockdev --getsize64 "$SOURCE_DEVICE" 2>/dev/null)
    if [ -z "$DEVICE_SIZE" ]; then
        echo -e "${YELLOW}Could not determine device size. Proceed with caution.${NC}"
        DEVICE_SIZE="unknown"
    else
        DEVICE_SIZE_GB=$(echo "scale=2; $DEVICE_SIZE / 1024 / 1024 / 1024" | bc)
        echo -e "${GREEN}Device size:${NC} $DEVICE_SIZE_GB GB"
    fi
    
    # Select destination
    echo -e "${YELLOW}Enter the destination path for the disk image:${NC}"
    read DEST_PATH
    
    # Create directory if it doesn't exist
    DEST_DIR=$(dirname "$DEST_PATH")
    mkdir -p "$DEST_DIR"
    
    # Check available space
    DEST_FS=$(df -P "$DEST_DIR" | awk 'NR==2 {print $1}')
    AVAIL_SPACE=$(df -P "$DEST_DIR" | awk 'NR==2 {print $4}')
    AVAIL_SPACE_BYTES=$((AVAIL_SPACE * 1024))
    
    if [ "$DEVICE_SIZE" != "unknown" ] && [ "$AVAIL_SPACE_BYTES" -lt "$DEVICE_SIZE" ]; then
        echo -e "${RED}Warning: Destination may not have enough space.${NC}"
        echo -e "${RED}Required: $(echo "scale=2; $DEVICE_SIZE / 1024 / 1024 / 1024" | bc) GB${NC}"
        echo -e "${RED}Available: $(echo "scale=2; $AVAIL_SPACE_BYTES / 1024 / 1024 / 1024" | bc) GB${NC}"
        echo -e "${YELLOW}Do you want to continue anyway? (yes/no):${NC}"
        read CONTINUE
        
        if [ "$CONTINUE" != "yes" ]; then
            echo -e "${RED}Operation cancelled.${NC}"
            return
        fi
    fi
    
    # Select imaging method
    echo -e "${YELLOW}Select imaging method:${NC}"
    echo -e "1. Standard (dd) - Good for healthy drives"
    echo -e "2. Fault-tolerant (ddrescue) - Better for damaged drives"
    read IMAGING_METHOD
    
    case $IMAGING_METHOD in
        1)
            echo -e "${BLUE}Using standard dd method...${NC}"
            echo -e "${YELLOW}This may take several hours depending on drive size.${NC}"
            
            # Create log file
            LOG_FILE="$DEST_DIR/dd_$(date +%Y%m%d_%H%M%S).log"
            
            # Start imaging with progress reporting
            dd if="$SOURCE_DEVICE" of="$DEST_PATH" bs=4M conv=sync,noerror status=progress 2> "$LOG_FILE"
            
            if [ $? -eq 0 ]; then
                echo -e "${GREEN}Imaging completed successfully.${NC}"
                echo -e "${GREEN}Image saved to:${NC} $DEST_PATH"
                echo -e "${GREEN}Log saved to:${NC} $LOG_FILE"
            else
                echo -e "${RED}Imaging failed. Check log for details:${NC} $LOG_FILE"
            fi
            ;;
            
        2)
            # Check if ddrescue is installed
            if ! command -v ddrescue &> /dev/null; then
                echo -e "${YELLOW}Installing ddrescue...${NC}"
                apt-get update
                apt-get install -y gddrescue
            fi
            
            echo -e "${BLUE}Using fault-tolerant ddrescue method...${NC}"
            echo -e "${YELLOW}This may take several hours or days depending on drive condition.${NC}"
            
            # Create log file
            LOG_FILE="$DEST_DIR/ddrescue_$(date +%Y%m%d_%H%M%S).log"
            MAP_FILE="$DEST_DIR/ddrescue_$(date +%Y%m%d_%H%M%S).map"
            
            # Start imaging with ddrescue
            ddrescue -d -r3 -v "$SOURCE_DEVICE" "$DEST_PATH" "$MAP_FILE" 2> "$LOG_FILE"
            
            if [ $? -eq 0 ]; then
                echo -e "${GREEN}Imaging completed.${NC}"
                echo -e "${GREEN}Image saved to:${NC} $DEST_PATH"
                echo -e "${GREEN}Map file saved to:${NC} $MAP_FILE"
                echo -e "${GREEN}Log saved to:${NC} $LOG_FILE"
            else
                echo -e "${YELLOW}Imaging completed with errors.${NC}"
                echo -e "${YELLOW}Image saved to:${NC} $DEST_PATH"
                echo -e "${YELLOW}Map file saved to:${NC} $MAP_FILE"
                echo -e "${YELLOW}Log saved to:${NC} $LOG_FILE"
                echo -e "${YELLOW}You may want to run ddrescue again with the map file to improve recovery.${NC}"
            fi
            ;;
            
        *)
            echo -e "${RED}Invalid option.${NC}"
            return
            ;;
    esac
}

# Function for file carving
file_carving() {
    echo -e "${BLUE}File Carving Recovery${NC}"
    
    # Check if required tools are installed
    if ! command -v foremost &> /dev/null || ! command -v scalpel &> /dev/null; then
        echo -e "${YELLOW}Installing required tools...${NC}"
        apt-get update
        apt-get install -y foremost scalpel
    fi
    
    # Select source
    echo -e "${YELLOW}Select source type:${NC}"
    echo -e "1. Disk/Partition (e.g., /dev/sda1)"
    echo -e "2. Disk Image (e.g., disk.img)"
    read SOURCE_TYPE
    
    case $SOURCE_TYPE in
        1)
            # Detect storage devices
            detect_storage_devices
            
            echo -e "${YELLOW}Enter the source device/partition:${NC}"
            read SOURCE
            
            if [ ! -b "$SOURCE" ]; then
                echo -e "${RED}Invalid device: $SOURCE${NC}"
                return
            fi
            ;;
            
        2)
            echo -e "${YELLOW}Enter the path to the disk image:${NC}"
            read SOURCE
            
            if [ ! -f "$SOURCE" ]; then
                echo -e "${RED}File not found: $SOURCE${NC}"
                return
            fi
            ;;
            
        *)
            echo -e "${RED}Invalid option.${NC}"
            return
            ;;
    esac
    
    # Select destination
    echo -e "${YELLOW}Enter the destination directory for recovered files:${NC}"
    read DEST_DIR
    
    # Create directory if it doesn't exist
    mkdir -p "$DEST_DIR"
    
    # Select file types to recover
    echo -e "${YELLOW}Select file types to recover:${NC}"
    echo -e "1. All supported types"
    echo -e "2. Images (jpg, png, gif, etc.)"
    echo -e "3. Documents (pdf, doc, xls, etc.)"
    echo -e "4. Archives (zip, rar, etc.)"
    echo -e "5. Custom (specify file extensions)"
    read FILE_TYPES
    
    # Select recovery tool
    echo -e "${YELLOW}Select recovery tool:${NC}"
    echo -e "1. Foremost (faster, less thorough)"
    echo -e "2. Scalpel (slower, more thorough)"
    read RECOVERY_TOOL
    
    # Create configuration based on file types
    CONFIG_FILE=""
    case $FILE_TYPES in
        1)
            # Use default configuration
            ;;
        2)
            # Images only
            if [ "$RECOVERY_TOOL" = "1" ]; then
                CONFIG_FILE="$DEST_DIR/foremost.conf"
                grep -E "^jpg|^png|^gif|^bmp|^tiff" /etc/foremost.conf > "$CONFIG_FILE"
            else
                CONFIG_FILE="$DEST_DIR/scalpel.conf"
                grep -E "^jpg|^png|^gif|^bmp|^tiff" /etc/scalpel/scalpel.conf > "$CONFIG_FILE"
                sed -i 's/^#//' "$CONFIG_FILE"
            fi
            ;;
        3)
            # Documents only
            if [ "$RECOVERY_TOOL" = "1" ]; then
                CONFIG_FILE="$DEST_DIR/foremost.conf"
                grep -E "^pdf|^doc|^xls|^ppt|^ole" /etc/foremost.conf > "$CONFIG_FILE"
            else
                CONFIG_FILE="$DEST_DIR/scalpel.conf"
                grep -E "^pdf|^doc|^xls|^ppt|^ole" /etc/scalpel/scalpel.conf > "$CONFIG_FILE"
                sed -i 's/^#//' "$CONFIG_FILE"
            fi
            ;;
        4)
            # Archives only
            if [ "$RECOVERY_TOOL" = "1" ]; then
                CONFIG_FILE="$DEST_DIR/foremost.conf"
                grep -E "^zip|^rar|^gz|^7z" /etc/foremost.conf > "$CONFIG_FILE"
            else
                CONFIG_FILE="$DEST_DIR/scalpel.conf"
                grep -E "^zip|^rar|^gz|^7z" /etc/scalpel/scalpel.conf > "$CONFIG_FILE"
                sed -i 's/^#//' "$CONFIG_FILE"
            fi
            ;;
        5)
            # Custom
            echo -e "${YELLOW}Enter file extensions to recover (comma-separated, e.g., jpg,pdf,doc):${NC}"
            read EXTENSIONS
            
            IFS=',' read -ra EXT_ARRAY <<< "$EXTENSIONS"
            
            if [ "$RECOVERY_TOOL" = "1" ]; then
                CONFIG_FILE="$DEST_DIR/foremost.conf"
                touch "$CONFIG_FILE"
                for ext in "${EXT_ARRAY[@]}"; do
                    grep "^$ext" /etc/foremost.conf >> "$CONFIG_FILE" 2>/dev/null
                done
            else
                CONFIG_FILE="$DEST_DIR/scalpel.conf"
                touch "$CONFIG_FILE"
                for ext in "${EXT_ARRAY[@]}"; do
                    grep "^$ext" /etc/scalpel/scalpel.conf >> "$CONFIG_FILE" 2>/dev/null
                    sed -i 's/^#//' "$CONFIG_FILE"
                done
            fi
            ;;
        *)
            echo -e "${RED}Invalid option.${NC}"
            return
            ;;
    esac
    
    # Run recovery
    case $RECOVERY_TOOL in
        1)
            echo -e "${BLUE}Running Foremost file carving...${NC}"
            if [ -n "$CONFIG_FILE" ]; then
                foremost -i "$SOURCE" -o "$DEST_DIR/recovered" -c "$CONFIG_FILE" -v
            else
                foremost -i "$SOURCE" -o "$DEST_DIR/recovered" -v
            fi
            ;;
        2)
            echo -e "${BLUE}Running Scalpel file carving...${NC}"
            if [ -n "$CONFIG_FILE" ]; then
                scalpel -i "$SOURCE" -o "$DEST_DIR/recovered" -c "$CONFIG_FILE" -v
            else
                scalpel -i "$SOURCE" -o "$DEST_DIR/recovered" -c /etc/scalpel/scalpel.conf -v
            fi
            ;;
        *)
            echo -e "${RED}Invalid option.${NC}"
            return
            ;;
    esac
    
    echo -e "${GREEN}File carving completed.${NC}"
    echo -e "${GREEN}Recovered files saved to:${NC} $DEST_DIR/recovered"
    echo -e "${YELLOW}Note: Recovered files may not have their original names or directory structure.${NC}"
}

# Function for RAID recovery
raid_recovery() {
    echo -e "${BLUE}RAID Recovery${NC}"
    
    # Check if mdadm is installed
    if ! command -v mdadm &> /dev/null; then
        echo -e "${YELLOW}Installing required tools...${NC}"
        apt-get update
        apt-get install -y mdadm
    fi
    
    # Detect potential RAID devices
    echo -e "${BLUE}Detecting potential RAID devices...${NC}"
    mdadm --examine --scan
    
    echo -e "${YELLOW}Select RAID recovery method:${NC}"
    echo -e "1. Assemble existing RAID array"
    echo -e "2. Recover failed RAID array"
    echo -e "3. Scan for RAID superblocks"
    read RAID_METHOD
    
    case $RAID_METHOD in
        1)
            echo -e "${BLUE}Assembling existing RAID array...${NC}"
            
            # Detect storage devices
            detect_storage_devices
            
            echo -e "${YELLOW}Enter the RAID devices (space-separated, e.g., /dev/sda1 /dev/sdb1):${NC}"
            read -a RAID_DEVICES
            
            echo -e "${YELLOW}Enter the RAID level (0, 1, 5, 6, 10):${NC}"
            read RAID_LEVEL
            
            echo -e "${YELLOW}Enter the mount point for the assembled array:${NC}"
            read MOUNT_POINT
            
            # Create mount point if it doesn't exist
            mkdir -p "$MOUNT_POINT"
            
            # Assemble the array
            mdadm --assemble --run /dev/md0 "${RAID_DEVICES[@]}"
            
            if [ $? -eq 0 ]; then
                echo -e "${GREEN}RAID array assembled successfully.${NC}"
                
                # Mount the array
                mount /dev/md0 "$MOUNT_POINT"
                
                if [ $? -eq 0 ]; then
                    echo -e "${GREEN}RAID array mounted at:${NC} $MOUNT_POINT"
                else
                    echo -e "${RED}Failed to mount RAID array.${NC}"
                    echo -e "${YELLOW}You may need to run fsck first:${NC}"
                    echo -e "fsck -y /dev/md0"
                fi
            else
                echo -e "${RED}Failed to assemble RAID array.${NC}"
                echo -e "${YELLOW}Trying forced assembly...${NC}"
                
                mdadm --assemble --force --run /dev/md0 "${RAID_DEVICES[@]}"
                
                if [ $? -eq 0 ]; then
                    echo -e "${GREEN}RAID array force-assembled successfully.${NC}"
                    
                    # Mount the array
                    mount /dev/md0 "$MOUNT_POINT"
                    
                    if [ $? -eq 0 ]; then
                        echo -e "${GREEN}RAID array mounted at:${NC} $MOUNT_POINT"
                    else
                        echo -e "${RED}Failed to mount RAID array.${NC}"
                        echo -e "${YELLOW}You may need to run fsck first:${NC}"
                        echo -e "fsck -y /dev/md0"
                    fi
                else
                    echo -e "${RED}Failed to force-assemble RAID array.${NC}"
                    echo -e "${YELLOW}Trying to create a degraded array...${NC}"
                    
                    mdadm --create --assume-clean --level="$RAID_LEVEL" --raid-devices="${#RAID_DEVICES[@]}" /dev/md0 "${RAID_DEVICES[@]}"
                    
                    if [ $? -eq 0 ]; then
                        echo -e "${GREEN}Degraded RAID array created successfully.${NC}"
                        echo -e "${YELLOW}Warning: This is a last-resort method and may not recover all data.${NC}"
                        
                        # Try to mount
                        mount /dev/md0 "$MOUNT_POINT"
                        
                        if [ $? -eq 0 ]; then
                            echo -e "${GREEN}RAID array mounted at:${NC} $MOUNT_POINT"
                        else
                            echo -e "${RED}Failed to mount RAID array.${NC}"
                        fi
                    else
                        echo -e "${RED}All RAID recovery attempts failed.${NC}"
                    fi
                fi
            fi
            ;;
            
        2)
            echo -e "${BLUE}Recovering failed RAID array...${NC}"
            
            # Detect storage devices
            detect_storage_devices
            
            echo -e "${YELLOW}Enter the RAID devices (space-separated, e.g., /dev/sda1 /dev/sdb1):${NC}"
            read -a RAID_DEVICES
            
            echo -e "${YELLOW}Enter the RAID level (0, 1, 5, 6, 10):${NC}"
            read RAID_LEVEL
            
            echo -e "${YELLOW}Enter the number of devices in the original array:${NC}"
            read RAID_DEVICES_COUNT
            
            echo -e "${YELLOW}Enter the mount point for the recovered array:${NC}"
            read MOUNT_POINT
            
            # Create mount point if it doesn't exist
            mkdir -p "$MOUNT_POINT"
            
            # Try to assemble with missing devices
            echo -e "${BLUE}Attempting to assemble array with missing devices...${NC}"
            mdadm --assemble --run --force /dev/md0 "${RAID_DEVICES[@]}"
            
            if [ $? -eq 0 ]; then
                echo -e "${GREEN}RAID array assembled successfully.${NC}"
                
                # Mount the array
                mount /dev/md0 "$MOUNT_POINT"
                
                if [ $? -eq 0 ]; then
                    echo -e "${GREEN}RAID array mounted at:${NC} $MOUNT_POINT"
                else
                    echo -e "${RED}Failed to mount RAID array.${NC}"
                    echo -e "${YELLOW}You may need to run fsck first:${NC}"
                    echo -e "fsck -y /dev/md0"
                fi
            else
                echo -e "${RED}Failed to assemble RAID array.${NC}"
                echo -e "${YELLOW}Trying to create a degraded array...${NC}"
                
                mdadm --create --assume-clean --level="$RAID_LEVEL" --raid-devices="$RAID_DEVICES_COUNT" /dev/md0 "${RAID_DEVICES[@]}" missing
                
                if [ $? -eq 0 ]; then
                    echo -e "${GREEN}Degraded RAID array created successfully.${NC}"
                    echo -e "${YELLOW}Warning: This is a last-resort method and may not recover all data.${NC}"
                    
                    # Try to mount
                    mount /dev/md0 "$MOUNT_POINT"
                    
                    if [ $? -eq 0 ]; then
                        echo -e "${GREEN}RAID array mounted at:${NC} $MOUNT_POINT"
                    else
                        echo -e "${RED}Failed to mount RAID array.${NC}"
                    fi
                else
                    echo -e "${RED}All RAID recovery attempts failed.${NC}"
                fi
            fi
            ;;
            
        3)
            echo -e "${BLUE}Scanning for RAID superblocks...${NC}"
            
            # Detect storage devices
            detect_storage_devices
            
            echo -e "${YELLOW}Enter the devices to scan (space-separated, e.g., /dev/sda /dev/sdb):${NC}"
            read -a SCAN_DEVICES
            
            for device in "${SCAN_DEVICES[@]}"; do
                echo -e "${BLUE}Scanning $device for RAID superblocks...${NC}"
                mdadm --examine "$device"
            done
            ;;
            
        *)
            echo -e "${RED}Invalid option.${NC}"
            return
            ;;
    esac
}

# Main function
main() {
    echo -e "${BLUE}============================================================${NC}"
    echo -e "${CYAN}             EXTREME DATA RECOVERY TOOLS                    ${NC}"
    echo -e "${BLUE}============================================================${NC}"
    echo -e "${YELLOW}This utility provides extreme methods to recover data${NC}"
    echo -e "${YELLOW}from severely damaged or inaccessible systems.${NC}"
    echo -e "${RED}WARNING: THESE ARE LAST-RESORT METHODS!${NC}"
    echo -e "${BLUE}============================================================${NC}"
    
    # Display legal disclaimer
    display_disclaimer
    
    # Display recovery options
    echo -e "${BLUE}============================================================${NC}"
    echo -e "${CYAN}                  RECOVERY OPTIONS                          ${NC}"
    echo -e "${BLUE}============================================================${NC}"
    echo -e "1. Raw Disk Imaging (for physically failing drives)"
    echo -e "2. File Carving (recover files from damaged filesystems)"
    echo -e "3. RAID Recovery (rebuild damaged RAID arrays)"
    echo -e "0. Exit"
    echo -e "${BLUE}============================================================${NC}"
    echo -e "Enter your choice [0-3]: "
    read CHOICE
    
    case $CHOICE in
        1)
            raw_disk_imaging
            ;;
        2)
            file_carving
            ;;
        3)
            raid_recovery
            ;;
        0)
            echo -e "${GREEN}Exiting extreme data recovery tools.${NC}"
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
