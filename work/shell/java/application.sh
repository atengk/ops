#!/bin/bash

## 应用程序主目录
APP_DIR="/root/application"
## 应用程序jar包名
APP_NAME="helloworld.jar"
## 应用程序配置文件
APP_CONFIG="application-dev.properties"
## 应用程序日志文件
APP_LOG="helloworld.log"
## java虚拟机启动参数
JAVA_OPTS="-server -Xms8g -Xmx8g -Dfile.encoding=UTF-8"

## 数据预处理
function transform_data() {
    ## 确保目录有效性
    APP_DIR=$(echo "${APP_DIR%%/}")
    APP_FILE="${APP_DIR}/${APP_NAME}"
    APP_CONFIG="${APP_DIR}/${APP_CONFIG}"
    APP_LOG="${APP_DIR}/${APP_LOG}"
    [[ -d "${APP_DIR}" ]] || mkdir -p ${APP_DIR}
    if [[ ! -f ${APP_FILE} ]]
    then
        log_error "file does not exist:" "${APP_FILE}" "0"
        exit 1
    fi
}

## 基础日志
function log_info() {
    data=$(log_manyline "$1" "$2" "$3")
    echo -e "[$(date +'%Y-%m-%d %H:%M:%S')] \033[32mINFO:  \033[0m${data}"| tee -a "$APP_LOG"
}

## 警告日志
function log_warning() {
    data=$(log_manyline "$1" "$2" "$3")
    echo -e "[$(date +'%Y-%m-%d %H:%M:%S')] \033[33mWARNING:  \033[0m${data}"| tee -a "$APP_LOG"
}

## 处理多行日志
function log_manyline() {
    head="$1"
    word="$2"
    ## 1：多行；0：单行
    if [[ "$3" == "1" ]]
    then
        word="$(echo -e "$word" | sed 's#^#\\033[37m----------------------------> \\033[0m#')"
        data="\033[1;36m${head}\033[0m\n${word}"
    else
        data="\033[1;36m${head}\033[0m ${word}"
    fi
    echo -n "${data}"
}

## 使用说明，用来提示输入参数
function script_usage() {
    echo "Usage: sh $0 [start|stop|restart|status|logs]"
    exit 1
}

## 检查程序是否在运行
function app_is_exist() {
    ## 获取程序的PID
    pid=$(ps -ef | grep ${APP_FILE} | grep -v grep | awk '{print $2}')
    ## 如果不存在返回1，存在返回0
    if [ -z "${pid}" ]; then
        return 1
    else
        return 0
    fi
}

## 启动应用程序
function app_start(){
    app_is_exist
    if [ $? -eq "0" ]; then
        log_warning "${APP_NAME} is already running. pid is ${pid}"
    else
        nohup java ${JAVA_OPTS} -Dspring.config.location=${APP_CONFIG} -jar ${APP_FILE} &>> ${APP_LOG} &
        log_info "${APP_NAME} started. pid is $!"
    fi
}

## 停止应用程序
function app_stop(){
    app_is_exist
    if [ $? -eq "0" ]; then
        kill -9 $pid
        log_info "${APP_NAME} stopped"
    else
	    log_warning "${APP_NAME} is not running"
    fi
}

## 查看应用程序状态
function app_status(){
    app_is_exist
    if [ $? -eq "0" ]; then
        log_info "${APP_NAME} is running. pid is ${pid}"
    else
        log_warning "${APP_NAME} is not running"
    fi
}

## 重启应用程序
function app_restart(){
    app_stop
    app_start
}

## 查看应用程序日志
function app_tail_log() {
    tail -200f ${APP_LOG}
}


## 根据输入参数，选择执行对应方法，不输入则执行使用说明
case "$1" in
    "start")
        transform_data
        app_start
    ;;
    "stop")
        transform_data
        app_stop
    ;;
    "status")
        transform_data
        app_status
    ;;
    "restart")
        transform_data
        app_restart
    ;;
    "logs" | "log" | "tail")
        app_tail_log
    ;;
    *)
        script_usage
    ;;
esac

