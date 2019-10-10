FROM paperist/alpine-texlive-ja:latest

RUN apk --no-cache add \
        curl \
        ghostscript \
        gnupg \
        perl \
        python \
        tar \
        wget \
        xz

ENV PATH="/opt/texlive/texdir/bin/x86_64-linuxmusl:${PATH}"
WORKDIR /root

COPY \
  LICENSE \
  README.md \
  entrypoint.sh \
  setup.sh \
  texlive.profile \
  texlive_pgp_keys.asc \
  funinfosys.sty \
  /root/
RUN /root/setup.sh

ENTRYPOINT ["/root/entrypoint.sh"]
