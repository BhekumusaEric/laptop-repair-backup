#!/bin/bash

# Fix boot script for laptop with PXE boot issues
# This script will attempt to repair the bootloader on /dev/sda

echo "===== Boot Repair Script ====="
echo "This script will attempt to fix your boot issues."
echo "WARNING: This may erase data on your hard drive."
echo ""

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

progress "Checking disk partitions..."
fdisk -l /dev/sda

# Create mount points
progress "Creating mount points..."
mkdir -p /mnt/system

# Mount the main partition
progress "Mounting main partition..."
mount /dev/sda1 /mnt/system || {
    echo "Failed to mount /dev/sda1. Attempting to format and reinstall..."
    
    # Format the partition
    progress "Formatting /dev/sda1 as ext4..."
    mkfs.ext4 -F /dev/sda1
    
    # Mount again
    mount /dev/sda1 /mnt/system || {
        echo "ERROR: Still cannot mount /dev/sda1 after formatting!"
        exit 1
    }
}

# Check if we need to install a basic system
if [ ! -d "/mnt/system/boot" ]; then
    progress "No boot directory found. Creating basic directory structure..."
    mkdir -p /mnt/system/{boot,etc,bin,sbin,lib,lib64,usr,var}
fi

# Install GRUB to the MBR
progress "Installing GRUB to MBR..."
grub-install --boot-directory=/mnt/system/boot /dev/sda || {
    echo "ERROR: Failed to install GRUB!"
    exit 1
}

# Create a basic GRUB configuration if needed
if [ ! -f "/mnt/system/boot/grub/grub.cfg" ]; then
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
fi

# Clean up
progress "Unmounting file systems..."
umount /mnt/system

progress "Boot repair completed!"
echo ""
echo "Please remove the USB drive and restart your computer."
echo "If the system still doesn't boot, you may need to reinstall the operating system."
