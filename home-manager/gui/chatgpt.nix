{ pkgs, lib, ... }:
let
  # OpenAI only publishes "latest" .deb/.rpm URLs; the Arch repo keeps
  # immutable per-version paths, so it is the one source we can pin.
  # Bump: take the newest entry of `versions=(...)` in
  # https://persistent.oaistatic.com/codex-app-prod/linux/install-arch.sh
  # and run `nix store prefetch-file <url>` for the new hash.
  version = "26.930.31730";

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

    # HTTP/code cache in tmpfs: JS bundles and images reload from RAM, wiped
    # on logout. Budget is sized to share the 3.1 GiB $XDG_RUNTIME_DIR with
    # Slack's ~1 GiB cache.
    "--disk-cache-dir=$CHATGPT_CACHE_DIR"
    "--disk-cache-size=402653184" # 384 MiB
    "--media-cache-size=67108864" # 64 MiB
  ];

  chatgpt = pkgs.stdenv.mkDerivation {
    pname = "chatgpt";
    inherit version;
    src = pkgs.fetchurl {
      url = "https://persistent.oaistatic.com/codex-app-prod/linux/arch/${version}/x86_64/chatgpt-bin-${version}-1-x86_64.pkg.tar.zst";
      hash = "sha256-gfPXXSHsbGtW4NT8O8HJsJRcK2sh5Rfp9n0D4f7mm44=";
    };
    sourceRoot = ".";
    nativeBuildInputs = [
      pkgs.autoPatchelfHook
      pkgs.makeWrapper
      pkgs.zstd
    ];
    # Shared libraries the Electron shell links against (from the package's
    # Arch `depend` list).
    buildInputs = with pkgs; [
      alsa-lib
      at-spi2-atk
      at-spi2-core
      cairo
      cups
      dbus
      expat
      gdk-pixbuf
      glib
      gtk3
      libdrm
      libgbm
      libnotify
      libsecret
      libusb1
      libxkbcommon
      nspr
      nss
      openssl
      pango
      stdenv.cc.cc.lib
      systemd
      tpm2-tss
      xz
      xorg.libX11
      xorg.libXScrnSaver
      xorg.libXcomposite
      xorg.libXdamage
      xorg.libXext
      xorg.libXfixes
      xorg.libXrandr
      xorg.libxcb
    ];
    # dlopen()ed at runtime, so autoPatchelf cannot see them via DT_NEEDED.
    runtimeDependencies = with pkgs; [
      libGL
      libnotify
      libsecret
      systemd
      vulkan-loader
    ];
    # Chromium's optional Qt theme shims (GTK is used instead) and musl
    # prebuilds of node-hid/serialport that glibc never loads.
    autoPatchelfIgnoreMissingDeps = [
      "libQt5*"
      "libQt6*"
      "libc.musl-x86_64.so.1"
    ];
    dontBuild = true;
    dontConfigure = true;
    # Stripping corrupts the bundled Node/Electron snapshots.
    dontStrip = true;
    installPhase = ''
      runHook preInstall
      mkdir -p $out/lib $out/bin
      cp -R usr/lib/chatgpt $out/lib/chatgpt
      cp -R usr/share $out/share
      makeWrapper $out/lib/chatgpt/ChatGPT $out/bin/chatgpt \
        --prefix PATH : ${lib.makeBinPath [ pkgs.xdg-utils ]} \
        --set ELECTRON_OZONE_PLATFORM_HINT wayland \
        --run 'CHATGPT_CACHE_DIR="''${XDG_RUNTIME_DIR:-/tmp}/chatgpt-cache"; mkdir -p "$CHATGPT_CACHE_DIR"' \
        --add-flags ${lib.escapeShellArg chatgptFlags}
      # Keep the launcher on the wrapper, and don't claim http(s): the app
      # would otherwise register itself as a browser for web links.
      substituteInPlace $out/share/applications/chatgpt.desktop \
        --replace-fail "Exec=chatgpt" "Exec=$out/bin/chatgpt" \
        --replace-fail "x-scheme-handler/http;x-scheme-handler/https;" ""
      runHook postInstall
    '';
    meta = {
      description = "ChatGPT desktop app (with Codex) by OpenAI";
      homepage = "https://learn.chatgpt.com/docs/linux/linux-app";
      license = lib.licenses.unfree;
      mainProgram = "chatgpt";
      platforms = [ "x86_64-linux" ];
      sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    };
  };
in
{
  home.packages = [ chatgpt ]; # ChatGPT desktop app (pinned above)
}
