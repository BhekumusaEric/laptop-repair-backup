# PC Repair Toolkit

A comprehensive, cross-platform solution for diagnosing and fixing computer issues.

## Vision

The PC Repair Toolkit aims to be a one-stop solution for diagnosing and repairing various computer issues across multiple operating systems. Whether you're dealing with boot problems, hardware failures, malware infections, network issues, or performance bottlenecks, this toolkit provides both automated and guided solutions to get your system back up and running.

## Quick Start

1. **Reboot your computer** with the Pop OS USB drive inserted
2. When the live environment loads, navigate to this directory
3. Run the installer script:
   ```
   ./launch_installer.sh
   ```
4. Follow the on-screen instructions to reinstall Pop OS

## Features (Planned)

- **Comprehensive Diagnostics**
  - Boot system analysis
  - Hardware diagnostics
  - Network troubleshooting
  - Operating system integrity checks
  - Performance analysis
  - Security scanning

- **Automated Repairs**
  - Boot repair (MBR/GPT, bootloader)
  - Hardware troubleshooting
  - Network configuration fixes
  - OS repair and recovery
  - Performance optimization
  - Security cleanup and hardening
  - Data recovery

- **System Restoration**
  - Complete system reset and reinstallation
  - Bootable USB creation for various operating systems
  - Automated OS installation with unattended setup
  - Cross-platform support for Windows, macOS, and Linux
  - Mac-specific tools for complete system wipe and recovery
  - T2/Apple Silicon security chip handling

- **Advanced Recovery**
  - System access recovery for locked devices
  - Password reset for Windows, Linux, and Mac
  - BIOS/UEFI password bypass
  - Secure Boot configuration
  - Disk encryption recovery
  - Extreme data recovery from damaged media
  - RAID array reconstruction

- **Multiple User Interfaces**
  - Command-line interface (CLI)
  - Terminal-based UI (TUI)
  - Web-based interface
  - Graphical UI (GUI)

- **Cross-Platform Support**
  - Linux
  - Windows
  - macOS

## Current Status

This project is currently in the early development phase. We started with boot repair scripts for Linux systems and are expanding to a comprehensive toolkit.

### Available Now
- Boot diagnostics and repair for Linux systems
- System reset and reinstallation for Windows, Linux, and Mac
- Bootable USB creation for all major operating systems
- Mac-specific tools for complete system wipe and recovery
- Advanced system access recovery for locked devices
- Extreme data recovery for damaged systems
- Automated OS installation
- Command-line interface
- System information gathering

### Coming Soon
- Hardware diagnostics
- Malware removal
- Performance optimization
- Data recovery
- Windows and macOS support
- Web and graphical interfaces

## Getting Started

### Prerequisites

- Linux-based operating system (currently supported)
- Bash shell
- Root/sudo access

### Installation

1. Clone the repository:
   ```
   git clone https://github.com/BhekumusaEric/pc-repair-toolkit.git
   ```

2. Navigate to the project directory:
   ```
   cd pc-repair-toolkit
   ```

3. Run the setup script:
   ```
   sudo ./setup.sh
   ```

4. Launch the toolkit:
   ```
   sudo ./pc-repair.sh
   ```

### Boot Repair Usage

For boot repair specifically:

1. Boot from a live USB/CD
2. Clone or download this repository
3. Run the boot repair script:
   ```
   sudo ./repair/boot/fix_boot.sh
   ```
   or for complete reinstallation:
   ```
   sudo ./repair/boot/complete_repair.sh
   ```

## Project Structure

See [project_structure.md](project_structure.md) for details on the organization of the toolkit.

## Implementation Plan

See [implementation_plan.md](implementation_plan.md) for the detailed roadmap of planned features.

## Contributing

We welcome contributions from the community! Whether you're fixing bugs, adding new features, or improving documentation, your help is appreciated.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- This project evolved from a simple boot repair script to fix PXE boot issues
- Inspired by various Linux rescue tools and Windows repair utilities
- Built with the goal of making computer repair accessible to everyone
