#!/bin/bash

# Check if the installer is running
if pgrep -f "io.elementary.installer" > /dev/null; then
    echo "Pop OS installer is already running."
    echo "Please look for the installer window or check your desktop."
else
    echo "Launching Pop OS installer..."
    io.elementary.installer &
    echo "Installer launched. Please follow the on-screen instructions."
fi

echo ""
echo "IMPORTANT: When installing, make sure to:"
echo "1. Choose 'Custom (Advanced)' installation"
echo "2. Select /dev/sda as the installation drive"
echo "3. Format the drive (this will erase all data)"
echo "4. Install the bootloader to /dev/sda"
echo ""
echo "After installation completes, remove the USB drive and restart your computer."
