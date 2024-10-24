# 下载镜像

下载镜像

```
docker pull bitnami/postgresql:16.4.0
docker pull bitnami/postgresql-repmgr:16.4.0
docker pull bitnami/pgpool:4.5.4
docker pull bitnami/os-shell:12
```

设置镜像仓库和命名空间

```
export registry_address="registry.lingo.local/service"
```

设置镜像标签

```
docker tag bitnami/postgresql:16.4.0 ${registry_address}/postgresql:16.4.0
docker tag bitnami/postgresql-repmgr:16.4.0 ${registry_address}/postgresql-repmgr:16.4.0
docker tag bitnami/pgpool:4.5.4 ${registry_address}/pgpool:4.5.4
docker tag bitnami/os-shell:12 ${registry_address}/os-shell:12
```

推送到本地仓库

```
docker push ${registry_address}/postgresql:16.4.0
docker push ${registry_address}/postgresql-repmgr:16.4.0
docker push ${registry_address}/pgpool:4.5.4
docker push ${registry_address}/os-shell:12
```

保存到本地文件

```
images="${registry_address}/postgresql:16.4.0
${registry_address}/postgresql-repmgr:16.4.0
${registry_address}/pgpool:4.5.4
${registry_address}/os-shell:12"
docker save $images | gzip -c > images-postgresql_16.4.0.tar.gz
```

