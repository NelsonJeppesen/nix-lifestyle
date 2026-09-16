{
  lib,
  pkgs,
  workiq,
  ...
}:
let
  workiqPackage = pkgs.stdenv.mkDerivation {
    pname = "workiq";
    version = "1.0.0";
    src = workiq;
    nativeBuildInputs = [
      pkgs.autoPatchelfHook
      pkgs.makeWrapper
    ];
    buildInputs = [ pkgs.stdenv.cc.cc.lib ];
    # The native .NET executable loads these libraries at runtime.
    runtimeDependencies = [
      pkgs.icu
      pkgs.openssl
      pkgs.zlib
    ];
    dontBuild = true;
    # Stripping removes the appended .NET single-file application bundle.
    dontStrip = true;
    installPhase = ''
      runHook preInstall
      install -Dm755 bin/linux-x64/workiq "$out/bin/workiq"
      mkdir -p "$out/share/workiq"
      cp -R EULA "$out/share/workiq/"
      wrapProgram "$out/bin/workiq" --prefix PATH : ${lib.makeBinPath [ pkgs.xdg-utils ]}
      runHook postInstall
    '';
    meta = {
      mainProgram = "workiq";
      platforms = [ "x86_64-linux" ];
    };
  };
in
{
  # Microsoft tenant admin consent may be required on first sign-in.
  programs.mcp.servers.workiq = {
    command = lib.getExe workiqPackage;
    args = [ "mcp" ];
    enabled = true;
  };

  home.packages = [ workiqPackage ]; # Official Microsoft 365 query CLI
}
