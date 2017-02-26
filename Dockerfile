# Version: 20170217
FROM richarvey/nginx-php-fpm:php5
MAINTAINER gaoermai <gaoermai@gmail.com>

ENV WEBROOT /data/webroot/

RUN mkdir -p /data/webroot/
ADD index.php /data/webroot/index.php
WORKDIR /data/webroot/

RUN apk --update add autoconf build-base php5-dev re2c
RUN cd /tmp/ && \
  curl https://codeload.github.com/phalcon/cphalcon/tar.gz/v3.0.4 > cphalcon-3.0.4.tar.gz && \
  tar zxf cphalcon-3.0.4.tar.gz && \
  cd cphalcon-3.0.4/build && \
  ./install
ADD phalcon.ini /etc/php5/conf.d/phalcon.ini
RUN rm -rf /tmp/cphalcon*

CMD ["/start.sh"]
