#!/bin/bash

docker build -t swr.cn-north-1.myhuaweicloud.com/kongyu/kubevirt/linux:openeuler-24.03-lts-x86_64 .

docker push swr.cn-north-1.myhuaweicloud.com/kongyu/kubevirt/linux:openeuler-24.03-lts-x86_64
