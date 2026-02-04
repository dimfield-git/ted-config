# TedOS-VM-Alpha-3 Installation Guide

**Fresh start with corrected configuration**

This guide uses the **fixed configuration** already pushed to GitHub that includes:
- Swedish keyboard layout
- Passwordless authentication (empty passwords for ted and root)
- Open SSH access
- Bash shell (simpler than zsh for base install)
- Corrected package names

---

## Prerequisites

- VirtualBox installed on host
- Internet connection for downloading NixOS ISO
- The TedOS repository cloned on your host: `~/ted-config`

---

## Part 1: Create VM in VirtualBox

### 1.1 Download NixOS ISO

Download the minimal ISO from: https://nixos.org/download.html#nixos-iso

Look for: **NixOS 24.11 Minimal ISO (x86_64-linux)**

### 1.2 Create New VM

**VirtualBox Settings:**
```
Name: TedOS-VM-Alpha-3
Type: Linux
Version: Other Linux (64-bit)

Memory: 2048 MB (or more)
Processors: 2 CPUs

Create virtual hard disk now
  - VDI (VirtualBox Disk Image)
  - Dynamically allocated
  - 20 GB (minimum)

✓ Enable EFI (CRITICAL!)
  Settings → System → Motherboard → Enable EFI
```

### 1.3 Configure Network

**Option A: NAT with Port Forward** (Easier for SSH)
```
Settings → Network → Adapter 1
  Attached to: NAT
  Advanced → Port Forwarding
    Name: SSH
    Protocol: TCP
    Host Port: 2222
    Guest Port: 22
```

**Option B: Bridged Adapter** (VM gets its own IP)
```
Settings → Network → Adapter 1
  Attached to: Bridged Adapter
```

### 1.4 Mount ISO and Boot

```
Settings → Storage
  Controller: IDE → Add Optical Drive
  Choose the NixOS minimal ISO
```

**Start the VM**

---

## Part 2: NixOS Installer Setup

### 2.1 Set Swedish Keyboard

Once booted into the installer console:

```bash
sudo loadkeys sv-latin1
```

### 2.2 Enable SSH and Set Password

```bash
sudo systemctl start sshd
sudo passwd nixos
```
*(Set a temporary password like: `nixos`)*

### 2.3 Find VM IP Address

```bash
ip -4 addr show | grep -Eo 'inet ([0-9]+\.){3}[0-9]+' | awk '{print $2}'
```

Note the IP address (e.g., `10.0.2.15` for NAT or `192.168.x.x` for Bridged)

### 2.4 SSH from Host

**If using NAT with port forward:**
```bash
ssh -p 2222 nixos@127.0.0.1
```

**If using Bridged:**
```bash
ssh nixos@<VM_IP>
```

---

## Part 3: Partition and Mount

### 3.1 Identify Disk

```bash
lsblk
```

Expect: `/dev/sda` in VirtualBox

### 3.2 Partition

```bash
# Create GPT partition table
sudo parted -s /dev/sda mklabel gpt

# Create EFI partition (512 MB)
sudo parted -s /dev/sda mkpart ESP fat32 1MiB 513MiB
sudo parted -s /dev/sda set 1 esp on

# Create root partition (rest of disk)
sudo parted -s /dev/sda mkpart primary ext4 513MiB 100%
```

### 3.3 Format

```bash
sudo mkfs.fat -F32 -n EFI /dev/sda1
sudo mkfs.ext4 -L nixos /dev/sda2
```

### 3.4 Mount

```bash
sudo mount /dev/sda2 /mnt
sudo mkdir -p /mnt/boot
sudo mount /dev/sda1 /mnt/boot
```

### 3.5 Verify (Recommended)

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

### 4.2 Copy TedOS Files from Host

**On your host machine** (where `~/ted-config` exists):

```bash
# If using NAT with port forward:
scp -P 2222 -r ~/ted-config nixos@127.0.0.1:/tmp/

# If using Bridged:
scp -r ~/ted-config nixos@<VM_IP>:/tmp/
```

### 4.3 Replace System Config

**Back in VM SSH session:**

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

### 5.3 Remove ISO

While VM is rebooting:
1. VirtualBox → TedOS-VM-Alpha-3 → Settings → Storage
2. Remove the ISO from the optical drive
3. Ensure disk boots first

---

## Part 6: First Boot Verification

### 6.1 Console Access

The VM should:
- ✓ Auto-login as `ted` on tty1
- ✓ Attempt to start Sway

**Known Issue:** Sway may show black screen in VirtualBox (graphics limitation)

### 6.2 Switch to Terminal

If you see a black screen:

**Press:** `Ctrl+Alt+F2` to switch to tty2

**Login:** 
```
username: ted
password: (just press Enter)
```

### 6.3 Verify Installation

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

### 6.4 SSH from Host

**If using NAT:**
```bash
ssh -p 2222 ted@127.0.0.1
```

**If using Bridged:** (find IP with `ip a`)
```bash
ssh ted@<VM_IP>
```

Password: (empty - just press Enter)

---

## Part 7: Next Steps

### If Sway Works (Graphical)

You should see:
- Workspace 1: Yazi file manager
- Workspace 2: tmux with HUD

**Keybindings:**
- `Super+Enter` → new terminal
- `Super+1/2` → switch workspaces
- `Super+Shift+Q` → kill window
- `Super+Q` → exit Sway

### If Sway Shows Black Screen (VirtualBox Issue)

**Workaround:** Use SSH + tmux for terminal workflow

```bash
# SSH into VM
ssh -p 2222 ted@127.0.0.1

# Start tmux session
tmux new -A -s main

# Your HUD should appear at top
# Run yazi
yazi
```

### Disable Auto-Sway Launch (Optional)

If you want to stay in pure terminal mode without Sway attempts:

```bash
sudo nano /etc/nixos/configuration.nix
```

Comment out or remove the auto-launch section:
```nix
# programs.bash.loginShellInit = ''
#   if [ -z "$WAYLAND_DISPLAY" ] && [ "$(tty)" = "/dev/tty1" ]; then
#     exec sway
#   fi
# '';
```

Then rebuild:
```bash
sudo nixos-rebuild switch
```

---

## Troubleshooting

### Can't SSH In

```bash
# Check SSH is running
systemctl status sshd

# Check firewall
sudo nf list

# Verify network
ip a
ping 8.8.8.8
```

### tmux HUD Not Showing

```bash
# Verify scripts exist and are executable
ls -l ~/bin/tedos-*
chmod +x ~/bin/tedos-hud ~/bin/tedos-procs

# Test scripts manually
~/bin/tedos-hud
~/bin/tedos-procs

# Reload tmux config
tmux source ~/.config/tmux/tmux.conf
```

### Package Errors During Install

If you see errors about packages:
1. Check `/mnt/etc/nixos/configuration.nix` matches the fixed version from GitHub
2. Look for typos like `poppler_utils` vs `poppler-utils`

---

## Success Criteria

TedOS-VM-Alpha-3 is ready when:

- ✓ System boots to auto-login
- ✓ SSH works with empty passwords
- ✓ All core packages installed (tmux, yazi, nvim, kitty)
- ✓ Configuration files in place
- ✓ HUD scripts executable
- ✓ Swedish keyboard works
- ✓ Can work in pure terminal mode (even if Sway has issues)

---

## What's Fixed from Alpha-2

✓ Swedish keyboard in config  
✓ Empty passwords (no auth barriers)  
✓ SSH fully open  
✓ Bash instead of zsh  
✓ Package name corrections  
✓ Passwordless sudo  
✓ Root login enabled  

All changes already pushed to GitHub - no manual edits needed!
