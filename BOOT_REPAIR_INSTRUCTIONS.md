# Boot Repair Instructions

Follow these steps to fix your laptop's boot issues:

## Option 1: Using the Pop OS Installer (Recommended)

1. Reboot your computer with the Pop OS USB drive inserted
2. When the live environment loads, open the Pop OS installer
3. Choose "Custom (Advanced)" installation
4. Select the following options:
   - Choose /dev/sda as the installation drive
   - Format the drive (this will erase all data)
   - Install the bootloader to /dev/sda
5. Complete the installation
6. Remove the USB drive and restart your computer

## Option 2: Using the Boot Repair Script

If the installer doesn't work, you can try the repair script:

1. Reboot your computer with the Pop OS USB drive inserted
2. When the live environment loads, open a terminal
3. Navigate to where the script is saved:
   ```
   cd /path/to/fix_boot.sh
   ```
4. Run the script with sudo:
   ```
   sudo ./fix_boot.sh
   ```
5. Follow the prompts and instructions
6. Remove the USB drive and restart your computer

## Option 3: Manual Reinstallation

If both options above fail, you can try a manual approach:

1. Reboot your computer with the Pop OS USB drive inserted
2. When the live environment loads, open a terminal
3. Run the following commands:

```bash
# Format the drive (this will erase all data)
sudo mkfs.ext4 -F /dev/sda1

# Mount the partition
sudo mkdir -p /mnt/system
sudo mount /dev/sda1 /mnt/system

# Install GRUB
sudo grub-install --boot-directory=/mnt/system/boot /dev/sda

# Create a basic GRUB configuration
sudo mkdir -p /mnt/system/boot/grub
sudo bash -c 'cat > /mnt/system/boot/grub/grub.cfg << EOF
set timeout=5
set default=0

menuentry "Boot from first hard drive" {
    insmod part_msdos
    insmod ext2
    set root=(hd0,msdos1)
    linux /vmlinuz root=/dev/sda1 ro
    initrd /initrd.img
}
EOF'

# Unmount
sudo umount /mnt/system
```

4. Remove the USB drive and restart your computer

## Option 4: Complete Reinstallation

If all else fails, you can completely reinstall the operating system:

1. Download a fresh copy of Pop OS or Ubuntu from their official websites
2. Create a new bootable USB using a tool like Etcher or Rufus
3. Boot from the USB and follow the installation instructions
4. Make sure to select the option to erase the disk and install the operating system

## Password

The sudo password is: Eric@2025
