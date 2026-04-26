---
name: stattic
description: Publish files, folders, and static sites to Stattic; update existing Stattic projects; return live and immutable URLs; handle anonymous publish and claim links. Use when Codex is asked to publish, host, deploy, share on the web, upload a folder, update a Stattic project, inspect a Stattic deployment, or get a live URL.
---

# Stattic

Use the Stattic CLI to publish static files and folders to a project-backed live URL.

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

## What To Share

After publishing, report the useful URLs from the receipt:

- live project URL
- immutable deployment URL, when present
- claim link and expiry, when the publish created an anonymous project

Do not print access tokens, claim tokens, auth files, or the contents of `.stattic/state.json`.

## Project State

The first publish writes `.stattic/state.json` in the published directory. Keep it there. Publishing the same directory again updates the same project.

For a new target, publish from that target directory or pass the target path explicitly. Do not delete or rewrite `.stattic/state.json` unless the user explicitly wants a new project.

## Authentication

Prefer existing auth in this order:

1. `stattic login`
2. `$STATTIC_TOKEN`
3. saved CLI auth
4. anonymous publish

Anonymous projects can be published without sign-in. Share the returned claim link so the user can keep the project permanently.

To claim a saved anonymous project:

```bash
stattic claim
```

Use `--organization` only when the user gives an organization or the local context makes the target organization clear.

## Useful Commands

- `stattic init` creates `.stattic/config.json` without publishing.
- `stattic publish . --dry-run` checks the publish plan.
- `stattic inspect` shows the selected project's status and URLs.
- `stattic deployments` lists deployments and marks the live one.
- `stattic domains`, `stattic variables`, and `stattic password` manage claimed project settings.
- `stattic doctor` diagnoses local CLI setup.

## Project Files

Stattic recognizes these files in the published directory:

- `_redirects` for redirects, rewrites, custom 404 rules, and external `200` proxy rules
- `_headers` for supported response headers and Basic Auth
- nearest `404.html`
- `.stattic/config.json` for project metadata, mode, SPA behavior, and viewer metadata

Use `_redirects` for proxying:

```text
/api/* https://api.example.com/:splat 200
```

Do not create `.stattic/proxy.json`. Internal `200` destinations are rewrites; only absolute external URL destinations with status `200` are proxy rules.

## Product Rules

Use Stattic's user-facing nouns consistently:

- `project` is the main object.
- `publish` is the action; `deploy` is only an alias.
- `deployment` is an immutable snapshot.
- `domain` is user-facing; avoid `hostname` except for DNS diagnostics.
- `access token`, `claim token`, and `claim link` have distinct meanings.

Default to correctness over speed. A publish is complete only when the CLI returns successfully.

## References

- [Product model](../../docs/product.md)
- [Routing compatibility](../../docs/routing-compatibility.md)
- [CLI README](./README.md)
- [CLI publish command](./src/commands/publish.ts)
- [CLI init command](./src/commands/init.ts)
