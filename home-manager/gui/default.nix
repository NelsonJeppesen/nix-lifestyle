{ ... }: {
  imports = [
    ./chrome.nix
    # ./firefox.nix
    ./flameshot.nix
    ./kitty.nix
    ./slack.nix
    ./tailscale-systray.nix
    ./packages.nix
  ];
}
