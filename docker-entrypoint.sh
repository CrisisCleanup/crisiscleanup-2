#!/bin/sh
set -e

# Workaround for issue where docker exits abruptly and leaves the pid file behind
if [ -f tmp/pids/server.pid ]; then
  rm tmp/pids/server.pid
fi

exec bundle exec "$@"