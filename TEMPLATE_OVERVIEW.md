# Pokemon Showdown on Railway

[![Deploy on Railway](https://railway.com/button.svg)](https://railway.com/deploy/pokemon-showdown-1)

Run your own **Pokemon Showdown battle server** — the open-source server behind pokemonshowdown.com — with one click. Custom formats and ladders, your own moderation team, your own chat rooms and tournaments, on your own URL.

This template provisions a single Dockerized service cloned from [smogon/pokemon-showdown](https://github.com/smogon/pokemon-showdown) at a **pinned commit** (see `UPSTREAM_PIN` in the repo), so deploys are reproducible and upgrades are deliberate:

- **Persistent storage** — a Railway volume mounted at `/data` holds `logs/` (battle logs, replays, chat logs, user stats) and `config/` (your `config.js`, `usergroups.csv`, custom CSS/JS). Everything survives redeploys and upgrades.
- **Zero configuration** — Railway assigns the port; the start script wires it through, seeds the config on first boot, and creates the directories the server expects. There are no deploy-form variables to fill in.
- **Modest footprint** — a small community server runs comfortably in ~256–512MB RAM, so Railway's low-cost Hobby tier is enough. 24/7 availability included.
- **Official client included** — the deployed domain redirects to the hosted Showdown client, which connects back to *your* server over WebSockets; players need zero setup.

## Become an admin (do this first!)

A server without admins can't be moderated, so this is the most important post-deploy step:

1. Open your server's client, open the **settings gear → Options → Register**, and register your username.
2. Add your username to `config/usergroups.csv` **on the volume**: one line, `YourName,~` — your username, a comma, a tilde, **no space** after the comma. Easiest way: `railway ssh -s <service>` and run `echo 'YourName,~' > /app/config/usergroups.csv` (writes through the symlink onto the volume). The config volume persists, so this only needs to happen once.
3. Restart the service, log back in — you are now `~` Administrator. Promote others in-game with `/globaladmin`, `/globalmod`, `/globaldriver`, `/roompromote`, etc.

## Upgrading Showdown

The upstream repo moves daily; this template pins a commit so your server never changes under you.

1. Get the latest commit SHA from https://github.com/smogon/pokemon-showdown/commits/master
2. Update `UPSTREAM_PIN` (and the `SHOWDOWN_COMMIT` ARG in the Dockerfile) in a commit and push — Railway redeploys.
3. User data, config, and battle logs live on the volume, so upgrades are drop-in.

# Deploy and Host
## About Hosting
Deploying this template creates one Railway service built from the public GitHub repo's Dockerfile (Node.js 22, per upstream's requirement) plus one persistent volume mounted at `/data`. Railway injects the `PORT` variable and generates a public domain automatically; the start script passes the port to Showdown (`node pokemon-showdown $PORT`), seeds `config/config.js` from the image's pristine copy on first boot, and symlinks `logs/` and `config/` into the volume. The first deployment passes a healthcheck against the server's root HTTP route before it is marked live. Running cost is a single low-memory service — typically the cheapest Hobby-tier plan — since Showdown is a lightweight Node.js server for small communities.
## Why Deploy
Self-hosting Showdown on Railway gives you a permanently online community battle server without renting or babysitting a VPS: redeploys don't lose battle logs or registered-staff config thanks to the volume, the pinned upstream commit means upgrades happen when *you* choose (bump one SHA), and the one-click flow avoids the setup mistakes that break manual installs — port wiring, missing log directories on fresh volumes, and config seeding. Unlike manual clones, the admin path (`usergroups.csv` → `~` Administrator → in-game promotion) is documented and verified end to end.
## Common Use Cases
- A friend group or community wants its own lobby with its own rules, staff, and tournaments instead of playing on the crowded official server.
- Hosting **custom formats and ladders** (edit `config/formats.js` on the volume) for side-server style play.
- Running moderated events: tournaments, tours, and chat rooms controlled by your own `~`/`@`/`%` staff promoted in-game.
- Development and testing of Showdown mods, bots, or client features against a private server you control.
## Dependencies for
### Deployment Dependencies
- **smogon/pokemon-showdown** — the upstream server, cloned at the commit pinned in `UPSTREAM_PIN` (MIT licensed).
- **Node.js 22** — upstream requires Node ≥ 22.18; baked into the Docker image.
- **Railway volume** — provisioned automatically, mounted at `/data` for all persistent state.
- No databases, no external services, and no deploy-form variables: authentication uses Showdown's official login server out of the box.
