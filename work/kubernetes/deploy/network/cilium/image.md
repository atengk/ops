# 下载镜像

镜像列表

```
app=cilium
version=v1.16.3
cat > images-list.txt <<EOF
quay.io/cilium/operator-generic:${version}
quay.io/cilium/operator:${version}
quay.io/cilium/cilium:${version}
quay.io/cilium/hubble-relay:${version}
quay.io/cilium/cilium-envoy:v1.29.9-1728346947-0d05e48bfbb8c4737ec40d5781d970a550ed2bbd
quay.io/cilium/hubble-ui:v0.13.1
quay.io/cilium/hubble-ui-backend:v0.13.1
quay.io/cilium/certgen:v0.2.0
docker.io/library/busybox:1.36.1
quay.io/cilium/startup-script:c54c7edeab7fde4da68e59acd319ab24af242c3f
quay.io/cilium/clustermesh-apiserver:${version}
ghcr.io/spiffe/spire-agent:1.9.6
ghcr.io/spiffe/spire-server:1.9.6
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

