#!/bin/bash

## 数据库信息
MYSQL_HOST=192.168.1.10
MYSQL_PORT=35725
MYSQL_USER=root
MYSQL_PASS=Admin@123
MYSQL_DATABASE=kongyu
## MYSQL_TABLES 参数为空就默认导出整个库，例如：MYSQL_TABLES="tb_account user"
MYSQL_TABLES=""
## 导出参数：--no-data 只导出表结构
MYSQL_DUMP_OPTIONS="--routines --events --triggers --single-transaction --flush-logs"
## 数据库备份位置
BACKUPS_DIR="/data/backups/mysql"
BACKUPS_FILE="${MYSQL_DATABASE}_$(date +%Y-%m-%d-%H-%M-%S).sql"
## 备份输出日志
LOG_FILE="bakckups.log"
## 备份文件保存的天数
BACKUP_SAVE_DAY=30
## 是否压缩
IS_COMPRESS=true

## 数据预处理
function transform_data() {
    ## 确保目录有效性
    BACKUPS_DIR=$(echo "${BACKUPS_DIR%%/}")
    BACKUPS_FILE="${BACKUPS_DIR}/${BACKUPS_FILE}"
    LOG_FILE="${BACKUPS_DIR}/${LOG_FILE}"
    [[ -d "${BACKUPS_DIR}" ]] || mkdir -p ${BACKUPS_DIR} && touch ${LOG_FILE}
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
        echo -e "\033[34m [$(date +'%Y-%m-%d %H:%M:%S')] INFO: Backup status：\033[0m\033[32msucceed!\033[0m" | tee -a ${LOG_FILE}
    else
        rm -rf ${BACKUPS_FILE}
        echo -e "\033[34m [$(date +'%Y-%m-%d %H:%M:%S')] INFO: Backup status：\033[0m\033[31mfailed!\033[0m" | tee -a ${LOG_FILE}
    fi
}

## 保留每年最后一个文件，其余文件删除
function delete_year_old() {
    ## 处理所有的文件
    select_files=$(realpath ${BACKUPS_DIR}/*)
    ## 查看文件的年份
    years=$(ls ${select_files} --full-time --time-style=long-iso -t | awk '{print $6}' | awk -F "-" '{print $1}' | uniq)
    delete_files=""
    for year in ${years}
    do
        ## 一年内的文件不做处理
        if [[ $(date "+%Y") == ${year} ]]
        then
            continue
        fi
        
        ## 查看每年的文件
        files_in_year=$(ls ${select_files} --full-time --time-style=long-iso -t | awk '{print $6" "$8}' | grep ${year}- | awk '{print $2}')
        count=0
        for file_in_year in ${files_in_year}
        do
            ## 只保留每年最后一个文件
            ((count++))
            if [[ $count == 1 ]]
            then
                continue
            fi
            delete_files="${delete_files} ${file_in_year}"
     
        done
    done
    ## 其余文件删除
    if [ -n "${delete_files}" ]
    then
        echo -e "\033[34m [$(date +'%Y-%m-%d %H:%M:%S')] INFO: Delete backups (years)\033[0m" | tee -a ${LOG_FILE}
        echo -e "$(echo ${delete_files} | tr " " "\n" | sed "s#^#\\\033[1;34m [$(date +'%Y-%m-%d %H:%M:%S')] INFO:\\0\\\033[1;37m Delete file --> #" | sed 's#$#\\033[0m#')" | tee -a ${LOG_FILE}
        rm -rf ${delete_files}
    fi
}

## 保留每月最后一个文件，其余文件删除
function delete_month_old() {
    ## 只处理本年内的文件
    select_files=$(find ${BACKUPS_DIR}/* -mtime -365)
    ## 查看文件的月份
    months=$(ls ${select_files} --full-time --time-style=long-iso -t | awk '{print $6}' | awk -F "-" '{print $1"-"$2}' | uniq)
    delete_files=""
    for month in ${months}
    do
        ## 一个月内的文件不做处理
        if [[ $(date "+%Y-%m") == ${month} ]]
        then
            continue
        fi
        
        ## 查看每月的文件
        files_in_month=$(ls ${select_files} --full-time --time-style=long-iso -t | awk '{print $6" "$8}' | grep ${month}- | awk '{print $2}')
        count=0
        for file_in_month in ${files_in_month}
        do
            ## 只保留每月最后一个文件
            ((count++))
            if [[ $count == 1 ]]
            then
                continue
            fi
            delete_files="${delete_files} ${file_in_month}"
            
        done
    done
    ## 其余文件删除
    if [ -n "${delete_files}" ]
    then
        echo -e "\033[34m [$(date +'%Y-%m-%d %H:%M:%S')] INFO: Delete backups (months)\033[0m" | tee -a ${LOG_FILE}
        echo -e "$(echo ${delete_files} | tr " " "\n" | sed "s#^#\\\033[1;34m [$(date +'%Y-%m-%d %H:%M:%S')] INFO:\\0\\\033[1;37m Delete file --> #" | sed 's#$#\\033[0m#')" | tee -a ${LOG_FILE}
        rm -rf ${delete_files}
    fi
}

## 保留指定天数最后一个文件，其余文件删除
function delete_save_old() {
    ## 只处理本月内的文件
    select_files=$(find ${BACKUPS_DIR}/* -mtime -30)
    ## 保留指定天数内的文件
    save_files=$(find ${BACKUPS_DIR}/* -mtime -${BACKUP_SAVE_DAY})
    ## 计算出需要处理的文件
    new_select_files=${select_files}
    for save_file in ${save_files}
    do
        new_select_files="$(echo ${new_select_files} | sed "s#${save_file}##g")"
    done
    ## 如果为空则跳过
    if [ -z "${new_select_files}" ]
    then
        return
    fi
    ## 保留最新的一个文件，其余文件删除
    files_out_save=$(ls ${new_select_files} --full-time --time-style=long-iso -t | sed "1d" | awk '{print $8}')
    if [ -n "${files_out_save}" ]
    then
        echo -e "\033[34m [$(date +'%Y-%m-%d %H:%M:%S')] INFO: Delete backups (days)\033[0m" | tee -a ${LOG_FILE}
        echo -e "$(echo ${files_out_save} | tr " " "\n" | sed "s#^#\\\033[1;34m [$(date +'%Y-%m-%d %H:%M:%S')] INFO:\\0\\\033[1;37m Delete file --> #" | sed 's#$#\\033[0m#')" | tee -a ${LOG_FILE}
        rm -rf ${files_out_save}
    fi
}


function delete_old_files() {
    ## 日：在一个月时间范围内，超过指定天数的，保留指定天数内的文件，其余文件只保留最后备份的一个
    ## 月：在一年时间范围内，超过一个月的，每个月的文件只保留最后备份的一个
    ## 年：当备份文件的时间大于一年的，每年只保留最后备份的一个

    ## 保留每年最后一个文件，其余文件删除
    delete_year_old

    ## 保留每月最后一个文件，其余文件删除
    delete_month_old

    ## 保留指定天数外的最后一个文件，其余文件删除
    delete_save_old
}

## 数据预处理
transform_data

## 删除备份文件
delete_old_files

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

## 制作数据
:<<!
for year in {2000..2022}
do
    for month in {01..07}
    do
        for day in {01..06}
        do
            touch -t ${year}${month}${day}1112 test-${year}${month}${day}1112
        done
    done
done
!
