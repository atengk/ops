# Harbor

Harbor是一个开源的企业级容器镜像仓库，提供安全、高效的镜像管理。它支持镜像的存储、分发和访问控制，支持多种镜像格式（如Docker镜像），并集成了身份认证、角色管理、镜像扫描和复制等功能。Harbor易于部署，可与Kubernetes无缝集成，是构建云原生应用的理想选择。

- [官网链接](https://goharbor.io/docs/2.12.0/install-config/)



## [前置条件](https://atengk.github.io/work/#/work/service/mysql/v8.4.3/?id=前置条件)

- 参考：[基础配置](https://atengk.github.io/work/#/work/service/00-basic/)、[Docker安装文档](/work/docker/deploy/v27.3.1/)



## 下载并安装软件包

**下载软件包**

```
wget https://github.com/goharbor/harbor/releases/download/v2.12.0/harbor-offline-installer-v2.12.0.tgz
```

**解压软件包**

```
tar -zxvf harbor-offline-installer-v2.12.0.tgz -C /data/service
```



## 编辑配置文件

拷贝配置文件

```
cd /data/service/harbor/
cp harbor.yml.tmpl harbor.yml
```

进入配置文件

```
vi harbor.yml
:set nu
```

配置域名

```
# 第5行
hostname: registry.ateng.local
```

关闭HTTPS

```
# 注释第13-20行
```

设置密码

```
# 第47行
harbor_admin_password: Admin@123
```

设置数据目录

```
# 第66行
data_volume: /data/service/harbor/data
```



## 启动服务

**运行脚本，启动服务**

```
sudo ./install.sh
```

- 启用 **Trivy** 作为镜像扫描工具：`sudo ./install.sh --with-trivy`

**设置开启自启**

编辑harbor.service

```
sudo tee /etc/systemd/system/harbor.service <<"EOF"
[Unit]
Description=Harbor
After=docker.service network.service
Requires=docker.service
Documentation=https://github.com/goharbor/harbor

[Service]
Type=oneshot
RemainAfterExit=yes
TimeoutStartSec=0
WorkingDirectory=/data/service/harbor
ExecStart=/usr/bin/docker-compose -f /data/service/harbor/docker-compose.yml up -d
ExecStop=/usr/bin/docker-compose -f /data/service/harbor/docker-compose.yml down
ExecReload=/usr/bin/docker-compose -f /data/service/harbor/docker-compose.yml restart

[Install]
WantedBy=multi-user.target
EOF
```

启动服务

```
sudo systemctl daemon-reload
sudo systemctl enable harbor
```



## 访问Harbor

**访问harbor**

```
URL: http://192.168.1.101/
Username: admin
Password: Admin@123
```

**配置安全仓库**

将仓库地址 `registry.ateng.local` 添加到Docker配置文件的 `insecure-registries`，如下配置文件

```
$ cat /etc/docker/daemon.json
{
  "bip": "10.128.0.1/16",
  "group": "ateng",
  "data-root": "/data/service/container",
  "features": { "buildkit": true },
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "200m",
    "max-file": "5"
  },
  "exec-opts": ["native.cgroupdriver=systemd"],
  "insecure-registries": ["registry.lingo.local", "registry.ateng.local", "192.168.1.0/24"],
  "registry-mirrors": ["https://docker.rainbond.cc"]
}
```

**登录harbor**

```
echo "192.168.1.101 registry.ateng.local" | sudo tee -a /etc/hosts
docker login registry.ateng.local -u admin -p Admin@123
```

**上传镜像**

```
docker pull nginx
docker tag nginx registry.ateng.local/library/nginx
docker push registry.ateng.local/library/nginx:latest
```

**退出登录**

```
docker logout registry.ateng.local
```



## 配置HTTPS

**获取证书**

参考文档 [创建证书](/work/service/tls/tls-openssl/) 得到证书，注意修改服务端证书的域名，需要和harbor配置文件中的hostname一致

```
ls ateng-ca.crt ateng-server.crt ateng-server.key
```

**拷贝证书**

```
mkdir /data/service/harbor/certs
cp ateng-ca.crt ateng-server.crt ateng-server.key /data/service/harbor/certs
```

**修改配置文件**

进入配置文件

```
vi /data/service/harbor/harbor.yml
:set nu
```

开启HTTPS

```
# 修改第13-20行
https:
  port: 443
  certificate: /data/service/harbor/certs/ateng-server.crt
  private_key: /data/service/harbor/certs/ateng-server.key
  strong_ssl_ciphers: true
```

**更新配置**

```
./prepare
```

**重启服务**

```
sudo systemctl restart harbor
```

**信任证书**

如果不想在配置Docker的 `insecure-registries`，可以配置Docker 信任自签名证书

```
sudo mkdir -p /etc/docker/certs.d/registry.ateng.local
sudo cp ateng-ca.crt /etc/docker/certs.d/registry.ateng.local/ca.crt
sudo systemctl restart docker
```

