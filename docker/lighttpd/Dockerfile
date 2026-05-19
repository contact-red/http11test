FROM alpine:latest

RUN apk add --no-cache lighttpd

RUN mkdir -p /var/www && echo "ok" > /var/www/index.html

COPY lighttpd.conf /etc/lighttpd/lighttpd.conf

EXPOSE 80

CMD ["lighttpd", "-D", "-f", "/etc/lighttpd/lighttpd.conf"]
