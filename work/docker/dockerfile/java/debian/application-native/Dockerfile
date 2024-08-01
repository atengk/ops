# 第一阶段：编译Java应用
FROM registry.lingo.local/service/java:debian12_graalvm_openjdk-jdk-21 as build

# 设置工作目录
WORKDIR /tmp

# 复制 Maven 配置文件和项目文件
COPY pom.xml pom.xml
COPY src src

# 编译 Java 应用，生成 GraalVM 原生映像
RUN mvn -Pnative native:compile -DskipTests

# 第二阶段：运行生成的二进制文件
FROM registry.lingo.local/service/debian:12.5

# 设置工作目录
WORKDIR /opt

# 设置时区
ENV TZ=Asia/Shanghai

# 设置编码
ENV LANG=zh_CN.UTF-8
ENV LANGUAGE=zh_CN:zh

# 从第一阶段复制生成的二进制文件到第二阶段
COPY --from=build /tmp/target/graalvm /opt/graalvm

# 安装软件
RUN sed -i "s#http.*\(com\|org\|cn\)#http://mirrors.cloud.tencent.com#g" /etc/apt/sources.list.d/debian.sources && \
    apt-get update && \
    apt-get install -y curl && \
    apt-get clean && \
    groupadd -g 1001 ateng && \
    useradd -u 1001 -g ateng -m admin && \
    chown 1001:1001 -R /opt && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# 设置应用环境变量
ENV JAVA_TOOL_OPTIONS="-Xms512m -Xmx1g"

# 设置暴露的端口号
EXPOSE 8080

# 设置用户
USER 1001:1001

# 启动应用
ENTRYPOINT ["./graalvm"]
