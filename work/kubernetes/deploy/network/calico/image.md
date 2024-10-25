# 下载镜像

镜像列表

```
app=calico
version=v3.28.2
cat > images-list.txt <<EOF
quay.io/tigera/operator:v1.34.5
docker.io/calico/typha:${version}
docker.io/calico/pod2daemon-flexvol:${version}
docker.io/calico/node:${version}
docker.io/calico/node-driver-registrar:${version}
docker.io/calico/kube-controllers:${version}
docker.io/calico/ctl:${version}
docker.io/calico/csi:${version}
docker.io/calico/cni:${version}
docker.io/calico/apiserver:${version}
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
	image_local=$(echo ${image} | awk -F "/" '{print "'"${registry_address}"'/calico-"$NF}')
	docker tag ${image} ${image_local}
	docker push ${image_local}
done
```

保存到本地文件

```
images=$(cat images-list.txt | awk -F "/" '{print "'"${registry_address}"'/"$NF}')
docker save $images | gzip -c > images-${app}_${version}.tar.gz
```

