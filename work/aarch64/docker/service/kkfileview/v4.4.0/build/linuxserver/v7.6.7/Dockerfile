FROM linuxserver/libreoffice:7.6.7

ARG KK_VERSION=4.4.0
ARG WORK_DIR=/opt/kkFileView-${KK_VERSION}

WORKDIR ${WORK_DIR}

ADD kkFileView-${KK_VERSION}.tar.gz /tmp
COPY docker-entrypoint.sh .

RUN set -eux && \
    sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories && \
    apk update && \
    apk upgrade && \
    apk add --no-cache \
        tzdata \
        curl \
        ca-certificates \
        fontconfig \
        font-noto-cjk \
        su-exec \
        shadow \
        bash \
        icu-data-full && \
    cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
    echo "Asia/Shanghai" > /etc/timezone && \
    mv /tmp/kkFileView-${KK_VERSION}/* . && \
    rm -rf /var/cache/apk/* /tmp/* /var/tmp/*

ENV KKFILEVIEW_BIN_FOLDER=${WORK_DIR}/bin
ENV TZ=Asia/Shanghai
ENV LANG=zh_CN.UTF-8
ENV LANGUAGE=zh_CN:zh
ENV LC_ALL=zh_CN.UTF-8

EXPOSE 8012
ENTRYPOINT ["./docker-entrypoint.sh"]
