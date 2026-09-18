# chrome-policies.nix - Declarative Google Chrome managed policies
#
# Writes Chrome's enterprise policy file at /etc/opt/chrome/policies/managed/
# which Chrome reads on launch. This is the only path that works for
# declaratively installing extensions in proprietary Google Chrome
# (home-manager's `programs.google-chrome` does not support `extensions`).
#
# Verify after rebuild via chrome://policy
# Policy reference: https://chromeenterprise.google/policies/
{ config, ... }:
let
  # The 2022 gram is the RAM-constrained machine. Everywhere else has memory
  # and cores to burn, so the performance block below deliberately spends both
  # to keep the browser responsive.
  lowSpec = config.networking.hostName == "lg-gram-14-2022";

  policies = {
    # ── Telemetry / privacy hardening ─────────────────────────────────
    MetricsReportingEnabled = false;
    SearchSuggestEnabled = false;
    UrlKeyedAnonymizedDataCollectionEnabled = false;
    SpellCheckServiceEnabled = false;
    AlternateErrorPagesEnabled = false;
    # 0 = default (preload likely next pages on Wi-Fi/Ethernet) for snappier
    # navigation. Was 2 (never preload); relaxed deliberately, accepting the
    # minor prefetch-telemetry tradeoff in exchange for faster page loads.
    NetworkPredictionOptions = 0;
    BackgroundModeEnabled = false;
    PromotionalTabsEnabled = false;
    BrowserAddPersonEnabled = false;
    BrowserGuestModeEnabled = false;
    PasswordManagerEnabled = false; # using 1Password
    AutofillCreditCardEnabled = false;
    DefaultBrowserSettingEnabled = false;

    # ── Performance: spend RAM/CPU to stay fast ───────────────────────
    # Memory Saver discards idle background tabs, so coming back to one costs a
    # full reload. Off on machines with RAM to spare; still on for lowSpec.
    HighEfficiencyModeEnabled = lowSpec;
    # Only consulted when Memory Saver is on (i.e. lowSpec). 0 = moderate:
    # the longest idle period before a tab is discarded.
    MemorySaverModeSavings = 0;

    # 0 = Battery Saver disabled. It throttles the frame rate (and on ChromeOS
    # the CPU) once the battery runs low; keep full speed on battery instead.
    BatterySaverModeAvailability = 0;

    # Don't coalesce background-tab JS timers down to once a minute. Costs CPU,
    # but background chat/dashboard tabs stay live and don't stall on focus.
    IntensiveWakeUpThrottlingEnabled = false;

    # ~2 GB of HTTP cache instead of Chrome's few-hundred-MB default. Chrome
    # policy integers are int32, so this is close to the usable ceiling; the
    # value is a hint and real on-disk usage lands in the same order.
    DiskCacheSize = 2000000000;

    # ── Force-installed extensions ────────────────────────────────────
    # Format: "<extension-id>;<update-url>"
    ExtensionInstallForcelist = [
      # "dbepggeogbaibhgnhhndojpepiihcmeb;https://clients2.google.com/service/update2/crx" # Vimium
      # "hlepfoohegkhhmjieoechaddaejaokhf;https://clients2.google.com/service/update2/crx" # Refined GitHub
      "nngceckbapebfimnlniiiahkandclblb;https://clients2.google.com/service/update2/crx" # Bitwarden

      # "aeblfdkhhhdcdjpifhhbdiojplfjncoa;https://clients2.google.com/service/update2/crx" # 1Password
      # "ddkjiahejlhfcafbddmgiahcphecmpfh;https://clients2.google.com/service/update2/crx" # uBlock Origin Lite
      # "edibdbjcniadpccecjdfdjjppcpchdlm;https://clients2.google.com/service/update2/crx" # I still don't care about cookies
      # "eimadpbcbfnmbkopoojfekhnkhdbieeh;https://clients2.google.com/service/update2/crx" # Dark Reader
      # "gebbhagfogifgggkldgodflihgfeippi;https://clients2.google.com/service/update2/crx" # Return YouTube Dislike
      # "mnjggcdmjocbbbhaepdhchncahnbgone;https://clients2.google.com/service/update2/crx" # SponsorBlock for YouTube
    ];
  };
in
{
  environment.etc."opt/chrome/policies/managed/policies.json".text = builtins.toJSON policies;
}
