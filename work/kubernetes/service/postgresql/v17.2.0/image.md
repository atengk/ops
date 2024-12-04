# 下载镜像

镜像列表

```
app=postgresql
version=17.2.0
cat > images-list.txt <<EOF
bitnami/os-shell:12
bitnami/pgpool:4.5.4
bitnami/postgres-exporter:0.16.0
bitnami/postgresql:${version}
bitnami/postgresql-repmgr:${version}
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

