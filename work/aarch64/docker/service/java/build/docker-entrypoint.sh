#!/bin/bash
set -euo pipefail

# 设置 Jar 启动的命令
JAR_CMD=${JAR_CMD:--jar /opt/app/app.jar}
# 设置 JVM 参数
JAVA_OPTS=${JAVA_OPTS:--Xms128m -Xmx1024m}
# 设置 Spring Boot 参数
SPRING_OPTS=${SPRING_OPTS:---spring.profiles.active=prod}
# 设置应用启动命令
RUN_CMD=${RUN_CMD:-java ${JAVA_OPTS} ${JAR_CMD} ${SPRING_OPTS}}

# 打印命令并启动
echo "[$(date '+%Y-%m-%d %H:%M:%S')] Starting application: ${RUN_CMD}"
exec ${RUN_CMD}
