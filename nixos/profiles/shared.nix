# shared.nix - Cross-host baseline (always imported via configuration.nix)
#
# Sets up: keyd Caps→layer remap, locale, zsh as default shell, nix flakes,
# Wayland session env, neovim as system editor, weekly nh clean, openssh,
# the `nelson` user with standard groups, and a minimal package set.
{
  config,
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
  security.sudo.extraConfig = "Defaults timestamp_timeout=600";

  # Allow `nelson` to drive system rebuilds without a sudo password.
  # The `update` script invokes:
  #   1. `sudo nix flake update --flake /etc/nixos`         → /run/current-system/sw/bin/nix
  #   2. `sudo nixos-rebuild switch --flake /etc/nixos`     → /run/current-system/sw/bin/nixos-rebuild
  # Both are stable symlinks (`/run/current-system/sw/bin/*` re-point on
  # activation, but the path itself never changes).
  #
  # We deliberately do NOT use `nh os switch` for the system layer here:
  # nh always wraps activation in `sudo env … switch-to-configuration`,
  # and sudo matches on argv[0] = `env`, which can't be safely allowlisted
  # (allowing `sudo env` is equivalent to full root). `nh home switch`
  # for the user layer needs no sudo at all and is still used.
  #
  # Firmware updates intentionally NOT covered: those live in the
  # separate `firmware-update` script which prompts normally.
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

  # Firefox has defaulted to Wayland since 121, so MOZ_ENABLE_WAYLAND is gone.
  environment.sessionVariables = {
    GDK_BACKEND = "wayland,x11"; # prefer Wayland, fall back to X11
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

  # GC with `nh clean all` instead of nix.gc: run as root, nix-collect-garbage
  # never prunes the Home Manager and `nix profile` generations under each
  # user's ~/.local/state/nix/profiles, so their closures piled up. nh also
  # drops stale result/direnv GC roots. Keep 30 days, and at least 5 of each.
  programs.nh.clean = {
    enable = lib.mkDefault true;
    dates = lib.mkDefault "weekly";
    extraArgs = lib.mkDefault "--keep-since 30d --keep 5";
  };

  # Weekly hard-link deduplication of identical store files.
  nix.optimise.automatic = lib.mkDefault true;

  services.openssh.enable = lib.mkDefault true;
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
    keyd
    wget
    curl
    git
    btop
    screen
  ];
}
