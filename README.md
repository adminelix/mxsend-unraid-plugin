# mxsend — Unraid Notification Agent for Matrix

Send Unraid system notifications to a Matrix room via [mxsend](https://github.com/adminelix/mxsend).

## Installation

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

## Configuration

1. Go to **Settings → Notification Settings → Notification Agents**
2. Scroll to the **Mxsend** section
3. Fill in:

   | Field | Description | Example |
   |-------|-------------|---------|
   | Sender (From) | Full Matrix user ID | `@bot:matrix.server.org` |
   | Password | Account password. **Avoid `#` and `;`** — Unraid's config parser treats them as comment delimiters, causing all fields to appear blank after saving. | `s3cret` |
   | Recipient (To) | Room ID or user ID | `!abc123:matrix.server.org` |
   | Recovery Key | E2EE key (optional) | |
   | Title | Fields for the message title | `$EVENT` |
   | Message | Fields for the message body | `$SUBJECT,$DESCRIPTION` |

4. Set **Agent function** to **Enabled**
5. Click **Apply**, then **Test**

## Enabling Notifications

In **Settings → Notification Settings**, check the **Agents** box for each importance level:
- **Alert** — critical events
- **Warning** — important events
- **Notice** — informational events

## Uninstallation

Via **Plugins → mxsend → Remove**, or manually:

```bash
plugin remove mxsend
rm -rf /boot/config/plugins/mxsend
```

## Building from Source

Requirements: `bash`, `tar`, `xz`, `curl`, `sha256sum` (or `shasum`)

```bash
git clone git@github.com:adminelix/mxsend-unraid-plugin.git
cd mxsend-unraid-plugin
./build.sh
```

Output files land in `dist/`.

## Release Process

This project uses [conventional commits](https://www.conventionalcommits.org/) and
[git-cliff](https://github.com/orhun/git-cliff) for changelog generation.

To create a release:

```bash
# 1. Bump version in build.sh
# 2. Commit changes
git commit -m "chore: release v0.1.0"

# 3. Tag and push
git tag v0.1.0
git push origin main --tags

# 4. CI builds and creates a GitHub Release automatically
```

## License

This plugin bundles [mxsend](https://github.com/adminelix/mxsend) under its own license.
