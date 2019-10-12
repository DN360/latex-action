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

#FROM ubuntu:18.04
#ENV DEBIAN_FRONTEND noninteractive
#RUN apt update && apt install -y --no-install-recommends \
# for (u)platex
#texlive-lang-japanese \
# for CTAN packages
#texlive-plain-generic texlive-latex-base texlive-latex-extra \
# Biber
#texlive-bibtex-extra biber texlive-fonts-recommended \
# for latexmk
#latexmk \
# for noto font: Bold and Regular
#fonts-noto-cjk \
# for noto font: Black, DemiLight, Light, Medium, Thin and so on
#fonts-noto-cjk-extra \
#&& rm -rf /var/lib/apt/lists/*

FROM ubuntu:18.04

RUN   apt update && \
      apt install -y \
            texlive-lang-cjk \
            xdvik-ja \
            texlive-fonts-recommended \
            texlive-fonts-extra \
            biber \
            nkf && \
      apt autoremove && \
      apt clean && \
      rm -rf /var/lib/apt/lists/*

ADD entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
