{ pkgs, ... }: {
  dconf.settings = {
    "org/gnome/shell/extensions/bitcoin-markets" =
      let
        # Each indicator is a JSON blob in an array of strings. Defaults match
        # what the prefs dialog writes; format "{vN}" is N decimal places.
        mkIndicator =
          attrs:
          builtins.toJSON (
            {
              api = "bitstamp";
              attribute = "last";
              show_change = false;
              format = "{v0}";
            }
            // attrs
          );
      in
      {
        first-run = false; # Suppress the default indicator the extension seeds on first launch

        indicators = [
          (mkIndicator {
            base = "BTC";
            quote = "USD";
          })
          (mkIndicator {
            base = "ETH";
            quote = "BTC";
            format = "{v3}"; # Sub-1 pair, needs decimals to be readable
          })
          (mkIndicator {
            base = "ETH";
            quote = "USD";
            api = "coinbase";
          })
        ];
      };
  };

  programs.gnome-shell.extensions = [
    {
      package = pkgs.gnomeExtensions.bitcoin-markets;
    }
  ];
}
