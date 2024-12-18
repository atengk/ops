# 下载镜像

下载镜像

```
docker pull selectdb/doris.fe-ubuntu:2.1.6
docker pull selectdb/doris.be-ubuntu:2.1.6
docker pull selectdb/doris.broker-ubuntu:2.1.6
docker pull selectdb/doris.k8s-operator:1.6.1
docker pull selectdb/alpine:latest
```

设置镜像仓库和命名空间

```
export registry_address="registry.lingo.local/service"
```

设置镜像标签

```
docker tag selectdb/doris.fe-ubuntu:2.1.6 ${registry_address}/doris.fe-ubuntu:2.1.6
docker tag selectdb/doris.be-ubuntu:2.1.6 ${registry_address}/doris.be-ubuntu:2.1.6
docker tag selectdb/doris.broker-ubuntu:2.1.6 ${registry_address}/doris.broker-ubuntu:2.1.6
docker tag selectdb/doris.k8s-operator:1.6.1 ${registry_address}/doris.k8s-operator:1.6.1
docker tag selectdb/alpine:latest ${registry_address}/selectdb-alpine:latest
```

推送到本地仓库

```
docker push ${registry_address}/doris.fe-ubuntu:2.1.6
docker push ${registry_address}/doris.be-ubuntu:2.1.6
docker push ${registry_address}/doris.broker-ubuntu:2.1.6
docker push ${registry_address}/doris.k8s-operator:1.6.1
docker push ${registry_address}/selectdb-alpine:latest
```

保存到本地文件

```
images="${registry_address}/doris.fe-ubuntu:2.1.6
${registry_address}/doris.be-ubuntu:2.1.6
${registry_address}/doris.broker-ubuntu:2.1.6
${registry_address}/doris.k8s-operator:1.6.1
${registry_address}/selectdb-alpine:latest"
docker save $images | gzip -c > images-doris_2.1.6.tar.gz
```

