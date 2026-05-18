[![Release](https://img.shields.io/github/v/release/adminelix/mxsend-unraid-plugin?style=flat-square)](https://github.com/adminelix/mxsend-unraid-plugin/releases/latest)
[![CI](https://img.shields.io/github/actions/workflow/status/adminelix/mxsend-unraid-plugin/ci.yml?branch=main&style=flat-square)](https://github.com/adminelix/mxsend-unraid-plugin/actions)

# mxsend-unraid-plugin

> Unofficial Unraid plugin for Matrix notifications via [mxsend](https://github.com/adminelix/mxsend).

This plugin packages mxsend as an Unraid notification agent. Install it, configure your Matrix credentials in the Unraid WebUI, and receive system alerts directly in a Matrix room.

## Features

- **One-click install** — Paste a plugin URL into Unraid and you're done.
- **Full WebUI integration** — Configure sender, recipient, title, and E2EE recovery key from **Settings → Notification Settings**.
- **Encryption support** — Optional end-to-end encryption via Matrix recovery key.
- **Slackware package** — Ships as a proper `.txz` package via `upgradepkg` for clean install and removal.

## Installation

### Prerequisites

- Unraid 6.12.0 or later
- A Matrix account on any homeserver

### Via Plugin URL (recommended)

Paste this URL into **Plugins → Install Plugin** in the Unraid WebUI:

```
https://github.com/adminelix/mxsend-unraid-plugin/releases/latest/download/mxsend.plg
```

The plugin automatically downloads the required package from the latest GitHub release.

### Offline / Air-gapped

1. Download both files from the [latest release](https://github.com/adminelix/mxsend-unraid-plugin/releases/latest):
   - `mxsend.plg`
   - `mxsend-*.txz`
2. Copy them to your Unraid flash drive:
   ```bash
   scp mxsend.plg root@tower:/boot/config/plugins/mxsend/
   scp mxsend-*.txz root@tower:/boot/config/plugins/mxsend/
   ```
3. SSH into Unraid and install:
   ```bash
   plugin install /boot/config/plugins/mxsend/mxsend.plg
   ```

### Build from source

Requirements: `bash`, `tar`, `xz`, `curl`, `sha256sum` (or `shasum`)

```bash
git clone git@github.com:adminelix/mxsend-unraid-plugin.git
cd mxsend-unraid-plugin
make build
```

Output files land in `dist/`. Override the package version:

```bash
VERSION=2026.05.18 ./build.sh
```

## Configuration

### Notification agent settings

1. Go to **Settings → Notification Settings → Notification Agents**
2. Scroll to the **Mxsend** section
3. Fill in:

   | Field | Description | Default | Example |
   |-------|-------------|---------|---------|
   | Sender (From) | Full Matrix user ID | — | `@bot:matrix.server.org` |
   | Password | Account password | — | `s3cret` |
   | Recipient (To) | Room ID or user ID | — | `!abc123:matrix.server.org` |
   | Recovery Key | E2EE device recovery key (set to `none` to disable encryption) | `none` | |
   | Title | Fields for the message title | `$SUBJECT` | `$EVENT` |
   | Message | Fields for the message body | `$DESCRIPTION` | `$SUBJECT,$DESCRIPTION` |

   > **Warning:** Avoid `#` and `;` in the **Password** field — Unraid's INI-style config parser treats them as comment delimiters, causing all fields to appear blank after saving.

4. Set **Agent function** to **Enabled**
5. Click **Apply**, then **Test**

### Enabling notifications

In **Settings → Notification Settings**, check the **Agents** box for each importance level:
- **Alert** — critical events
- **Warning** — important events
- **Notice** — informational events

## Troubleshooting

### Password contains `#` or `;`

Unraid's config parser interprets these as comments. If you must use them, generate an app-specific password that avoids these characters, or use a password manager to create one.

### Agent not appearing in Notification Agents list

- Refresh the Unraid WebUI (Ctrl+F5)
- Verify the plugin installed successfully under **Plugins**
- Reinstall the plugin if the agent XML was not deployed

### Connection failures

- Verify the Matrix homeserver is reachable from your Unraid server
- Confirm credentials are correct via the **Test** button
- Check Unraid's system log (`/var/log/syslog`) for mxsend error output

### End-to-end encryption issues

If your Matrix server requires E2EE, the first message sent will attempt device verification. Set **Recovery Key** to the device recovery key from your Matrix client. Set it to `none` (or leave blank) to skip encryption.

## Uninstallation

Via **Plugins → mxsend → Remove**, or manually:

```bash
plugin remove mxsend
rm -rf /boot/config/plugins/mxsend
```

## Development

```bash
# Build the plugin
make build

# Lint shell scripts with shellcheck
make lint

# Clean build artifacts
make clean
```

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md).

## License

Licensed under either of

- Apache License, Version 2.0 ([LICENSE-APACHE](LICENSE-APACHE))
- MIT license ([LICENSE-MIT](LICENSE-MIT))

at your option.

Unless you explicitly state otherwise, any contribution intentionally
submitted for inclusion in the work by you shall be dual licensed as
above, without any additional terms or conditions.

This plugin packages [mxsend](https://github.com/adminelix/mxsend),
which is also dual-licensed Apache 2.0 / MIT.

## Project

- **Repository:** https://github.com/adminelix/mxsend-unraid-plugin
- **Releases:** https://github.com/adminelix/mxsend-unraid-plugin/releases
- **mxsend:** https://github.com/adminelix/mxsend
- **Release process:** See [RELEASE.md](RELEASE.md)
