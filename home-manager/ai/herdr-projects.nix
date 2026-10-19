{
  lib,
  pkgs,
  herdr-projects,
  ...
}:
let
  # Upstream's plugin build step downloads a release binary into its own
  # checkout; build the pinned tag instead and lay the result out as a plugin
  # root: herdr-plugin.toml, skill/ and target/release/herdr-projects.
  herdrProjects = pkgs.rustPlatform.buildRustPackage {
    pname = "herdr-projects";
    inherit ((lib.importTOML "${herdr-projects}/Cargo.toml").package) version;
    src = herdr-projects;
    cargoLock.lockFile = "${herdr-projects}/Cargo.lock";

    postPatch = ''
      # Timed-out commands are killed as a process group through /bin/kill,
      # which NixOS lacks; without it grandchildren hold the pipes open and
      # the timeout waits for them to exit.
      substituteInPlace src/runner.rs --replace-fail \
        'Command::new("/bin/kill")' 'Command::new("${lib.getExe' pkgs.coreutils "kill"}")'

      # The plugin applies its project-grouped agent view at startup only when
      # its journal says `configure` wrote Herdr's config.toml. That file is
      # Home Manager's here (herdr.nix declares the same rows), so apply it anyway.
      substituteInPlace src/setup.rs --replace-fail \
        'let configured = load_journal(&ctx.config_dir).values().any(|o| o.kind == "config");' \
        'let configured = true;'
    '';

    # The suite drives real git repositories and rsync, and schedules
    # routines in named time zones.
    nativeCheckInputs = [
      pkgs.git
      pkgs.rsync
    ];
    preCheck = ''
      export TZDIR=${pkgs.tzdata}/share/zoneinfo
    '';
    # Covers upstream's install script, which this build replaces.
    checkFlags = [
      "--skip=command_link::tests::the_install_script_links_where_herdr_will_move_the_checkout"
    ];

    # The binary finds its plugin root (and the bundled skill) three levels up
    # from its resolved path, so it must be a real file under target/release.
    postInstall = ''
      root=$out/share/herdr-projects
      mkdir -p $root/target/release
      mv $out/bin/herdr-projects $root/target/release/
      ln -s $root/target/release/herdr-projects $out/bin/herdr-projects
      cp -r herdr-plugin.toml skill $root/
    '';

    meta.mainProgram = "herdr-projects";
  };

  pluginRoot = "${herdrProjects}/share/herdr-projects";

  # Herdr records a linked plugin's resolved root, so relink whenever the store
  # path changes, keeping a disabled plugin disabled. `configure --hooks-only`
  # repoints the progress hooks and the autoproject skill at this build and
  # leaves Herdr's config.toml alone; it refuses Home Manager's symlink anyway.
  ensurePlugin = pkgs.writeShellApplication {
    name = "herdr-projects-ensure";
    runtimeInputs = [
      herdrProjects
      pkgs.herdr
      pkgs.jq
    ];
    text = ''
      registration="$(herdr plugin list --plugin herdr-projects --json \
        | jq -c '.result.plugins[0] // empty')"
      if [ "$(jq -r '.plugin_root // empty' <<<"$registration")" != "${pluginRoot}" ]; then
        state=--enabled
        if jq -e '.enabled == false' <<<"$registration" >/dev/null; then
          state=--disabled
        fi
        herdr plugin link "${pluginRoot}" "$state" >/dev/null
      fi
      herdr-projects configure --hooks-only --clients claude,codex >/dev/null
    '';
  };
in
{
  home.file = {
    # The plugin relinks ~/.local/bin/herdr-projects at startup only when the
    # link is missing or points into Herdr's plugins folder; a stale store path
    # would stick. Owning the link keeps it on the current build, and herdr.nix
    # runs the tab-bar count through this stable path.
    ".local/bin/herdr-projects".source = "${pluginRoot}/target/release/herdr-projects";
  };

  home.activation.herdrProjects = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
    if ! $DRY_RUN_CMD ${lib.getExe ensurePlugin}; then
      warnEcho "herdr-projects setup failed; retry with ${lib.getExe ensurePlugin}, then check 'herdr-projects doctor'."
    fi
  '';
}
