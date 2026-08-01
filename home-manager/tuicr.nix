# tuicr.nix - terminal code review UI and OpenCode skill
{ pkgs, tuicr, ... }:
{
  home.packages = [ tuicr.packages.${pkgs.stdenv.hostPlatform.system}.default ];

  # OpenCode discovers global skills below ~/.config/opencode/skills.
  home.file.".config/opencode/skills/tuicr/SKILL.md".source = ./dotfiles/tuicr-skill.md;
}
