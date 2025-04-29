FROM linuxserver/libreoffice:7.6.7

ARG UID=1412
ARG GID=1412
ARG USER_NAME=admin
ARG GROUP_NAME=ateng
ARG KK_VERSION=4.4.0
ARG WORK_DIR=/opt/kkFileView-${KK_VERSION}

WORKDIR ${WORK_DIR}

ADD kkFileView-${KK_VERSION}.tar.gz /tmp
COPY docker-entrypoint.sh .

RUN sed -i 's|dl-cdn.alpinelinux.org|mirrors.aliyun.com|g' /etc/apk/repositories && \
    apk update && \
    apk add --no-cache \
        tzdata \
        curl \
        ca-certificates \
        fontconfig \
        su-exec \
        shadow \
        bash && \
    apk add --no-cache \
        font-dejavu \
        font-liberation \
        font-noto \
        font-noto-cjk \
        font-noto-extra && \
    fc-cache -f -v && \
    mv /tmp/kkFileView-${KK_VERSION}/* . && \
    groupadd -g ${GID} ${GROUP_NAME} && \
    useradd -u ${UID} -g ${GROUP_NAME} -m ${USER_NAME} && \
    chown ${UID}:${GID} -R ${WORK_DIR} && \
    rm -rf /var/cache/apk/* /tmp/* /var/tmp/*

ENV KKFILEVIEW_BIN_FOLDER=${WORK_DIR}/bin
ENV TZ=Asia/Shanghai
ENV LANG=zh_CN.UTF-8

EXPOSE 8012
ENTRYPOINT ["./docker-entrypoint.sh"]
