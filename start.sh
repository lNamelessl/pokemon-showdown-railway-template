#!/bin/sh
# First boot: seed config.js so the server has a real config file.
if [ ! -f config/config.js ]; then
  cp config/config-example.js config/config.js
fi
# The Railway volume shadows /app/logs, so the subdirectories the server
# expects (normally shipped in the repo) must exist on first boot.
mkdir -p logs/repl logs/chat logs/modlog logs/tickets logs/battles logs/users
# Railway assigns a dynamic port via $PORT; Showdown accepts the port as argv[1].
# Anything persistent (logs/, config/) lives on the attached Railway volume.
exec node pokemon-showdown "${PORT:-8000}"
