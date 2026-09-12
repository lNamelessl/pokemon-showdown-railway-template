# Pokemon Showdown Server on Railway

[![Deploy on Railway](https://railway.com/button.svg)](https://railway.com/deploy/pokemon-showdown-1)

Run your own [Pokemon Showdown](https://github.com/smogon/pokemon-showdown) battle server — the open-source server behind pokemonshowdown.com — with one click. Custom ladders and formats, your own moderation team, your own chat rooms, on your own Railway URL.

- **Pinned upstream**: cloned at a fixed commit (`UPSTREAM_PIN`), so deploys are reproducible.
- **Persistent**: `logs/` (battle logs/replays, chat logs, user stats) and `config/` (your config, `usergroups.csv`, custom CSS/JS) live on a Railway volume and survive redeploys.
- **Modest footprint**: a small community server runs comfortably in ~256–512MB RAM — Railway's low Hobby tier is enough.

## Deploy

1. Click the button and deploy — Railway attaches a **volume** mounted at `/data`. The start script symlinks Showdown's persistent directories (`logs/` for battle logs/replays/chat logs, `config/` for your config, `usergroups.csv`, custom CSS/JS) into it, so everything survives redeploys.
2. Railway injects `PORT`; the start script passes it to Showdown (`node pokemon-showdown $PORT`). No manual port wiring needed.
3. When the deployment is live, open your public domain — you'll be redirected to `https://<yourserver>.insecure.psim.us`, the hosted Showdown client, which connects back to your server over WebSockets. This is expected: the client UI is served by Showdown's public client host, but battles run on *your* server.

> If you want the client served from your own domain with HTTPS, that requires an SSL cert per the upstream docs — out of scope for this template.

## Become an admin (do this first!)

A server without admins can't be moderated, so this is the most important post-deploy step:

1. Open your server's client, open the **settings gear → Register**, and register your username (registration uses Showdown's official login server).
2. Add your username to `config/usergroups.csv` **on the volume**. The file needs exactly one line — your username, a comma, a tilde, no spaces:

   ```
   YourName,~
   ```

   Easiest way: `railway ssh -s <service>` and run `echo 'YourName,~' > /app/config/usergroups.csv` (from your machine with the Railway CLI), or use the file editor in any other way you have. The config volume persists, so this only needs to happen once.
3. Reconnect (or wait for the config watcher to pick it up) and use `>>` console or relogin — you are now `~` Administrator. Promote others with `/globaladmin`, `/globalmod`, `/globaldriver`, `/roompromote`, etc.

## Upgrading Showdown

The upstream repo moves daily; this template pins a commit so your server never changes under you.

1. Get the latest commit SHA from https://github.com/smogon/pokemon-showdown/commits/master
2. Update `UPSTREAM_PIN` (and the Dockerfile `ARG` default) in a commit and push — Railway redeploys.
3. User data, config, and battle logs are on volumes, so upgrades are drop-in.

## Troubleshooting

| Symptom | Fix |
| --- | --- |
| Deployment healthcheck fails | Railway probes `/` on the assigned `PORT`. Make sure you didn't override `PORT`; Showdown listens on it via the start script. |
| Client says "connection lost" / wrong server | The `PORT` variable must be the one Railway exposes on your public domain — don't hardcode 8000. |
| Battle logs / replays vanish after redeploy | The volume isn't mounted at `/data` (the start script symlinks `logs/` and `config/` into it). Re-attach and redeploy. |
| `usergroups.csv` ignored | No space after the comma (`YourName,~`), and the username must be registered first. |
| Build fails on Node version | Upstream requires Node ≥ 22.18; the Dockerfile pins `node:22-slim`. Bump the base image if upstream moves past 22. |
| Wrong server name shown | Edit `config/config.js` (server name) on the volume; it hot-reloads (`watchconfig`). |

## Repository layout

- `Dockerfile` — builds upstream at the pinned commit (`npm install` + `node build` in a builder stage, slim runtime).
- `start.sh` — seeds `config/config.js` on first boot, execs Showdown on `$PORT`.
- `railway.json` — Dockerfile builder, healthcheck path, restart policy.
- `UPSTREAM_PIN` — the pinned upstream commit; bump to upgrade.

Code is MIT (upstream smogon/pokemon-showdown). This template repo only packages it.
