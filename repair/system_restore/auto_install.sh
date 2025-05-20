#!/bin/bash

# PC Repair Toolkit - Automated OS Installation
# This script creates unattended installation configurations for various operating systems
# Supports Windows, Ubuntu, and other Linux distributions

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

# Function to create Windows answer file (autounattend.xml)
create_windows_answer_file() {
    echo -e "${BLUE}Creating Windows unattended installation file...${NC}"
    
    # Ask for basic configuration
    echo -e "${CYAN}Enter computer name:${NC}"
    read COMPUTER_NAME
    
    echo -e "${CYAN}Enter username:${NC}"
    read USERNAME
    
    echo -e "${CYAN}Enter password:${NC}"
    read -s PASSWORD
    echo ""
    
    echo -e "${CYAN}Enter Windows product key (leave empty to skip):${NC}"
    read PRODUCT_KEY
    
    # Ask for destination
    echo -e "${CYAN}Enter path to save autounattend.xml:${NC}"
    read DEST_PATH
    
    # Create directory if it doesn't exist
    mkdir -p "$(dirname "$DEST_PATH")"
    
    # Create the answer file
    cat > "$DEST_PATH" << EOF
<?xml version="1.0" encoding="utf-8"?>
<unattend xmlns="urn:schemas-microsoft-com:unattend">
    <settings pass="windowsPE">
        <component name="Microsoft-Windows-International-Core-WinPE" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS" xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
            <SetupUILanguage>
                <UILanguage>en-US</UILanguage>
            </SetupUILanguage>
            <InputLocale>en-US</InputLocale>
            <SystemLocale>en-US</SystemLocale>
            <UILanguage>en-US</UILanguage>
            <UserLocale>en-US</UserLocale>
        </component>
        <component name="Microsoft-Windows-Setup" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS" xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
            <DiskConfiguration>
                <Disk wcm:action="add">
                    <CreatePartitions>
                        <CreatePartition wcm:action="add">
                            <Order>1</Order>
                            <Size>300</Size>
                            <Type>Primary</Type>
                        </CreatePartition>
                        <CreatePartition wcm:action="add">
                            <Order>2</Order>
                            <Size>100</Size>
                            <Type>EFI</Type>
                        </CreatePartition>
                        <CreatePartition wcm:action="add">
                            <Order>3</Order>
                            <Size>16</Size>
                            <Type>MSR</Type>
                        </CreatePartition>
                        <CreatePartition wcm:action="add">
                            <Order>4</Order>
                            <Extend>true</Extend>
                            <Type>Primary</Type>
                        </CreatePartition>
                    </CreatePartitions>
                    <ModifyPartitions>
                        <ModifyPartition wcm:action="add">
                            <Format>NTFS</Format>
                            <Label>WinRE</Label>
                            <Order>1</Order>
                            <PartitionID>1</PartitionID>
                            <TypeID>de94bba4-06d1-4d40-a16a-bfd50179d6ac</TypeID>
                        </ModifyPartition>
                        <ModifyPartition wcm:action="add">
                            <Format>FAT32</Format>
                            <Label>System</Label>
                            <Order>2</Order>
                            <PartitionID>2</PartitionID>
                        </ModifyPartition>
                        <ModifyPartition wcm:action="add">
                            <Order>3</Order>
                            <PartitionID>3</PartitionID>
                        </ModifyPartition>
                        <ModifyPartition wcm:action="add">
                            <Format>NTFS</Format>
                            <Label>Windows</Label>
                            <Letter>C</Letter>
                            <Order>4</Order>
                            <PartitionID>4</PartitionID>
                        </ModifyPartition>
                    </ModifyPartitions>
                    <DiskID>0</DiskID>
                    <WillWipeDisk>true</WillWipeDisk>
                </Disk>
            </DiskConfiguration>
            <ImageInstall>
                <OSImage>
                    <InstallTo>
                        <DiskID>0</DiskID>
                        <PartitionID>4</PartitionID>
                    </InstallTo>
                    <InstallToAvailablePartition>false</InstallToAvailablePartition>
                </OSImage>
            </ImageInstall>
            <UserData>
                <AcceptEula>true</AcceptEula>
EOF

    # Add product key if provided
    if [ -n "$PRODUCT_KEY" ]; then
        cat >> "$DEST_PATH" << EOF
                <ProductKey>
                    <Key>$PRODUCT_KEY</Key>
                </ProductKey>
EOF
    fi

    cat >> "$DEST_PATH" << EOF
            </UserData>
        </component>
    </settings>
    <settings pass="specialize">
        <component name="Microsoft-Windows-Shell-Setup" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS" xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
            <ComputerName>$COMPUTER_NAME</ComputerName>
            <TimeZone>UTC</TimeZone>
        </component>
    </settings>
    <settings pass="oobeSystem">
        <component name="Microsoft-Windows-Shell-Setup" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS" xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
            <AutoLogon>
                <Password>
                    <Value>$PASSWORD</Value>
                    <PlainText>true</PlainText>
                </Password>
                <Enabled>true</Enabled>
                <Username>$USERNAME</Username>
            </AutoLogon>
            <OOBE>
                <HideEULAPage>true</HideEULAPage>
                <HideLocalAccountScreen>true</HideLocalAccountScreen>
                <HideOEMRegistrationScreen>true</HideOEMRegistrationScreen>
                <HideOnlineAccountScreens>true</HideOnlineAccountScreens>
                <HideWirelessSetupInOOBE>true</HideWirelessSetupInOOBE>
                <NetworkLocation>Home</NetworkLocation>
                <ProtectYourPC>1</ProtectYourPC>
            </OOBE>
            <UserAccounts>
                <LocalAccounts>
                    <LocalAccount wcm:action="add">
                        <Password>
                            <Value>$PASSWORD</Value>
                            <PlainText>true</PlainText>
                        </Password>
                        <DisplayName>$USERNAME</DisplayName>
                        <Group>Administrators</Group>
                        <Name>$USERNAME</Name>
                    </LocalAccount>
                </LocalAccounts>
            </UserAccounts>
        </component>
    </settings>
</unattend>
EOF

    echo -e "${GREEN}Windows answer file created at $DEST_PATH${NC}"
    echo -e "${YELLOW}Instructions:${NC}"
    echo -e "1. Copy this file to the root of your Windows installation USB"
    echo -e "2. Rename it to 'autounattend.xml'"
    echo -e "3. Boot from the USB to start the unattended installation"
}

# Function to create Ubuntu preseed file
create_ubuntu_preseed() {
    echo -e "${BLUE}Creating Ubuntu preseed file...${NC}"
    
    # Ask for basic configuration
    echo -e "${CYAN}Enter hostname:${NC}"
    read HOSTNAME
    
    echo -e "${CYAN}Enter username:${NC}"
    read USERNAME
    
    echo -e "${CYAN}Enter password:${NC}"
    read -s PASSWORD
    echo ""
    
    # Ask for destination
    echo -e "${CYAN}Enter path to save preseed.cfg:${NC}"
    read DEST_PATH
    
    # Create directory if it doesn't exist
    mkdir -p "$(dirname "$DEST_PATH")"
    
    # Create the preseed file
    cat > "$DEST_PATH" << EOF
# Localization
d-i debian-installer/locale string en_US.UTF-8
d-i keyboard-configuration/xkb-keymap select us

# Network configuration
d-i netcfg/choose_interface select auto
d-i netcfg/get_hostname string $HOSTNAME
d-i netcfg/get_domain string localdomain

# Mirror settings
d-i mirror/country string manual
d-i mirror/http/hostname string archive.ubuntu.com
d-i mirror/http/directory string /ubuntu
d-i mirror/http/proxy string

# Account setup
d-i passwd/root-login boolean false
d-i passwd/user-fullname string $USERNAME
d-i passwd/username string $USERNAME
d-i passwd/user-password password $PASSWORD
d-i passwd/user-password-again password $PASSWORD
d-i user-setup/allow-password-weak boolean true
d-i user-setup/encrypt-home boolean false

# Clock and time zone setup
d-i clock-setup/utc boolean true
d-i time/zone string UTC
d-i clock-setup/ntp boolean true

# Partitioning
d-i partman-auto/method string regular
d-i partman-auto/choose_recipe select atomic
d-i partman-partitioning/confirm_write_new_label boolean true
d-i partman/choose_partition select finish
d-i partman/confirm boolean true
d-i partman/confirm_nooverwrite boolean true

# Package selection
tasksel tasksel/first multiselect ubuntu-desktop
d-i pkgsel/include string openssh-server build-essential
d-i pkgsel/upgrade select full-upgrade
d-i pkgsel/update-policy select none

# Boot loader installation
d-i grub-installer/only_debian boolean true
d-i grub-installer/with_other_os boolean true
d-i grub-installer/bootdev string default

# Finishing up the installation
d-i finish-install/reboot_in_progress note
EOF

    echo -e "${GREEN}Ubuntu preseed file created at $DEST_PATH${NC}"
    echo -e "${YELLOW}Instructions:${NC}"
    echo -e "1. Copy this file to the root of your Ubuntu installation USB"
    echo -e "2. Edit the boot menu (press F6 at boot) and add:"
    echo -e "   auto=true priority=critical file=/cdrom/preseed.cfg"
    echo -e "3. Boot from the USB to start the unattended installation"
}

# Function to create Kickstart file for RHEL/CentOS/Fedora
create_kickstart() {
    echo -e "${BLUE}Creating Kickstart file...${NC}"
    
    # Ask for basic configuration
    echo -e "${CYAN}Enter hostname:${NC}"
    read HOSTNAME
    
    echo -e "${CYAN}Enter username:${NC}"
    read USERNAME
    
    echo -e "${CYAN}Enter password:${NC}"
    read -s PASSWORD
    echo ""
    
    # Generate encrypted password
    ENCRYPTED_PASSWORD=$(python3 -c "import crypt; print(crypt.crypt('$PASSWORD', crypt.mksalt(crypt.METHOD_SHA512)))")
    
    # Ask for destination
    echo -e "${CYAN}Enter path to save kickstart.cfg:${NC}"
    read DEST_PATH
    
    # Create directory if it doesn't exist
    mkdir -p "$(dirname "$DEST_PATH")"
    
    # Create the kickstart file
    cat > "$DEST_PATH" << EOF
#version=RHEL8
# System authorization information
auth --enableshadow --passalgo=sha512

# Use graphical install
graphical

# Run the Setup Agent on first boot
firstboot --enable

# Keyboard layouts
keyboard --vckeymap=us --xlayouts='us'

# System language
lang en_US.UTF-8

# Network information
network --bootproto=dhcp --device=link --activate
network --hostname=$HOSTNAME

# Root password
rootpw --iscrypted $ENCRYPTED_PASSWORD

# Create user
user --groups=wheel --name=$USERNAME --password=$ENCRYPTED_PASSWORD --iscrypted

# System services
services --enabled="chronyd"

# System timezone
timezone America/New_York --isUtc

# Disk partitioning
clearpart --all --initlabel
autopart --type=lvm

# Bootloader configuration
bootloader --location=mbr

# Accept EULA
eula --agreed

# Reboot after installation
reboot

%packages
@^minimal-environment
@standard
chrony
kexec-tools
%end

%addon com_redhat_kdump --enable --reserve-mb='auto'
%end

%anaconda
pwpolicy root --minlen=6 --minquality=1 --notstrict --nochanges --notempty
pwpolicy user --minlen=6 --minquality=1 --notstrict --nochanges --emptyok
pwpolicy luks --minlen=6 --minquality=1 --notstrict --nochanges --notempty
%end
EOF

    echo -e "${GREEN}Kickstart file created at $DEST_PATH${NC}"
    echo -e "${YELLOW}Instructions:${NC}"
    echo -e "1. Copy this file to the root of your RHEL/CentOS/Fedora installation USB"
    echo -e "2. Edit the boot menu and add:"
    echo -e "   inst.ks=cdrom:/kickstart.cfg"
    echo -e "3. Boot from the USB to start the unattended installation"
}

# Main function
main() {
    echo -e "${BLUE}============================================================${NC}"
    echo -e "${CYAN}            AUTOMATED OS INSTALLATION CREATOR               ${NC}"
    echo -e "${BLUE}============================================================${NC}"
    echo -e "${YELLOW}This utility creates unattended installation configurations${NC}"
    echo -e "${YELLOW}for various operating systems.${NC}"
    echo -e "${BLUE}============================================================${NC}"
    
    # Ask for OS type
    echo -e "${CYAN}Select the type of unattended installation to create:${NC}"
    echo -e "1. Windows (autounattend.xml)"
    echo -e "2. Ubuntu (preseed.cfg)"
    echo -e "3. RHEL/CentOS/Fedora (kickstart.cfg)"
    echo -e "Enter your choice [1-3]: "
    read OS_CHOICE
    
    case $OS_CHOICE in
        1)
            create_windows_answer_file
            ;;
        2)
            create_ubuntu_preseed
            ;;
        3)
            create_kickstart
            ;;
        *)
            echo -e "${RED}Invalid choice. Exiting.${NC}"
            exit 1
            ;;
    esac
    
    echo -e "${BLUE}============================================================${NC}"
    echo -e "${GREEN}Unattended installation configuration created successfully!${NC}"
    echo -e "${BLUE}============================================================${NC}"
}

# Run the main function
main
