---
name: stattic
description: Publish files, folders, and static sites to Stattic; update existing Stattic spaces; return live and immutable URLs; handle anonymous publish and claim links. Use when Codex is asked to publish, host, deploy, share on the web, upload a folder, update a Stattic space, inspect a Stattic version, or get a live URL.
---

# Stattic

Use the Stattic CLI to publish static files and folders to a space-backed live URL.
Use an existing `stattic` binary when one is already available, or install the
CLI through the documented Stattic setup path.

## Fast Path

Run:

```bash
stattic publish {file-or-dir}
```

Use `--json` when another tool or script needs to parse the result:

```bash
stattic publish {file-or-dir} --json
```

If `stattic` is unavailable but `$STATTIC_CLI_BIN` is set, run that binary instead.
The CLI package name is `stattic-cli` and the installed binary is `stattic`.

## What To Share

After publishing, report the useful URLs from the receipt:

- live space URL
- immutable version URL, when present
- claim link and expiry, when the publish created an anonymous space

Do not print access tokens, claim tokens, auth files, or the contents of `.stattic/state.json`.

## Space State

The first publish writes `.stattic/state.json` in the published directory. Keep it there. Publishing the same directory again updates the same space.

For a new target, publish from that target directory or pass the target path explicitly. Do not delete or rewrite `.stattic/state.json` unless the user explicitly wants a new space.

## Authentication

Prefer existing auth in this order:

1. `$STATTIC_TOKEN` or `--token`, when the user already provided one
2. saved CLI auth from `~/.stattic/auth.json`
3. `stattic login`, when an interactive browser login is appropriate
4. anonymous publish

Anonymous spaces can be published without login. Share the returned claim link so the user can keep the space permanently.

To claim a saved anonymous space:

```bash
stattic claim
```

Use `--team` only when the user gives a team or the local context makes the target team clear.

## Useful Commands

- `stattic init` creates `.stattic/config.json` without publishing.
- `stattic publish . --dry-run` checks the publish plan.
- `stattic inspect` shows the selected space's status and URLs.
- `stattic versions` lists versions and marks the live one.
- `stattic rollback {version}` makes an older ready version live without rebuilding; `stattic promote {version}` is the explicit equivalent.
- `stattic domains`, `stattic variables`, and `stattic password` manage claimed space settings.
- `stattic doctor` diagnoses local CLI setup.

## Space Files

Stattic recognizes these files in the published directory:

- `_redirects` for redirects, rewrites, custom 404 rules, and external `200` proxy rules
- `_headers` for supported response headers and Basic Auth
- nearest `404.html`
- `.stattic/config.json` for space metadata, mode, SPA behavior, and viewer metadata

Free spaces publish only HTML, CSS, JavaScript, images, and fonts. Other file types are ignored during upload and reported as warnings. Free applies only `Basic-Auth` from `_headers`; custom response headers require Plus.

Use `_redirects` for proxying:

```text
/api/* https://api.example.com/:splat 200
```

Do not create `.stattic/proxy.json`. Internal `200` destinations are rewrites; only absolute external URL destinations with status `200` are proxy rules.

## Product Rules

Use Stattic's user-facing nouns consistently:

- `space` is the main object.
- `publish` is the action; `deploy` is only an alias.
- `version` is an immutable snapshot.
- `domain` is user-facing; avoid `hostname` except for DNS diagnostics.
- `access token`, `claim token`, and `claim link` have distinct meanings.

Default to correctness over speed. A publish is complete only when the CLI returns successfully.

## References

- [Product model](../../docs/product.md)
- [Routing compatibility](../../docs/routing-compatibility.md)
- [CLI README](./README.md)
- [CLI publish command](./src/commands/publish.ts)
- [CLI init command](./src/commands/init.ts)
