{ pkgs, lib, ... }: {
  programs.gnome-shell.extensions = [
    {
      package = pkgs.gnomeExtensions.blur-my-shell;
    }
  ];

  dconf.settings = {
    "org/gnome/shell/extensions/blur-my-shell" =
      let
        g = lib.hm.gvariant;
        # An a{sv} attribute dict: list of dictionary entries, value side variant-wrapped.
        mkAsv =
          attrs:
          g.mkArray
            (g.type.dictionaryEntryOf [
              g.type.string
              g.type.variant
            ])
            (
              lib.mapAttrsToList (
                k: v:
                g.mkDictionaryEntry [
                  k
                  (g.mkVariant v)
                ]
              ) attrs
            );
        # A single effect entry: a{sv} dict with type/id/params keys.
        mkEffect =
          {
            type,
            id,
            params,
          }:
          mkAsv {
            inherit type id;
            params = mkAsv params;
          };
        # A pipeline: a{sv} dict with name + effects (av).
        mkPipeline =
          { name, effects }:
          mkAsv {
            inherit name;
            effects = g.mkArray g.type.variant (map (e: g.mkVariant (mkEffect e)) effects);
          };
        # Outer a{sa{sv}}: list of dict entries keyed by pipeline id, value is the pipeline a{sv}.
        pipelinesValue =
          g.mkArray
            (g.type.dictionaryEntryOf [
              g.type.string
              (g.type.arrayOf (
                g.type.dictionaryEntryOf [
                  g.type.string
                  g.type.variant
                ]
              ))
            ])
            (
              lib.mapAttrsToList
                (
                  k: v:
                  g.mkDictionaryEntry [
                    k
                    (mkPipeline v)
                  ]
                )
                {
                  pipeline_default = {
                    name = "Default";
                    effects = [
                      {
                        type = "native_static_gaussian_blur";
                        id = "effect_000000000000";
                        params = {
                          radius = 30;
                          brightness = g.mkDouble 0.6;
                        };
                      }
                    ];
                  };
                  pipeline_default_rounded = {
                    name = "Default rounded";
                    effects = [
                      {
                        type = "native_static_gaussian_blur";
                        id = "effect_000000000001";
                        params = {
                          radius = 30;
                          brightness = g.mkDouble 0.6;
                        };
                      }
                      {
                        type = "corner";
                        id = "effect_000000000002";
                        params = {
                          radius = 24;
                        };
                      }
                    ];
                  };
                  # Disable lock-screen blur.
                  pipeline_03754227297483 = {
                    name = "nothing";
                    effects = [ ];
                  };
                }
            );
      in
      {
        settings-version = 2;
        pipelines = pipelinesValue;
      };

    "org/gnome/shell/extensions/blur-my-shell/lockscreen" = {
      blur = true;
      pipeline = "pipeline_03754227297483";
    };

    "org/gnome/shell/extensions/blur-my-shell/panel".blur = false;

    "org/gnome/shell/extensions/blur-my-shell/overview".blur = false;

    "org/gnome/shell/extensions/blur-my-shell/dash-to-dock".blur = false;

    "org/gnome/shell/extensions/blur-my-shell/screenshot".blur = false;

    "org/gnome/shell/extensions/blur-my-shell/window-list".blur = false;

    "org/gnome/shell/extensions/blur-my-shell/coverflow-alt-tab".blur = false;
  };
}
