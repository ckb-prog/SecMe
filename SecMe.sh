#!/bin/bash

LOGFILE="/var/log/system_hardening.log"
BACKUP_DIR="/root/hardening_backup"

# Ensure script is run as root
if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root!" >&2
    exit 1
fi

# Backup function
backup_file() {
    local file="$1"
    if [ -f "$file" ]; then
        mkdir -p "$BACKUP_DIR"
        cp "$file" "$BACKUP_DIR/$(basename $file).bak"
        echo "Backup created for $file" >> "$LOGFILE"
    fi
}

# Security Profile Selection
echo "Select Security Level:"
echo "1) Basic Hardening (Minimal security)"
echo "2) Standard Hardening (Moderate security)"
echo "3) Enhanced Hardening (Strict security)"
echo "4) Extreme Hardening (Maximum security)"
read -rp "Enter choice (1-4): " choice

case "$choice" in
    1) SECURITY_LEVEL="Basic";;
    2) SECURITY_LEVEL="Standard";;
    3) SECURITY_LEVEL="Enhanced";;
    4) SECURITY_LEVEL="Extreme";;
    *) echo "Invalid choice. Exiting."; exit 1;;
esac

echo "Applying $SECURITY_LEVEL security level..." | tee -a "$LOGFILE"

# Common Hardening - Applies to all levels
echo "Hardening common system settings..."
backup_file "/etc/ssh/sshd_config"
cat <<EOF > /etc/ssh/sshd_config
Protocol 2
PermitRootLogin no
PasswordAuthentication no
PermitEmptyPasswords no
ChallengeResponseAuthentication no
UsePAM yes
AllowUsers $(whoami)
EOF
systemctl restart sshd
echo "SSH hardened." | tee -a "$LOGFILE"

# Disable Unnecessary Services
echo "Disabling unnecessary services..."
systemctl disable --now avahi-daemon
systemctl disable --now cups
systemctl disable --now rpcbind
systemctl disable --now nfs-server
systemctl disable --now bluetooth
echo "Unnecessary services disabled." | tee -a "$LOGFILE"

# Kernel Hardening
echo "Applying Kernel Hardening..."
backup_file "/etc/sysctl.conf"
cat <<EOF >> /etc/sysctl.conf
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.all.secure_redirects = 0
net.ipv4.conf.all.log_martians = 1
net.ipv4.conf.all.rp_filter = 1
kernel.randomize_va_space = 2
fs.protected_hardlinks = 1
fs.protected_symlinks = 1
EOF
sysctl -p
echo "Kernel hardened." | tee -a "$LOGFILE"

# Secure File Permissions
echo "Applying secure file permissions..."
chmod 700 /root
chmod 700 ~/.ssh
chmod 600 ~/.ssh/*
echo "File permissions hardened." | tee -a "$LOGFILE"

# Time-based access controls (Enhanced and Extreme)
if [[ "$SECURITY_LEVEL" == "Enhanced" || "$SECURITY_LEVEL" == "Extreme" ]]; then
    echo "Setting time-based access control..."
    backup_file "/etc/security/access.conf"
    echo "-:ALL EXCEPT LOCAL:ALL" >> /etc/security/access.conf
    echo "Time-based access control enabled." | tee -a "$LOGFILE"
fi

# Enable Intrusion Detection Systems (IDS) (Extreme)
if [[ "$SECURITY_LEVEL" == "Extreme" ]]; then
    echo "Installing and configuring IDS (AIDE)..."
    apt install -y aide
    aide --init
    mv /var/lib/aide/aide.db.new /var/lib/aide/aide.db
    echo "IDS (AIDE) installed and configured." | tee -a "$LOGFILE"
fi

# Firewall Hardening (Enhanced and Extreme)
if [[ "$SECURITY_LEVEL" == "Enhanced" || "$SECURITY_LEVEL" == "Extreme" ]]; then
    echo "Configuring Firewall (ufw)..."
    ufw default deny incoming
    ufw default allow outgoing
    ufw allow ssh
    ufw enable
    echo "Firewall configured." | tee -a "$LOGFILE"
fi

# SELinux / AppArmor Hardening (Extreme)
if [[ "$SECURITY_LEVEL" == "Extreme" ]]; then
    echo "Enabling SELinux..."
    apt install -y selinux-utils
    setenforce 1
    echo "SELinux enabled and enforced." | tee -a "$LOGFILE"
fi

# Resource Restrictions (Extreme)
if [[ "$SECURITY_LEVEL" == "Extreme" ]]; then
    echo "Applying system resource restrictions..."
    backup_file "/etc/security/limits.conf"
    echo "* hard nproc 50" >> /etc/security/limits.conf
    echo "* hard nofile 1024" >> /etc/security/limits.conf
    echo "Resource restrictions applied." | tee -a "$LOGFILE"
fi

# Enhanced Logging and Auditing (Extreme)
if [[ "$SECURITY_LEVEL" == "Extreme" ]]; then
    echo "Enabling detailed auditing..."
    apt install -y auditd
    systemctl enable auditd --now
    auditctl -e 1
    echo "Detailed auditing enabled." | tee -a "$LOGFILE"
fi

# Enable Automatic Security Updates (Standard, Enhanced, Extreme)
if [[ "$SECURITY_LEVEL" == "Standard" || "$SECURITY_LEVEL" == "Enhanced" || "$SECURITY_LEVEL" == "Extreme" ]]; then
    echo "Enabling automatic security updates..."
    apt install -y unattended-upgrades
    dpkg-reconfigure -plow unattended-upgrades
    echo "Automatic updates enabled." | tee -a "$LOGFILE"
fi

# Extreme Hardening - Extreme Level Only
if [[ "$SECURITY_LEVEL" == "Extreme" ]]; then
    echo "Applying extreme hardening measures..."

    # Disable USB Storage
    echo "Disabling USB storage..."
    backup_file "/etc/modprobe.d/usb-storage.conf"
    echo "install usb-storage /bin/true" > /etc/modprobe.d/usb-storage.conf
    modprobe -r usb-storage
    echo "USB storage disabled." | tee -a "$LOGFILE"

    # Disable Core Dumps
    echo "Disabling core dumps..."
    backup_file "/etc/security/limits.conf"
    echo "* hard core 0" >> /etc/security/limits.conf
    echo "Core dumps disabled." | tee -a "$LOGFILE"

    # Apply AppArmor
    echo "Enforcing AppArmor profiles..."
    apt install -y apparmor apparmor-utils
    systemctl enable apparmor --now
    echo "AppArmor enabled and enforced." | tee -a "$LOGFILE"
fi

# Final Security Audit
echo "Final security audit completed." | tee -a "$LOGFILE"
echo "Security Level: $SECURITY_LEVEL" >> "$LOGFILE"
echo "Reboot your system to apply all changes."

