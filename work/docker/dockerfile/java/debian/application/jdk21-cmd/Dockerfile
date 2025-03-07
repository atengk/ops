# 环境
FROM registry.lingo.local/service/java:debian12_temurin_openjdk-jdk-21-jre

# 定义变量
ARG JAR_FILE=springboot3-demo-v1.0.jar

# 设置工作目录并拷贝数据
WORKDIR /opt/app
COPY --chown=1001:1001 ${JAR_FILE} ${JAR_FILE}

# 设置暴露的端口号
EXPOSE 8080

# 设置启动命令
ENTRYPOINT ["java"]
CMD ["-server", "-Xms128m", "-Xmx1024m", "-jar", "springboot3-demo-v1.0.jar", "--server.port=8080"]
