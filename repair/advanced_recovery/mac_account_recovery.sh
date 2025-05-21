#!/bin/bash

# PC Repair Toolkit - Mac Account Recovery Module
# This script provides guidance for recovering access to Mac devices
# when users have forgotten their iCloud credentials or for family members
# after someone has passed away

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

# Source utility functions if available
if [ -f "$PARENT_DIR/utils/logging.sh" ]; then
    source "$PARENT_DIR/utils/logging.sh"
fi

# Function for forgotten iCloud password recovery
forgotten_icloud_recovery() {
    echo -e "${BLUE}============================================================${NC}"
    echo -e "${CYAN}           FORGOTTEN ICLOUD PASSWORD RECOVERY              ${NC}"
    echo -e "${BLUE}============================================================${NC}"

    echo -e "${YELLOW}If you've forgotten your iCloud password, follow these steps:${NC}"
    echo -e ""
    echo -e "${CYAN}Method 1: Reset via Apple ID website${NC}"
    echo -e "1. Visit https://iforgot.apple.com in a web browser"
    echo -e "2. Enter your Apple ID email address"
    echo -e "3. Choose to reset your password"
    echo -e "4. Select how you want to reset (email authentication or security questions)"
    echo -e "5. Follow the on-screen instructions"
    echo -e ""
    echo -e "${CYAN}Method 2: Reset via another Apple device${NC}"
    echo -e "1. On another iPhone, iPad, or Mac signed in with the same Apple ID:"
    echo -e "   - Go to Settings > [your name] > Password & Security"
    echo -e "   - Tap 'Change Password' and follow the instructions"
    echo -e ""
    echo -e "${CYAN}Method 3: Contact Apple Support${NC}"
    echo -e "1. Visit https://support.apple.com"
    echo -e "2. Choose 'Apple ID' > 'Forgotten Apple ID or password'"
    echo -e "3. Follow the recovery steps or contact Apple directly"
    echo -e ""
    echo -e "${YELLOW}Note: You will need to verify your identity through:${NC}"
    echo -e "- Trusted phone numbers"
    echo -e "- Recovery email"
    echo -e "- Recovery key (if enabled)"
    echo -e "- Two-factor authentication trusted devices"

    echo -e ""
    echo -e "${BLUE}Press Enter to return to the main menu...${NC}"
    read
}

# Function for family access after death
family_access_recovery() {
    echo -e "${BLUE}============================================================${NC}"
    echo -e "${CYAN}           FAMILY ACCESS AFTER DEATH                       ${NC}"
    echo -e "${BLUE}============================================================${NC}"

    echo -e "${YELLOW}For accessing a deceased family member's Mac device:${NC}"
    echo -e ""
    echo -e "${CYAN}Option 1: Digital Legacy Program (iOS 15.2+ / macOS Monterey+)${NC}"
    echo -e "If the deceased person set up Legacy Contacts before passing:"
    echo -e "1. Visit https://digital-legacy.apple.com"
    echo -e "2. Click 'Request Access'"
    echo -e "3. Enter the deceased person's Apple ID"
    echo -e "4. Upload a copy of the death certificate"
    echo -e "5. Enter the access key provided to you as a Legacy Contact"
    echo -e "6. Follow the on-screen instructions to gain access"
    echo -e ""
    echo -e "${CYAN}Option 2: Apple Support with Court Order${NC}"
    echo -e "If Digital Legacy wasn't set up, you'll need legal documentation:"
    echo -e "1. Obtain a court order specifically naming you as the rightful inheritor"
    echo -e "   of the deceased person's digital assets"
    echo -e "2. Contact Apple Support at 1-800-275-2273 (US) or visit an Apple Store"
    echo -e "3. Provide the court order and death certificate"
    echo -e "4. Request access to the deceased person's Apple account"
    echo -e ""
    echo -e "${CYAN}Option 3: Device Reset (when legal access can't be obtained)${NC}"
    echo -e "If you cannot get legal access but need to use the device:"
    echo -e "1. You can erase the Mac and set it up as new, but all data will be lost"
    echo -e "2. Boot into Recovery Mode by holding Command+R during startup"
    echo -e "3. Use Disk Utility to erase the drive"
    echo -e "4. Reinstall macOS"
    echo -e ""
    echo -e "${RED}WARNING: Option 3 will permanently erase all data on the device.${NC}"
    echo -e "${RED}Only use this if you have legal rights to the device and data recovery is not needed.${NC}"

    echo -e ""
    echo -e "${BLUE}Press Enter to return to the main menu...${NC}"
    read
}

# Function for bypassing screen time or restrictions
bypass_screen_restrictions() {
    echo -e "${BLUE}============================================================${NC}"
    echo -e "${CYAN}           BYPASS SCREEN TIME & RESTRICTIONS               ${NC}"
    echo -e "${BLUE}============================================================${NC}"

    echo -e "${YELLOW}For bypassing Screen Time or restrictions on a Mac:${NC}"
    echo -e ""
    echo -e "${CYAN}Option 1: Reset Screen Time passcode (if you're the parent/owner)${NC}"
    echo -e "1. On another device signed in with the same Apple ID:"
    echo -e "   - Go to Settings > Screen Time > Change Screen Time Passcode"
    echo -e "   - Tap 'Forgot Passcode?' and authenticate with your Apple ID"
    echo -e ""
    echo -e "${CYAN}Option 2: For Family Sharing (if you're the family organizer)${NC}"
    echo -e "1. On your device:"
    echo -e "   - Go to Settings > [your name] > Family Sharing"
    echo -e "   - Select the family member's account"
    echo -e "   - Tap Screen Time and reset the passcode"
    echo -e ""
    echo -e "${CYAN}Option 3: Reset the Mac (last resort)${NC}"
    echo -e "If you have legitimate ownership but no access to Apple ID:"
    echo -e "1. Boot into Recovery Mode (Command+R during startup)"
    echo -e "2. Use Terminal and run: 'resetpassword'"
    echo -e "3. Reset the admin password"
    echo -e "4. After login, you can disable Screen Time from System Preferences"
    echo -e ""
    echo -e "${RED}WARNING: Only use these methods if you are the legitimate owner${NC}"
    echo -e "${RED}or legal guardian of the device. Unauthorized access may be illegal.${NC}"

    echo -e ""
    echo -e "${BLUE}Press Enter to return to the main menu...${NC}"
    read
}

# Function for activation lock bypass guidance
activation_lock_guidance() {
    echo -e "${BLUE}============================================================${NC}"
    echo -e "${CYAN}           ACTIVATION LOCK GUIDANCE                        ${NC}"
    echo -e "${BLUE}============================================================${NC}"

    echo -e "${YELLOW}For dealing with Activation Lock on Mac devices:${NC}"
    echo -e ""
    echo -e "${CYAN}Option 1: Remove Activation Lock with Apple ID${NC}"
    echo -e "If you know the Apple ID and password:"
    echo -e "1. Sign in with the Apple ID that enabled Activation Lock"
    echo -e "2. Go to System Preferences > Apple ID > iCloud"
    echo -e "3. Uncheck 'Find My Mac'"
    echo -e ""
    echo -e "${CYAN}Option 2: Remove via iCloud website${NC}"
    echo -e "1. Visit https://icloud.com/find"
    echo -e "2. Sign in with the Apple ID"
    echo -e "3. Click 'All Devices' and select the Mac"
    echo -e "4. Click 'Remove from Account'"
    echo -e ""
    echo -e "${CYAN}Option 3: Proof of Purchase (for legitimate owners)${NC}"
    echo -e "If you've forgotten the Apple ID or inherited the device:"
    echo -e "1. Gather proof of purchase (original receipt with serial number)"
    echo -e "2. Contact Apple Support at 1-800-275-2273 (US) or visit an Apple Store"
    echo -e "3. Provide proof of purchase and request Activation Lock removal"
    echo -e ""
    echo -e "${CYAN}Option 4: Advanced Activation Lock Bypass (for legitimate owners)${NC}"
    echo -e "If standard methods fail even with proof of ownership:"
    echo -e "1. We offer advanced bypass techniques for legitimate device owners"
    echo -e "2. These methods can help when Apple's standard verification fails"
    echo -e "3. To access these advanced tools, run the mac_activation_bypass.sh script"
    echo -e "   or select 'Advanced Activation Lock Bypass' from the main menu"
    echo -e ""
    echo -e "${RED}WARNING: Advanced bypass methods should only be used by legitimate${NC}"
    echo -e "${RED}device owners when standard Apple procedures have failed.${NC}"

    echo -e ""
    echo -e "${BLUE}Press Enter to return to the main menu...${NC}"
    read
}

# Main function
main() {
    while true; do
        clear
        echo -e "${BLUE}============================================================${NC}"
        echo -e "${CYAN}           MAC ACCOUNT RECOVERY TOOLS                      ${NC}"
        echo -e "${BLUE}============================================================${NC}"
        echo -e "1. Forgotten iCloud Password Recovery"
        echo -e "2. Family Access After Death"
        echo -e "3. Bypass Screen Time & Restrictions"
        echo -e "4. Activation Lock Guidance"
        echo -e "5. Advanced Activation Lock Bypass"
        echo -e "0. Return to Main Menu"
        echo -e "${BLUE}============================================================${NC}"
        echo -e "Enter your choice [0-5]: "
        read CHOICE

        case $CHOICE in
            1)
                forgotten_icloud_recovery
                ;;
            2)
                family_access_recovery
                ;;
            3)
                bypass_screen_restrictions
                ;;
            4)
                activation_lock_guidance
                ;;
            5)
                # Run the Advanced Activation Lock Bypass script
                if [ -f "$SCRIPT_DIR/mac_activation_bypass.sh" ]; then
                    bash "$SCRIPT_DIR/mac_activation_bypass.sh"
                else
                    echo -e "${RED}Advanced Activation Lock Bypass script not found.${NC}"
                    echo -e "${YELLOW}Please ensure mac_activation_bypass.sh exists in the same directory.${NC}"
                    sleep 3
                fi
                ;;
            0)
                echo -e "${GREEN}Returning to main menu.${NC}"
                exit 0
                ;;
            *)
                echo -e "${RED}Invalid choice.${NC}"
                sleep 2
                ;;
        esac
    done
}

# Run the main function
main
