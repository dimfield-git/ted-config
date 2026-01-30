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
