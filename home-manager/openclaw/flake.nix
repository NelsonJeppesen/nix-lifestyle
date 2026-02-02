{
  description = "Openclaw - barebones nix-openclaw setup";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nix-openclaw.url = "github:openclaw/nix-openclaw";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nix-openclaw, home-manager, ... }:
    let
      system = "x86_64-linux"; # Change to "aarch64-darwin" for Apple Silicon or "x86_64-darwin" for Intel Mac
      pkgs = import nixpkgs { inherit system; };
    in
    {
      homeConfigurations = {
        # Replace "youruser" with your username
        youruser = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;

          modules = [
            nix-openclaw.homeManagerModules.default

            {
              home.username = "openclaw"; # REPLACE with your username
              home.homeDirectory = "/home/openclaw"; # REPLACE with your home directory

              home.stateVersion = "25.11"; # Match your NixOS/Home Manager version

              programs.openclaw = {
                enable = true;

                # Documents directory (AGENTS.md, SOUL.md, TOOLS.md)
                documents = ./documents;

                config = {
                  gateway = {
                    mode = "local";
                    auth = {
                      # Set OPENCLAW_GATEWAY_TOKEN environment variable
                      # or uncomment and add token here:
                      # token = "your-gateway-token-here";
                    };
                  };

                  channels.telegram = {
                    # Path to file containing Telegram bot token (from @BotFather)
                    tokenFile = "${builtins.getEnv "HOME"}/.secrets/telegram-bot-token";

                    # Your Telegram user ID (from @userinfobot)
                    allowFrom = [
                      # 12345678  # REPLACE with your Telegram user ID
                    ];
                  };
                };

                # Enable some basic plugins
                firstParty = {
                  summarize.enable = true;  # Summarize web pages, PDFs, videos
                  peekaboo.enable = true;   # Take screenshots
                };
              };
            }
          ];
        };
      };
    };
}
