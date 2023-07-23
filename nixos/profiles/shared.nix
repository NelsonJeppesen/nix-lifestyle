let
  my-python-packages = ps: with ps; [
    # ...
    (
      buildPythonPackage rec {
        pname = "okta-awscli";
        version = "0.5.4";
        src = fetchPypi {
          inherit pname version;
          sha256 = "sha256-UJkho43txvoUJPBuW7lKW7NZRjkSxFIYq99glbOqyCE=";
        };
        doCheck = false;
        propagatedBuildInputs = [
          # Specify dependencies
          pkgs.python3Packages.configparser
          pkgs.python3Packages.beautifulsoup4
          pkgs.python3Packages.boto3
          pkgs.python3Packages.click
          pkgs.python3Packages.requests
          pkgs.python3Packages.validators
        ];
      }
    )
  ];
in
{ config, pkgs, stdenv, lib, ... }:
{
  nixpkgs.config.allowUnfree = true; # Chrome, steam etc
  console.earlySetup = lib.mkDefault true; # Set virtual console options in initrd
  environment.defaultPackages = lib.mkDefault [ ]; # Remove default pacakges
  security.sudo.extraConfig = ''Defaults timestamp_timeout=600'';
  programs.zsh.enable = true;
  users.defaultUserShell = pkgs.zsh;

  #ddc monitor control
  #hardware.i2c.enable = true;

  environment.sessionVariables = rec { MOZ_ENABLE_WAYLAND = "1"; };
  nix.extraOptions = ''experimental-features = nix-command flakes'';
  services.fwupd.enable = lib.mkDefault true;

  # Install neovim as the system's editor
  programs.neovim.enable = lib.mkDefault true;
  programs.neovim.defaultEditor = lib.mkDefault true;
  programs.neovim.vimAlias = lib.mkDefault true;
  programs.neovim.viAlias = lib.mkDefault true;

  networking.dhcpcd.enable = lib.mkDefault false;
  systemd.network.enable = lib.mkDefault true;

  # trim deleted blocks from ssd
  services.fstrim.enable = lib.mkDefault true;

  nix = {
    gc = {
      automatic = lib.mkDefault true;
      dates = lib.mkDefault "weekly";
      options = lib.mkDefault "--delete-older-than 30d";
    };
  };

  services.sshd.enable = lib.mkDefault true;
  users.users.nelson.isNormalUser = lib.mkDefault true;
  users.users.nelson.extraGroups = lib.mkDefault [ "i2c" "dialout" "wheel" "docker" "networkmanager" "plugdev" ];
  environment.systemPackages = with pkgs; [
    #(python3.withPackages (ps: with ps; [ okta-awscli ]))
    wget
    curl
    git
    btop
  ];

  networking.firewall.enable = lib.mkDefault true;
}
