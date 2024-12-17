# Distribution Registry

registry 是一个无状态、高度可扩展的服务器端应用程序，用于存储并允许您分发容器映像和其他内容。该注册表是开源的，遵循 Apache 许可协议。

- [官方文档](https://distribution.github.io/distribution/about/configuration/)



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
sudo cp registry_2.8.3/registry /usr/bin/
```

**查看版本**

```
registry --version
```



## 启动服务

**编辑配置文件**

数据存储在本地目录

```
sudo mkdir -p /etc/registry /data/service/registry
sudo tee /etc/registry/config.yaml <<"EOF"
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
sudo mkdir -p /etc/registry
sudo tee /etc/registry/config.yaml <<"EOF"
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
sudo tee /etc/systemd/system/registry.service <<"EOF"
[Unit]
Description=v2 Registry server for Container
After=network.target
[Service]
Type=simple
Restart=on-failure
RestartSec=10
ExecStart=/usr/bin/registry serve /etc/registry/config.yaml
ExecStop=/bin/kill -SIGTERM $MAINPID
KillSignal=SIGTERM
TimeoutStopSec=60
[Install]
WantedBy=multi-user.target
EOF
```

**启动服务**

```
sudo systemctl daemon-reload
sudo systemctl enable --now registry
```



## 上传镜像

**配置映射**

方便后期迁移镜像

```
echo "192.168.1.101 registry.ateng.local" >> /etc/hosts
```

**上传镜像到仓库**

```
docker pull nginx
docker tag nginx registry.ateng.local/library/nginx
docker push registry.ateng.local/library/nginx:latest
```



## 配置HTTPS

**获取证书**

参考文档 [创建证书](/work/service/tls/tls-openssl/) 得到证书，注意修改服务端证书的域名

```
ls ateng-ca.crt ateng-server.crt ateng-server.key
```

**拷贝证书**

```
sudo mkdir /data/service/registry/certs
sudo cp ateng-ca.crt ateng-server.crt ateng-server.key /data/service/registry/certs
```

**修改配置文件**

修改**http**部分

```
$ sudo vi /etc/registry/config.yaml
http:
  addr: :443
  tls:
    certificate: /data/service/registry/certs/ateng-server.crt
    key: /data/service/registry/certs/ateng-server.key
```

**重启服务**

```
sudo systemctl restart registry
```

**信任证书**

如果不想在配置Docker的 `insecure-registries`，可以配置Docker 信任自签名证书

```
sudo mkdir -p /etc/docker/certs.d/registry.ateng.local
sudo cp ateng-ca.crt /etc/docker/certs.d/registry.ateng.local/ca.crt
sudo systemctl restart docker
```

