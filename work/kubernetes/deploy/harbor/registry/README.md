# Distribution Registry

registry 是一个无状态、高度可扩展的服务器端应用程序，用于存储并允许您分发容器映像和其他内容。该注册表是开源的，遵循 Apache 许可协议。

https://distribution.github.io/distribution/

https://distribution.github.io/distribution/about/configuration/



## 安装软件包

**下载软件包**

```
wget https://github.com/distribution/distribution/releases/download/v2.8.3/registry_2.8.3_linux_amd64.tar.gz
```

**解压软件包**

```
mkdir -p registry_2.8.3
tar -zxvf registry_2.8.3_linux_amd64.tar.gz -C registry_2.8.3
```

**安装软件包**

```
cp registry_2.8.3/registry /usr/local/bin/
```

**查看版本**

```
registry --version
```



## 启动服务

**编辑配置文件**

数据存储在本地目录

```
mkdir -p /etc/registry /data/service/registry
tee /etc/registry/config.yaml <<"EOF"
version: 0.1
log:
  fields:
    service: registry
storage:
    filesystem:
        rootdirectory: /data/service/registry
http:
    addr: :80
EOF
```

数据存储在MinIO

```
mkdir -p /etc/registry /data/service/registry
tee /etc/registry/config.yaml <<"EOF"
version: 0.1
log:
  fields:
    service: registry
storage:
  s3:
    accesskey: admin
    secretkey: Lingo@local_minio_9000
    region: us-east-1
    bucket: test
    regionendpoint: http://192.168.1.13:9000
    forcepathstyle: true
    secure: false
    v4auth: true
    chunksize: 5242880
    rootdirectory: /registry
http:
    addr: :80
EOF
```

**配置systemd**

```
tee /etc/systemd/system/registry.service <<"EOF"
[Unit]
Description=v2 Registry server for Container
After=network.target
[Service]
Type=simple
ExecStart=/usr/local/bin/registry serve /etc/registry/config.yaml
Restart=on-failure
[Install]
WantedBy=multi-user.target
EOF
```

**启动服务**

```
systemctl daemon-reload
systemctl enable --now registry
```



## 上传镜像

**配置映射**

方便后期迁移镜像

```
echo "192.168.1.101 registry.lingo.local" >> /etc/hosts
```

**上传镜像到仓库**

```
docker pull nginx
docker tag nginx registry.lingo.local/library/nginx
docker push registry.lingo.local/library/nginx:latest
```

