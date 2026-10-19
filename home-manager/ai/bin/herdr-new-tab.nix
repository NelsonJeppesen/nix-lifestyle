# Shared by herdr.nix (keybindings) and herdr-plus.nix (quick actions).
{
  writeShellApplication,
  herdr,
  jq,
}:
writeShellApplication {
  name = "herdr-new-tab";
  runtimeInputs = [
    herdr
    jq
  ];
  text = builtins.readFile ./herdr-new-tab;
}
