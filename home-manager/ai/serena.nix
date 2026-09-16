{
  config,
  lib,
  pkgs,
  serena,
  ...
}:
let
  serenaPackage = serena.packages.${pkgs.stdenv.hostPlatform.system}.serena;
  serenaConfig = pkgs.writeText "serena-config.yml" ''
    language_backend: LSP
    line_ending: lf
    gui_log_window: false
    web_dashboard: false
    log_level: 30
    trace_lsp_communication: false
    ls_specific_settings:
      ansible:
        ls_path: "${lib.getExe pkgs.ansible-language-server}"
        ansible_path: "${pkgs.ansible}/bin/ansible"
        lint_enabled: true
        lint_path: "${lib.getExe pkgs.ansible-lint}"
        python_interpreter_path: "${lib.getExe pkgs.python3}"
    ignored_paths: []
    excluded_tools:
      - list_dir
      - find_file
      - search_for_pattern
      - replace_content
      - read_file
      - execute_shell_command
    included_optional_tools: []
    fixed_tools: []
    base_modes:
      - interactive
      - editing
    default_modes: []
    tool_timeout: 240
    default_max_tool_answer_chars: 150000
    symbol_info_budget: 10
    project_serena_folder_location: "$projectDir/.serena"
    trusted_project_path_patterns:
      - "${config.home.homeDirectory}/source/**"
    projects: []
  '';
in
{
  home.packages = [ serenaPackage ];

  programs.mcp.servers.serena = {
    enabled = true;
    command = lib.getExe serenaPackage;
    args = [
      "start-mcp-server"
      "--context"
      "ide"
      "--mode"
      "no-memories"
      "--project-from-cwd"
      "--open-web-dashboard"
      "false"
    ];
  };

  # Use Nix-managed Ansible tools.
  home.activation.serenaConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    config_dir="${config.home.homeDirectory}/.serena"
    target="$config_dir/serena_config.yml"
    projects='[]'
    if [ -r "$target" ]; then
      projects="$(${lib.getExe pkgs.yq} -r '.projects // [] | @json' "$target")"
    fi
    $DRY_RUN_CMD mkdir -p "$config_dir"
    if [ -z "''${DRY_RUN_CMD:-}" ]; then
      tmp="$(mktemp "$config_dir/serena_config.yml.XXXXXX")"
      trap 'rm -f -- "$tmp"' EXIT
      ${lib.getExe pkgs.yq} -y --argjson projects "$projects" \
        '.projects = $projects' ${serenaConfig} > "$tmp"
      install -m 600 "$tmp" "$target"
      rm -f -- "$tmp"
      trap - EXIT
    fi
  '';
}
