#!/bin/bash
# deploy.sh ? Hugo ???????bash / WSL?
# ???./deploy.sh

set -e

SERVER="root@47.107.56.48"
REMOTE_PATH="/var/www/blog"

echo "=== 1. ????? ==="
rm -rf public/

echo "=== 2. Hugo ?? ==="
hugo --minify --buildFuture
echo "???? ? public/"

echo "=== 3. ?????? ==="
rsync -avz --delete public/ "${SERVER}:${REMOTE_PATH}/"

echo "=== 4. ???? ==="
ssh "${SERVER}" "chown -R www-data:www-data ${REMOTE_PATH}"

echo ""
echo "? ?????"
echo "http://$([ -z "$DOMAIN" ] && echo "47.107.56.48" || echo "$DOMAIN")"
