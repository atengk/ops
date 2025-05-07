# Docker

Docker 是一个开源的容器化平台，通过容器技术实现应用的打包、分发和运行。它使开发者能够以一致的环境快速部署和扩展应用，无需关心底层系统差异。Docker 提供了轻量级、高性能的虚拟化方式，支持镜像管理和容器编排，是 DevOps 和微服务架构的核心工具之一。

- [官网链接](https://www.docker.com)

## 安装Docker

**下载软件包**

```
wget https://download.docker.com/linux/static/stable/aarch64/docker-27.3.1.tgz
```

**安装依赖**

```
sudo yum -y install iptables procps xz
```

**配置内核网络过滤**

加载桥接模块

```
echo "br_netfilter" | sudo tee /etc/modules-load.d/br_netfilter.conf
sudo modprobe br_netfilter
lsmod | grep br_netfilter
```

启动内核的网络过滤（netfilter）模块

```
sudo tee /etc/sysctl.d/99-docker.conf <<EOF
net.bridge.bridge-nf-call-iptables=1
net.bridge.bridge-nf-call-ip6tables=1
EOF
sudo sysctl --system
```

**解压并安装软件包**

```
tar -zxvf docker-27.3.1.tgz
sudo cp -v docker/* /usr/bin/
rm -rf docker/
```

**编辑配置文件**

注意设置 `group` 运行docker的组，他可以修改 `/var/run/docker.sock` 的所属组，以便该组下的用户可以访问docker。如果没有其他用户组设置为root即可。

镜像加速器registry-mirrors：如果无法拉取镜像了，可以考虑换加速器，例如华为云或者阿里云。这里以华为云为例：容器镜像服务→镜像资源→镜像中心→镜像加速器

```
sudo mkdir -p /etc/docker
sudo tee /etc/docker/daemon.json <<"EOF"
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
  "registry-mirrors": ["https://docker.m.daocloud.io"]
}
EOF
```

**使用systemd管理服务**

编辑 `docker.service` 

```
sudo tee /etc/systemd/system/docker.service <<"EOF"
[Unit]
Description=Docker Application Container Engine
Documentation=https://docs.docker.com
After=network-online.target
Wants=network-online.target
[Service]
Type=notify
ExecStart=/usr/bin/dockerd --config-file=/etc/docker/daemon.json
ExecReload=/bin/kill -s HUP $MAINPID
TimeoutSec=0
RestartSec=10
Restart=always
StartLimitBurst=3
StartLimitInterval=100s
LimitNOFILE=infinity
LimitNPROC=infinity
LimitCORE=infinity
TasksMax=infinity
Delegate=yes
KillMode=process
OOMScoreAdjust=-500
[Install]
WantedBy=multi-user.target
EOF
```

启动服务

```
sudo systemctl daemon-reload
sudo systemctl enable --now docker
```

**查看服务**

```
docker info
```

**配置自动补全**

安装 bash-completion

```
sudo yum -y install bash-completion
source /usr/share/bash-completion/bash_completion
```

下载 bash_completion

> [下载地址](https://github.com/docker/cli/blob/v27.3.1/contrib/completion/bash/docker)

```
curl -L -o docker_bash_completion https://raw.githubusercontent.com/docker/cli/refs/tags/v27.3.1/contrib/completion/bash/docker
```

配置自动补全

```
sudo cp docker_bash_completion /etc/bash_completion.d/docker
source <(cat /etc/bash_completion.d/docker)
```



## 安装buildx

builddx是一个Docker CLI插件，用于扩展[BuildKit](https://github.com/moby/buildkit)的构建功能。

- [Github地址](https://github.com/docker/buildx)

**下载插件**

```
wget https://github.com/docker/buildx/releases/download/v0.19.2/buildx-v0.19.2.linux-arm64
```

**安装插件**

```
mkdir -p ~/.docker/cli-plugins
cp buildx-v0.19.2.linux-arm64 ~/.docker/cli-plugins/docker-buildx
chmod +x ~/.docker/cli-plugins/docker-buildx
```

**验证安装**

```
$ docker buildx version
github.com/docker/buildx v0.19.2 1fc5647dc281ca3c2ad5b451aeff2dce84f1dc49
```



## 安装Docker Compose

**下载软件包**

```
wget https://github.com/docker/compose/releases/download/v2.31.0/docker-compose-linux-aarch64
```

**安装软件包**

```
chmod +x docker-compose-linux-aarch64
sudo cp docker-compose-linux-aarch64 /usr/bin/docker-compose
```

**查看版本**

```
$ docker-compose version
Docker Compose version v2.31.0
```



## 客户端远程访问

### 使用SSH

前提：配置免秘钥

**使用默认参数**

```
docker -H ssh://root@10.244.172.126 ps
```

**指定其他参数**

编辑或创建你的 `~/.ssh/config` 文件，添加如下内容：

```
Host mydockerhost
    HostName 10.244.172.126
    Port 22
    User root
    IdentityFile /opt/id_rsa
```

然后使用如下命令：

```
docker -H ssh://mydockerhost ps
```



### 使用API

将下面的 `配置远程API`



## 配置远程API

- [API文档](https://docs.docker.com/engine/api/latest/)

### 启用 Docker 远程 API

Docker 默认只监听本地 Unix socket（`/var/run/docker.sock`），为了使用远程 API，你需要让它监听 TCP 端口。

**修改 Docker 配置**

编辑 `/etc/docker/daemon.json`，添加以下内容：

> ⚠️ 注意：使用 `tcp://0.0.0.0:2375` 是 **不安全的**（没有 TLS 加密），建议仅用于测试或在内网中使用。生产环境应配置 TLS。

```
{
  "hosts": ["unix:///var/run/docker.sock", "tcp://0.0.0.0:2375"]
}
```

然后重启 Docker：

```
sudo systemctl restart docker
```

验证

```
curl http://localhost:2375/version
```



### 使用远程的Docker

**使用参数**

```
docker -H tcp://<远程主机IP>:2375 ps
```

**使用环境变量**

```
export DOCKER_HOST=tcp://192.168.1.100:2375
docker ps
```



### 配置TLS

参考 [openssl创建证书](/work/service/tls/tls-openssl/) 文件生成证书和秘钥

- CA 根证书：ateng-ca.crt
- 服务端证书：ateng-server.crt
- 服务端私钥：ateng-server.key

```
mkdir -p /etc/docker/certs
cp ateng-ca.crt ateng-server.crt ateng-server.key /etc/docker/certs
```

**修改Docker配置文件**

在 Docker 服务器端，编辑 /etc/docker/daemon.json 来启用 TLS 和监听 HTTPS（而非 HTTP）。例如：

```
{
  "hosts": [
    "unix:///var/run/docker.sock",
    "tcp://0.0.0.0:2376"
  ],
  "tlsverify": true,
  "tlscacert": "/etc/docker/certs/ateng-ca.crt",
  "tlscert": "/etc/docker/certs/ateng-server.crt",
  "tlskey": "/etc/docker/certs/ateng-server.key"
}
```

其中：

- `tlsverify`: 启用 TLS 验证
- `tlscacert`: CA证书路径
- `tlscert`: 服务器证书路径
- `tlskey`: 服务器密钥路径

**重启 Docker 服务**

```
sudo systemctl restart docker
```

**客户端使用远程的TLS的Docker**

拷贝证书到客户端并重命名

- `ca.pem` (CA证书)
- `cert.pem` (客户端证书)
- `key.pem` (客户端私钥)

```
mkdir -p /etc/ssl/docker/ca
cp ateng-ca.crt /etc/ssl/docker/ca/ca.pem
cp ateng-server.crt /etc/ssl/docker/ca/cert.pem
cp ateng-server.key /etc/ssl/docker/ca/key.pem
```

使用环境变量指定远程Docker

```
export DOCKER_TLS_VERIFY="1"
export DOCKER_CERT_PATH="/etc/ssl/docker/ca"
export DOCKER_HOST="tcp://10.244.172.126:2376"
docker images
```

使用命令参数定远程Docker

```
docker --tlsverify \
  --tlscacert=/etc/ssl/docker/ca/ca.pem \
  --tlscert=/etc/ssl/docker/ca/cert.pem \
  --tlskey=/etc/ssl/docker/ca/key.pem \
  -H=tcp://10.244.172.126:2376 \
  images
```

