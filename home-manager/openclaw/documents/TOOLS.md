# Available Tools

This document describes the tools currently enabled in your Openclaw setup.

## summarize
**Purpose**: Summarize web pages, PDFs, and YouTube videos

**Usage**: Ask me to summarize a URL or content
- "Summarize https://example.com"
- "Summarize this YouTube video: [link]"
- "Give me a summary of this PDF: [link]"

## peekaboo
**Purpose**: Take screenshots of your screen

**Usage**: Ask me to take a screenshot
- "Take a screenshot"
- "What's on my screen?"
- "Show me what's currently displayed"

---

## Adding More Tools

To enable additional tools, edit your `flake.nix` and set plugins to `enable = true`:

```nix
programs.openclaw.firstParty = {
  summarize.enable = true;
  peekaboo.enable = true;
  oracle.enable = true;      # Web search
  poltergeist.enable = true; # UI automation (macOS only)
  sag.enable = true;         # Text-to-speech
  camsnap.enable = true;     # Camera snapshots
  gogcli.enable = true;      # Google Calendar
  bird.enable = true;        # Twitter/X
  sonoscli.enable = true;    # Sonos control
  imsg.enable = true;        # iMessage (macOS only)
};
```

Then run `home-manager switch --flake .#youruser` to apply changes.
