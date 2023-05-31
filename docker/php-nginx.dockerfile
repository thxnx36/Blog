



#FROM trafex/php-nginx as php-nginx-pre-vite-build

#USER root

# nginx config
#COPY ./docker/nginx/default.conf /etc/nginx/conf.d/default.conf

# install php extension
#RUN apk add --no-cache php81-zip php81-pdo php81-pdo_mysql php81-pdo_sqlite php81-gd php81-curl php81-fileinfo php81-mysqli php81-tokenizer php81-xmlwriter php81-exif php81-simplexml php81-iconv

# php config
#COPY ./docker/php/settings.ini /etc/php81/conf.d/settings.ini

# copy source code to image
#COPY ./ /var/www/html

# # composer 
#COPY --from=composer /usr/bin/composer /usr/bin/composer

#RUN composer install --optimize-autoloader --no-interaction --no-progress --no-dev


#FROM node:lts-alpine as vite-build

#WORKDIR /app

#COPY package*.json ./
#COPY postcss.config.js ./
#COPY vite.config.js ./
#COPY tailwind.config.js ./
#COPY --from=php-nginx-pre-vite-build /var/www/html/vendor ./vendor

#COPY /resources ./resources

#RUN npm install
#RUN npm run build


FROM trafex/php-nginx 

USER root

# nginx config
COPY ./docker/nginx/default.conf /etc/nginx/conf.d/default.conf

# install php extension
RUN apk add --no-cache php81-zip php81-pdo php81-pdo_mysql php81-pdo_sqlite php81-gd php81-curl php81-fileinfo php81-mysqli php81-tokenizer php81-xmlwriter php81-exif php81-simplexml php81-iconv

# php config
COPY ./docker/php/settings.ini /etc/php81/conf.d/settings.ini

# copy source code to image
COPY ./ /var/www/html

#COPY --from=vite-build /app/public/build /var/www/html/public/build

RUN chown -R nobody:nobody storage bootstrap/cache
RUN chmod -R ugo+rwx storage bootstrap/cache

# composer 
COPY --from=composer /usr/bin/composer /usr/bin/composer

RUN composer install --optimize-autoloader --no-interaction --no-progress --no-dev

# for mysqldumper
RUN apk add --no-cache mysql-client
# cron
ENV SUPERCRONIC_URL=https://github.com/aptible/supercronic/releases/download/v0.2.1/supercronic-linux-amd64 \
    SUPERCRONIC=supercronic-linux-amd64 \
    SUPERCRONIC_SHA1SUM=d7f4c0886eb85249ad05ed592902fa6865bb9d70

RUN curl -fsSLO "$SUPERCRONIC_URL" \
    && echo "${SUPERCRONIC_SHA1SUM}  ${SUPERCRONIC}" | sha1sum -c - \
    && chmod +x "$SUPERCRONIC" \
    && mv "$SUPERCRONIC" "/usr/local/bin/${SUPERCRONIC}" \
    && ln -s "/usr/local/bin/${SUPERCRONIC}" /usr/local/bin/supercronic

ADD ./docker/cron/crontab /etc/crontab

# Configure supervisord
COPY ./docker/supervisord/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]

COPY ./docker/entrypoint.sh /tmp
RUN chmod +x /tmp/entrypoint.sh
ENTRYPOINT ["/tmp/entrypoint.sh"]


USER nobody