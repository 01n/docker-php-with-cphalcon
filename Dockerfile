# Version: 20170212
FROM richarvey/nginx-php-fpm:php5
MAINTAINER gaoermai <gaoermai@gmail.com>

ENV WEBROOT /data/webroot/

RUN apk --update add autoconf build-base php5-dev
RUN cd /tmp/ && \
  curl https://codeload.github.com/phalcon/cphalcon/tar.gz/v3.0.2 > cphalcon-3.0.2.tar.gz && \
  tar zxf cphalcon-3.0.2.tar.gz && \
  cd cphalcon-3.0.2/build && \
  ./install
RUN rm -rf /tmp/cphalcon*

CMD ["/start.sh"]
