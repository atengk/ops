#!/bin/bash

## 配置参数
VSFTP_DIR=/opt/vsftp

set -x

## 安装vsftp
yum localinstall -y --disablerepo=* --skip-broken vsftpd/packages/*.rpm

## 修改数据目录
mkdir -p ${VSFTP_DIR}
echo "anon_root=${VSFTP_DIR}" >> /etc/vsftpd/vsftpd.conf

## 启动vsftp
systemctl restart vsftpd
systemctl enable vsftpd
