#FROM  tkr1205/docker-alpine-texlive-ja:latest

#RUN apk --no-cache add \
#        curl \
#        file \
#        ghostscript \
#        gnupg \
#        jq \
#        perl \
#        python \
#        python3 \
#        tar \
#        wget \
#        xz

#ENV PATH="/opt/texlive/texdir/bin/x86_64-linuxmusl:${PATH}"
#WORKDIR /root

#COPY \
#  LICENSE \
#  README.md \
#  entrypoint.sh \
#  setup.sh \
#  texlive.profile \
#  texlive_pgp_keys.asc \
#  funinfosys.sty \
#  kanjix.map \
#  /root/
#RUN /root/setup.sh

#ENTRYPOINT ["/root/entrypoint.sh"]

FROM ubuntu:16.04

RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    curl \
    python3 \
    latexmk \
    lmodern \
    texlive \
    texlive-latex-extra \
    texlive-lang-japanese \
  && rm -rf /var/lib/apt/lists/*

RUN mktexlsr && mkdir -p /app
WORKDIR /app

ADD entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
