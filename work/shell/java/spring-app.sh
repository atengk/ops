#!/bin/bash

# 配置部分
# -----------------------------------------------------------------------------
# 设置Java路径，如果设置了JAVA_HOME，优先使用，否则使用自带的全局的java
# 设置 JAVA_HOME
JAVA_HOME=${JAVA_HOME}
# 尝试获取 java 命令的路径
JAVA_BIN=$(command -v java &> /dev/null && echo $(command -v java))
# 如果设置了 JAVA_HOME，优先使用 JAVA_HOME/bin/java
if [ -n "$JAVA_HOME" ]; then
    JAVA_BIN="$JAVA_HOME/bin/java"
# 如果 JAVA_BIN 不为空，使用 JAVA_BIN
elif [ -n "$JAVA_BIN" ]; then
    JAVA_BIN="$JAVA_BIN"
# 如果 JAVA_HOME 和 JAVA_BIN 都为空，报错
else
    echo "Error: JAVA_HOME or java binary not found!"
    exit 1
fi
# 判断 JAVA_BIN 是否可用
if ! [ -x "$JAVA_BIN" ]; then
    echo "Error: JAVA binary at '$JAVA_BIN' is not executable or does not exist!"
    exit 1
fi

# 从环境变量中读取JAR路径
JAR_PATH="${SPRINGBOOT_JAR_PATH}"

# 如果环境变量未设置，则自动寻找同一目录下的JAR文件
if [ -z "$JAR_PATH" ]; then
  SCRIPT_DIR=$(dirname "$(realpath "$0")")
  JAR_PATH=$(find "$SCRIPT_DIR" -maxdepth 1 -name "*.jar" | head -n 1)
fi

if [ -z "$JAR_PATH" ]; then
  echo -e "\033[90m$(date +'%Y-%m-%d %H:%M:%S')\033[0m \033[31m[ERROR]\033[0m 未找到 JAR 文件。"
  echo -e "\033[90m$(date +'%Y-%m-%d %H:%M:%S')\033[0m \033[33m[INFO]\033[0m 请确保 JAR 文件与脚本位于同一目录，或者设置环境变量 SPRINGBOOT_JAR_PATH。"
  exit 1
fi

# 解析JAR路径
JAR_PATH=$(realpath "$JAR_PATH") # 转换为绝对路径
if [ ! -f "$JAR_PATH" ]; then
  echo -e "\033[90m$(date +'%Y-%m-%d %H:%M:%S')\033[0m \033[31m[ERROR]\033[0m JAR文件不存在: $JAR_PATH"
  exit 1
fi

# 自动推断应用名称和日志目录
APP_NAME=$(basename "$JAR_PATH" .jar)
APP_HOME=$(dirname "$JAR_PATH")
LOG_DIR="$(dirname "$JAR_PATH")/logs"

# 日志配置
LOG_ENABLED=${LOG_ENABLED:-false}
LOG_DATE_FORMAT='%Y-%m-%d'
LOG_FILE_BASE="$LOG_DIR/$APP_NAME-$(date +$LOG_DATE_FORMAT)"
LOG_FILE="$LOG_FILE_BASE.log"
LOG_LINK="$LOG_DIR/$APP_NAME-current.log"

# PID文件
#PID_FILE="$APP_HOME/$APP_NAME.pid"
PID_FILE="/tmp/$APP_NAME.pid"

# JVM参数
JVM_OPTS=${JVM_OPTS:--server}

# Spring Boot应用参数
SPRING_OPTS=${SPRING_OPTS:-}

# 优雅关闭的最大等待时间（秒）
GRACEFUL_SHUTDOWN_TIMEOUT=${GRACEFUL_SHUTDOWN_TIMEOUT:-60}

# 日志清理配置
LOG_CLEANUP_ENABLED=${LOG_ENABLED:-false}
LOG_RETENTION_DAYS=${LOG_RETENTION_DAYS:-7}

# 健康检查配置
HEALTH_CHECK_METHOD=${HEALTH_CHECK_METHOD:-none} # 可选：none, log, tcp, url
LOG_KEYWORD=${LOG_KEYWORD:-JVM running for} # 日志关键字
HEALTH_CHECK_TCP_PORT=${HEALTH_CHECK_TCP_PORT:-8888} # 用于TCP端口检查的端口
HEALTH_CHECK_URL=${HEALTH_CHECK_URL:-http://localhost:8888/actuator/health} # 用于URL检查的健康检查URL
# -----------------------------------------------------------------------------

# 颜色定义
# -----------------------------------------------------------------------------
COLOR_RESET="\033[0m"
COLOR_TIME="\033[90m" # 灰色
COLOR_INFO="\033[32m" # 绿色
COLOR_WARN="\033[33m" # 黄色
COLOR_ERROR="\033[31m" # 红色
# -----------------------------------------------------------------------------

# 打印消息函数
log_message() {
  local message_type="$1"
  local message="$2"
  local color_type=""
  case "$message_type" in
    INFO)
      color_type="$COLOR_INFO"
      ;;
    WARN)
      color_type="$COLOR_WARN"
      ;;
    ERROR)
      color_type="$COLOR_ERROR"
      ;;
    *)
      color_type="$COLOR_RESET"
      ;;
  esac
  echo -e "${COLOR_TIME}$(date +'%Y-%m-%d %H:%M:%S')${COLOR_RESET} ${color_type}[${message_type}]${COLOR_RESET} ${message}"
}

# 初始化日志文件和符号链接
init_logs() {
  if [ "$LOG_ENABLED" = true ]; then
    mkdir -p "$LOG_DIR"
    
    # 处理日志文件重命名
    if [ -f "$LOG_FILE" ]; then
      count=1
      while [ -f "${LOG_FILE_BASE}.${count}.log" ]; do
        count=$((count + 1))
      done
      mv "$LOG_FILE" "${LOG_FILE_BASE}.${count}.log"
    fi
    
    # 更新日志文件链接
    ln -sf "$LOG_FILE" "$LOG_LINK"
  fi
}

# 启动应用程序
start() {
  if [ -f "$PID_FILE" ]; then
    log_message "WARN" "应用程序已经在运行 (PID: $(cat $PID_FILE))"
    exit 1
  fi

  init_logs
  log_message "INFO" "启动 $APP_NAME..."

  if [ "$LOG_ENABLED" = true ]; then
    nohup $JAVA_BIN $JVM_OPTS -jar $JAR_PATH $SPRING_OPTS >> "$LOG_FILE" 2>&1 &
    # 更新日志链接
    ln -sf "$LOG_FILE" "$LOG_LINK"
  else
    nohup $JAVA_BIN $JVM_OPTS -jar $JAR_PATH $SPRING_OPTS > /dev/null 2>&1 &
  fi
  
  echo $! > "$PID_FILE"

  # 判断是否进行健康检查
  if [ "$HEALTH_CHECK_METHOD" != "none" ]; then
    log_message "INFO" "进行健康检查 [$HEALTH_CHECK_METHOD]..."
    for (( i=1; i<=$GRACEFUL_SHUTDOWN_TIMEOUT; i++ )); do
      sleep 1
      if health_check; then
        log_message "INFO" "$APP_NAME 启动成功 (PID: $(cat $PID_FILE))"
        return
      fi
    done
	log_message "ERROR" "$APP_NAME 启动失败，请检查日志或健康检查配置"
    stop
    exit 1
  fi
  log_message "INFO" "$APP_NAME 启动成功 (PID: $(cat $PID_FILE))"
  return
}

# 健康检查函数
health_check() {
  case "$HEALTH_CHECK_METHOD" in
    log)
      [ "$LOG_ENABLED" = true ] && grep -q "$LOG_KEYWORD" "$LOG_FILE"
      return $?
      ;;
    tcp)
	  ss -tuln | grep $HEALTH_CHECK_TCP_PORT &> /dev/null
      return $?
      ;;
    url)
      curl -s -o /dev/null -w "%{http_code}" $HEALTH_CHECK_URL | grep -q "200"
      return $?
      ;;
    none)
      return 0
      ;;
    *)
      log_message "ERROR" "未知的健康检查方法: $HEALTH_CHECK_METHOD"
      return 1
      ;;
  esac
}

# 停止应用程序
stop() {
  log_message "INFO" "准备停止 $APP_NAME..."
  
  if [ -f "$PID_FILE" ]; then
    PID=$(cat "$PID_FILE")
    # 判断进程是否存在
    ps -p $PID &> /dev/null
    if [ "$?" != "0" ]
    then
      log_message "WARN" "$APP_NAME 未运行"
      rm -f "$PID_FILE"
      return
    fi
  else
    log_message "WARN" "$APP_NAME 未运行"
	return
  fi
  
  PID=$(cat "$PID_FILE")
  log_message "INFO" "停止 $APP_NAME (PID: $PID)..."

  kill $PID
  TIMEOUT=$GRACEFUL_SHUTDOWN_TIMEOUT
  while [ $TIMEOUT -gt 0 ]; do
    if ! kill -0 $PID > /dev/null 2>&1; then
      log_message "INFO" "$APP_NAME 已停止"
      rm -f "$PID_FILE"
      return
    fi
    sleep 1
    TIMEOUT=$((TIMEOUT - 1))
  done

  log_message "WARN" "$APP_NAME 停止超时，强制停止..."
  kill -9 $PID
  rm -f "$PID_FILE"
  log_message "INFO" "$APP_NAME 已强制停止"
}

# 检查应用程序状态
status() {
  if [ -f "$PID_FILE" ]; then
    # 判断PID文件夹存在，应用程序进程是否存在
	PID=$(cat "$PID_FILE")
	ps -p $PID &> /dev/null
	if [ "$?" = "0" ]
	then
	  log_message "INFO" "$APP_NAME 正在运行 (PID: $(cat $PID_FILE))"
	else
      log_message "WARN" "$APP_NAME 未运行"
	  rm -f $PID_FILE
	  exit 0
	fi
  else
    log_message "WARN" "$APP_NAME 未运行"
	exit 0
  fi
}

# 重启应用程序
restart() {
  stop
  start
}

# 查看日志
show_log() {
  if [ "$LOG_ENABLED" = true ]; then
    if [ -f "$LOG_LINK" ]; then
      tail -300f "$LOG_LINK"
    else
      log_message "WARN" "日志文件不存在: $LOG_LINK"
    fi
  else
    log_message "WARN" "日志功能未启用"
  fi
}

# 清理旧日志
clean_logs() {
  if [ "$LOG_CLEANUP_ENABLED" = true ]; then
    log_message "INFO" "清理日志文件..."
    find "$LOG_DIR" -type f -name "*.log" -mtime +$LOG_RETENTION_DAYS -exec rm -f {} \;
    log_message "INFO" "日志清理完成"
  else
    log_message "WARN" "日志清理功能未启用"
  fi
}

# 打印使用说明
usage() {
  log_message "INFO" "用法: $0 {start|stop|restart|status|log|clean}"
  log_message "INFO" "  start   - 启动应用程序"
  log_message "INFO" "  stop    - 停止应用程序"
  log_message "INFO" "  restart - 重启应用程序"
  log_message "INFO" "  status  - 查看应用程序状态"
  log_message "INFO" "  log     - 查看应用程序日志"
  log_message "INFO" "  clean   - 清理旧的日志文件"
  exit 1
}

# 解析命令行参数
case "$1" in
  start)
    start
    ;;
  stop)
    stop
    ;;
  restart)
    restart
    ;;
  status)
    status
    ;;
  log)
    show_log
    ;;
  clean)
    clean_logs
    ;;
  *)
    usage
    ;;
esac

exit 0

