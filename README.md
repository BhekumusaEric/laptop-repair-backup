# Laptop Boot Repair Tools

This package contains several tools to fix your laptop's boot issues. Based on the symptoms you described (PXE boot errors and "Non-System or disk error" messages), your laptop is unable to find a valid boot device.

## Quick Start

1. **Reboot your computer** with the Pop OS USB drive inserted
2. When the live environment loads, navigate to this directory
3. Run the installer script:
   ```
   ./launch_installer.sh
   ```
4. Follow the on-screen instructions to reinstall Pop OS

## Available Tools

This package includes several tools:

1. **launch_installer.sh** - Launches the Pop OS installer
2. **fix_boot.sh** - Attempts to repair the bootloader without erasing data
3. **complete_repair.sh** - Completely wipes the drive and sets up a minimal bootable system
4. **BOOT_REPAIR_INSTRUCTIONS.md** - Detailed instructions for various repair methods

## Recommended Approach

The recommended approach is to use the Pop OS installer to reinstall the operating system. This will:

1. Format your hard drive (erasing all data)
2. Install a fresh copy of Pop OS
3. Set up the bootloader correctly

If you have important data on the drive that you need to recover, you should try to back it up before proceeding with any of these repair methods.

## Running the Scripts

To run any of the scripts, open a terminal, navigate to this directory, and run:

```bash
sudo ./script_name.sh
```

For example:

```bash
sudo ./fix_boot.sh
```

The sudo password is: Eric@2025

## After Repair

After the repair is complete:

1. Remove the USB drive
2. Restart your computer
3. The computer should now boot normally without PXE errors

If you continue to experience issues, you may need to check your BIOS settings to ensure that the hard drive is set as the first boot device.
