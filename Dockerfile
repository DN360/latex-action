FROM ubuntu:18.04
LABEL maintainer YOSHIMI Masato <myoshimi@DOMAIN_NAME>

ENV DEBIAN_FRONTEND noninteractive

RUN set -xe && \
    apt-get -y update && \
    apt-get install -y \
        make \
        curl \
        jq \
        texlive-lang-cjk \
        xdvik-ja \
        texlive-fonts-recommended \
        texlive-fonts-extra && \
    apt autoremove -y && \
    apt-get clean

ADD entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]