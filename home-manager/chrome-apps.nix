# chrome-apps.nix - Chrome-based PWA (Progressive Web App) wrappers
#
# Creates standalone Chrome app windows for web services that work better
# as dedicated windows rather than browser tabs. Each app gets its own
# Chrome profile directory to isolate cookies/storage.
#
# Common flags are tuned for battery life on laptops:
# - Low-end device mode reduces background activity
# - Limited renderer processes cap memory usage
# - VAAPI hardware video acceleration on Wayland
# - PWA link capturing is disabled to prevent the app from hijacking URLs
{ pkgs, ... }:

let
  chrome = pkgs.google-chrome;

  # Shared Chrome flags for all PWA wrappers
  # These optimize for battery life and Wayland compatibility
  common_flags = ''
    --no-default-browser-check
    --no-first-run
    --password-store=basic

    # Battery-saving flags
    --enable-low-end-device-mode
    --disable-background-networking
    --disable-backgrounding-occluded-windows
    --disable-renderer-backgrounding
    --renderer-process-limit=4
    --disk-cache-size=65536
    --media-cache-size=65536
    --ignore-gpu-blocklist
    --enable-features=VaapiVideoEncoder,VaapiVideoDecoder,WaylandWindowDecorations
    --ozone-platform=wayland
    --use-gl=egl
    # Prevent PWA from capturing external links (open in default browser instead)
    --disable-features=DesktopPWAsLinkCapturing,IntentPickerPWALinkCapturing
  '';

  # ChatGPT PWA: runs in its own Chrome profile as a standalone app window
  chatgpt-chrome = pkgs.writeShellScriptBin "chatgpt" ''
    PROFILE_DIR="$HOME/.local/share/chatgpt-chrome-profile"
    exec ${chrome}/bin/google-chrome-stable \
      --user-data-dir="$PROFILE_DIR" \
      --app="https://chatgpt.com" \
      --class="chatgpt" \
      --name="chatgpt" \
      ${common_flags} \
      "$@"
  '';

  # OpenCode PWA: web interface for OpenCode running locally
  opencode-chrome = pkgs.writeShellScriptBin "opencode-web" ''
    PROFILE_DIR="$HOME/.local/share/opencode-chrome-profile"
    exec ${chrome}/bin/google-chrome-stable \
      --user-data-dir="$PROFILE_DIR" \
      --app="http://localhost:4096" \
      --class="opencode" \
      --name="opencode" \
      ${common_flags} \
      "$@"
  '';
in
{
  home.packages = [
    chatgpt-chrome
    opencode-chrome
  ];
}
