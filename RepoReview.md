# Repo Review

## High-level overview

- This repository is a NixOS “terminal cockpit” configuration called **TedOS**, 
focused on a minimal GUI substrate (sway + kitty) that hosts TUI tools like tmux, 
Yazi, and Neovim, with detailed install instructions and repository layout documented 
in the main README.
- There is a separate README aimed at VM-based installation steps and verification 
for NixOS in a VM context, including SSH setup and disk partitioning guidance.

## Configuration files by area

- **NixOS system configuration:** `nixos/configuration.nix` defines the system identity, 
networking, user setup, fonts,sway boot behavior, SSH hardening, firewall ports, and the 
core terminal-focused package set (kitty, yazi, tmux, neovim, etc.).
- **Sway compositor:** `sway/config` sets up Mod4 bindings, window splits, fullscreen, workspaces, 
and autostarts two kitty windows (Yazi + tmux) that are assigned to named workspaces.
- **Kitty terminal:** `kitty/kitty.conf` sets basic terminal behavior (no bell, scrollback), font size, 
and uses JetBrainsMono Nerd Font.
- **tmux:** `tmux/tmux.conf` enables mouse support, defines split bindings, status bar settings, 
and integrates the HUD/PROC scripts in the status line with powerline styling.
- **Yazi:** `yazi/yazi.toml` sets file manager display preferences and preview limits; 
`yazi/keymap.toml` adds quick navigation keybindings for home/root.
- **Zsh:** `.zshrc` sets editor variables, initializes starship, and defines 
alias overrides for common CLI tools (bat, delta, eza).

## Helper scripts

- **HUD script:** `bin/tedos-hud` prints VPN status, SSH session count, CPU usage, and disk free space, with tmux color formatting when run inside tmux.
- **Process watcher:** `bin/tedos-procs` monitors a list of “important” processes and prints a comma-separated RUN list for tmux status usage.

## Repo metadata and tooling

- **Git ignore rules:** `.gitignore` excludes common swap/backup files and macOS `.DS_Store`.
- **JetBrains IDE metadata:** `.idea` contains project config (Python SDK 3.12, module definition, VCS mapping, and IDE-specific ignore rules).
