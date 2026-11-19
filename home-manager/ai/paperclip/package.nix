# Adapt the pinned Paperclip npm release and its native dependencies to NixOS.
{
  lib,
  pkgs,
  paperclip,
}:
pkgs.buildNpmPackage {
  pname = "paperclipai";
  version = "2026.1106.0";
  src = paperclip;
  nodejs = pkgs.nodejs_24;

  postPatch = ''
    # package-lock.json is `npm install --package-lock-only --ignore-scripts`
    # output for the release's package.json. Some packages bundle their
    # Linux x64 dependencies with broken edges that `npm ci` rejects;
    # bundled-lock.jq repairs only those bundled entries.
    ${lib.getExe pkgs.jq} -f ${./bundled-lock.jq} ${./package-lock.json} > package-lock.json

    # The stable Home Manager CLI link is not an upstream managed-install
    # shim. Code in the Nix store needs no ~/.paperclip/cli/install.json.
    substituteInPlace dist/index.js \
      --replace-fail 'if (!hasManagedArtifacts(paths)) {' \
        'if (import.meta.url.startsWith("file://${builtins.storeDir}/") || !hasManagedArtifacts(paths)) {' \
      --replace-fail 'Not present (optional for npx, global npm, and source-checkout usage)' \
        'Managed by Nix; update through Home Manager'

    # Nix PostgreSQL defaults to /run/postgresql, which is owned by the
    # system service. Paperclip connects over loopback TCP instead.
    substituteInPlace dist/index.js \
      --replace-fail 'postgresFlags: [],' 'postgresFlags: ["-c", "unix_socket_directories="],'
  '';

  npmDepsFetcherVersion = 2;
  npmDepsHash = "sha256-J06mlgHPsDkwL3cC6bw42Lo4WBNQHwbncDJCwHUZcAY=";
  dontNpmBuild = true;
  dontNpmPrune = true;
  npmFlags = [ "--ignore-scripts" ];

  # patchelf 0.15.2 relocates libvips' .init/.plt without updating their
  # addresses. The newer patcher preserves them and loads successfully.
  nativeBuildInputs = [
    pkgs.autoPatchelfHook
    pkgs.patchelfUnstable
  ];

  preFixup = ''
    export PATH="${pkgs.patchelfUnstable}/bin:$PATH"
  '';
  buildInputs = [
    pkgs.stdenv.cc.cc.lib
    pkgs.openssl
    pkgs.zlib
    pkgs.libxcrypt-legacy
    pkgs.ncurses
  ];

  postInstall = ''
    # embedded-postgres resolves these executables through its platform npm
    # package. Use Nix's PostgreSQL 18 with its working loader and data files.
    native="$out/lib/node_modules/paperclipai/node_modules/@embedded-postgres/linux-x64"
    rm -r "$native/native"
    substituteInPlace "$native/dist/index.js" \
      --replace-fail "path.resolve(__dirname, '..', 'native', 'bin', 'pg_ctl')" "'${pkgs.postgresql_18}/bin/pg_ctl'" \
      --replace-fail "path.resolve(__dirname, '..', 'native', 'bin', 'initdb')" "'${pkgs.postgresql_18}/bin/initdb'" \
      --replace-fail "path.resolve(__dirname, '..', 'native', 'bin', 'postgres')" "'${pkgs.postgresql_18}/bin/postgres'"

    substituteInPlace "$out/lib/node_modules/paperclipai/node_modules/embedded-postgres/dist/index.js" \
      --replace-fail 'postgresFlags: [],' 'postgresFlags: ["-c", "unix_socket_directories="],'

    # ACP child processes also require Node 24, even when the login shell
    # uses another Node version.
    wrapProgram "$out/bin/paperclipai" \
      --prefix PATH : "${
        lib.makeBinPath [
          pkgs.nodejs_24
          pkgs.postgresql_18
        ]
      }" \
      --set PAPERCLIP_UPDATE_CHECK 0
  '';

  # Exercise libvips through sharp after ELF fixups; a successful CLI version
  # check alone does not prove the image-processing addon can load.
  doInstallCheck = true;
  installCheckPhase = ''
    runHook preInstallCheck
    "$out/bin/paperclipai" --version
    node --input-type=module -e "
      const { createRequire } = await import('node:module');
      const require = createRequire('$out/lib/node_modules/paperclipai/dist/index.js');
      const sharp = require('sharp');
      const image = await sharp({ create: {
        width: 8, height: 8, channels: 3,
        background: { r: 0, g: 0, b: 0 }
      } }).png().toBuffer();
      if (image.readUInt32BE(0) !== 0x89504e47) process.exit(1);
    "
    runHook postInstallCheck
  '';

  meta = {
    description = "Local dashboard and orchestration for AI agents";
    homepage = "https://github.com/paperclipai/paperclip";
    license = lib.licenses.mit;
    platforms = [ "x86_64-linux" ];
    mainProgram = "paperclipai";
  };
}
