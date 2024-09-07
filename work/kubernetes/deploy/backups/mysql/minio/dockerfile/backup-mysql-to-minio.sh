#!/bin/bash

## 数据库信息
export MYSQL_HOST=${MYSQL_HOST:-192.168.1.10}
export MYSQL_PORT=${MYSQL_PORT:-35725}
export MYSQL_USER=${MYSQL_USER:-root}
export MYSQL_PASS=${MYSQL_PASS:-Admin@123}
export MYSQL_DATABASE=${MYSQL_DATABASE:-kongyu}
## MYSQL_TABLES 参数为空就默认导出整个库，例如：MYSQL_TABLES="tb_account user"
export MYSQL_TABLES=${MYSQL_TABLES:-}
## 导出参数：--no-data 只导出表结构
export MYSQL_DUMP_OPTIONS=${MYSQL_DUMP_OPTIONS:---routines --events --triggers --single-transaction --flush-logs}
## MinIO信息
export MINIO_SERVER_HOST=${MINIO_SERVER_HOST:-http://192.168.1.101:9000}
export MINIO_SERVER_ACCESS_KEY=${MINIO_SERVER_ACCESS_KEY:-admin}
export MINIO_SERVER_SECRET_KEY=${MINIO_SERVER_SECRET_KEY:-Admin@123}
export MINIO_SERVER_BUCKET=${MINIO_SERVER_BUCKET:-service-backups}
## 数据库备份位置
export BACKUPS_DIR=${BACKUPS_DIR:-/opt}
export BACKUPS_FILE=${BACKUPS_FILE:-${MYSQL_DATABASE}_$(date +%Y-%m-%d-%H-%M-%S).sql}
## 备份输出日志
export LOG_FILE=${LOG_FILE:-bakckup.log}
## 备份文件保存的天数
export BACKUP_SAVE_DAY=${BACKUP_SAVE_DAY:-100}
## 是否压缩
export IS_COMPRESS=${IS_COMPRESS:-true}

## 数据预处理
function transform_data() {
    ## 确保目录有效性
    BACKUPS_DIR=$(echo "${BACKUPS_DIR%%/}")
    BACKUPS_FILE="${BACKUPS_DIR}/${BACKUPS_FILE}"
    LOG_FILE="${BACKUPS_DIR}/${LOG_FILE}"
    [[ -d "${BACKUPS_DIR}" ]] || mkdir -p ${BACKUPS_DIR} && touch ${LOG_FILE}
    ## 添加MinIO信息
    mcli config host add minio ${MINIO_SERVER_HOST} ${MINIO_SERVER_ACCESS_KEY} ${MINIO_SERVER_SECRET_KEY} --api s3v4
    mcli mb -p minio/${MINIO_SERVER_BUCKET}
}

## 备份函数，传入备份目录
function create_bakckup() {
    echo -e "\033[34m [$(date +'%Y-%m-%d %H:%M:%S')] INFO: Backup path --> ${BACKUPS_FILE} \033[0m" | tee -a ${LOG_FILE}
    ## 开始备份
    ## 判断是否备份整个库
    if [[ -z "${MYSQL_TABLES}" ]]
    then
        mysqldump -h${MYSQL_HOST} -P${MYSQL_PORT} -u${MYSQL_USER} -p${MYSQL_PASS} ${MYSQL_DUMP_OPTIONS} --databases ${MYSQL_DATABASE} > ${BACKUPS_FILE} 2> /dev/null 
    else
        mysqldump -h${MYSQL_HOST} -P${MYSQL_PORT} -u${MYSQL_USER} -p${MYSQL_PASS} ${MYSQL_DUMP_OPTIONS} ${MYSQL_DATABASE} ${MYSQL_TABLES} > ${BACKUPS_FILE} 2> /dev/null
    fi
    ## 判断备份是否执行成功
    if [[ "$?" == "0" ]]
    then
        [[ "${IS_COMPRESS}" == "true" ]] && gzip ${BACKUPS_FILE}
        mcli cp -r -q ${BACKUPS_FILE}* minio/${MINIO_SERVER_BUCKET}/mysql
        ## 设置生命周期
        is_ilm=$(mcli ilm ls minio/${MINIO_SERVER_BUCKET} 2> /dev/null | grep mysql)
        if [[ -z "${is_ilm}" ]]
        then
            mcli ilm add --expiry-days ${BACKUP_SAVE_DAY} minio/${MINIO_SERVER_BUCKET}/mysql
        fi
        echo -e "\033[34m [$(date +'%Y-%m-%d %H:%M:%S')] INFO: Backup status：\033[0m\033[32msucceed!\033[0m" | tee -a ${LOG_FILE}
    else
        rm -rf ${BACKUPS_FILE}
        echo -e "\033[34m [$(date +'%Y-%m-%d %H:%M:%S')] INFO: Backup status：\033[0m\033[31mfailed!\033[0m" | tee -a ${LOG_FILE}
    fi
}

## 数据预处理
transform_data

## 备份数据库
create_bakckup

## 数据恢复
:<<!
mysql -h172.16.0.148 -p3306 -uroot -pAdmin@123 treeFacility < /data/backups/mariadb/treeFacility_2022-07-06-14-47-14.sql
!

## 定时任务
:<<!
## 每天凌晨12点备份
0 0 * * * /bin/bash /data/shell/mariadb_bakckup.sh

## 每周六凌晨12点备份
0 0 * * 6 /bin/bash /data/shell/mariadb_bakckup.sh

systemctl restart crond
!
