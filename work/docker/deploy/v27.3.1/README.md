# Docker

Docker 是一个开源的容器化平台，通过容器技术实现应用的打包、分发和运行。它使开发者能够以一致的环境快速部署和扩展应用，无需关心底层系统差异。Docker 提供了轻量级、高性能的虚拟化方式，支持镜像管理和容器编排，是 DevOps 和微服务架构的核心工具之一。

- [官网链接](https://www.docker.com)

## 安装Docker

**下载软件包**

```
wget https://download.docker.com/linux/static/stable/x86_64/docker-27.3.1.tgz
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
  "registry-mirrors": ["https://docker.rainbond.cc"]
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
After=network-online.target docker.socket
Wants=network-online.target
[Service]
Type=notify
ExecStart=/usr/bin/dockerd
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
wget https://github.com/docker/buildx/releases/download/v0.19.2/buildx-v0.19.2.linux-amd64
```

**安装插件**

```
mkdir -p ~/.docker/cli-plugins
cp buildx-v0.19.2.linux-amd64 ~/.docker/cli-plugins/docker-buildx
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
wget https://github.com/docker/compose/releases/download/v2.31.0/docker-compose-linux-x86_64
```

**安装软件包**

```
chmod +x docker-compose-linux-x86_64
sudo cp docker-compose-linux-x86_64 /usr/bin/docker-compose
```

**查看版本**

```
$ docker-compose version
Docker Compose version v2.31.0
```

