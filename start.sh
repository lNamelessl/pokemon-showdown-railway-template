#!/bin/sh
# Railway mounts a single volume at /app/data. The server's persistent dirs
# (logs/, config/) are symlinked into it; everything else lives in the image.
mkdir -p /app/data/logs /app/data/config

# Seed missing config files from the pristine copy baked into the image
# (cp -n never overwrites user edits, e.g. config.js or usergroups.csv).
cp -rn /app/config-dist/. /app/data/config/ 2>/dev/null || true
if [ ! -f /app/data/config/config.js ]; then
  cp /app/config-dist/config.js /app/data/config/config.js
fi

# Subdirectories the server expects on a fresh volume.
mkdir -p /app/data/logs/repl /app/data/logs/chat /app/data/logs/modlog \
         /app/data/logs/tickets /app/data/logs/battles /app/data/logs/users

# Replace the image's dirs with symlinks into the volume (idempotent).
ln -sfn /app/data/logs /app/logs
ln -sfn /app/data/config /app/config

# Railway assigns a dynamic port via $PORT; Showdown accepts the port as argv[1].
cd /app
exec node pokemon-showdown "${PORT:-8000}"
