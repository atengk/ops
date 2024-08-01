#!/bin/bash

## ETCD信息，只能选择一个节点备份数据
export ETCDCTL_API=${ETCDCTL_API:-3}
export ETCDCTL_ENDPOINTS=${ETCDCTL_ENDPOINTS:-https://192.168.1.12:2379}
export ETCDCTL_CACERT=${ETCDCTL_CACERT:-/etc/ssl/etcd/ca.pem}
export ETCDCTL_KEY=${ETCDCTL_KEY:-/etc/ssl/etcd/etcd-client-key.pem}
export ETCDCTL_CERT=${ETCDCTL_CERT:-/etc/ssl/etcd/etcd-client.pem}
## MinIO信息
export MINIO_SERVER_HOST=${MINIO_SERVER_HOST:-http://192.168.1.101:9000}
export MINIO_SERVER_ACCESS_KEY=${MINIO_SERVER_ACCESS_KEY:-admin}
export MINIO_SERVER_SECRET_KEY=${MINIO_SERVER_SECRET_KEY:-Admin@123}
export MINIO_SERVER_BUCKET=${MINIO_SERVER_BUCKET:-service-backups}
## 备份位置
export BACKUPS_DIR=${BACKUPS_DIR:-/opt}
export BACKUPS_FILE=${BACKUPS_FILE:-etcd_$(date +%Y-%m-%d-%H-%M-%S).db}
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
    etcdctl snapshot save ${BACKUPS_FILE}
    ## 判断备份是否执行成功
    if [[ "$?" == "0" ]]
    then
        [[ "${IS_COMPRESS}" == "true" ]] && gzip ${BACKUPS_FILE}
        mcli cp -r -q ${BACKUPS_FILE}* minio/${MINIO_SERVER_BUCKET}/etcd
        ## 设置生命周期
        is_ilm=$(mcli ilm ls minio/${MINIO_SERVER_BUCKET} 2> /dev/null | grep etcd)
        if [[ -z "${is_ilm}" ]]
        then
            mcli ilm add --expiry-days ${BACKUP_SAVE_DAY} minio/${MINIO_SERVER_BUCKET}/etcd
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
0 0 * * * /data/shell/backup-etcd-to-local.sh

## 每周六凌晨12点备份
0 0 * * 6 /data/shell/backup-etcd-to-local.sh

systemctl restart crond
!
