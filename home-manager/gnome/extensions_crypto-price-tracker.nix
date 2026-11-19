# Show selected market pairs through the extension's CoinGecko backend.
{ pkgs, ... }: {
  dconf.settings = {
    "org/gnome/shell/extensions/crypto-tracker" =
      let
        # Coingecko rather than the Binance default: Binance's API refuses US
        # traffic. Coingecko is queried by coin id, not ticker; the id field
        # is any stable string (the extension generates one if missing and
        # writes it back, which would fight the managed value).
        mkCoin =
          {
            symbol,
            coingecko_id,
          }:
          {
            id = symbol;
            inherit symbol coingecko_id;
            active = true; # Show in the top bar, not just the dropdown
            title = "";
            exchange = "Coingecko";
          };
      in
      {
        exchange = "Coingecko";
        # The whole coin list is one JSON string (schema type "s")
        coins = builtins.toJSON {
          coins = [
            (mkCoin {
              symbol = "BTC/USD";
              coingecko_id = "bitcoin";
            })
            (mkCoin {
              symbol = "ETH/BTC";
              coingecko_id = "ethereum";
            })
            (mkCoin {
              symbol = "ETH/USD";
              coingecko_id = "ethereum";
            })
          ];
        };
      };
  };

  programs.gnome-shell.extensions = [
    {
      package = pkgs.gnomeExtensions.crypto-price-tracker;
    }
  ];
}
