{ config, pkgs, ... }:



{
  imports = [./hardware-configuration.nix];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # --- Base identity ---
  networking.hostName = "tedos";
  time.timeZone = "Europe/Stockholm";
  i18n.defaultLocale = "en_US.UTF-8";
  console.keyMap = "sv-latin1";
  # --- Networking ---
  networking.networkmanager.enable = true;


  # --- User ---
  users.users.ted = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ];
    shell = pkgs.bash;
    initialPassword = "";  # ← Add this for empty password
  };

  # Root with NO password
  users.root.initialPassword = "";
  # Sudo with NO password
  security.sudo.wheelNeedsPassword = false;

  # Fonts (for powerline separators + icons)
  fonts.fontconfig.enable = true;
  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
  ];



  # Enables Gnome Keyring to store secrets for applications.
  services.gnome.gnome-keyring.enable = true;

  # Enable Sway.
  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
  };

  # --- Boot into cockpit automatically on tty1 ---
  services.getty.autologinUser = "ted";


programs.bash.loginShellInit = ''
  if [ -t 0 ] && [ -z "$WAYLAND_DISPLAY" ] && [ "$(tty)" = "/dev/tty1" ]; then
    read -t 5 -p "Start Sway? [Y/n]: " response
    if [[ ! "$response" =~ ^[Nn]$ ]]; then
      exec sway
    fi
  fi
'';


#  programs.bash.loginShellInit = ''
#    if [ -z "$WAYLAND_DISPLAY" ] && [ "$(tty)" = "/dev/tty1" ]; then
#      exec sway
#    fi
#  '';



  # --- SSH (optional but recommended) ---
  services.openssh.enable = true;
  services.openssh.settings = {
    PermitRootLogin = "yes";
    PasswordAuthentication = true;
    PermitEmptyPasswords = true;
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
   # zsh starship

    bat delta
    eza
    fzf ripgrep fd
    btop
    jq

    wl-clipboard # Copy/Paste functionality.
    mako # Notification utility
    bind # provides dig

    git curl wget
    unzip zip

    # yazi helpers
    file
    ffmpegthumbnailer
    poppler-utils
    unar
  ];

 # programs.zsh.enable = true;

  # IMPORTANT: keep whatever the installer generates if different
  system.stateVersion = "25.11";
}
