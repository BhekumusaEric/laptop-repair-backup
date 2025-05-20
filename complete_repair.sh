#!/bin/bash

# Complete Boot Repair Script
# This script will completely reinstall the bootloader and set up a minimal bootable system
# WARNING: This will erase all data on the target drive

echo "===== Complete Boot Repair Script ====="
echo "This script will completely reinstall the bootloader and set up a minimal bootable system."
echo "WARNING: This will erase ALL data on /dev/sda!"
echo ""
echo "Press CTRL+C now to cancel or wait 10 seconds to continue..."
sleep 10

# Check if running as root
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root. Please use sudo."
    exit 1
fi

# Function to display progress
progress() {
    echo "===> $1"
}

# Check if the drive exists
if [ ! -b /dev/sda ]; then
    echo "ERROR: Drive /dev/sda not found!"
    exit 1
fi

# Completely wipe and repartition the drive
progress "Completely wiping and repartitioning /dev/sda..."
(
echo o # Create a new empty DOS partition table
echo n # Add a new partition
echo p # Primary partition
echo 1 # Partition number 1
echo   # First sector (default)
echo   # Last sector (default, uses whole disk)
echo a # Make partition bootable
echo w # Write changes
) | fdisk /dev/sda

# Format the partition
progress "Formatting /dev/sda1 as ext4..."
mkfs.ext4 -F /dev/sda1

# Create mount points
progress "Creating mount points..."
mkdir -p /mnt/system

# Mount the main partition
progress "Mounting main partition..."
mount /dev/sda1 /mnt/system || {
    echo "ERROR: Failed to mount /dev/sda1 after formatting!"
    exit 1
}

# Create basic directory structure
progress "Creating basic directory structure..."
mkdir -p /mnt/system/{boot,etc,bin,sbin,lib,lib64,usr,var}

# Check if debootstrap is available
if ! command -v debootstrap &> /dev/null; then
    progress "Installing debootstrap..."
    apt-get update
    apt-get install -y debootstrap
fi

# Install a minimal system (if debootstrap is available)
if command -v debootstrap &> /dev/null; then
    progress "Installing a minimal system using debootstrap..."
    debootstrap --arch=amd64 focal /mnt/system http://archive.ubuntu.com/ubuntu/
else
    progress "Debootstrap not available. Skipping minimal system installation."
fi

# Install GRUB to the MBR
progress "Installing GRUB to MBR..."
grub-install --boot-directory=/mnt/system/boot /dev/sda || {
    echo "ERROR: Failed to install GRUB!"
    exit 1
}

# Create a basic GRUB configuration
progress "Creating basic GRUB configuration..."
mkdir -p /mnt/system/boot/grub
cat > /mnt/system/boot/grub/grub.cfg << EOF
set timeout=5
set default=0

menuentry "Boot from first hard drive" {
    insmod part_msdos
    insmod ext2
    set root=(hd0,msdos1)
    linux /vmlinuz root=/dev/sda1 ro
    initrd /initrd.img
}

menuentry "Boot from USB" {
    insmod part_msdos
    insmod ext2
    set root=(hd1)
    chainloader +1
}
EOF

# If we have a minimal system installed, try to set it up properly
if [ -d "/mnt/system/etc" ]; then
    progress "Setting up the minimal system..."
    
    # Create fstab
    cat > /mnt/system/etc/fstab << EOF
# /etc/fstab: static file system information.
/dev/sda1  /  ext4  errors=remount-ro  0  1
EOF

    # Set up networking
    if [ -d "/mnt/system/etc/network" ]; then
        cat > /mnt/system/etc/network/interfaces << EOF
# This file describes the network interfaces available on your system
# and how to activate them. For more information, see interfaces(5).

source /etc/network/interfaces.d/*

# The loopback network interface
auto lo
iface lo inet loopback

# The primary network interface
auto eth0
iface eth0 inet dhcp
EOF
    fi
fi

# Clean up
progress "Unmounting file systems..."
umount /mnt/system

progress "Complete boot repair finished!"
echo ""
echo "Please remove the USB drive and restart your computer."
echo "If the system still doesn't boot, you may need to use a full OS installer."
