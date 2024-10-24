# 下载镜像

下载镜像

```
docker pull bitnami/sonarqube:10.7.0
docker pull bitnami/os-shell:12
```

设置镜像仓库和命名空间

```
export registry_address="registry.lingo.local/service"
```

设置镜像标签

```
docker tag bitnami/sonarqube:10.7.0 ${registry_address}/sonarqube:10.7.0
docker tag bitnami/os-shell:12 ${registry_address}/os-shell:12
```

推送到本地仓库

```
docker push ${registry_address}/sonarqube:10.7.0
docker push ${registry_address}/os-shell:12
```

保存到本地文件

```
images="${registry_address}/sonarqube:10.7.0
${registry_address}/sonarqube:10.7.0"
docker save $images | gzip -c > images-sonarqube_10.7.0.tar.gz
```

