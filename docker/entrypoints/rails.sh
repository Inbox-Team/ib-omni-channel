#!/bin/sh

set -x

# Remove a potentially pre-existing server.pid for Rails.
rm -rf /app/tmp/pids/server.pid
rm -rf /app/tmp/cache/*

echo "Waiting for postgres to become ready...."

# Let DATABASE_URL env take presedence over individual connection params.
# This is done to avoid printing the DATABASE_URL in the logs
$(docker/entrypoints/helpers/pg_database_url.rb)
PG_READY="pg_isready -h $POSTGRES_HOST -p $POSTGRES_PORT -U $POSTGRES_USERNAME"

until $PG_READY
do
  sleep 2;
done

echo "Database ready to accept connections."

#install missing gems for local dev as we are using base image compiled for production
bundle install

BUNDLE="bundle check"

until $BUNDLE
do
  sleep 2;
done

# Precompile assets on first start when not already built (e.g. production Docker image)
if [ -z "$SKIP_ASSETS_PRECOMPILE" ] && ! ls /app/public/assets/.sprockets-manifest-*.json 1>/dev/null 2>&1; then
  echo "Precompiling assets..."
  bundle exec rake assets:precompile
fi

# Execute the main process of the container
exec "$@"
