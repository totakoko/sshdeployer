FROM alpine:3.17

LABEL maintainer="maxime@dreau.fr"

ENV SSH_FROM_ENV=true

RUN apk --update --no-cache add openssh-client

COPY remote.sh /usr/local/bin/remote
RUN ln -s /usr/local/bin/remote /remote

WORKDIR /

CMD ["remote"]
