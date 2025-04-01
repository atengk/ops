#!/bin/bash

# 设置 JVM 参数
JAVA_OPTS=${JAVA_OPTS:-}
# 设置 Spring Boot 运行参数
SPRING_OPTS=${SPRING_OPTS:-}

# 执行 Java 进程
RUN_CMD="java ${JAVA_OPTS} ${SPRING_OPTS}"
echo "运行程序: ${RUN_CMD}"
exec ${RUN_CMD}
