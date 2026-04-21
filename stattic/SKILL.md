---
name: stattic
description: >
  Publish files and folders to Stattic with anonymous-first deploys,
  browser-based claim links, managed deployments for claimed projects, and
  agent-friendly project updates. Use when asked to "publish this", "host
  this", "deploy this", "share this on the web", "upload this folder",
  "update this site", or "give me a live URL".
---

# Stattic

Create a live URL from any file or folder. Stattic uses one project-first
model: create or resolve a project, create a publish session, upload only
changed files, finalize, then share the live project URL and immutable
deployment URL when available.

To install or update (recommended): `npx skills add batuhan/stattic-skill --skill stattic -g -y`

If npm is not available, use: `curl -fsSL https://stattic.net/install.sh | bash`

## Requirements

- Optional environment variable: `$STATTIC_ACCESS_TOKEN`
- Optional auth file: `~/.stattic/auth.json`
- Local state file: `.stattic/state.json`

## Create a project

```bash
./scripts/publish.sh {file-or-dir}
```

Outputs the live URL for the current project. When the project is anonymous,
the publish also returns a claim URL and expiry time.

Without an access token this creates an anonymous project that expires in 24
hours. With a saved access token, the project is managed and does not need a
claim link.

## Update an existing project

```bash
./scripts/publish.sh {file-or-dir} --project {project-ref}
```

The wrapper auto-loads the saved `claimToken` from `.stattic/state.json`
when updating anonymous projects. Pass `--claim-token {token}` to override.

Use the returned `project.id` as the canonical reference for follow-up
publishes, claim flows, and metadata updates.

For anonymous follow-up deploys, reuse the saved `claimToken`. Direct API
clients can send it with `X-Stattic-Claim-Token`. Managed API clients send
`x-stattic-access-token: <token>`. After claim, token-based project access
stops working and organization-scoped routes require account auth.

## Client attribution

Pass `--client` so Stattic can track publish reliability by agent:

```bash
./scripts/publish.sh {file-or-dir} --client cursor
```

If omitted, the wrapper sends a default `skills.sh/publish-sh` client name.

## Access token storage

The publish wrapper and CLI read access tokens from these sources, in order:

1. `--access-token {token}`
2. `$STATTIC_ACCESS_TOKEN`
3. `~/.stattic/auth.json`

The CLI login flow writes `~/.stattic/auth.json` automatically:

```bash
npx @bi/stattic-cli login
```

Never commit credentials or local state files.

## State file

After every create or update, Stattic stores local project metadata in
`.stattic/state.json` in the working directory. That cache may include:

- `projectId`
- `claimToken`
- `claimUrl`
- `expiresAt`
- last live and immutable deployment URLs

Treat `.stattic/state.json` as local cache only. Never use it as the source
of truth for auth mode, expiry, or claim URLs when the current publish output
already provides those values.

## Project conventions

Stattic understands these publishing inputs during deployment creation or
project setup:

- `_redirects`
- supported `_headers`
- nearest `404.html`
- `.stattic/config.json`

Use `.stattic/config.json` for project-level behavior such as SPA mode,
viewer title, viewer description, and OG image path.

## Claim flow

For the normal human flow, share the returned `claimUrl`. The user opens it
in the dashboard, signs in with WordPress.com, and claims the project there.

Claim URLs are browser-only links, not API credentials.

Agents with an account access token can also claim directly with:

```bash
npx @bi/stattic-cli claim --project prj_123 --access-token <token>
```

If the account has exactly one organization, the CLI uses it automatically.
Otherwise pass `--organization`.

## What to tell the user

- Always share the live URL from the current publish run.
- Read and follow the `publish_result.*` lines from stderr.
- When `publish_result.auth_mode=authenticated`, tell the user the project is managed and does not expire.
- When `publish_result.auth_mode=anonymous`, tell the user it expires in 24 hours until claimed.
- Share the `claimUrl` whenever `publish_result.claim_url` is present.
- When available, also share the immutable deployment URL.
- Never tell the user to inspect `.stattic/state.json` for claim or auth details.

## Common options

| Flag | Description |
| ---- | ----------- |
| `--project {ref}` | Update an existing project by id, domain/URL, or slug |
| `--organization {slug}` | Required with bare slugs and multi-organization claim flows |
| `--access-token {token}` | Managed account access token override |
| `--claim-token {token}` | Override anonymous project access token |
| `--client {name}` | Agent attribution header value |
| `--api-url {url}` | API base override for local development |
