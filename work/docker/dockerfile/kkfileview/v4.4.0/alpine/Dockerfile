FROM linuxserver/libreoffice:7.6.7

ARG KK_VERSION=4.4.0
ARG WORK_DIR=/opt/kkFileView-${KK_VERSION}

WORKDIR ${WORK_DIR}

ADD kkFileView-${KK_VERSION}.tar.gz /tmp
COPY docker-entrypoint.sh .

RUN mv /tmp/kkFileView-${KK_VERSION}/* . && \
    rm -rf /tmp/*

ENV KKFILEVIEW_BIN_FOLDER=${WORK_DIR}/bin
ENV TZ=Asia/Shanghai

EXPOSE 8012
ENTRYPOINT ["./docker-entrypoint.sh"]
