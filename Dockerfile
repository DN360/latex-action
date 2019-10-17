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

FROM alpine:3.10

ENV LANG=C.UTF-8
ENV PATH /usr/local/texlive/2019/bin/x86_64-linux:$PATH

# Reference: https://github.com/frol/docker-alpine-glibc
# Here we install GNU libc (aka glibc) and set C.UTF-8 locale as default.
RUN ALPINE_GLIBC_BASE_URL="https://github.com/sgerrand/alpine-pkg-glibc/releases/download" && \
    ALPINE_GLIBC_PACKAGE_VERSION="2.29-r0" && \
    ALPINE_GLIBC_BASE_PACKAGE_FILENAME="glibc-$ALPINE_GLIBC_PACKAGE_VERSION.apk" && \
    ALPINE_GLIBC_BIN_PACKAGE_FILENAME="glibc-bin-$ALPINE_GLIBC_PACKAGE_VERSION.apk" && \
    ALPINE_GLIBC_I18N_PACKAGE_FILENAME="glibc-i18n-$ALPINE_GLIBC_PACKAGE_VERSION.apk" && \
    apk add --no-cache --virtual=.build-dependencies wget ca-certificates && \
    echo \
        "-----BEGIN PUBLIC KEY-----\
        MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEApZ2u1KJKUu/fW4A25y9m\
        y70AGEa/J3Wi5ibNVGNn1gT1r0VfgeWd0pUybS4UmcHdiNzxJPgoWQhV2SSW1JYu\
        tOqKZF5QSN6X937PTUpNBjUvLtTQ1ve1fp39uf/lEXPpFpOPL88LKnDBgbh7wkCp\
        m2KzLVGChf83MS0ShL6G9EQIAUxLm99VpgRjwqTQ/KfzGtpke1wqws4au0Ab4qPY\
        KXvMLSPLUp7cfulWvhmZSegr5AdhNw5KNizPqCJT8ZrGvgHypXyiFvvAH5YRtSsc\
        Zvo9GI2e2MaZyo9/lvb+LbLEJZKEQckqRj4P26gmASrZEPStwc+yqy1ShHLA0j6m\
        1QIDAQAB\
        -----END PUBLIC KEY-----" | sed 's/   */\n/g' > "/etc/apk/keys/sgerrand.rsa.pub" && \
    wget \
        "$ALPINE_GLIBC_BASE_URL/$ALPINE_GLIBC_PACKAGE_VERSION/$ALPINE_GLIBC_BASE_PACKAGE_FILENAME" \
        "$ALPINE_GLIBC_BASE_URL/$ALPINE_GLIBC_PACKAGE_VERSION/$ALPINE_GLIBC_BIN_PACKAGE_FILENAME" \
        "$ALPINE_GLIBC_BASE_URL/$ALPINE_GLIBC_PACKAGE_VERSION/$ALPINE_GLIBC_I18N_PACKAGE_FILENAME" && \
    apk add --no-cache \
        "$ALPINE_GLIBC_BASE_PACKAGE_FILENAME" \
        "$ALPINE_GLIBC_BIN_PACKAGE_FILENAME" \
        "$ALPINE_GLIBC_I18N_PACKAGE_FILENAME" && \
    \
    rm "/etc/apk/keys/sgerrand.rsa.pub" && \
    /usr/glibc-compat/bin/localedef --force --inputfile POSIX --charmap UTF-8 "$LANG" || true && \
    echo "export LANG=$LANG" > /etc/profile.d/locale.sh && \
    \
    apk del glibc-i18n && \
    \
    rm "/root/.wget-hsts" && \
    apk del .build-dependencies && \
    rm \
        "$ALPINE_GLIBC_BASE_PACKAGE_FILENAME" \
        "$ALPINE_GLIBC_BIN_PACKAGE_FILENAME" \
        "$ALPINE_GLIBC_I18N_PACKAGE_FILENAME"

# Reference: https://github.com/Paperist/docker-alpine-texlive-ja
# install texlive
RUN apk add --no-cache perl fontconfig-dev freetype-dev && \
    apk add --no-cache --virtual .fetch-deps wget xz tar && \
    mkdir /tmp/install-tl-unx && \
    wget -qO - ftp://tug.org/historic/systems/texlive/2019/install-tl-unx.tar.gz | \
    tar -xz -C /tmp/install-tl-unx --strip-components=1 && \
    printf "%s\n" \
      "selected_scheme scheme-basic" \
      "option_doc 0" \
      "option_src 0" \
      > /tmp/install-tl-unx/texlive.profile && \
    /tmp/install-tl-unx/install-tl \
      --profile=/tmp/install-tl-unx/texlive.profile && \
    tlmgr install \
      collection-basic\
      collection-latex \
      collection-latexrecommended\
      collection-latexextra \
      collection-fontsrecommended\
      collection-langjapanese \
      latexmk \
      dvipdfmx && \
    (tlmgr install xetex || exit 0) && \
    rm -fr /tmp/install-tl-unx && \
    apk del .fetch-deps

# References: https://gist.github.com/e10101/a4e833120f8a66a22cd581241cc79ed0
#           : https://qiita.com/zr_tex8r/items/9dfeafecca2d091abd02
#           : https://github.com/googlefonts/noto-cjk
# install noto font jp
# フォントをインストールする場所は以下で探し, /fonts/以下は自由なディレクトリが可能.
# $ kpsewhich -var-value=TEXMFLOCAL
RUN mkdir -p /usr/local/texlive/texmf-local/fonts/opentype/google && \
    cd /usr/local/texlive/texmf-local/fonts/opentype/google/ && \
    # 以下はgoogle noto font cjkのjpフォントだけをインストールしている.
    wget https://github.com/googlefonts/noto-cjk/raw/master/NotoSansJP-Black.otf \
         https://github.com/googlefonts/noto-cjk/raw/master/NotoSansJP-Bold.otf \
         https://github.com/googlefonts/noto-cjk/raw/master/NotoSansJP-DemiLight.otf \
         https://github.com/googlefonts/noto-cjk/raw/master/NotoSansJP-Light.otf \
         https://github.com/googlefonts/noto-cjk/raw/master/NotoSansJP-Medium.otf \
         https://github.com/googlefonts/noto-cjk/raw/master/NotoSansJP-Regular.otf \
         https://github.com/googlefonts/noto-cjk/raw/master/NotoSansJP-Thin.otf \
         https://github.com/googlefonts/noto-cjk/raw/master/NotoSerifJP-Black.otf \
         https://github.com/googlefonts/noto-cjk/raw/master/NotoSerifJP-Bold.otf \
         https://github.com/googlefonts/noto-cjk/raw/master/NotoSerifJP-ExtraLight.otf \
         https://github.com/googlefonts/noto-cjk/raw/master/NotoSerifJP-Light.otf \
         https://github.com/googlefonts/noto-cjk/raw/master/NotoSerifJP-Medium.otf \
         https://github.com/googlefonts/noto-cjk/raw/master/NotoSerifJP-Regular.otf \
         https://github.com/googlefonts/noto-cjk/raw/master/NotoSerifJP-SemiBold.otf && \
    mktexlsr
# 明朝体・細字（\mcfamily\ltseries）
# 明朝体・中字（\mcfamily\mdseries）
# 明朝体・太字（\mcfamily\bfseries）
# ゴシック体・中字（\gtfamily\mdseries）
# ゴシック体・太字（\gtfamily\bfseries）
# ゴシック体・極太（\gtfamily\ebseries）
# 丸ゴシック体（\mgfamily）
# 上記の7つのフォントを使うには, `.texファイル`のプリアンブルに以下の2行を追加する.
# \usepackage[deluxe]{otf}% 多書体設定
# \usepackage[noto-jp]{pxchfon}% 後に読み込む

ADD entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]