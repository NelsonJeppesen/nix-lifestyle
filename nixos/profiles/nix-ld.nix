# nix-ld.nix - Real dynamic linker + curated glibc-stack for FHS-style binaries
#
# NixOS replaces /lib64/ld-linux-x86-64.so.2 with a stub that prints a help
# message and exits. Programs downloaded as pre-built generic-Linux binaries
# (npm-fetched native runtimes, language servers, opencode's plan-annotator,
# VSCode remote helpers, Bun's standalone bins, etc.) trip on the stub.
#
# `programs.nix-ld` swaps the stub for a real loader and exposes a configurable
# library set via $NIX_LD / $NIX_LD_LIBRARY_PATH. The default library list
# nix-ld ships with (`programs.nix-ld.libraries`) is intentionally minimal;
# we extend it with the libs most generic-Linux binaries actually `dlopen`.
#
# Sized for: Node native modules, Electron-ish runtimes, language servers
# (TypeScript, gopls, rust-analyzer pre-builts), and tools like
# `open-plan-annotator` that statically know they need glibc + pthread/dl/m.
{ pkgs, ... }:
{
  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [
      # Core C runtime (already covered by ld itself, listed for clarity)
      glibc
      # Pulled in by almost any Node/Electron/Bun binary
      stdenv.cc.cc.lib
      zlib
      openssl
      curl
      libuv
      icu
      libffi
      # GUI / Electron-ish (cheap to include; harmless if unused)
      libxkbcommon
      libdrm
      mesa
      # X11 / desktop libs that random tooling occasionally dlopens
      libx11
      libxcomposite
      libxdamage
      libxext
      libxfixes
      libxrandr
      libxrender
      libxcb
      # Common transitive needs for HTTP/crypto-heavy tools
      nss
      nspr
      cups
      expat
      fontconfig
      freetype
      dbus
    ];
  };
}
