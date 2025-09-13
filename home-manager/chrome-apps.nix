{ pkgs, ... }:

let
  chrome = pkgs.google-chrome;

  # Common flags tuned for battery life
  common_flags = ''
    --no-default-browser-check
    --no-first-run
    --password-store=basic

    # Battery-saving
    --enable-low-end-device-mode
    --disable-background-networking
    --disable-backgrounding-occluded-windows
    --disable-renderer-backgrounding
    --renderer-process-limit=4
    --disk-cache-size=65536
    --media-cache-size=65537
    --ignore-gpu-blocklist
    --enable-features=VaapiVideoEncoder,VaapiVideoDecoder
    --ozone-platform-hint=auto
    --ozone-platform=wayland
    --use-gl=egl
    # Stop PWA window from hijacking external links
    --disable-features=DesktopPWAsLinkCapturing,IntentPickerPWALinkCapturing
  '';

  # Normal GPU-enabled version
  slack-chrome = pkgs.writeShellScriptBin "slack" ''
    #!/usr/bin/env bash
    PROFILE_DIR="$HOME/.local/share/slack-chrome-profile"
    exec ${chrome}/bin/google-chrome-stable \
      --user-data-dir="$PROFILE_DIR" \
      --app="https://app.slack.com/client" \
      --class="slack" \
      --name="slack" \
      ${common_flags} \
      "$@"
  '';

  # Normal GPU-enabled version
  chatgpt-chrome = pkgs.writeShellScriptBin "chatgpt" ''
    #!/usr/bin/env bash
    PROFILE_DIR="$HOME/.local/share/chatgpt-chrome-profile"
    exec ${chrome}/bin/google-chrome-stable \
      --user-data-dir="$PROFILE_DIR" \
      --app="https://chatgpt.com" \
      --class="chatgpt" \
      --name="chatgpt" \
      ${common_flags} \
      "$@"
  '';
in
{
  home.packages = [
    slack-chrome
    chatgpt-chrome
  ];
}
