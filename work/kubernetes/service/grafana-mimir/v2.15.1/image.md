# 下载镜像

镜像列表

```
app=grafana-mimir
version=2.15.1
cat > images-list.txt <<EOF
bitnami/grafana-mimir:${version}
bitnami/nginx:1.27.4
bitnami/os-shell:12
bitnami/memcached:1.6.38
bitnami/minio:2024.11.7
bitnami/minio-client:2024.11.17
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

