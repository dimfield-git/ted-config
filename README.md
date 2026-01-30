# TedOS — Terminal Cockpit NixOS

TedOS is a terminal-centric NixOS configuration built as a **“non-GUI GUI”**:  
a minimal graphical substrate (sway + kitty) hosting a powerful text-based cockpit built around **tmux**, **Yazi**, and **Neovim**.

There is **no desktop environment**.  
All work happens in terminal / TUI applications.

---

## Philosophy

- GUI exists **only** to render terminal windows
- All interaction is **TUI / CLI**
- Reproducible, declarative system (NixOS)
- Incremental, inspectable evolution
- Clear separation between:
  - **Creative workstation** (Ubuntu Studio)
  - **System / ops / dev / OSINT box** (TedOS)

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

# TedOS — InstallationInstructions.md

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

- You have a working Ubuntu Studio (or other Linux) system with the `tedos-config` folder available.
- You will install TedOS onto a dedicated target disk (example: `/dev/nvme1n1`).
- You want a terminal-centric cockpit using sway + kitty to host TUI apps (Yazi, tmux, etc.).
- A user account `ted` will exist on TedOS.
- SSH access between Ubuntu Studio and TedOS will be used to copy files after the base install.

---

## Stage 1 — Install Base NixOS

### 1. Download NixOS Minimal ISO

Download the current NixOS Minimal ISO (x86_64) from the official site.

---

### 2. Flash the ISO to a USB stick (Ubuntu Studio)

Identify the USB device (example output shows it as `/dev/sda`; yours may differ).

```bash
lsblk -o NAME,SIZE,MODEL,TYPE,MOUNTPOINTS

