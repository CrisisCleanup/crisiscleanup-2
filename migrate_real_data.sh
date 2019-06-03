#!/usr/bin/env bash

docker-compose exec web bash -c 'bin/rake db:create'
docker cp ./dev.dump crisiscleanup_postgres_1:/tmp
docker-compose exec postgres bash -c 'pg_restore --verbose --clean --no-acl --no-owner -h localhost -U postgres -d postgres /tmp/dev.dump'