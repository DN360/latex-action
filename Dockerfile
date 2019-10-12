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

FROM alpine:3.8

ENV PATH /usr/local/texlive/2018/bin/x86_64-linuxmusl:$PATH

RUN apk --no-cache --update add bash
ENV SHELL /bin/bash

WORKDIR /root
RUN apk --no-cache --update add wget perl xz tar fontconfig-dev && \
    wget http://mirror.ctan.org/systems/texlive/tlnet/install-tl-unx.tar.gz  && \
    mkdir install-tl-unx && \
    tar xf install-tl-unx.tar.gz --strip-components 1 -C install-tl-unx

COPY texlive.profile /root/install-tl-unx/
RUN /root/install-tl-unx/install-tl \
    --repository=http://mirror.ctan.org/systems/texlive/tlnet/ \
    --profile=/root/install-tl-unx/texlive.profile && \
    tlmgr install \
        collection-basic collection-latex \
        collection-latexrecommended collection-latexextra \
        collection-fontsrecommended collection-langjapanese latexmk && \
    ( tlmgr install xetex || exit 0 ) && \
    rm -rf /root/install-tl-unx && \
    apk --no-cache del wget xz tar fontconfig-dev && \
    rm -rf /root/install-tl-unx

COPY \
  LICENSE \
  README.md \
  entrypoint.sh \
  setup.sh \
  texlive.profile \
  texlive_pgp_keys.asc \
  funinfosys.sty \
  kanjix.map \
  /root/

#RUN /root/setup.sh

ENTRYPOINT ["/root/entrypoint.sh"]
