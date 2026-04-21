# stattic-skill

Public skill repository for Stattic.

## Install

```bash
npx skills add batuhan/stattic-skill --skill stattic -g -y
```

If you want a curlable bootstrap instead:
review https://stattic.net/install.sh in a browser before running it locally.

## Publish

```bash
./stattic/scripts/publish.sh ./dist
```

Update an existing project:

```bash
./stattic/scripts/publish.sh ./dist --project my-project
```

## Repository layout

- `stattic/SKILL.md`: the installable skill entrypoint
- `stattic/scripts/publish.sh`: thin shell wrapper around the Stattic CLI
- `install.sh`: convenience installer for the `skills` CLI flow

This repository is generated from the Stattic monorepo. Edit the source there, not here.
