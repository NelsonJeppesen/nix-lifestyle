# Local document capture, OCR, and page-plan exports. Scanner USB permissions
# and the Fujitsu backend configuration come from the NixOS scanner profile.
{ pkgs, ... }:
let
  python_env = pkgs.python3.withPackages (ps: [
    ps.img2pdf
    ps.pikepdf
    ps.pillow
  ]);
  scan_docs = pkgs.writeShellApplication {
    name = "scan-docs";
    runtimeInputs = [
      pkgs.sane-backends # USB document capture through scanimage.
      pkgs.ocrmypdf # Searchable text layer, rotation, and deskewing.
      pkgs.poppler-utils # Extract OCR text with stable PDF page boundaries.
    ];
    text = ''
      export SANE_CONFIG_DIR="''${SANE_CONFIG_DIR:-/etc/sane-config}"
      exec ${python_env}/bin/python3 ${./bin/scan-docs} "$@"
    '';
  };
in
{
  home.packages = [ scan_docs ]; # Scan, read, split, and combine local PDFs.
}
