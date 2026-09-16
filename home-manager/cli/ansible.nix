{ pkgs, ... }:
{
  home.packages = [
    pkgs.ansible # Core playbook, inventory, Galaxy, and Vault commands
    pkgs.ansible-builder # Build portable execution-environment images
    pkgs.ansible-lint # Playbook, role, and collection best-practice checks
    pkgs.ansible-navigator # TUI for running and inspecting Ansible content
    pkgs.molecule # Role and collection scenario testing
  ];
}
