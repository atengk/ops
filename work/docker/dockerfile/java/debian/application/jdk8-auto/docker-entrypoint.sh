#!/bin/bash

# 设置 JVM 参数
JAVA_OPTS=${JAVA_OPTS:--XX:+UseG1GC -server -Xms128m -Xmx1024m -jar}
# 设置 Spring Boot 运行参数
SPRING_OPTS=${SPRING_OPTS:-}
# 指定 JAR 文件
JAR_FILE=${JAR_FILE:-}

# 判空：检查 JAR_FILE 是否为空
if [ -z "$JAR_FILE" ]; then
    echo "错误: JAR_FILE 变量未设置！请检查环境变量或脚本配置。"
    exit 1
fi
# 判断 JAR 文件是否存在
if [ ! -f "$JAR_FILE" ]; then
    echo "错误: JAR 文件 '$JAR_FILE' 不存在！请检查路径。"
    exit 1
fi

# 执行 Java 进程
RUN_CMD="java ${JAVA_OPTS} ${JAR_FILE} ${SPRING_OPTS}"
echo "运行程序: ${RUN_CMD}"
exec ${RUN_CMD}
