# Release Process

## Prerequisites

- Maintainer access to push protected `v*` tags.
- [Conventional commits](https://www.conventionalcommits.org/) on `main` (required by `git-cliff` for changelog generation).
- [git-cliff](https://git-cliff.github.io/) installed locally.

## Where to set versions

Three version variables in `build.sh`:

| Variable | Line | Description | Example |
|----------|------|-------------|---------|
| `VERSION` | 15 | Plugin version (date-based, `YYYY.MM.DD`) | `2026.05.18` |
| `BUILD` | 17 | Slackware package build number (bump when repackaging same version) | `2` |
| `MXSEND_VERSION` | 21 | Bundled mxsend binary tag | `v0.1.1` |

All three can be overridden via environment variables:

```bash
VERSION=2026.05.18 BUILD=2 MXSEND_VERSION=v0.1.1 ./build.sh
```

## Steps

### 1. Create a release branch

Branch from `main`:

```bash
git checkout main && git pull
git checkout -b release/v<VERSION>
```

### 2. Bump versions

Update `VERSION`, `BUILD`, and `MXSEND_VERSION` in `build.sh`. Remove any `.0-beta.N` suffix from `VERSION` for a stable release.

Commit the version bump — the changelog step needs this commit to exist so the new section includes it:

```bash
git add build.sh
git commit -m "chore: prepare v<VERSION>"
```

### 3. Update changelog

Prepend the new version section to `CHANGELOG.md`:

```bash
git cliff --unreleased --tag v<VERSION> --prepend
```

This renders the section for all commits since the last tag (version header, date, grouped commits) and inserts it below the existing `# Changelog` header without duplicating it. Review the diff before continuing.

Fold the changelog into the prepare commit:

```bash
git add CHANGELOG.md
git commit --amend --no-edit
```

> **Note:** Do not use `git cliff --bump -o CHANGELOG.md`. `--bump` computes the next version by semver-bumping the previous tag, which is incompatible with the date-based versioning scheme: the semver crate rejects both the `v` tag prefix and leading zeros (any month or day 01–09), and even when a tag happens to parse, a semver patch bump is not today's date. It also truncates `CHANGELOG.md` before failing — restore it with `git restore CHANGELOG.md` if that happens.

### 4. Tag and push

Create the tag on the release branch and push both branch and tag:

```bash
git tag v<VERSION>
git push origin release/v<VERSION>
git push origin v<VERSION>
```

### 5. CI creates a pre-release

The tag push triggers the pipeline (`.github/workflows/ci.yml`):

1. **check** — shellcheck and source structure validation
2. **build** — creates `.plg` + `.txz` artifacts
3. **release** — runs `git-cliff --latest` to extract release notes, then creates a **GitHub Pre-release** with assets attached

All tag-pushed releases start as pre-releases, regardless of tag name.

### 6. Open a pull request

Open a PR from `release/v<VERSION>` to `main`. The PR contains the version bump and changelog update. Use the pre-release page on GitHub to verify the generated release notes and attached artifacts.

### 7. Review

- Review the PR diff (version bump, changelog entries).
- Review the pre-release page (release notes formatting, artifacts).

### 8. Merge

Merge the PR to `main`. The tag remains on the release branch commit — it is an ancestor of `main` through the merge and stays valid.

### 9. Publish the release

1. Go to [Releases](https://github.com/adminelix/mxsend-unraid-plugin/releases).
2. Find the pre-release, click **Edit**.
3. Click **Publish release** to promote it to a full release.

### 10. Clean up

Delete the release branch:

```bash
git branch -d release/v<VERSION>
git push origin --delete release/v<VERSION>
```

## Notes

- **Versioning**: This project uses date-based versioning (`YYYY.MM.DD` for stable, `YYYY.MM.DD.0-beta.N` for pre-releases). The `.0` before the `-beta.N` suffix is required so PHP's `version_compare` correctly identifies the stable release as newer than its pre-release candidates.
- **Beta / pre-release tags**: Tags like `v2026.05.18.0-beta.1` are ignored by `git-cliff` — the `tag_pattern` in `cliff.toml` only matches stable versions (`vYYYY.MM.DD`), so they don't appear in the changelog. A beta tag push still triggers the CI pipeline and creates a pre-release.
- **Install URLs**: The PLG embeds `releases/latest/download/` as the `pluginURL`, but `releases/download/v{VERSION}/` for the TXZ — don't confuse them.
- **macOS builds**: `build.sh` uses `tar -cJf` with `--exclude='.DS_Store'`; the `--owner`/`--group` flags don't work on BSD tar — omit them if running locally.
- **Changelog**: Maintained in `CHANGELOG.md` using the [Keep a Changelog](https://keepachangelog.com/en/1.1.0/) format, auto-generated via [`git-cliff`](https://git-cliff.github.io/). Do not edit manually.
