# Openclaw Configuration

Barebones flake-based setup for [nix-openclaw](https://github.com/openclaw/nix-openclaw) - a batteries-included Nix package for Openclaw (AI assistant gateway).

## What is Openclaw?

Openclaw is a self-hosted AI assistant that connects to Telegram/Discord and can control your computer. You message your bot, and your machine does things:

- Take screenshots
- Summarize web pages, PDFs, videos
- Control Spotify
- Transcribe voice notes
- Search the web
- And much more via plugins

## Important Note

**This setup uses Nix flakes**, which is separate from the main nix-lifestyle repo's legacy channel approach. This directory is a standalone flake-based configuration that you can use independently.

## Setup Instructions

### 1. Prerequisites

- **Determinate Nix** installed ([install guide](https://docs.determinate.systems/determinate-nix/))
- **Flakes enabled** (Determinate Nix enables this by default)
- **Home Manager** installed (see below if not installed)
- A Telegram account

#### Installing Home Manager (if needed)

If you don't have home-manager installed yet:

**Standalone installation (recommended for flake-based setup):**

```bash
nix run home-manager/master -- init --switch
```

This will:
1. Create `~/.config/home-manager/` with a basic `flake.nix` and `home.nix`
2. Install home-manager
3. Apply the initial configuration

**Verify installation:**
```bash
home-manager --version
```

For more details, see the [Home Manager manual](https://nix-community.github.io/home-manager/).

### 2. Configure the Flake

Edit `openclaw/flake.nix` and update the placeholders:

1. **System type** (line 14):
   - `x86_64-linux` for Linux
   - `aarch64-darwin` for Apple Silicon Mac
   - `x86_64-darwin` for Intel Mac

2. **Username and home directory** (lines 22-23):
   ```nix
   home.username = "youruser";  # Your actual username
   home.homeDirectory = "/home/youruser";  # Your home directory path
   ```

3. **Telegram user ID** (line 40):
   ```nix
   allowFrom = [
     12345678  # Your Telegram user ID
   ];
   ```

### 3. Create Required Directories

```bash
# Create secrets directory
mkdir -p ~/.secrets

# The documents directory already exists in openclaw/documents/
# with AGENTS.md, SOUL.md, and TOOLS.md pre-configured
```

### 4. Set Up Telegram Bot

1. **Create a bot**: Message [@BotFather](https://t.me/BotFather) on Telegram
   - Send `/newbot`
   - Follow prompts to name your bot
   - Save the bot token you receive

2. **Get your Telegram user ID**: Message [@userinfobot](https://t.me/userinfobot)
   - Note your user ID number

3. **Save the bot token**:
   ```bash
   echo "YOUR_BOT_TOKEN_HERE" > ~/.secrets/telegram-bot-token
   chmod 600 ~/.secrets/telegram-bot-token
   ```

### 5. Set Up API Keys

Openclaw needs an AI provider. The default is Anthropic (Claude):

```bash
# Add to your shell profile (~/.zshrc, ~/.bashrc, etc.)
export ANTHROPIC_API_KEY="your-anthropic-api-key"
export OPENCLAW_GATEWAY_TOKEN="your-secret-gateway-token"
```

Get an Anthropic API key from [Anthropic Console](https://console.anthropic.com/).

### 6. Apply Configuration

From the `openclaw` directory:

```bash
cd ~/path/to/nix-lifestyle/home-manager/openclaw
home-manager switch --flake .#youruser  # Replace 'youruser' with your username
```

### 7. Verify Setup

Check that the service is running:

**On Linux:**
```bash
systemctl --user status openclaw-gateway
journalctl --user -u openclaw-gateway -f
```

**On macOS:**
```bash
launchctl print gui/$UID/com.steipete.openclaw.gateway | grep state
tail -50 /tmp/openclaw/openclaw-gateway.log
```

### 8. Test Your Bot

Message your Telegram bot. On first contact, Openclaw will run a **bootstrap ritual** asking you questions like:
- "Who am I?"
- "What am I?"
- "Who are you?"

Answer these to teach your bot its identity and your relationship. After that, you're up and running!

## Configuration Options

### Enable More Plugins

Edit `openclaw/flake.nix` and modify the `programs.openclaw.firstParty` section:

```nix
programs.openclaw.firstParty = {
  summarize.enable = true;   # Summarize web pages, PDFs, videos
  peekaboo.enable = true;    # Take screenshots
  oracle.enable = true;      # Web search
  poltergeist.enable = true; # Control macOS UI (macOS only)
  sag.enable = true;         # Text-to-speech
};
```

### Add Community Plugins

```nix
programs.openclaw.plugins = [
  { source = "github:owner/repo-name"; }
];
```

### Manage Group Chats

Allow specific Telegram groups and configure mention requirements:

```nix
channels.telegram = {
  allowFrom = [
    12345678          # Your user ID (DM)
    -1001234567890    # Group 1
    -1002345678901    # Group 2
  ];
  groups = {
    "*" = { requireMention = true; };  # Default: require @mention
    "-1001234567890" = { requireMention = false; };  # No mention needed in this group
  };
};
```

## Troubleshooting

### Service Not Starting

Check logs:
```bash
# Linux
journalctl --user -u openclaw-gateway -f

# macOS
tail -50 /tmp/openclaw/openclaw-gateway.log
```

### Bot Not Responding

1. Verify bot token is correct
2. Check your Telegram user ID is in `allowFrom`
3. Ensure `ANTHROPIC_API_KEY` is set
4. Check service is running

### Rollback

If something breaks:
```bash
cd ~/path/to/nix-lifestyle/home-manager/openclaw
home-manager generations  # List previous generations
home-manager switch --rollback  # Revert to previous
```

## Standalone vs Main Repo

This openclaw setup is **intentionally separate** from the main nix-lifestyle configuration:

- **Main repo**: Uses legacy Nix channels (no flakes)
- **Openclaw**: Requires flakes (not compatible with legacy approach)

This means:
- You manage openclaw separately with `home-manager switch --flake ./openclaw#youruser`
- Changes to openclaw don't affect your main system config
- You can remove openclaw without touching the rest of your setup

## Further Reading

- [nix-openclaw GitHub](https://github.com/openclaw/nix-openclaw)
- [Openclaw Discord](https://discord.com/channels/1456350064065904867/1457003026412736537)
- [Plugin Development Guide](https://github.com/openclaw/nix-openclaw#for-plugin-developers)

## Philosophy

This setup follows the nix-lifestyle repo principles:

- **Declarative**: Everything defined in Nix
- **Reproducible**: Same config = same result
- **Rollbackable**: Easily undo changes
- **Minimal**: Only what's needed
- **Explicit**: No magic, clear dependencies
