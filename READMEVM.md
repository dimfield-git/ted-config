##  A1. Create and boot a VM from the NixOS ISO

Ensure EFI-mode is checked
Type: Linux, Other Linux 64-bit

**IMPORTANT**

**A1.1** Select VM network mode (NAT with port-forward host 2222 → guest 22 or Bridged)

**A1.2** Ensure the VM has network connectivity so SSH access to the installer is possible




##  A2. Enter NixOS installer environment, partition disks, and mount filesystems


**A2.1** Run command:

```bash
sudo loadkeys sv-latin1

```
**A2.2** SSH into the NixOS installer from the host terminal
On the VM Console run:
```bash
sudo systemctl start sshd
sudo passwd nixos
ip -4 addr show | grep -Eo 'inet ([0-9]+\.){3}[0-9]+' | awk '{print $2}'
```
On the host terminal run (replace VM_IP with the IP you got):
```bash
ssh nixos@VM_IP
```
If you are using VirtualBox NAT with port-forward (host 2222 → guest 22), use:
```bash
ssh -p 2222 nixos@127.0.0.1
```

## A3. Partition disks and mount filesystems

```bash
# Identify disk (expect /dev/sda in VirtualBox)
lsblk

# Partition as GPT with EFI + root
sudo parted -s /dev/sda mklabel gpt
sudo parted -s /dev/sda mkpart ESP fat32 1MiB 513MiB
sudo parted -s /dev/sda set 1 esp on
sudo parted -s /dev/sda mkpart primary ext4 513MiB 100%

# Format
sudo mkfs.fat -F32 -n EFI /dev/sda1
sudo mkfs.ext4 -L nixos /dev/sda2

# Mount for install
sudo mount /dev/sda2 /mnt
sudo mkdir -p /mnt/boot
sudo mount /dev/sda1 /mnt/boot
```

If your VM disk shows up as /dev/vda (rare in VirtualBox) or similar, replace /dev/sda accordingly.


**Verification (Recommended)**

**V1.** Verify partitions exist and look right
```bash
lsblk -f
```
You want to see:

/dev/sda1 = vfat (EFI)

/dev/sda2 = ext4 (root)

**V2.** Verify the mounts are correct
```bash
mount | grep -E ' /mnt($| )| /mnt/boot($| )'
```
You want:

/dev/sda2 mounted on /mnt

/dev/sda1 mounted on /mnt/boot

**V3.** Sanity-check the EFI partition is FAT32
```bash
sudo blkid /dev/sda1
```
You want:

You want TYPE="vfat"

**V4.** Confirm /mnt is writable (format worked)
```bash
sudo touch /mnt/OK && ls -l /mnt/OK
```
You want: 

-rw-r--r-- 1 root root 0 OK


---

##  B1. Generate NixOS configuration and replace it with TedOS configuration

**B1.1** Generate necessary configuration files (two files) under /mnt/etc/nixos/:

```bash
sudo nixos-generate-config --root /mnt
ls -l /mnt/etc/nixos/
```

**File 1:** ```hardware-configuration.nix```

*auto-detected hardware + mount config for this VM (disk UUIDs, filesystem mounts, drivers)*

**File 2:** ```configuration.nix``` **(default stub)**

*a starting system config template we use it mainly as a placeholder and then replace it with your TedOS configuration.nix*


**B1.2** Copy files for TedOS in folder ted-config from host into VM via scp over SSH

On your host machine (where ted-config repository lives):
```bash
# Copy the entire ted-config directory to the VM
scp -r ~/path/to/ted-config nixos@VM_IP:/tmp/

# Or if using VirtualBox NAT with port forward:
scp -P 2222 -r ~/path/to/ted-config nixos@127.0.0.1:/tmp/
```

Then on the VM (via SSH session):
```bash
# Verify the files arrived
ls -l /tmp/ted-config/

# Replace the generated configuration.nix with your TedOS one
sudo cp /tmp/ted-config/nixos/configuration.nix /mnt/etc/nixos/configuration.nix

# Also copy your other config files to the mounted system
# (sway, kitty, tmux, etc. - but these go to user home, so maybe do this after install?)
```

Commands for copying user config files:
```bash
# Still on the VM via SSH, after copying configuration.nix

# Create config directories in the new system's user home
sudo mkdir -p /mnt/home/ted/.config/{sway,kitty,tmux,yazi}
sudo mkdir -p /mnt/home/ted/bin

# Copy user configs
sudo cp /tmp/ted-config/sway/config /mnt/home/ted/.config/sway/config
sudo cp /tmp/ted-config/kitty/kitty.conf /mnt/home/ted/.config/kitty/kitty.conf
sudo cp /tmp/ted-config/tmux/tmux.conf /mnt/home/ted/.config/tmux/tmux.conf
sudo cp /tmp/ted-config/yazi/yazi.toml /mnt/home/ted/.config/yazi/yazi.toml
sudo cp /tmp/ted-config/yazi/keymap.toml /mnt/home/ted/.config/yazi/keymap.toml
sudo cp /tmp/ted-config/.zshrc /mnt/home/ted/.zshrc

# Copy HUD scripts
sudo cp /tmp/ted-config/bin/tedos-hud /mnt/home/ted/bin/tedos-hud
sudo cp /tmp/ted-config/bin/tedos-procs /mnt/home/ted/bin/tedos-procs
sudo chmod +x /mnt/home/ted/bin/tedos-hud /mnt/home/ted/bin/tedos-procs

# Fix ownership (important!)
sudo chown -R 1000:100 /mnt/home/ted
```


##  B2. Install NixOS and reboot the VM

---
##  C1. Verify boot into TedOS cockpit
