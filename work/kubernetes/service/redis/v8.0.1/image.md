# 下载镜像

镜像列表

```
app=redis
version=8.0.1
cat > images-list.txt <<EOF
bitnami/redis-exporter:1.71.0
bitnami/redis:${version}
bitnami/redis-sentinel:${version}
bitnami/redis-cluster:${version}
bitnami/os-shell:12
bitnami/kubectl:1.33.0
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
registry_address="registry.lingo.local/bitnami"
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

