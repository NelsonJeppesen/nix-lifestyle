# Package ChatGPT with Wayland flags and a desktop entry for app links only.
{ pkgs, lib, ... }:
let
  # nixpkgs' chatgpt package (pkgs/by-name/ch/chatgpt) replaces the bundled
  # `cua_node` runtime with nodejs-slim. The bundled one segfaulted in ld.so
  # after autoPatchelf added an rpath, which left the in-app browser (Codex
  # browser use) stuck on blank pages.

  # Use the same Wayland/GPU integration as the other Electron applications.
  chatgptFlags = lib.concatStringsSep " " [
    "--ozone-platform=wayland" # native Wayland, never XWayland
    "--enable-features=UseOzonePlatform,WaylandWindowDecorations,VaapiVideoDecoder,VaapiVideoEncoder,CanvasOopRasterization"
    "--ignore-gpu-blocklist" # allow HW accel on the iGPU (matches chrome.nix)
    "--enable-wayland-ime=false" # Disable Wayland input-method composition
    "--enable-gpu-rasterization"
    "--enable-zero-copy"

    # Use Electron's background scheduling and V8 heap limits. Applying this
    # configuration does not restart the app; new launches use these defaults.

    # No --disk-cache-dir / --disk-cache-size here (unlike slack.nix): with a
    # custom cache dir the in-app browser's "codex-browser-app" session hung
    # forever creating its HTTP cache backend, so pages never loaded.
  ];

  chatgpt = pkgs.chatgpt.overrideAttrs (prev: {
    postFixup = (prev.postFixup or "") + ''
      # The nixpkgs launcher forwards extra args to Electron, so our tuning
      # flags go on top of (and override) its own Wayland defaults. A shell
      # shim rather than wrapProgram keeps the flag list readable.
      mv $out/bin/chatgpt $out/bin/.chatgpt-nixpkgs
      cat > $out/bin/chatgpt <<'EOF'
      #!${pkgs.runtimeShell}
      exec ${placeholder "out"}/bin/.chatgpt-nixpkgs ${chatgptFlags} "$@"
      EOF
      chmod +x $out/bin/chatgpt
      # Don't claim http(s): the app would otherwise register itself as a
      # browser for web links.
      substituteInPlace $out/share/applications/chatgpt.desktop \
        --replace-fail "x-scheme-handler/http;x-scheme-handler/https;" ""
    '';
  });
in
{
  home.packages = [ chatgpt ]; # ChatGPT desktop app (nixpkgs, with local flags)
}
