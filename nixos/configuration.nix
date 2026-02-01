{ config, pkgs, ... }:



{
  imports = [./hardware-configuration.nix];



  # --- Base identity ---
  networking.hostName = "tedos";
  time.timeZone = "Europe/Stockholm";
  i18n.defaultLocale = "en_US.UTF-8";

  # --- Networking ---
  networking.networkmanager.enable = true;


  # --- User ---
  users.users.ted = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ];
    shell = pkgs.zsh;
  };
  security.sudo.wheelNeedsPassword = true;

  # Fonts (for powerline separators + icons)
  fonts.fontconfig.enable = true;
  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
  ];
 

  # --- Minimal GUI layer (NO desktop environment) ---
  services.xserver.enable = true;          # plumbing only
  services.displayManager.enable = false;  # no GDM/SDDM/etc
  programs.sway.enable = true;

  # --- Boot into cockpit automatically on tty1 ---
  services.getty.autologinUser = "ted";
  programs.bash.loginShellInit = ''
    if [ -z "$WAYLAND_DISPLAY" ] && [ "$(tty)" = "/dev/tty1" ]; then
      exec sway
    fi
  '';

  # --- SSH (optional but recommended) ---
  services.openssh.enable = true;
  services.openssh.settings = {
    PermitRootLogin = "no";
    PasswordAuthentication = false;
    KbdInteractiveAuthentication = false;
  };

  networking.firewall.enable = true;
  networking.firewall.allowedTCPPorts = [ 22 ];

  # --- Packages: cockpit only (still terminal-centric) ---
  environment.systemPackages = with pkgs; [
    kitty
    yazi
    tmux

    neovim
    vim
    zsh starship

    bat delta
    eza
    fzf ripgrep fd
    btop
    jq

    bind # provides dig

    git curl wget
    unzip zip

    # yazi helpers
    file
    ffmpegthumbnailer
    poppler_utils
    unar
  ];

  programs.zsh.enable = true;

  # IMPORTANT: keep whatever the installer generates if different
  system.stateVersion = "25.11";
}
