# 下载镜像

镜像列表

```
app=harbor
version=2.12.0
cat > images-list.txt <<EOF
bitnami/os-shell:12
bitnami/nginx:1.27.2
bitnami/harbor-portal:${version}
bitnami/harbor-core:${version}
bitnami/harbor-jobservice:${version}
bitnami/harbor-registry:${version}
bitnami/harbor-registryctl:${version}
bitnami/harbor-adapter-trivy:${version}
bitnami/harbor-exporter:${version}
bitnami/postgresql:14.13.0
bitnami/redis:7.4.1
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

