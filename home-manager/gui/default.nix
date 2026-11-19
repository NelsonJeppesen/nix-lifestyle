# Compose managed graphical applications; commented imports are optional choices.
{ ... }: {
  imports = [
    ./chatgpt.nix
    ./chrome.nix
    # ./firefox.nix
    ./flameshot.nix
    ./kitty.nix
    ./slack.nix
    ./tailscale-systray.nix
    ./packages.nix
  ];
}
