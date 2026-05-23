# console.nix - kmscon-based virtual console with a Nerd Font
#
# Replaces the kernel VT renderer (which is hard-capped at PSF bitmap fonts
# with 512 glyphs and 16 colors) with `kmscon`, a userspace KMS/DRM console
# that renders TrueType via FreeType. This is the only path on Linux that
# lets the bare console show Nerd Font icons + Powerline separators
# correctly without dropping into X11/Wayland.
#
# Trade-offs vs. the kernel VT:
# - kmscon owns the TTYs after stage-2, so Plymouth's handoff is to kmscon
#   rather than the kernel framebuffer console. In practice this works
#   cleanly with `boot.initrd.systemd.enable = true` (already set on the
#   hosts importing this), but if a future Plymouth/kmscon version flickers
#   on handoff, disabling kmscon falls back to the kernel VT immediately.
# - A handful of tools poking /dev/tty* directly (legacy installers, some
#   recovery utilities) may behave differently. None used here today.
# - `hwRender = true` requires DRM/KMS access; fine on all current hosts
#   (Intel xe/i915, Apple AGX via simpledrm fallback).
#
# Font: JetBrainsMono Nerd Font ships the full Nerd Fonts glyph set
# (Powerline, Devicons, Font Awesome, Material, Octicons, Codicons, etc.)
# patched into a monospace TTF, so prompts and tmux status bars render
# the same on the bare console as in a userspace terminal.
{ pkgs, ... }:
{
  services.kmscon = {
    enable = true;
    hwRender = true;
    fonts = [
      {
        name = "JetBrainsMono Nerd Font";
        package = pkgs.nerd-fonts.jetbrains-mono;
      }
    ];
    # 14pt is a reasonable starting point across panels (it scales with
    # the framebuffer resolution kmscon picks). Bump per-host if needed.
    extraConfig = ''
      font-size=14
      palette=solarized
    '';
  };

  # Make the same font available to userspace so anything reading
  # /run/current-system/sw/share/fonts (xdg, fontconfig consumers) sees it
  # too. Harmless if other profiles also pull it in.
  fonts.packages = [ pkgs.nerd-fonts.jetbrains-mono ];
}
