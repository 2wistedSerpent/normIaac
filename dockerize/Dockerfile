FROM aptible/php:7.1
WORKDIR /app

# begin worker only
#RUN apt-install --no-install-recommends supervisor
#COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
# end worker only

ADD composer.json /app/
# we don't need composer.lock since composer install will create it
RUN composer install --no-ansi --no-interaction --no-scripts --no-autoloader

ADD . /app
RUN composer install --no-ansi --no-interaction

RUN mkdir -p /app/storage/app/incoming /app/public /app/bootstrap/cache
RUN chmod -R 774 /app/storage
#RUN mkdir -p /app/bootstrap/cache

COPY redirect-laravel-logs /usr/local/bin/
RUN chmod +x /usr/local/bin/redirect-laravel-logs

# begin web only
RUN chown -R www-data:www-data /app/storage /app/bootstrap/cache
RUN rm -rf /var/www/html && ln -s /app/public /var/www/html
RUN ln -s /etc/apache2/mods-available/headers.load /etc/apache2/mods-enabled/headers.load
COPY headers.conf /etc/apache2/mods-enabled/
# end web only
RUN apt-get -y update && apt-get -y upgrade
RUN apt-get -y install openssh-client software-properties-common wget apt-transport-https vim-tiny

# increase max size of uploaded files to 25M for dna files
ADD php-overrides.ini /opt/php/lib/conf.d/php-overrides.ini

# Set aliases
RUN echo "alias pam='php artisan migrate --database pgsql-admin'" >> /root/.bashrc
RUN echo "alias pal='php artisan list'" >> /root/.bashrc

# Run php artisan commands
WORKDIR /app

