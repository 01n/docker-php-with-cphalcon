FROM webdevops/php-nginx:ubuntu-16.04

# To override this run: docker run -e
ENV COMPOSER_HOME=/root/composer \
    PATH=/root/composer/vendor/bin:$PATH \
    COMPOSER_ALLOW_SUPERUSER=1 \
    WEB_DOCUMENT_ROOT="/project"

# Add installers
ADD installers /

RUN mkdir -p $WEB_DOCUMENT_ROOT \
    # These vars need to be exported twice
    && export DEBIAN_FRONTEND=noninteractive \
    && export COMPOSER_HOME=/root/composer \
    && export PATH=/root/composer/vendor/bin:$PATH \
    && export COMPOSER_ALLOW_SUPERUSER=1 \
    && echo "<?php phpinfo(); ?>" > $WEB_DOCUMENT_ROOT/index.php \
    && chown -R $APPLICATION_USER:$APPLICATION_GROUP $WEB_DOCUMENT_ROOT \
    # Adding repositories
    && curl -s https://packagecloud.io/install/repositories/phalcon/stable/script.deb.sh | bash \
    && LC_ALL=en_US.UTF-8 add-apt-repository -y ppa:ondrej/php \
    # Avoid ERROR: invoke-rc.d: policy-rc.d denied execution of start
    && echo "#!/bin/sh\nexit 0" > /usr/sbin/policy-rc.d \
    # Update apt cache
    && apt-get update -y \
    # Install base stuff
    && apt-get -o Dpkg::Options::="--force-confnew" install -y -f --no-install-recommends \
        php7.0-apcu \
        php-apcu-bc \
        php7.0-dev \
        php7.0-dba \
        php7.0-gearman \
        php7.0-gmp \
        php-igbinary \
        php7.0-imagick \
        php7.0-imap \
        php-libsodium \
        php-memcache \
        php7.0-mongodb \
        php7.0-msgpack \
        php-pear \
        php7.0-odbc \
        php7.0-pgsql \
        php7.0-phalcon \
        php7.0-pspell \
        php7.0-recode \
        php-ssh2 \
        php7.0-tidy \
        php-yaml \
        libssh2-1-dev \
        libyaml-dev \
        build-essential \
        make \
        re2c \
    # Getting phive
    && wget https://phar.io/releases/phive.phar \
    && wget https://phar.io/releases/phive.phar.asc \
    && gpg --keyserver hkps.pool.sks-keyservers.net --recv-keys 0x9B2D5D79 \
    && gpg --verify phive.phar.asc phive.phar \
    && chmod +x phive.phar \
    && sudo mv phive.phar /usr/bin/phive \
    && pecl channel-update pecl.php.net \
    # Getting phpcs
    && curl -sOL https://squizlabs.github.io/PHP_CodeSniffer/phpcs.phar \
    && chmod +x phpcs.phar \
    && mv phpcs.phar /usr/local/bin/phpcs \
    # Getting phpcbf
    && curl -sOL https://squizlabs.github.io/PHP_CodeSniffer/phpcbf.phar \
    && chmod +x phpcbf.phar \
    && mv phpcbf.phar /usr/local/bin/phpcbf \
    # Getting phpmd
    && curl -sOL http://static.phpmd.org/php/latest/phpmd.phar \
    && chmod +x phpmd.phar \
    && mv phpmd.phar /usr/local/bin/phpmd \
    # Getting phing
    && curl -sOL http://www.phing.info/get/phing-latest.phar \
    && chmod +x phing-latest.phar \
    && mv phing-latest.phar /usr/local/bin/phing \
    # Install aerospike
    && bash /installers/aerospike.sh \
    # Install handlersocketi
    && bash /installers/handlersocketi.sh \
    # Install pinba
    && bash /installers/pinba.sh \
    # Install Weakref
    && bash /installers/weakref.sh \
    # Install Composer
    && mkdir $COMPOSER_HOME \
    && curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \
    && chmod +x /usr/local/bin/composer \
    # Tune up PHP-CLI
    && TIMEZONE=`cat /etc/timezone`; sed -i "s|;date.timezone =.*|date.timezone = ${TIMEZONE}|" /etc/php/7.0/cli/php.ini \
    && TIMEZONE=`cat /etc/timezone`; sed -i "s|;date.timezone =.*|date.timezone = ${TIMEZONE}|" /etc/php/7.0/fpm/php.ini \
    && sed -i "s|memory_limit =.*|memory_limit = -1|" /etc/php/7.0/cli/php.ini \
    && sed -i 's|short_open_tag =.*|short_open_tag = On|' /etc/php/7.0/cli/php.ini \
    && sed -i 's|error_reporting =.*|error_reporting = -1|' /etc/php/7.0/cli/php.ini \
    && sed -i 's|display_errors =.*|display_errors = On|' /etc/php/7.0/cli/php.ini \
    && sed -i 's|display_startup_errors =.*|display_startup_errors = On|' /etc/php/7.0/cli/php.ini \
    && sed -i -re 's|^(;?)(session.save_path) =.*|\2 = "/tmp"|g' /etc/php/7.0/cli/php.ini \
    && sed -i -re 's|^(;?)(phar.readonly) =.*|\2 = off|g' /etc/php/7.0/cli/php.ini \
    && echo "apc.enable_cli = 1" >> /etc/php/7.0/mods-available/apcu.ini \
    # Cleanup
    && apt-get purge -y -f \
        build-essential \
        make \
        re2c \
    && apt-get autoremove -y -f \
    && apt-get clean -y \
    && rm -rf \
        /tmp/* \
        /var/lib/apt/lists/* \
        /installers \
        /opt/docker/etc/php/fpm/pool.d/www.conf

# PHPUnit
RUN wget -O /usr/local/bin/phpunit-6.0.8 https://phar.phpunit.de/phpunit-6.0.8.phar \
  && chmod +x /usr/local/bin/phpunit-6.0.8 \
  && ln -s /usr/local/bin/phpunit-6.0.8 /usr/local/bin/phpunit-6
RUN wget -O /usr/local/bin/phpunit-5.7.15 https://phar.phpunit.de/phpunit-5.7.15.phar \
  && chmod +x /usr/local/bin/phpunit-5.7.15 \
  && ln -s /usr/local/bin/phpunit-5.7.15 /usr/local/bin/phpunit-5.7

# 在Docker内启动SSH，方便通过PHPStorm运行PHPUnit
RUN echo 'root:123456' | chpasswd
RUN sed -i 's/PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config

# SSH login fix. Otherwise user is kicked off after login
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile

# Expose ports
EXPOSE 80 443 22

CMD ["/usr/sbin/sshd", "-D"]
