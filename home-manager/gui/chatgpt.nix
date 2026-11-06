{ pkgs, lib, ... }:
let
  # nixpkgs' chatgpt package (pkgs/by-name/ch/chatgpt) replaces the bundled
  # `cua_node` runtime with nodejs-slim. The bundled one segfaulted in ld.so
  # after autoPatchelf added an rpath, which left the in-app browser (Codex
  # browser use) stuck on blank pages.

  # Mirrors the Wayland/GPU/RAM tuning in slack.nix.
  chatgptFlags = lib.concatStringsSep " " [
    "--ozone-platform=wayland" # native Wayland, never XWayland
    "--enable-features=UseOzonePlatform,WaylandWindowDecorations,VaapiVideoDecoder,VaapiVideoEncoder,CanvasOopRasterization"
    "--ignore-gpu-blocklist" # allow HW accel on the iGPU (matches chrome.nix)
    "--enable-wayland-ime=false" # IME off -> lower input latency (matches kitty)
    "--enable-gpu-rasterization"
    "--enable-zero-copy"

    # Keep the renderer at full priority while hidden, so switching back to
    # a long conversation (or a running Codex task) doesn't stall.
    "--disable-renderer-backgrounding"
    "--disable-background-timer-throttling"
    "--disable-backgrounding-occluded-windows"
    "--disable-features=IntensiveWakeUpThrottling"

    # Higher V8 heap ceilings (not preallocated): fewer major GC pauses in a
    # client that keeps long chat transcripts live in the heap. Inner quotes
    # keep both V8 flags in one argv entry (see slack.nix).
    "--js-flags='--max-old-space-size=4096 --max-semi-space-size=64'"

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
