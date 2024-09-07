#!/bin/bash

docker build -t swr.cn-north-1.myhuaweicloud.com/kongyu/kubevirt/linux:centos-7-x86_64-genericcloud-2009 .

docker push swr.cn-north-1.myhuaweicloud.com/kongyu/kubevirt/centos:centos7.9.2009
