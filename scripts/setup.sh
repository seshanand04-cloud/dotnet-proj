#!/bin/sh

echo "⏳ Waiting for WordPress files to be ready..."
max_wait=120
waited=0
while [ ! -f /var/www/html/wp-load.php ]; do
  sleep 3
  waited=$((waited + 3))
  echo "   Still waiting... (${waited}s)"
  if [ $waited -ge $max_wait ]; then
    echo "❌ Timed out waiting for WordPress files."
    exit 1
  fi
done
echo "✅ WordPress files found!"

echo "⏳ Waiting for database to be fully ready..."
sleep 8

# Check if WordPress is already installed
if php -d memory_limit=512M /usr/local/bin/wp core is-installed --path=/var/www/html --allow-root 2>/dev/null; then
  echo "✅ WordPress already installed — skipping."
  exit 0
fi

# If seed.sql exists, import it instead of running fresh install
if [ -f /seed.sql ]; then
  echo "📦 Importing seed database..."
  mysql --skip-ssl -h "${WORDPRESS_DB_HOST%%:*}" -u "${WORDPRESS_DB_USER}" -p"${WORDPRESS_DB_PASSWORD}" "${WORDPRESS_DB_NAME}" < /seed.sql
  echo "✅ Database imported from seed.sql!"
else
  echo "🚀 Installing WordPress automatically..."
  php -d memory_limit=512M /usr/local/bin/wp core install \
    --path=/var/www/html \
    --url="${WP_SITE_URL}" \
    --title="${WP_SITE_TITLE}" \
    --admin_user="${WP_ADMIN_USER}" \
    --admin_password="${WP_ADMIN_PASSWORD}" \
    --admin_email="${WP_ADMIN_EMAIL}" \
    --skip-email \
    --allow-root
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ WordPress is ready!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🌐 Site URL   : ${WP_SITE_URL}"
echo "👤 Admin User : ${WP_ADMIN_USER}"
echo "🔑 Password   : ${WP_ADMIN_PASSWORD}"
echo "📧 Email      : ${WP_ADMIN_EMAIL}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"