# TedOS — Terminal Cockpit NixOS
<img width="1536" height="1024" alt="image" src="https://github.com/user-attachments/assets/d0f68445-0ac0-4406-9248-5d3dcd7f1667" />

TedOS is a terminal-centric NixOS configuration built as a **“non-GUI"-GUI**:  
a minimal graphical substrate (sway + kitty) hosting a powerful text-based cockpit built around **tmux**, **Yazi**, and **Neovim**.

There is **no desktop environment**.  
All work happens in terminal / TUI applications.

---
<img width="41.6" height="40.5" alt="TedOSIcon2" src="https://github.com/user-attachments/assets/f03661c2-a371-4307-a85a-f36e12da18a5" /> && ## Philosophy

**Know what you get - get what you know!**
- GUI exists **only** to render terminal windows
- All interaction is **TUI / CLI**
- Baseline operations using tmux and yazi file manager
- Reproducible, declarative system (NixOS)
- Build your own system module by modyle, packet by packet, byte by byte
- Incremental, inspectable evolution

---

## Core Stack 

- **NixOS (minimal ISO)**
- **sway** — tiling Wayland compositor (no DE)
- **kitty** — terminal emulator
- **tmux** — session manager + HUD
- **Yazi** — terminal file manager (Norton Commander style)
- **Neovim** — primary editor
- **JetBrainsMono Nerd Font** — icons & powerline glyphs

### Cockpit Features

- Auto-launch into:
  - Yazi (workspace 1)
  - tmux session (workspace 2)
- tmux HUD (top bar) showing:
  - VPN status (green ON / dim red OFF)
  - SSH connection count
  - CPU usage
  - Disk free
  - Mode (tmux session name)
  - Running program watchlist
- Terminator-style splits (sway + tmux)
- Fully terminal-based workflow

---

## Repository Layout

```text
ted-config/
├── nixos/
│   └── configuration.nix
├── sway/
│   └── config
├── kitty/
│   └── kitty.conf
├── tmux/
│   └── tmux.conf
├── yazi/
│   ├── yazi.toml
│   └── keymap.toml
├── bin/
│   ├── tedos-hud
│   └── tedos-procs
└── .zshrc
```

<img width="41.4" height="40.0" alt="TedOSIcon1" src="https://github.com/user-attachments/assets/0db8a7ab-7a5a-4f6a-a2b6-9b1e423781e8" /> # — Installation Instructions.md

This document is written entirely in Markdown.  
All commands are presented in fenced code blocks.

---

## Overview

This install uses a two-stage workflow:

1. Install a clean NixOS base system to the target disk.
2. Copy and apply the TedOS configuration after installation.

The TedOS repository/config is not required during the NixOS installer.

---

## Assumptions

- You will install TedOS onto a dedicated target disk (example: `/dev/nvme1n1`).
- You want a terminal-centric cockpit using sway + kitty to host TUI apps (Yazi, tmux, etc.).
- A user account `ted` will exist on TedOS.
- SSH access between primary OS and TedOS will be used to copy files after the base install. (Alternative route: Install NixOS with Network then fetch config from github, or use USB-stick)

---

## Stage 1 — Install Base NixOS

### 1. Download NixOS Minimal ISO

Download the current NixOS Minimal ISO (x86_64) from the official site.

---

### 2. Flash the ISO to a USB stick (Ubuntu Studio)

Identify the USB device (example output shows it as `/dev/sda`; yours may differ).

```bash
lsblk -o NAME,SIZE,MODEL,TYPE,MOUNTPOINTS
```
Unmount any mounted partitions on the USB (if any).
```bash
sudo umount /dev/sdX* 2>/dev/null || true
```
Flash the ISO to the USB device (replace sdX with the USB device, e.g. sda).
```bash
cd ~/Downloads
sudo dd if=nixos-minimal-*.iso of=/dev/sdX bs=4M status=progress conv=fsync
sync
sudo eject /dev/sdX
```
3. Boot the installer USB (UEFI)

Reboot and select the USB in the boot menu in UEFI mode.

After booting into the installer shell, confirm disks.
```bash
lsblk -o NAME,SIZE,MODEL,TYPE
```
4. Connect to the network (if needed)

If wired, networking may already work.

For Wi-Fi, use NetworkManager (nmcli).
```bash
sudo -i
nmcli dev wifi list
nmcli dev wifi connect "SSID" password "PASSWORD"
```
5. Partition and encrypt the target disk

Partitioning choices vary. A common recommended layout:

EFI System Partition (FAT32, ~1 GiB)

Encrypted root partition (LUKS, rest of disk)

After partitioning, open the LUKS container, format, and mount to /mnt.

You will execute the exact partition/encryption commands appropriate to your disk and preference at install time.

6. Generate initial NixOS config
```bash
nixos-generate-config --root /mnt
```
7. Ensure baseline requirements are present in installed system

Before installing, ensure the configuration used for the first boot includes:

A normal user ted

Networking (NetworkManager)

SSH enabled

If you are using the generated configuration for the base install, edit:
```bash
nano /mnt/etc/nixos/configuration.nix
```
Add/ensure:
```bash
networking.networkmanager.enable = true;
services.openssh.enable = true;

users.users.ted = {
  isNormalUser = true;
  extraGroups = [ "wheel" "networkmanager" ];
};
```
8. Install NixOS
```bash
nixos-install
```
Reboot into the installed system.
```bash
reboot
```
Remove the USB when it begins rebooting.

Stage 2 — Copy TedOS Config From Ubuntu Studio
1. Find TedOS IP address

On TedOS, run:
```bash
ip a
```
Note the IP address of the active interface.

2. Copy the config directory from Ubuntu Studio to TedOS

On Ubuntu Studio:
```bash
scp -r ~/tedos-config ted@TEDOS_IP:~
```
Replace TEDOS_IP with the actual IP address.

Stage 3 — Apply TedOS Configuration (on TedOS)
1. Apply system configuration
```bash
sudo cp ~/tedos-config/nixos/configuration.nix /etc/nixos/configuration.nix
```
2. Create user config directories
```bash
mkdir -p ~/.config/{sway,kitty,tmux,yazi} ~/bin
```
3. Copy user configuration files
```bash
cp ~/tedos-config/sway/config ~/.config/sway/config
cp ~/tedos-config/kitty/kitty.conf ~/.config/kitty/kitty.conf
cp ~/tedos-config/tmux/tmux.conf ~/.config/tmux/tmux.conf
cp ~/tedos-config/yazi/yazi.toml ~/.config/yazi/yazi.toml
cp ~/tedos-config/yazi/keymap.toml ~/.config/yazi/keymap.toml
cp ~/tedos-config/.zshrc ~/.zshrc
```
4. Install HUD scripts
```bash
cp ~/tedos-config/bin/tedos-hud ~/bin/tedos-hud
cp ~/tedos-config/bin/tedos-procs ~/bin/tedos-procs
chmod +x ~/bin/tedos-hud ~/bin/tedos-procs
```
5. Ensure ~/bin is on PATH
If ~/bin is not already on PATH, add this to your ~/.zshrc:
```bash
export PATH="$HOME/bin:$PATH"
```
6. Rebuild system
```bash
sudo nixos-rebuild switch
```
7. Reboot
```bash
reboot
```

<img width="1476" height="252" alt="tedosbydimfieldbanner2" src="https://github.com/user-attachments/assets/18052ba2-7bc0-4682-a363-466ae2f50700" />


