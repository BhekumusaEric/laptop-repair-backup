#!/bin/bash

# PC Repair Toolkit - Mac Activation Lock Bypass Module
# This script provides advanced methods for bypassing Activation Lock on Mac devices
# when standard Apple verification processes aren't working
# IMPORTANT: These methods should only be used for legitimate device owners

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

# Function to display legal disclaimer
display_disclaimer() {
    echo -e "${RED}============================================================${NC}"
    echo -e "${RED}                    LEGAL DISCLAIMER                         ${NC}"
    echo -e "${RED}============================================================${NC}"
    echo -e "${YELLOW}This tool contains advanced recovery methods that should ONLY be used:${NC}"
    echo -e "${YELLOW}1. On devices you legally own or have explicit permission to access${NC}"
    echo -e "${YELLOW}2. For legitimate recovery purposes when standard methods fail${NC}"
    echo -e "${YELLOW}3. In compliance with all applicable laws and regulations${NC}"
    echo -e ""
    echo -e "${RED}UNAUTHORIZED ACCESS TO DEVICES IS ILLEGAL${NC}"
    echo -e "${RED}AND MAY RESULT IN CIVIL AND CRIMINAL PENALTIES.${NC}"
    echo -e ""
    echo -e "${YELLOW}By continuing, you confirm that:${NC}"
    echo -e "${YELLOW}1. You are the legal owner of the device or have explicit permission${NC}"
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

# Function for MDM-based Activation Lock bypass
mdm_bypass_guidance() {
    echo -e "${BLUE}============================================================${NC}"
    echo -e "${CYAN}           MDM-BASED ACTIVATION LOCK BYPASS                ${NC}"
    echo -e "${BLUE}============================================================${NC}"
    
    echo -e "${YELLOW}For enterprise/business-owned Mac devices enrolled in MDM:${NC}"
    echo -e ""
    echo -e "${CYAN}Method 1: Device Enrollment Credential Override${NC}"
    echo -e "If the Mac is secured with an organization-linked Activation Lock:"
    echo -e "1. On the Activation Lock screen, enter the Apple ID credentials of the user"
    echo -e "   who created the device enrollment token in Apple Business Manager"
    echo -e "2. This user must have the role of Administrator or Device Enrollment Manager"
    echo -e "3. Leave all other fields as they are and proceed with activation"
    echo -e ""
    echo -e "${CYAN}Method 2: MDM Activation Lock Bypass Code${NC}"
    echo -e "For supervised Mac devices with T2 or Apple Silicon:"
    echo -e "1. Contact your IT administrator to generate an Activation Lock bypass code"
    echo -e "2. On the Activation Lock screen, click 'Recovery Assistant' in the menu bar"
    echo -e "3. Select 'Activate with MDM key' option"
    echo -e "4. Enter the bypass code provided by your IT administrator"
    echo -e "5. Complete the activation process"
    echo -e ""
    echo -e "${CYAN}Method 3: Apple Business Manager Direct Unlock${NC}"
    echo -e "As of 2024, Apple Business Manager can directly disable Activation Lock:"
    echo -e "1. Have your IT administrator log into Apple Business Manager"
    echo -e "2. Navigate to the Devices section"
    echo -e "3. Locate your device by serial number"
    echo -e "4. Select the option to disable Activation Lock"
    echo -e "5. Restart your Mac and proceed through setup"
    echo -e ""
    echo -e "${RED}NOTE: These methods require enterprise management and won't work${NC}"
    echo -e "${RED}for personally-owned devices not enrolled in MDM.${NC}"
    
    echo -e ""
    echo -e "${BLUE}Press Enter to return to the main menu...${NC}"
    read
}

# Function for Apple Support escalation techniques
apple_support_escalation() {
    echo -e "${BLUE}============================================================${NC}"
    echo -e "${CYAN}           APPLE SUPPORT ESCALATION TECHNIQUES             ${NC}"
    echo -e "${BLUE}============================================================${NC}"
    
    echo -e "${YELLOW}When standard Apple Support channels aren't working:${NC}"
    echo -e ""
    echo -e "${CYAN}Method 1: Business Support Escalation${NC}"
    echo -e "1. Call Apple Business Support directly: 1-800-800-2775"
    echo -e "   (Do NOT use regular consumer support)"
    echo -e "2. Explain that you have proof of ownership but are unable to"
    echo -e "   complete the standard verification process"
    echo -e "3. Ask to speak with a senior advisor if the first-level support cannot help"
    echo -e "4. Be prepared to provide:"
    echo -e "   - Original purchase receipt with serial number"
    echo -e "   - Affidavit of ownership (notarized if possible)"
    echo -e "   - Government-issued ID matching the name on the affidavit"
    echo -e "   - Any documentation showing chain of ownership"
    echo -e ""
    echo -e "${CYAN}Method 2: In-Person Genius Bar Appointment${NC}"
    echo -e "1. Schedule an in-person appointment at an Apple Store Genius Bar"
    echo -e "2. Bring all documentation mentioned above"
    echo -e "3. Request that the Genius escalate to a manager if needed"
    echo -e "4. Be polite but persistent about your legitimate ownership"
    echo -e ""
    echo -e "${CYAN}Method 3: Legal Documentation Route${NC}"
    echo -e "If you have legal documentation such as:"
    echo -e "- Court order granting you ownership"
    echo -e "- Estate documentation (for inherited devices)"
    echo -e "- Business dissolution paperwork (for company-owned devices)"
    echo -e ""
    echo -e "1. Submit these documents to Apple Legal via certified mail"
    echo -e "2. Include a formal letter explaining your situation"
    echo -e "3. Provide contact information for follow-up"
    echo -e "4. Allow 2-4 weeks for processing"
    
    echo -e ""
    echo -e "${BLUE}Press Enter to return to the main menu...${NC}"
    read
}

# Function for T2/Apple Silicon recovery techniques
t2_silicon_recovery() {
    echo -e "${BLUE}============================================================${NC}"
    echo -e "${CYAN}           T2/APPLE SILICON RECOVERY TECHNIQUES            ${NC}"
    echo -e "${BLUE}============================================================${NC}"
    
    echo -e "${YELLOW}For T2 and Apple Silicon Macs with Activation Lock:${NC}"
    echo -e ""
    echo -e "${CYAN}Method 1: Recovery Mode DFU Technique${NC}"
    echo -e "1. Shut down your Mac completely"
    echo -e "2. For T2 Macs: Hold Command+R while pressing the power button"
    echo -e "   For Apple Silicon: Press and hold the power button until 'Loading startup options' appears"
    echo -e "3. Select Options > Continue to enter Recovery Mode"
    echo -e "4. From Recovery Mode, open Terminal from the Utilities menu"
    echo -e "5. Run the command: 'resetpassword'"
    echo -e "6. In the Reset Password tool, select 'Recovery Assistant' from the menu bar"
    echo -e "7. Look for any available activation options"
    echo -e ""
    echo -e "${CYAN}Method 2: Apple Configurator 2 Approach (requires another Mac)${NC}"
    echo -e "1. Install Apple Configurator 2 on another Mac"
    echo -e "2. Connect your locked Mac to the other Mac with appropriate cables"
    echo -e "3. Put your locked Mac into DFU mode:"
    echo -e "   - For T2 Macs: Follow Apple's DFU mode instructions for your specific model"
    echo -e "   - For Apple Silicon: Power off, then press and hold power button while connecting"
    echo -e "4. In Apple Configurator 2, select the device when it appears"
    echo -e "5. Choose 'Advanced' > 'Revive Device' or 'Restore Device'"
    echo -e "6. This will reinstall the operating system but may not bypass Activation Lock"
    echo -e "7. After restore, check if Activation Lock status has changed"
    echo -e ""
    echo -e "${RED}WARNING: These methods may not work in all cases and could result${NC}"
    echo -e "${RED}in data loss. They should only be attempted as a last resort.${NC}"
    
    echo -e ""
    echo -e "${BLUE}Press Enter to return to the main menu...${NC}"
    read
}

# Function for professional service options
professional_service_options() {
    echo -e "${BLUE}============================================================${NC}"
    echo -e "${CYAN}           PROFESSIONAL SERVICE OPTIONS                    ${NC}"
    echo -e "${BLUE}============================================================${NC}"
    
    echo -e "${YELLOW}When all other methods have failed:${NC}"
    echo -e ""
    echo -e "${CYAN}Option 1: Apple Authorized Service Providers${NC}"
    echo -e "Some Apple Authorized Service Providers have additional resources"
    echo -e "for Activation Lock removal with proper proof of ownership:"
    echo -e ""
    echo -e "1. Visit https://locate.apple.com to find authorized providers"
    echo -e "2. Call ahead to ask specifically about Activation Lock removal services"
    echo -e "3. Bring all ownership documentation and the device"
    echo -e "4. Be prepared to leave the device for several days"
    echo -e ""
    echo -e "${CYAN}Option 2: Logic Board Service${NC}"
    echo -e "As an absolute last resort for devices with critical data:"
    echo -e ""
    echo -e "1. Some specialized repair shops can transfer the SSD data to a new logic board"
    echo -e "2. This is expensive ($500-1500 depending on model) and not guaranteed"
    echo -e "3. Only consider this if the data on the device is irreplaceable"
    echo -e "4. Research the repair shop thoroughly before proceeding"
    echo -e ""
    echo -e "${RED}WARNING: Third-party services that claim to remove Activation Lock${NC}"
    echo -e "${RED}remotely are often scams or use questionable methods. Only use${NC}"
    echo -e "${RED}reputable, verifiable service providers.${NC}"
    
    echo -e ""
    echo -e "${BLUE}Press Enter to return to the main menu...${NC}"
    read
}

# Main function
main() {
    clear
    echo -e "${BLUE}============================================================${NC}"
    echo -e "${CYAN}           MAC ACTIVATION LOCK BYPASS TOOLS                ${NC}"
    echo -e "${BLUE}============================================================${NC}"
    echo -e "${YELLOW}This utility provides advanced methods for bypassing${NC}"
    echo -e "${YELLOW}Activation Lock on Mac devices for legitimate owners.${NC}"
    echo -e "${RED}WARNING: USE THESE TOOLS RESPONSIBLY AND LEGALLY!${NC}"
    echo -e "${BLUE}============================================================${NC}"
    
    # Display legal disclaimer
    display_disclaimer
    
    while true; do
        clear
        echo -e "${BLUE}============================================================${NC}"
        echo -e "${CYAN}           MAC ACTIVATION LOCK BYPASS TOOLS                ${NC}"
        echo -e "${BLUE}============================================================${NC}"
        echo -e "1. MDM-Based Activation Lock Bypass"
        echo -e "2. Apple Support Escalation Techniques"
        echo -e "3. T2/Apple Silicon Recovery Techniques"
        echo -e "4. Professional Service Options"
        echo -e "0. Return to Main Menu"
        echo -e "${BLUE}============================================================${NC}"
        echo -e "Enter your choice [0-4]: "
        read CHOICE
        
        case $CHOICE in
            1)
                mdm_bypass_guidance
                ;;
            2)
                apple_support_escalation
                ;;
            3)
                t2_silicon_recovery
                ;;
            4)
                professional_service_options
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
