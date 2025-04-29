FROM ubuntu:22.04

ARG UID=1001
ARG GID=1001
ARG USER_NAME=admin
ARG GROUP_NAME=ateng
ARG KK_VERSION=4.4.0
ARG WORK_DIR=/opt/kkFileView-${KK_VERSION}

WORKDIR ${WORK_DIR}

COPY --from=eclipse-temurin:8 /opt/java/openjdk /opt/jdk
ADD kkFileView-${KK_VERSION}.tar.gz /tmp
COPY docker-entrypoint.sh .

RUN sed -i 's|http://.*ubuntu.com|http://mirrors.aliyun.com|g' /etc/apt/sources.list && \
    apt-get update && \
    apt-get install --no-install-recommends -y \
        locales \
        tzdata \
        curl \
        wget \
        unzip \
        ca-certificates \
        fontconfig \
        libreoffice-nogui=1:7.3.7-0ubuntu0.22.04.9 && \
    apt-get install --no-install-recommends -y \
        fonts-dejavu \
        fonts-liberation \
        fonts-noto \
        fonts-noto-cjk \
        fonts-noto-color-emoji \
        fonts-noto-extra \
        fonts-noto-ui-core \
        fonts-droid-fallback && \
    fc-cache -f -v && \
    apt-get clean && \
    echo "zh_CN.UTF-8 UTF-8" > /etc/locale.gen && \
    locale-gen zh_CN.UTF-8 && \
    mv /tmp/kkFileView-${KK_VERSION}/* . && \
    groupadd -g ${GID} ${GROUP_NAME} && \
    useradd -u ${UID} -g ${GROUP_NAME} -m ${USER_NAME} && \
    chown ${UID}:${GID} -R ${WORK_DIR} && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ENV KKFILEVIEW_BIN_FOLDER=${WORK_DIR}/bin
ENV JAVA_HOME=/opt/jdk
ENV PATH=$PATH:$JAVA_HOME/bin
ENV TZ=Asia/Shanghai
ENV LANG=zh_CN.UTF-8

USER ${UID}:${GID}
EXPOSE 8012
ENTRYPOINT ["./docker-entrypoint.sh"]
