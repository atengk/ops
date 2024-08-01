# 环境
FROM registry.lingo.local/service/java:ubuntu23_temurin_openjdk-jdk-21.0.2-13-jre

# 拷贝数据
COPY --chown=1001:1001 MySpringBoot3Admin-3.3.0.jar /opt/MySpringBoot3Admin-3.3.0.jar

# 定位到/opt目录
WORKDIR /opt

# 设置环境变量
ENV JAVA_OPTS="-server -Xms128m -Xmx1g -Dfile.encoding=UTF-8"

# 设置暴露的端口号
EXPOSE 8080

# 执行命令
CMD java ${JAVA_OPTS} -jar /opt/MySpringBoot3Admin-3.3.0.jar

