# 下载镜像

镜像列表

```
app=cilium
version=1.16.3
cat > images-list.txt <<EOF
bitnami/cilium:${version}
bitnami/cilium-operator:${version}
bitnami/cilium-proxy:1.29.9
bitnami/hubble-relay:${version}
bitnami/hubble-ui:0.13.1
bitnami/hubble-ui-backend:0.13.1
EOF
```

下载镜像

```
images=$(cat images-list.txt)
for image in $images
do
    docker pull $image
done
```

设置镜像仓库和命名空间

```
registry_address="registry.lingo.local/kubernetes"
```

设置镜像标签并推送到本地仓库

```shell
images=$(cat images-list.txt)
for image in $images
do
	image_local=$(echo ${image} | awk -F "/" '{print "'"${registry_address}"'/"$NF}')
	docker tag ${image} ${image_local}
	docker push ${image_local}
done
```

保存到本地文件

```
images=$(cat images-list.txt | awk -F "/" '{print "'"${registry_address}"'/"$NF}')
docker save $images | gzip -c > images-${app}_${version}.tar.gz
```

