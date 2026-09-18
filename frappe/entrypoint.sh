#!/bin/bash
set -euo pipefail

: "${DB_HOST:?DB_HOST is required}"
: "${DB_ROOT_PASSWORD:?DB_ROOT_PASSWORD is required}"
: "${REDIS_URL:?REDIS_URL is required}"
: "${ADMIN_PASSWORD:?ADMIN_PASSWORD is required}"

SITE_NAME="${SITE_NAME:-frontend}"
DB_PORT="${DB_PORT:-3306}"
FRAPPE_APPS="${FRAPPE_APPS:-}"
BENCH=/home/frappe/frappe-bench
cd "$BENCH"

mkdir -p sites logs
chown -R frappe:frappe sites logs
rm -rf sites/assets
ln -s "$BENCH/assets" sites/assets

wait-for-it -t 180 "$DB_HOST:$DB_PORT"
redis_host="${REDIS_URL#*://}"
redis_host="${redis_host%%/*}"
wait-for-it -t 180 "$redis_host"

ls -1 apps > sites/apps.txt
if [ ! -f sites/common_site_config.json ]; then
  echo '{}' > sites/common_site_config.json
fi
chown frappe:frappe sites/apps.txt sites/common_site_config.json

runuser -u frappe -- bench set-config -g db_host "$DB_HOST"
runuser -u frappe -- bench set-config -gp db_port "$DB_PORT"
runuser -u frappe -- bench set-config -g redis_cache "$REDIS_URL"
runuser -u frappe -- bench set-config -g redis_queue "$REDIS_URL"
runuser -u frappe -- bench set-config -g redis_socketio "$REDIS_URL"
runuser -u frappe -- bench set-config -gp socketio_port 9000
runuser -u frappe -- bench set-config -g chromium_path /usr/bin/chromium-headless-shell

# App names derived from the <git-url>@<branch> list baked into FRAPPE_APPS.
app_names() {
  for app in $(echo "$FRAPPE_APPS" | tr ',' ' '); do
    name="${app%%@*}"
    name="${name##*/}"
    echo "${name%.git}"
  done
}

install_apps() {
  local app installed
  installed=$(runuser -u frappe -- bench --site "$SITE_NAME" list-apps 2>/dev/null || true)
  for app in $(app_names); do
    if echo "$installed" | grep -qx "$app"; then continue; fi
    runuser -u frappe -- bench --site "$SITE_NAME" install-app "$app"
  done
}

if [ ! -f "sites/$SITE_NAME/site_config.json" ]; then
  runuser -u frappe -- bench new-site "$SITE_NAME" \
    --mariadb-user-host-login-scope='%' \
    --admin-password "$ADMIN_PASSWORD" \
    --db-root-username root \
    --db-root-password "$DB_ROOT_PASSWORD" \
    --no-mariadb-socket
else
  runuser -u frappe -- bench --site "$SITE_NAME" migrate
fi
install_apps

runuser -u frappe -- bench --site "$SITE_NAME" clear-cache
runuser -u frappe -- bench --site "$SITE_NAME" clear-website-cache
runuser -u frappe -- bench use "$SITE_NAME"
exec /usr/bin/supervisord -c /etc/supervisor/supervisord.conf
