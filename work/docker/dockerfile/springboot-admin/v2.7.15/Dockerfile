# 环境
FROM registry.lingo.local/service/java:ubuntu23_oracle-jre-8u391

# 拷贝数据
COPY --chown=1001:1001 MySpringBootAdmin-2.7.15.jar /opt/MySpringBootAdmin-2.7.15.jar

# 定位到/opt目录
WORKDIR /opt

# 设置环境变量
ENV JAVA_OPTS="-server -Xms128m -Xmx1g -Dfile.encoding=UTF-8"

# 设置暴露的端口号
EXPOSE 80

# 执行命令
CMD java ${JAVA_OPTS} -jar /opt/MySpringBootAdmin-2.7.15.jar

