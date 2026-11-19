# User-layer dependency boundary. This flake intentionally pins nixpkgs
# independently of nixos/flake.nix; updates and rollback can differ by layer.
{
  description = "Home Manager configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    # Nix modules share this layer's package set to avoid duplicate evaluations.
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nvf = {
      url = "github:NotAShelf/nvf";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Source-only inputs are packaged/configured by the consuming feature module.
    # Exact revisions and integrity hashes are recorded in flake.lock.
    gitalias = {
      url = "github:GitAlias/gitalias";
      flake = false;
    };

    open-ralph-wiggum = {
      url = "github:Th0rgal/open-ralph-wiggum";
      flake = false;
    };

    pi-mcp-adapter = {
      url = "github:nicobailon/pi-mcp-adapter/v7.0.1";
      flake = false;
    };

    # npm release archives have matching offline dependency locks under ai/.
    openrig = {
      url = "https://registry.npmjs.org/@openrig/cli/-/cli-0.7.14.tgz";
      flake = false;
    };

    paperclip = {
      url = "https://registry.npmjs.org/paperclipai/-/paperclipai-2026.1106.0.tgz";
      flake = false;
    };

    workiq = {
      url = "https://registry.npmjs.org/@microsoft/workiq/-/workiq-1.0.1.tgz";
      flake = false;
    };

    agent-deck = {
      url = "github:asheshgoplani/agent-deck/v1.16.38";
      flake = false;
    };

    herdr-projects = {
      url = "github:eliasstravik/herdr-projects/v0.2.33";
      flake = false;
    };

    herdr-plus = {
      url = "github:cloudmanic/herdr-plus/v0.1.24";
      flake = false;
    };

    # The notification extension's review branch supplies its Nix package.
    gnome-github-notifications-redux = {
      url = "github:NelsonJeppesen/gnome-github-notifications-redux/review-01";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      nixpkgs,
      home-manager,
      nvf,
      agenix,
      gitalias,
      nix-index-database,
      gnome-github-notifications-redux,
      open-ralph-wiggum,
      pi-mcp-adapter,
      openrig,
      paperclip,
      workiq,
      agent-deck,
      herdr-projects,
      herdr-plus,
      ...
    }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        overlays = [
          (final: prev: {
            herdr = prev.herdr.overrideAttrs (o: {
              # Hide the expanded sidebar's Agents section: Spaces take the
              # full height and the drag divider between them goes away. No
              # config or plugin API can do this; the Agents header already
              # skips drawing into a zero-height area. Upstream's versions stay
              # alongside, unused, so a failed replace shows what moved.
              postPatch = (o.postPatch or "") + ''
                substituteInPlace src/ui/sidebar.rs \
                  --replace-fail \
                    'fn sidebar_section_heights(total_height: u16, split_ratio: f32) -> (u16, u16) {' \
                    'fn sidebar_section_heights(total_height: u16, _split_ratio: f32) -> (u16, u16) {
                    (total_height, 0)
                }

                #[allow(dead_code)]
                fn upstream_sidebar_section_heights(total_height: u16, split_ratio: f32) -> (u16, u16) {' \
                  --replace-fail \
                    'pub(crate) fn sidebar_section_divider_rect(area: Rect, split_ratio: f32) -> Rect {' \
                    'pub(crate) fn sidebar_section_divider_rect(_area: Rect, _split_ratio: f32) -> Rect {
                    Rect::default()
                }

                #[allow(dead_code)]
                fn upstream_sidebar_section_divider_rect(area: Rect, split_ratio: f32) -> Rect {'
              '';
            });
          })
        ];
      };
    in
    {
      # Single user configuration for "nelson"
      homeConfigurations."nelson" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;

        modules = [
          ./home.nix # User modules
          nvf.homeManagerModules.default # Neovim
          agenix.homeManagerModules.default # Secrets
          nix-index-database.homeModules.nix-index # Package index
        ];

        # Pass external sources explicitly; feature modules must not fetch
        # independent copies during evaluation.
        extraSpecialArgs = {
          inherit
            nvf
            agenix
            gitalias
            nix-index-database
            gnome-github-notifications-redux
            open-ralph-wiggum
            pi-mcp-adapter
            openrig
            paperclip
            workiq
            agent-deck
            herdr-projects
            herdr-plus
            ;
        };
      };
    };
}
