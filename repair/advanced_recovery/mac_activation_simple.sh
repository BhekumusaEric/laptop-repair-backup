#!/bin/bash

# PC Repair Toolkit - Simple Mac Activation Lock Bypass
# This script provides easy-to-follow instructions for non-technical users
# to bypass Activation Lock on Mac devices they legitimately own

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

# Function to display simple disclaimer
display_disclaimer() {
    echo -e "${BLUE}============================================================${NC}"
    echo -e "${CYAN}           MAC ACTIVATION LOCK REMOVAL HELPER               ${NC}"
    echo -e "${BLUE}============================================================${NC}"
    echo -e "${YELLOW}This tool will help you regain access to a Mac that's locked${NC}"
    echo -e "${YELLOW}with an Apple ID that you can't access anymore.${NC}"
    echo -e ""
    echo -e "${YELLOW}Please confirm that:${NC}"
    echo -e "1. You are the legitimate owner of this Mac"
    echo -e "2. You have proof of purchase (receipt, invoice, etc.)"
    echo -e ""
    echo -e "Do you confirm you own this Mac? (yes/no): "
    read CONFIRM
    
    if [ "$CONFIRM" != "yes" ]; then
        echo -e "${RED}You need to be the legitimate owner to use this tool.${NC}"
        echo -e "${RED}Exiting...${NC}"
        exit 1
    fi
}

# Function to identify Mac model and age
identify_mac() {
    echo -e "${BLUE}============================================================${NC}"
    echo -e "${CYAN}                 IDENTIFY YOUR MAC                          ${NC}"
    echo -e "${BLUE}============================================================${NC}"
    
    echo -e "${YELLOW}Let's figure out what kind of Mac you have.${NC}"
    echo -e ""
    echo -e "1. MacBook/MacBook Pro/MacBook Air from 2018 or newer"
    echo -e "2. MacBook/MacBook Pro/MacBook Air from 2017 or older"
    echo -e "3. iMac/Mac mini/Mac Pro from 2018 or newer"
    echo -e "4. iMac/Mac mini/Mac Pro from 2017 or older"
    echo -e "5. I'm not sure (we'll help you identify it)"
    echo -e ""
    echo -e "Select your Mac type [1-5]: "
    read MAC_TYPE
    
    if [ "$MAC_TYPE" = "5" ]; then
        echo -e ""
        echo -e "${YELLOW}Let's identify your Mac:${NC}"
        echo -e "1. Click the Apple menu (🍎) in the top-left corner"
        echo -e "2. Select 'About This Mac'"
        echo -e "3. Look at the model and year information"
        echo -e ""
        echo -e "What year is your Mac from? (e.g., 2015, 2020): "
        read MAC_YEAR
        
        if [ "$MAC_YEAR" -ge 2018 ]; then
            echo -e "${YELLOW}Your Mac is newer (2018 or later).${NC}"
            echo -e "Is it a laptop (MacBook) or desktop (iMac, Mac mini, Mac Pro)?"
            echo -e "Type 'laptop' or 'desktop': "
            read MAC_FORM
            
            if [ "$MAC_FORM" = "laptop" ]; then
                MAC_TYPE=1
            else
                MAC_TYPE=3
            fi
        else
            echo -e "${YELLOW}Your Mac is older (2017 or earlier).${NC}"
            echo -e "Is it a laptop (MacBook) or desktop (iMac, Mac mini, Mac Pro)?"
            echo -e "Type 'laptop' or 'desktop': "
            read MAC_FORM
            
            if [ "$MAC_FORM" = "laptop" ]; then
                MAC_TYPE=2
            else
                MAC_TYPE=4
            fi
        fi
    fi
    
    # Store the Mac type for later use
    export MAC_TYPE
}

# Function for simple Apple ID recovery
simple_apple_id_recovery() {
    echo -e "${BLUE}============================================================${NC}"
    echo -e "${CYAN}              RECOVER YOUR APPLE ID                         ${NC}"
    echo -e "${BLUE}============================================================${NC}"
    
    echo -e "${YELLOW}If you remember your Apple ID but forgot the password:${NC}"
    echo -e ""
    echo -e "${CYAN}Step 1:${NC} Go to iforgot.apple.com on any device"
    echo -e "${CYAN}Step 2:${NC} Enter your Apple ID email address"
    echo -e "${CYAN}Step 3:${NC} Follow Apple's instructions to reset your password"
    echo -e ""
    echo -e "${YELLOW}This is the simplest solution and preserves all your data.${NC}"
    echo -e ""
    echo -e "Would you like to try this method now? (yes/no): "
    read TRY_APPLE_ID
    
    if [ "$TRY_APPLE_ID" = "yes" ]; then
        echo -e "${GREEN}Opening Apple ID recovery website...${NC}"
        echo -e "${YELLOW}Please go to your web browser to continue.${NC}"
        xdg-open "https://iforgot.apple.com" 2>/dev/null || open "https://iforgot.apple.com" 2>/dev/null || echo -e "${RED}Could not open browser. Please visit https://iforgot.apple.com manually.${NC}"
        
        echo -e ""
        echo -e "Were you able to recover your Apple ID? (yes/no): "
        read RECOVERED
        
        if [ "$RECOVERED" = "yes" ]; then
            echo -e "${GREEN}Great! You should now be able to unlock your Mac.${NC}"
            echo -e "${GREEN}Simply sign in with your recovered Apple ID.${NC}"
            exit 0
        else
            echo -e "${YELLOW}Let's try another approach...${NC}"
        fi
    fi
}

# Function for Apple Support contact
contact_apple_support() {
    echo -e "${BLUE}============================================================${NC}"
    echo -e "${CYAN}              CONTACT APPLE SUPPORT                         ${NC}"
    echo -e "${BLUE}============================================================${NC}"
    
    echo -e "${YELLOW}Apple Support can help remove Activation Lock if you have proof of purchase.${NC}"
    echo -e ""
    echo -e "${CYAN}What you'll need:${NC}"
    echo -e "1. Your Mac's serial number (found on the Activation Lock screen)"
    echo -e "2. Proof of purchase (original receipt with your name and the serial number)"
    echo -e "3. Your government-issued ID"
    echo -e ""
    echo -e "${CYAN}Steps to contact Apple:${NC}"
    echo -e "1. Call Apple Support: 1-800-275-2273 (US) or your local Apple Support number"
    echo -e "2. Tell them you need help with Activation Lock removal"
    echo -e "3. Explain that you have proof of purchase"
    echo -e "4. Follow their instructions to submit your documentation"
    echo -e ""
    echo -e "${YELLOW}This is the official and most reliable method.${NC}"
    echo -e ""
    echo -e "Would you like to visit Apple's support website? (yes/no): "
    read VISIT_SUPPORT
    
    if [ "$VISIT_SUPPORT" = "yes" ]; then
        echo -e "${GREEN}Opening Apple Support website...${NC}"
        echo -e "${YELLOW}Please go to your web browser to continue.${NC}"
        xdg-open "https://support.apple.com/contact" 2>/dev/null || open "https://support.apple.com/contact" 2>/dev/null || echo -e "${RED}Could not open browser. Please visit https://support.apple.com/contact manually.${NC}"
    fi
}

# Function for simple recovery mode reset
simple_recovery_mode() {
    echo -e "${BLUE}============================================================${NC}"
    echo -e "${CYAN}              RECOVERY MODE RESET                           ${NC}"
    echo -e "${BLUE}============================================================${NC}"
    
    echo -e "${YELLOW}You can try to reset your Mac using Recovery Mode.${NC}"
    echo -e "${RED}WARNING: This will erase all data on your Mac!${NC}"
    echo -e ""
    
    if [ "$MAC_TYPE" = "1" ] || [ "$MAC_TYPE" = "3" ]; then
        # Newer Macs (2018+)
        echo -e "${CYAN}For your newer Mac (2018 or later):${NC}"
        echo -e ""
        echo -e "1. Shut down your Mac completely"
        echo -e "2. Press and hold the power button until you see 'Loading startup options'"
        echo -e "3. Click 'Options' and then 'Continue'"
        echo -e "4. Select 'Disk Utility' and click 'Continue'"
        echo -e "5. Select your main drive (usually 'Macintosh HD')"
        echo -e "6. Click 'Erase' at the top of the window"
        echo -e "7. Confirm and wait for the process to complete"
        echo -e "8. Close Disk Utility"
        echo -e "9. Select 'Reinstall macOS' and follow the instructions"
    else
        # Older Macs (pre-2018)
        echo -e "${CYAN}For your older Mac (2017 or earlier):${NC}"
        echo -e ""
        echo -e "1. Shut down your Mac completely"
        echo -e "2. Turn on your Mac and immediately press and hold: Command (⌘) + R"
        echo -e "3. Keep holding until you see the Apple logo or spinning globe"
        echo -e "4. Select 'Disk Utility' and click 'Continue'"
        echo -e "5. Select your main drive (usually 'Macintosh HD')"
        echo -e "6. Click 'Erase' at the top of the window"
        echo -e "7. Confirm and wait for the process to complete"
        echo -e "8. Close Disk Utility"
        echo -e "9. Select 'Reinstall macOS' and follow the instructions"
    fi
    
    echo -e ""
    echo -e "${YELLOW}During setup, you may be able to skip the Activation Lock screen.${NC}"
    echo -e "${RED}Remember: This erases ALL your data. Only use if you have backups or don't need the data.${NC}"
}

# Function for in-person Apple Store visit
visit_apple_store() {
    echo -e "${BLUE}============================================================${NC}"
    echo -e "${CYAN}              VISIT AN APPLE STORE                          ${NC}"
    echo -e "${BLUE}============================================================${NC}"
    
    echo -e "${YELLOW}Sometimes, visiting an Apple Store in person is the easiest solution.${NC}"
    echo -e ""
    echo -e "${CYAN}What to bring:${NC}"
    echo -e "1. Your locked Mac"
    echo -e "2. Original proof of purchase (receipt with serial number)"
    echo -e "3. Your government-issued ID"
    echo -e ""
    echo -e "${CYAN}Steps:${NC}"
    echo -e "1. Make an appointment at the Genius Bar (recommended)"
    echo -e "2. Explain your situation to the Apple technician"
    echo -e "3. Show your proof of purchase and ID"
    echo -e "4. They can often remove Activation Lock on the spot"
    echo -e ""
    echo -e "Would you like to find the nearest Apple Store? (yes/no): "
    read FIND_STORE
    
    if [ "$FIND_STORE" = "yes" ]; then
        echo -e "${GREEN}Opening Apple Store locator...${NC}"
        echo -e "${YELLOW}Please go to your web browser to continue.${NC}"
        xdg-open "https://www.apple.com/retail/storelist/" 2>/dev/null || open "https://www.apple.com/retail/storelist/" 2>/dev/null || echo -e "${RED}Could not open browser. Please visit https://www.apple.com/retail/storelist/ manually.${NC}"
    fi
}

# Function for family member access
family_member_access() {
    echo -e "${BLUE}============================================================${NC}"
    echo -e "${CYAN}              FAMILY MEMBER ACCESS                          ${NC}"
    echo -e "${BLUE}============================================================${NC}"
    
    echo -e "${YELLOW}If this Mac belonged to a family member who has passed away:${NC}"
    echo -e ""
    echo -e "${CYAN}Option 1: Digital Legacy Program (for newer Macs)${NC}"
    echo -e "If your family member set you up as a Legacy Contact:"
    echo -e "1. Visit digital-legacy.apple.com"
    echo -e "2. Click 'Request Access'"
    echo -e "3. Enter their Apple ID"
    echo -e "4. Upload a copy of the death certificate"
    echo -e "5. Enter the access key they provided to you"
    echo -e ""
    echo -e "${CYAN}Option 2: Contact Apple Support with documentation${NC}"
    echo -e "1. Gather: Death certificate, proof of relation, and proof of Mac ownership"
    echo -e "2. Contact Apple Support at 1-800-275-2273 (US)"
    echo -e "3. Explain your situation and follow their guidance"
    echo -e ""
    echo -e "Would you like to learn more about Digital Legacy? (yes/no): "
    read LEARN_LEGACY
    
    if [ "$LEARN_LEGACY" = "yes" ]; then
        echo -e "${GREEN}Opening Digital Legacy information...${NC}"
        echo -e "${YELLOW}Please go to your web browser to continue.${NC}"
        xdg-open "https://support.apple.com/en-us/HT212360" 2>/dev/null || open "https://support.apple.com/en-us/HT212360" 2>/dev/null || echo -e "${RED}Could not open browser. Please visit https://support.apple.com/en-us/HT212360 manually.${NC}"
    fi
}

# Main function
main() {
    clear
    display_disclaimer
    identify_mac
    
    while true; do
        clear
        echo -e "${BLUE}============================================================${NC}"
        echo -e "${CYAN}           SIMPLE MAC ACTIVATION LOCK REMOVAL              ${NC}"
        echo -e "${BLUE}============================================================${NC}"
        echo -e "1. I forgot my Apple ID password"
        echo -e "2. Contact Apple Support (recommended)"
        echo -e "3. Reset using Recovery Mode (erases all data)"
        echo -e "4. Visit an Apple Store in person"
        echo -e "5. Access a deceased family member's Mac"
        echo -e "0. Exit"
        echo -e "${BLUE}============================================================${NC}"
        echo -e "Enter your choice [0-5]: "
        read CHOICE
        
        case $CHOICE in
            1)
                simple_apple_id_recovery
                ;;
            2)
                contact_apple_support
                ;;
            3)
                simple_recovery_mode
                ;;
            4)
                visit_apple_store
                ;;
            5)
                family_member_access
                ;;
            0)
                echo -e "${GREEN}Exiting. Good luck with your Mac!${NC}"
                exit 0
                ;;
            *)
                echo -e "${RED}Invalid choice. Please try again.${NC}"
                sleep 2
                ;;
        esac
        
        echo -e ""
        echo -e "${YELLOW}Press Enter to return to the main menu...${NC}"
        read
    done
}

# Run the main function
main
