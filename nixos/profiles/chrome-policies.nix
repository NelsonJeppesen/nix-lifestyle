# chrome-policies.nix - Declarative Google Chrome managed policies
#
# Writes Chrome's enterprise policy file at /etc/opt/chrome/policies/managed/
# which Chrome reads on launch. This is the only path that works for
# declaratively installing extensions in proprietary Google Chrome
# (home-manager's `programs.google-chrome` does not support `extensions`).
#
# Verify after rebuild via chrome://policy
# Policy reference: https://chromeenterprise.google/policies/
{ ... }:
let
  policies = {
    # ── Telemetry / privacy hardening ─────────────────────────────────
    MetricsReportingEnabled = false;
    SearchSuggestEnabled = false;
    UrlKeyedAnonymizedDataCollectionEnabled = false;
    SpellCheckServiceEnabled = false;
    AlternateErrorPagesEnabled = false;
    NetworkPredictionOptions = 2; # 2 = never preload
    BackgroundModeEnabled = false;
    PromotionalTabsEnabled = false;
    BrowserAddPersonEnabled = false;
    BrowserGuestModeEnabled = false;
    PasswordManagerEnabled = false; # using 1Password
    AutofillCreditCardEnabled = false;
    DefaultBrowserSettingEnabled = false;

    # ── Force-installed extensions ────────────────────────────────────
    # Format: "<extension-id>;<update-url>"
    ExtensionInstallForcelist = [
      "dbepggeogbaibhgnhhndojpepiihcmeb;https://clients2.google.com/service/update2/crx" # Vimium
      "hlepfoohegkhhmjieoechaddaejaokhf;https://clients2.google.com/service/update2/crx" # Refined GitHub
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
