{
  lib,
  pkgs,
  openrig,
}:
pkgs.buildNpmPackage {
  pname = "openrig";
  version = "0.6.4";
  src = openrig;
  nodejs = pkgs.nodejs_24;

  postPatch = ''
    cp ${./package-lock.json} package-lock.json
  '';

  npmDepsFetcherVersion = 2;
  npmDepsHash = "sha256-ROLRT6ARVs9GIhUUJ2m0fDS+M5BuMukpcnHQrgdDWsY=";
  dontNpmBuild = true;
  npmFlags = [ "--ignore-scripts" ];
  nativeBuildInputs = [ pkgs.python3 ];
  env.npm_config_build_from_source = "true";

  # Compile SQLite against Nix's Node headers instead of downloading a
  # prebuilt addon. Run only the required dependency's installation script.
  buildPhase = ''
    runHook preBuild
    npm rebuild better-sqlite3 --ignore-scripts=false
    node scripts/check-abi.mjs
    runHook postBuild
  '';

  postInstall = ''
    for cli in rig openrig-tui; do
      wrapProgram "$out/bin/$cli" \
        --prefix PATH : "${
          lib.makeBinPath [
            pkgs.nodejs_24
            pkgs.tmux
          ]
        }"
    done
  '';

  doInstallCheck = true;
  installCheckPhase = ''
    runHook preInstallCheck
    "$out/bin/rig" --version
    node --input-type=module -e "
      const { createRequire } = await import('node:module');
      const require = createRequire('$out/lib/node_modules/@openrig/cli/dist/index.js');
      const Database = require('better-sqlite3');
      const db = new Database(':memory:');
      if (db.prepare('select 42 as result').get().result !== 42) process.exit(1);
      db.close();
    "
    runHook postInstallCheck
  '';

  meta = {
    description = "Local control plane for teams of coding agents";
    homepage = "https://openrig.dev";
    license = lib.licenses.asl20;
    platforms = [ "x86_64-linux" ];
    mainProgram = "rig";
  };
}
