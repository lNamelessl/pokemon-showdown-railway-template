#!/bin/sh
# The Railway volume mounts shadow /app/logs and /app/config. Seed any missing
# files from the pristine copy baked into the image (never overwrite user edits).
mkdir -p config logs
cp -rn /app/config-dist/. config/ 2>/dev/null || true
if [ ! -f config/config.js ]; then
  cp /app/config-dist/config.js config/config.js
fi
# The subdirectories the server expects must exist on a fresh volume.
mkdir -p logs/repl logs/chat logs/modlog logs/tickets logs/battles logs/users
# Railway assigns a dynamic port via $PORT; Showdown accepts the port as argv[1].
exec node pokemon-showdown "${PORT:-8000}"
