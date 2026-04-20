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

Create a live URL from a file or folder. Stattic uses one project-first model:
create or resolve a project, create a publish session, upload only changed files,
finalize, then share the live project URL and, for claimed projects, the immutable
deployment URL.

## Fast path

```bash
npx @automattic/stattic-cli publish ./dist
```

This creates a project if needed, uploads changed files, finalizes the publish,
and prints the live URL plus the immutable deployment URL when available.

## Requirements

- Node.js 22+
- Optional environment variable: `$STATTIC_API_KEY`
- Optional credentials file: `~/.stattic/credentials`
- Local state file: `.stattic/state.json`

## Auth model

Without an API key, Stattic creates an anonymous project that expires in 24
hours. Anonymous project creation returns:

- `claimToken`
- `claimUrl`
- `expiresAt`

`claimToken` and `claimUrl` are returned only once on creation. Save them
immediately. The CLI stores them in `.stattic/state.json`. Claiming a project
immediately invalidates the claim token.

With an account API key, the project is created as a managed project and does
not need a claim link. Managed API keys are sent as
`Authorization: Bearer <token>`.

For agent follow-up work, use the returned `project.id` as the canonical
reference.

## Create a project

The direct API flow is:

1. `POST /v1/projects`
2. `POST /v1/projects/:projectId/deployments` with the desired file manifest
3. Upload each returned `uploads[]` instruction directly to staging storage
4. If a multipart upload is used, complete or abort it with:
   - `POST /v1/projects/:projectId/deployments/:deploymentId/uploads/multipart/complete`
   - `POST /v1/projects/:projectId/deployments/:deploymentId/uploads/multipart/abort`
5. If upload URLs expire, refresh them with:
   - `POST /v1/projects/:projectId/deployments/:deploymentId/uploads/refresh`
6. Finalize with:
   - `POST /v1/projects/:projectId/deployments/:deploymentId/finalize`

Finalize is asynchronous. Wait for the project operation to settle before
treating the new release as live.

## Update an existing project

```bash
npx @automattic/stattic-cli publish ./dist --project prj_123
```

Use the returned `project.id` for follow-up deploys, claim flows, and metadata
updates. Do not switch to slug or domain references when the project id is
already available.

For anonymous follow-up deploys, reuse the saved `claimToken`. Direct API
clients can send it with `X-Stattic-Claim-Token`. Managed API clients send
`Authorization: Bearer <token>`. After claim, token-based project access
stops working and organization-scoped routes require account auth.

The CLI loads credentials in this order:

1. `--api-key`
2. `$STATTIC_API_KEY`
3. `~/.stattic/credentials`
4. saved `claimToken` from `.stattic/state.json`

If the manifest includes `sha256`, unchanged files are skipped instead of
being uploaded again.

## Claim flow

For the normal human flow, share the returned `claimUrl`. The user opens it in
the dashboard, signs in with WordPress.com, and claims the project there.

Claim URLs are browser-only links, not API credentials.

Agents with an account API key can also claim directly with:

- `POST /v1/projects/claim`

The CLI wraps those flows with:

```bash
npx @automattic/stattic-cli claim --project prj_123 --organization acme --api-key <token>
```

## Project conventions

Stattic understands these publishing inputs during deployment creation or project setup:

- `_redirects`
- supported `_headers`
- nearest `404.html`
- `.stattic/config.json`

Use `.stattic/config.json` for project-level behavior such as:

- SPA mode
- viewer title
- viewer description
- OG image path

`_redirects` and `_headers` are compiled as deployment conventions.
`.stattic/config.json` is project configuration, not an uploaded runtime file.

## What to tell the user

- Always share the live URL from the current publish run.
- When available, also share the immutable deployment URL.
- If the publish is anonymous, tell the user it expires in 24 hours until claimed.
- Anonymous publishes do not expose deployment URLs until claimed.
- Share the `claimUrl` for anonymous publishes.
- Treat `.stattic/state.json` as local cache only, not the source of truth.
