# SecMe
A security hardening script for Linux
-------------------------------------
**SecMe README Manual**
## Introduction
SecMe (Secure Me) is an advanced security hardening script designed to automate the process of securing Linux systems by applying national security standards and best practices. This script enhances your system's security by applying configurable hardening measures based on custom security levels, from basic hardening to extreme hardening, ensuring that your system is protected against various security threats.

## Features
Customizable Security Levels: Choose from four security levels—Basic, Standard, Enhanced, and Extreme—to apply the appropriate hardening measures based on your security requirements.
Comprehensive System Hardening: Applies a wide range of security measures, including:
- SSH Hardening
- Service Disabling
- Kernel Hardening
- Firewall Configuration
- Intrusion Detection (AIDE)
- SELinux & AppArmor
- USB and Core Dump Restrictions
- Time-based Access Control
- System Resource Restrictions
- Automatic Security Updates
- Enhanced Logging
-----------------------------------------
Backup and Logging: All changes made by SecMe are logged for future reference, and backups of critical files are made before changes are applied.
## Installation
Download the Script:
Download the secure_harden.sh script to your machine. You can either clone it from a repository or download it directly.

Set Permissions:
Before running the script, ensure that it has execute permissions:

```bash
chmod +x secure_harden.sh
```
**Run as Root:**
For the script to apply system changes, it must be run with root privileges:

```bash
sudo ./secure_harden.sh
```
## Usage
**Step 1**: Select Security Level
When you run SecMe, you will be prompted to choose a security level. Each security level will apply a different set of hardening measures:

- Basic Hardening
Minimal security measures, suitable for systems with a moderate risk profile.

- Standard Hardening
Adds firewall configuration and automatic updates. Suitable for most systems that require reasonable security.

- Enhanced Hardening
Applies intrusion detection (AIDE), time-based access control, and more stringent network controls. Best for systems with sensitive data.

- Extreme Hardening
The most stringent security level, enabling SELinux, AppArmor, USB storage disabling, core dump disabling, and extensive logging. Ideal for systems with high-security needs.

**Step 2**: Apply Security Measures
Once you select a security level, the script will apply the corresponding hardening measures. You will see the progress of these changes in the terminal as they are applied.

**Step 3**: Review the Log
All actions performed by SecMe are logged in the /var/log/system_hardening.log file. This log file can be used for auditing purposes to track which changes were made to the system.

**Step 4**: Reboot the System
After the hardening process is complete, the script will suggest rebooting your system to ensure all changes take effect.

## Detailed Overview of Security Levels
Security Level	Features Included
Basic	Basic SSH hardening, disabling unnecessary services, kernel hardening, secure file permissions
Standard	Basic features plus firewall configuration, automatic security updates
Enhanced	Standard features plus intrusion detection (AIDE), time-based access control
Extreme	Enhanced features plus SELinux, AppArmor, USB storage and core dump restrictions, resource restrictions, detailed logging (auditd)
Backup and Recovery
Before making any changes to your system, SecMe backs up critical files to the /root/hardening_backup/ directory. These backups can be restored manually if needed.

File Backups:
/etc/ssh/sshd_config
/etc/sysctl.conf
/etc/security/limits.conf
/etc/modprobe.d/usb-storage.conf
/etc/security/access.conf
These files are backed up to the backup directory with a .bak extension.

Log File:
All actions performed by SecMe are logged in /var/log/system_hardening.log. This file contains:

Date and time of the changes.
Details of the changes applied.
Any errors or issues encountered during the process.
Uninstall or Revert Changes
Although SecMe doesn't provide a built-in rollback mechanism, you can manually revert changes by restoring the backed-up configuration files from /root/hardening_backup/.

## To uninstall a particular hardening measure:

Restore the original configuration file from the backup directory.
If applicable, undo changes in the system using the following commands (e.g., disabling SELinux or reversing firewall settings).
Troubleshooting
Issue: The script fails to apply changes because of permissions.

Solution: Make sure you are running the script with sudo to ensure it has root privileges.
Issue: Some services do not work after hardening.

Solution: Check the log file /var/log/system_hardening.log for errors. It may provide clues about what was changed and what needs to be adjusted.
Issue: Unable to access the system after applying time-based access control.

Solution: Adjust the settings in /etc/security/access.conf or temporarily disable the feature by commenting out the access control entries.
Contributing
If you would like to contribute to SecMe, feel free to fork the repository and submit a pull request. Contributions are always welcome!

## License
- GPL-3 License
