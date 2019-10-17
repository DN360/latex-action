#FROM ubuntu:18.04

#ENV DEBIAN_FRONTEND noninteractive

#RUN set -xe && \
#    apt-get -y update && \
#    apt-get install -y \
#        make \
#        curl \
#        jq \
#        texlive-lang-cjk \
#        xdvik-ja \
#        texlive-fonts-recommended \
#        texlive-fonts-extra && \
#    apt autoremove -y && \
#    apt-get clean

#ADD entrypoint.sh /entrypoint.sh
#ENTRYPOINT ["/entrypoint.sh"]

FROM alpine:latest

RUN apk update && \
    apk --no-cache add make curl jq && \
    apk --no-cache add texlive-lang-cjk \
        xdvik-ja \
        texlive-fonts-recommended \
        texlive-fonts-extra && \
    apk cache clean

ADD entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]