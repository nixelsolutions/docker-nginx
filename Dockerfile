FROM ubuntu:14.04

MAINTAINER Manel Martinez <manel@nixelsolutions.com>

ENV DEBIAN_FRONTEND=noninteractive
ENV TERM=xterm

RUN apt-get update && \
    apt-get install -y python-software-properties software-properties-common
RUN add-apt-repository -y ppa:nginx/stable && \
    perl -p -i -e "s/^# deb-src/deb-src/g" /etc/apt/sources.list.d/nginx-stable-trusty.list
RUN apt-get update && \
apt-get install -y nginx nginx-extras supervisor

ENV HTTP_USER www-data
ENV HTTP_PORT 80
ENV HTTP_DOCUMENTROOT /var/www
ENV LOGS_PATH /var/log/nginx

EXPOSE ${HTTP_PORT}

VOLUME ${LOGS_PATH}

RUN mkdir -p /var/log/supervisor

# nginx config
RUN rm -f /etc/nginx/sites-enabled/default
# Force logrotate
RUN perl -p -i -e "s/\/usr\/sbin\/logrotate \/etc\/logrotate\.conf/\/usr\/sbin\/logrotate -f \/etc\/logrotate\.conf/g" /etc/cron.daily/logrotate

# Add config files
ADD ./etc /etc
RUN mkdir -p /usr/local/bin
ADD ./bin /usr/local/bin
RUN chmod +x /usr/local/bin/*.sh

# Add sources
ADD ./src /var/www
RUN chown -R www-data:www-data /var/www

CMD ["/usr/local/bin/run.sh"]
