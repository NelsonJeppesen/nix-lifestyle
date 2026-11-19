# Package Microsoft WorkIQ for NixOS and expose its Microsoft 365 MCP endpoint.
{
  lib,
  pkgs,
  workiq,
  ...
}:
let
  workiqPackage = pkgs.stdenv.mkDerivation {
    pname = "workiq";
    version = "1.0.1";
    src = workiq;
    nativeBuildInputs = [
      pkgs.autoPatchelfHook
      pkgs.makeWrapper
    ];
    buildInputs = [ pkgs.stdenv.cc.cc.lib ];
    # .NET dlopens these libraries. Use library outputs: OpenSSL's default
    # output contains executables, so its /lib cannot satisfy the loader.
    runtimeDependencies = map lib.getLib [
      pkgs.icu
      pkgs.openssl
      pkgs.zlib
    ];
    dontBuild = true;
    # Stripping removes the appended .NET single-file application bundle.
    dontStrip = true;
    installPhase = ''
      runHook preInstall
      # System.CommandLine derives the root alias from the executable name.
      # A hidden .workiq-wrapped basename becomes an empty alias in .NET.
      install -Dm755 bin/linux-x64/workiq "$out/libexec/workiq"
      mkdir -p "$out/share/workiq"
      cp -R EULA "$out/share/workiq/"
      makeWrapper "$out/libexec/workiq" "$out/bin/workiq" \
        --prefix PATH : ${lib.makeBinPath [ pkgs.xdg-utils ]}
      runHook postInstall
    '';
    # Startup needs the native crypto loader even for local help. Check the
    # installed wrapper after ELF fixups without signing in or making queries.
    doInstallCheck = true;
    installCheckPhase = ''
      runHook preInstallCheck
      export DOTNET_BUNDLE_EXTRACT_BASE_DIR="$TMPDIR/workiq-bundle"
      "$out/bin/workiq" --help >/dev/null
      runHook postInstallCheck
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
