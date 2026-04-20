# stattic-skill

Public skill repository for Stattic.

## Install

```bash
npx skills add batuhan/stattic-skill --skill stattic -g
```

If you want a curlable bootstrap instead:

```bash
curl -fsSL https://stattic.net/install.sh | bash
```

## Repository layout

- `stattic/SKILL.md`: the installable skill entrypoint
- `stattic/scripts/publish.sh`: thin shell wrapper around the Stattic CLI
- `install.sh`: convenience installer for the `skills` CLI flow

This repository is generated from the Stattic monorepo. Edit the source there, not here.
