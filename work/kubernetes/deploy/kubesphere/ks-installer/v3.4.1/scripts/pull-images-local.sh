#!/bin/bash

set -x

# 转换为阿里云镜像仓库
images=$(cat images-list.txt  | grep -v \# | awk -F / '{print $NF}' | sed "s#^#registry.cn-beijing.aliyuncs.com/kubesphereio/#")

# 拉取镜像并上传到本地harbor仓库
for image in $images
do
    docker pull $image
    new_image=$(echo $image | sed "s#registry.cn-beijing.aliyuncs.com/kubesphereio/#registry.lingo.local/kubesphereio/#")
    docker tag $image $new_image
    docker push $new_image
done

