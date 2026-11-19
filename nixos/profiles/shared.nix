# shared.nix - Cross-host baseline (always imported via configuration.nix)
#
# Sets up: keyd Caps→layer remap, locale, zsh as default shell, nix flakes,
# Wayland session env, neovim as system editor, weekly nh clean, disabled SSH serving,
# the `nelson` user with standard groups, and a minimal package set.
{
  pkgs,
  lib,
  ...
}:
{

  services.keyd = {
    enable = true;
    keyboards.default = {
      settings = {
        main = {
          capslock = "layer(capslock)";
        };
        "capslock:M" = { };

      };
    };
  };

  i18n.extraLocaleSettings = {
    LC_TIME = "en_GB.UTF-8";
  }; # monday is the start of the week

  console.earlySetup = lib.mkDefault true; # Set virtual console options in initrd
  environment.defaultPackages = lib.mkDefault [ ]; # Remove default packages
  nixpkgs.config.allowUnfree = true; # Chrome, steam etc
  programs.zsh.enable = true;
  # Cache interactive sudo authentication for ten hours per sudo policy.
  security.sudo.extraConfig = "Defaults timestamp_timeout=600";

  # Passwordless system updates are an intentional root-equivalent grant.
  # `nix` can execute arbitrary commands as root and `nixos-rebuild` can
  # activate a caller-selected configuration; this command list is not a
  # sandbox for agents or for untrusted repositories. The `update` helper
  # uses these stable paths; firmware-update still requests authentication.
  security.sudo.extraRules = [
    {
      users = [ "nelson" ];
      commands = [
        {
          command = "/run/current-system/sw/bin/nixos-rebuild";
          options = [ "NOPASSWD" ];
        }
        {
          command = "/run/current-system/sw/bin/nix";
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];
  services.dbus.implementation = "broker";
  users.defaultUserShell = pkgs.zsh;

  # Firefox and GTK select Wayland through their native defaults.
  # No GDK_BACKEND: GTK already prefers Wayland, and any value makes
  # xdg-desktop-portal-gnome expose only Settings, which breaks portal
  # screenshots (Flameshot), screencasts and file choosers.
  environment.sessionVariables = {
    MOZ_USE_XINPUT2 = "1"; # smoother scrolling/input
    NIXOS_OZONE_WL = "1";
  };

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  # Flakes are the only input source. NIX_PATH keeps nixpkgs=flake:nixpkgs,
  # pinned to this flake's nixpkgs.
  nix.channel.enable = false;
  services.fwupd.enable = lib.mkDefault true;

  # Install neovim as the system's editor
  programs.neovim.enable = lib.mkDefault true;
  programs.neovim.defaultEditor = lib.mkDefault true;
  programs.neovim.vimAlias = lib.mkDefault true;
  programs.neovim.viAlias = lib.mkDefault true;

  zramSwap.enable = lib.mkDefault true;

  # Clean system and per-user profiles, including Home Manager generations
  # under ~/.local/state/nix/profiles. Keep 30 days and at least 5 generations;
  # protect any long-term recovery generation separately from this policy.
  programs.nh.clean = {
    enable = lib.mkDefault true;
    dates = lib.mkDefault "weekly";
    extraArgs = lib.mkDefault "--keep-since 30d --keep 5";
  };

  # Weekly hard-link deduplication of identical store files.
  nix.optimise.automatic = lib.mkDefault true;

  # These laptops do not accept incoming OpenSSH sessions. Outgoing SSH
  # clients remain available for Git and other authenticated connections.
  services.openssh = {
    enable = false;
    openFirewall = false;
  };
  users.users.nelson.isNormalUser = lib.mkDefault true;

  users.users.nelson.extraGroups = lib.mkDefault [
    "cdrom"
    "dialout"
    "docker"
    "i2c"
    "networkmanager"
    "optical"
    "plugdev"
    "wheel"
  ];

  environment.systemPackages = with pkgs; [
    keyd # Keyboard remapping daemon and diagnostic CLI.
    wget # Download files from a recovery console.
    curl # Inspect HTTP endpoints and transfer data.
    git # Fetch and inspect configuration repositories.
    btop # Inspect CPU, memory, and process pressure.
    screen # Keep terminal work running across disconnects.
  ];
}
