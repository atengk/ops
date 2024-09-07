#!/bin/bash

## 数据库信息
export POSTGRESQL_HOST=${POSTGRESQL_HOST:-192.168.1.10}
export POSTGRESQL_PORT=${POSTGRESQL_PORT:-32297}
export POSTGRESQL_USER=${POSTGRESQL_USER:-postgres}
export POSTGRESQL_PASS=${POSTGRESQL_PASS:-Lingo@local_postgresql_5432}
export PGPASSWORD=$POSTGRESQL_PASS
export POSTGRESQL_DATABASE=${POSTGRESQL_DATABASE:-kongyu}
export POSTGRESQL_SCHEMA=${POSTGRESQL_SCHEMA:-public}
## POSTGRESQL_TABLES 参数为空就默认导出整个库，例如：POSTGRESQL_TABLES="tb_account user"
export POSTGRESQL_TABLES=${POSTGRESQL_TABLES:-}
## 导出参数：--no-data 只导出表结构
export POSTGRESQL_DUMP_OPTIONS=${POSTGRESQL_DUMP_OPTIONS:---inserts --no-owner --no-privileges}
## MinIO信息
export MINIO_SERVER_HOST=${MINIO_SERVER_HOST:-http://192.168.1.12:9000}
export MINIO_SERVER_ACCESS_KEY=${MINIO_SERVER_ACCESS_KEY:-admin}
export MINIO_SERVER_SECRET_KEY=${MINIO_SERVER_SECRET_KEY:-Lingo@local_minio_9000}
export MINIO_SERVER_BUCKET=${MINIO_SERVER_BUCKET:-service-backups}
## 数据库备份位置
export BACKUPS_DIR=${BACKUPS_DIR:-/opt}
export BACKUPS_FILE=${BACKUPS_FILE:-${POSTGRESQL_DATABASE}_$(date +%Y-%m-%d-%H-%M-%S).sql}
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
    if [[ -z "${POSTGRESQL_TABLES}" ]]
    then
        pg_dump -U ${POSTGRESQL_USER} -h ${POSTGRESQL_HOST} -p ${POSTGRESQL_PORT} -d ${POSTGRESQL_DATABASE} > ${BACKUPS_FILE} 2> /dev/null
    else
        tables=""
        for table in ${POSTGRESQL_TABLES}
        do
            tables="${tables} -t ${POSTGRESQL_SCHEMA}.${table}"
        done
        pg_dump -U ${POSTGRESQL_USER} -h ${POSTGRESQL_HOST} -p ${POSTGRESQL_PORT} -d ${POSTGRESQL_DATABASE} ${tables} > ${BACKUPS_FILE} 2> /dev/null
    fi
    ## 判断备份是否执行成功
    if [[ "$?" == "0" ]]
    then
        [[ "${IS_COMPRESS}" == "true" ]] && gzip ${BACKUPS_FILE}
        mcli cp -r -q ${BACKUPS_FILE}* minio/${MINIO_SERVER_BUCKET}/postgresql
        ## 设置生命周期
        is_ilm=$(mcli ilm ls minio/${MINIO_SERVER_BUCKET} 2> /dev/null | grep postgresql)
        if [[ -z "${is_ilm}" ]]
        then
            mcli ilm add --expiry-days ${BACKUP_SAVE_DAY} minio/${MINIO_SERVER_BUCKET}/postgresql
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

## 定时任务
:<<!
## 每天凌晨12点备份
0 0 * * * /bin/bash /data/shell/mariadb_bakckup.sh

## 每周六凌晨12点备份
0 0 * * 6 /bin/bash /data/shell/mariadb_bakckup.sh

systemctl restart crond
!
