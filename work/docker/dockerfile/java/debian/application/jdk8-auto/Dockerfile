# 环境
FROM registry.lingo.local/service/java:debian12_temurin_openjdk-jdk-8-jre

# 设置工作目录并拷贝数据
WORKDIR /opt/app
COPY --chown=1001:1001 docker-entrypoint.sh docker-entrypoint.sh

# 执行命令
CMD ["/bin/bash", "./docker-entrypoint.sh"]
