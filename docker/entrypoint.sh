#!/bin/sh
# php artisan backup:run --only-db
php artisan migrate --force

/usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf