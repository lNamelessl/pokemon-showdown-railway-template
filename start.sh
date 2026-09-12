#!/bin/sh
# First boot: seed config.js so the server has a real config file.
if [ ! -f config/config.js ]; then
  cp config/config-example.js config/config.js
fi
# Railway assigns a dynamic port via $PORT; Showdown accepts the port as argv[1].
# Anything persistent (logs/, config/) lives on the attached Railway volume.
exec node pokemon-showdown "${PORT:-8000}"
