# 环境
FROM alpine:latest

# 作者信息
LABEL maintainer="KongYu <2385569970@qq.com>"
# 设置容器的描述信息
LABEL description="MinIO版本是：minio.RELEASE.2023-12-09T18-17-51Z"
# 添加其他标签
LABEL version="1.0"
LABEL release-date="2023-12-12"

# 拷贝数据
## https://dl.min.io/server/minio/release/linux-amd64/archive/minio.RELEASE.2023-12-09T18-17-51Z
COPY minio.RELEASE.2023-12-09T18-17-51Z /usr/bin/minio
## https://dl.min.io/client/mc/release/linux-amd64/archive/mc.RELEASE.2023-12-07T22-13-17Z
COPY mc.RELEASE.2023-12-07T22-13-17Z /usr/bin/mc

# 安装时区数据包
RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories && \
    apk update --no-cache && \
    apk add --no-cache tzdata

# 设置 MinIO 的账号密码
ENV MINIO_ROOT_USER admin
ENV MINIO_ROOT_PASSWORD Admin@123

# 设置编码和时区
ENV LANG=zh_CN.UTF-8 \
    LANGUAGE=zh_CN:zh
ENV TZ=Asia/Shanghai

# 暴露端口
EXPOSE 9001
EXPOSE 9000

# 设置用户
USER 1001:1001

# 设置容器的启动命令
CMD ["minio", "server", "--address", ":9000", "--console-address", ":9001", "/tmp"]
