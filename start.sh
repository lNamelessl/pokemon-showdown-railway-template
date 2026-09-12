#!/bin/sh
# Railway mounts a single volume at /data (NOT /app/data: that would shadow
# Showdown's own game-data directory). The server's persistent dirs (logs/,
# config/) are symlinked into it; everything else lives in the image.
mkdir -p /data/logs /data/config

# Seed missing config files from the pristine copy baked into the image
# (cp -n never overwrites user edits, e.g. config.js or usergroups.csv).
cp -rn /app/config-dist/. /data/config/ 2>/dev/null || true
if [ ! -f /data/config/config.js ]; then
  cp /app/config-dist/config.js /data/config/config.js
fi

# Subdirectories the server expects on a fresh volume.
mkdir -p /data/logs/repl /data/logs/chat /data/logs/modlog \
         /data/logs/tickets /data/logs/battles /data/logs/users

# Replace the image's dirs with symlinks into the volume (idempotent).
ln -sfn /data/logs /app/logs
ln -sfn /data/config /app/config

# Railway assigns a dynamic port via $PORT; Showdown accepts the port as argv[1].
cd /app
exec node pokemon-showdown "${PORT:-8000}"
