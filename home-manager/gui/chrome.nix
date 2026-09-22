{ pkgs, lib, ... }:
let
  # Chromium feature flags. Chrome stores --enable-features in a switch map, so
  # a second copy of the switch would silently replace the first -- everything
  # has to go in this one list.
  chromeFeatures = lib.concatStringsSep "," [
    "VaapiVideoEncoder"
    "VaapiVideoDecoder"
    "WaylandWindowDecorations"

    # Back/forward cache: keep 10 whole pages alive instead of 6, and keep them
    # for 30 min instead of 10. A cached entry is a frozen renderer with its
    # heap intact, so Back is a restore rather than a refetch + reparse + relayout.
    # This is the single biggest RAM-for-latency trade in the browser.
    "BackForwardCacheSize:cache_size/10"
    "BackForwardCacheTimeToLiveControl:time_to_live_seconds/1800"

    # Background prefetch, widened. NetworkPredictionOptions=0 in
    # chrome-policies.nix already allows preloading on any connection; these
    # turn on the optional predictors that spend that budget:
    #   LoadingPredictorPrefetch  - prefetch subresources the predictor expects
    #                               from the navigation history of a site
    #   SearchPrefetchServicePrefetching - prefetch the omnibox's top search
    #                               suggestion before Enter is pressed
    #   PreconnectToSearch        - hold a warm socket open to the default
    #                               search engine
    "LoadingPredictorPrefetch"
    "SearchPrefetchServicePrefetching"
    "PreconnectToSearch"
  ];
in
{
  programs.google-chrome = {
    enable = true;
    package = pkgs.google-chrome;

    # Command-line flags (mirrors the battery/Wayland tuning in chrome-apps.nix,
    # minus the PWA-only switches like --app= and --user-data-dir=).
    commandLineArgs = [
      "--no-default-browser-check"
      "--password-store=basic" # don't prompt for kwallet/gnome-keyring

      # Wayland and GPU acceleration.
      "--ozone-platform=wayland"
      "--use-angle=gl"
      "--ignore-gpu-blocklist"
      "--enable-features=${chromeFeatures}"

      # Enable GPU rasterization and zero-copy.
      "--enable-gpu-rasterization"
      "--enable-zero-copy"

      # Keep background work at full speed rather than saving power. Pairs with
      # the IntensiveWakeUpThrottlingEnabled=false policy in chrome-policies.nix:
      # background tabs keep normal renderer priority and un-throttled timers,
      # so switching back to one is instant instead of janky.
      "--disable-backgrounding-occluded-windows"
      "--disable-renderer-backgrounding"
      "--disable-background-timer-throttling"
    ];

    # GNOME desktop, not Plasma
    plasmaSupport = false;
  };
}
