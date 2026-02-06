# TedOS Laptop Installation Guide

**Target: Sister's HP 15-db0xxx (Ryzen 3 2200u, 256GB NVMe)**

---

## Part 1: Setup SSH Access from Ubuntu PC

1. Boot NixOS installer on laptop
2. Connect to network (ethernet or wifi - use `nmtui` for Wi-Fi)
3. Set password: `passwd`
4. Get IP: `ip a`
5. SSH from Ubuntu: `ssh nixos@<laptop-ip>`

---

## Part 2: NixOS Installer Setup

### 2.1 Set Swedish Keyboard

Once booted into the installer console:

```bash
sudo loadkeys sv-latin1
```

### 2.2 Enable SSH and Get IP

```bash
passwd
```
*(Set a password like: `nixos`)*

```bash
ip a
```

Note the IP address (e.g., `192.168.x.x`)

### 2.3 SSH from Ubuntu PC

```bash
ssh nixos@<LAPTOP_IP>
```

---

## Part 3: Partition and Mount

### 3.1 Identify Disk

```bash
lsblk
```

Expect: `/dev/nvme0n1` (256GB)

### 3.2 Partition

```bash
# Create GPT partition table
sudo parted -s /dev/nvme0n1 mklabel gpt

# Create EFI partition (512 MB)
sudo parted -s /dev/nvme0n1 mkpart ESP fat32 1MiB 513MiB
sudo parted -s /dev/nvme0n1 set 1 esp on

# Create root partition (rest of disk)
sudo parted -s /dev/nvme0n1 mkpart primary ext4 513MiB 100%
```

### 3.3 Format

```bash
sudo mkfs.fat -F32 -n EFI /dev/nvme0n1p1
sudo mkfs.ext4 -L nixos /dev/nvme0n1p2
```

### 3.4 Mount

```bash
sudo mount /dev/nvme0n1p2 /mnt
sudo mkdir -p /mnt/boot
sudo mount /dev/nvme0n1p1 /mnt/boot
```

### 3.5 Verify

```bash
# Check partitions
lsblk -f

# Verify mounts
mount | grep /mnt

# Test writability
sudo touch /mnt/test && ls -l /mnt/test
```

---

## Part 4: Deploy TedOS Configuration

### 4.1 Generate Hardware Config

```bash
sudo nixos-generate-config --root /mnt
```

This creates:
- `/mnt/etc/nixos/hardware-configuration.nix` (keep this)
- `/mnt/etc/nixos/configuration.nix` (we'll replace this)

### 4.2 Copy TedOS Files from Ubuntu PC

**On your Ubuntu PC** (where `~/ted-config` exists):

```bash
scp -r ~/ted-config nixos@<LAPTOP_IP>:/tmp/
```

### 4.3 Replace System Config

**Back in laptop SSH session:**

```bash
# Replace the generated configuration.nix with TedOS version
sudo cp /tmp/ted-config/nixos/configuration.nix /mnt/etc/nixos/configuration.nix

# Verify it copied
sudo cat /mnt/etc/nixos/configuration.nix | head -20
```

### 4.4 Deploy User Configs

```bash
# Create user config directories
sudo mkdir -p /mnt/home/ted/.config/{sway,kitty,tmux,yazi}
sudo mkdir -p /mnt/home/ted/bin

# Copy application configs
sudo cp /tmp/ted-config/sway/config /mnt/home/ted/.config/sway/config
sudo cp /tmp/ted-config/kitty/kitty.conf /mnt/home/ted/.config/kitty/kitty.conf
sudo cp /tmp/ted-config/tmux/tmux.conf /mnt/home/ted/.config/tmux/tmux.conf
sudo cp /tmp/ted-config/yazi/yazi.toml /mnt/home/ted/.config/yazi/yazi.toml
sudo cp /tmp/ted-config/yazi/keymap.toml /mnt/home/ted/.config/yazi/keymap.toml
sudo cp /tmp/ted-config/.zshrc /mnt/home/ted/.zshrc

# Copy HUD scripts
sudo cp /tmp/ted-config/bin/tedos-hud /mnt/home/ted/bin/tedos-hud
sudo cp /tmp/ted-config/bin/tedos-procs /mnt/home/ted/bin/tedos-procs
sudo chmod +x /mnt/home/ted/bin/tedos-hud
sudo chmod +x /mnt/home/ted/bin/tedos-procs

# Fix ownership (IMPORTANT!)
sudo chown -R 1000:100 /mnt/home/ted
```

---

## Part 5: Install and Boot

### 5.1 Install NixOS

```bash
sudo nixos-install
```

**When prompted for root password:** Just press Enter (empty password)

### 5.2 Unmount and Reboot

```bash
# Unmount filesystems
sudo umount /mnt/boot
sudo umount /mnt

# Reboot
reboot
```

### 5.3 Remove USB Stick

Remove the NixOS installer USB stick when the laptop starts rebooting.

---

## Part 6: First Boot Verification

### 6.1 Initial Boot

The laptop should:
- ✓ Auto-login as `ted` on tty1
- ✓ Attempt to start Sway

### 6.2 Verify Installation

```bash
# Check all core programs are installed
which sway kitty tmux yazi nvim

# Check configs exist
ls -la ~/.config/sway/config
ls -la ~/.config/tmux/tmux.conf
ls -la ~/bin/tedos-hud

# Test HUD scripts
~/bin/tedos-hud
~/bin/tedos-procs

# Check SSH is running
systemctl status sshd
```

### 6.3 SSH from Ubuntu PC (Optional)

Find laptop IP:
```bash
ip a
```

From Ubuntu PC:
```bash
ssh ted@<LAPTOP_IP>
```

Password: (empty - just press Enter)

---

## Success Criteria

TedOS laptop is ready when:

- ✓ System boots to auto-login
- ✓ SSH works with empty passwords
- ✓ All core packages installed (tmux, yazi, nvim, kitty)
- ✓ Configuration files in place
- ✓ HUD scripts executable
- ✓ Swedish keyboard works
- ✓ Sway launches (or can work in terminal mode)

