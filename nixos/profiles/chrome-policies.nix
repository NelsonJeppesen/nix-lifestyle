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
  # Release the background browser process on close on the 8 GiB host.
  # Other hosts prioritize quick browser reactivation over idle RAM.
  lowSpec = config.networking.hostName == "lg-gram-14-2022";

  policies = {
    # ── Telemetry / privacy hardening ─────────────────────────────────
    MetricsReportingEnabled = false;
    SearchSuggestEnabled = false;
    UrlKeyedAnonymizedDataCollectionEnabled = false;
    SpellCheckServiceEnabled = false;
    AlternateErrorPagesEnabled = false;
    PromotionalTabsEnabled = false;
    BrowserAddPersonEnabled = false;
    BrowserGuestModeEnabled = false;
    PasswordManagerEnabled = false; # Password storage belongs to the extension.
    AutofillCreditCardEnabled = false;
    DefaultBrowserSettingEnabled = false;

    # Battery Saver, Memory Saver, background timer throttling, and network
    # prediction use Chrome's defaults rather than forced performance settings.

    # HTTP cache at the ceiling instead of Chrome's few-hundred-MB default.
    # Chrome policy integers are int32, so 2147483647 is the literal maximum;
    # the value is a hint and real on-disk usage lands in the same order.
    DiskCacheSize = 2147483647;

    # Keep Chrome's browser process resident after the last window closes, so
    # background extensions keep running and the next launch is a window open
    # rather than a cold start. Costs a few hundred MB at idle, so the
    # RAM-constrained gram still exits on last-window-close.
    BackgroundModeEnabled = !lowSpec;

    # ── Force-installed extensions ────────────────────────────────────
    # Format: "<extension-id>;<update-url>"
    ExtensionInstallForcelist = [
      # "dbepggeogbaibhgnhhndojpepiihcmeb;https://clients2.google.com/service/update2/crx" # Vimium
      # "hlepfoohegkhhmjieoechaddaejaokhf;https://clients2.google.com/service/update2/crx" # Refined GitHub
      "nngceckbapebfimnlniiiahkandclblb;https://clients2.google.com/service/update2/crx" # Bitwarden
      "eimadpbcbfnmbkopoojfekhnkhdbieeh;https://clients2.google.com/service/update2/crx" # Dark Reader

      # "aeblfdkhhhdcdjpifhhbdiojplfjncoa;https://clients2.google.com/service/update2/crx" # 1Password
      # "ddkjiahejlhfcafbddmgiahcphecmpfh;https://clients2.google.com/service/update2/crx" # uBlock Origin Lite
      # "edibdbjcniadpccecjdfdjjppcpchdlm;https://clients2.google.com/service/update2/crx" # I still don't care about cookies
      # "gebbhagfogifgggkldgodflihgfeippi;https://clients2.google.com/service/update2/crx" # Return YouTube Dislike
      # "mnjggcdmjocbbbhaepdhchncahnbgone;https://clients2.google.com/service/update2/crx" # SponsorBlock for YouTube
    ];
  };
in
{
  environment.etc."opt/chrome/policies/managed/policies.json".text = builtins.toJSON policies;
}
