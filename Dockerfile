FROM alpine:3.7

MAINTAINER maxime@dreau.fr

RUN apk --update --no-cache add openssh-client rsync \
 && mkdir -p ~/.ssh \
 && chmod 700 ~/.ssh

COPY remote.sh /remote

RUN chmod +x /remote

WORKDIR /

CMD ["/remote"]
