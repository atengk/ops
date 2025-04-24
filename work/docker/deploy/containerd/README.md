# containerd

`containerd` 是一个由 CNCF 托管的高性能容器运行时，用于管理容器的完整生命周期，包括镜像传输、容器执行、存储和网络等功能。它是 Docker 的核心组件之一，也可被 Kubernetes 直接调用，具有轻量、稳定、可扩展等特点，广泛应用于云原生环境中。

- [官网链接](https://containerd.io/)



## 安装containerd

**下载软件包**

```
wget https://github.com/containerd/containerd/releases/download/v1.7.27/containerd-1.7.27-linux-amd64.tar.gz
```

**解压并安装软件包**

```
tar -zxvf containerd-1.7.27-linux-amd64.tar.gz
sudo cp -v bin/* /usr/bin/
rm -rf bin/
```

**编辑配置文件（已弃用）**

```
sudo mkdir -p /etc/containerd
sudo tee /etc/containerd/config.toml <<"EOF"
version = 2
root = "/data/service/container"

[plugins."io.containerd.grpc.v1.cri"]
  sandbox_image = "registry.aliyuncs.com/google_containers/pause:3.9"

  [plugins."io.containerd.grpc.v1.cri".containerd]
    [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc]
      runtime_type = "io.containerd.runc.v2"
      [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc.options]
        SystemdCgroup = true

  [plugins."io.containerd.grpc.v1.cri".registry]
    insecure_skip_verify = true
    [plugins."io.containerd.grpc.v1.cri".registry.mirrors]
      [plugins."io.containerd.grpc.v1.cri".registry.mirrors."docker.io"]
        endpoint = ["https://docker.m.daocloud.io"]
      [plugins."io.containerd.grpc.v1.cri".registry.mirrors."registry.lingo.local"]
        endpoint = ["http://registry.lingo.local"]
    [plugins."io.containerd.grpc.v1.cri".registry.configs]
      [plugins."io.containerd.grpc.v1.cri".registry.configs."registry.lingo.local".auth]
        username = "admin"
        password = "Admin@123"
      [plugins."io.containerd.grpc.v1.cri".registry.configs."registry.lingo.local".tls]
        insecure_skip_verify = true
EOF
```

如果有私有的仓库是HTTPS可以参考以下配置

```
    [plugins."io.containerd.grpc.v1.cri".registry.configs]
      [plugins."io.containerd.grpc.v1.cri".registry.configs."dockerhub.kubekey.local".auth]
        username = ""
        password = ""
      [plugins."io.containerd.grpc.v1.cri".registry.configs."dockerhub.kubekey.local".tls]
        ca_file = "/etc/docker/certs.d/dockerhub.kubekey.local/ca.crt"
        cert_file = "/etc/docker/certs.d/dockerhub.kubekey.local/dockerhub.kubekey.local.cert"
        key_file = "/etc/docker/certs.d/dockerhub.kubekey.local/dockerhub.kubekey.local.key"
        insecure_skip_verify = false
```

**编辑配置文件**

```
sudo mkdir -p /etc/containerd
sudo tee /etc/containerd/config.toml <<"EOF"
version = 2
root = "/data/service/container"

[plugins."io.containerd.grpc.v1.cri"]
  sandbox_image = "registry.aliyuncs.com/google_containers/pause:3.9"

  [plugins."io.containerd.grpc.v1.cri".containerd]
    [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc]
      runtime_type = "io.containerd.runc.v2"
      [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc.options]
        SystemdCgroup = true

  [plugins."io.containerd.grpc.v1.cri".registry]
    config_path = "/etc/containerd/certs.d"
EOF
```

配置镜像仓库 `docker.io`：配置镜像加速器

```
sudo mkdir -p /etc/containerd/certs.d/docker.io
sudo tee /etc/containerd/certs.d/docker.io/hosts.toml <<"EOF"
server = "https://docker.io"
[host."https://docker.m.daocloud.io"]
  capabilities = ["pull", "resolve"]
EOF
```

配置镜像仓库 `registry.lingo.local`：配置 HTTP 私有仓库

```
sudo mkdir -p /etc/containerd/certs.d/registry.lingo.local
sudo tee /etc/containerd/certs.d/registry.lingo.local/hosts.toml <<"EOF"
server = "http://registry.lingo.local"
[host."http://registry.lingo.local"]
  capabilities = ["pull", "push", "resolve"]
EOF
```

配置镜像仓库 `registry.ateng.local`：配置 HTTPS 私有仓库 + 跳过 TLS

```
sudo mkdir -p /etc/containerd/certs.d/registry.ateng.local
sudo tee /etc/containerd/certs.d/registry.ateng.local/hosts.toml <<"EOF"
server = "https://registry.ateng.local"
[host."https://registry.lingo.local"]
  capabilities = ["pull", "push", "resolve"]
  skip_verify = true
EOF
```

配置镜像仓库 `registry.ateng.local`：配置 HTTPS 私有仓库 + TLS证书

```
sudo mkdir -p /etc/containerd/certs.d/registry.ateng.local
sudo tee /etc/containerd/certs.d/registry.ateng.local/hosts.toml <<"EOF"
server = "https://registry.ateng.local"
[host."https://registry.ateng.local"]
  capabilities = ["pull", "push", "resolve"]
  ca = "/etc/containerd/certs.d/registry.ateng.local/ca.crt"
  client_cert = "/etc/containerd/certs.d/registry.ateng.local/client.cert"
  client_key = "/etc/containerd/certs.d/registry.ateng.local/client.key"
EOF
```

配置镜像仓库 `http://192.168.1.13`：局域网段 IP

```
sudo mkdir -p /etc/containerd/certs.d/192.168.1.13
sudo tee /etc/containerd/certs.d/192.168.1.13/hosts.toml <<"EOF"
server = "http://192.168.1.13"
[host."http://192.168.1.13"]
  capabilities = ["pull", "push", "resolve"]
  skip_verify = true
EOF
```



**使用systemd管理服务**

编辑 `containerd.service` 

```
sudo tee /etc/systemd/system/containerd.service <<"EOF"
[Unit]
Description=containerd container runtime
Documentation=https://containerd.io
After=network.target dbus.service
[Service]
ExecStartPre=-/sbin/modprobe overlay
ExecStart=/usr/bin/containerd --config /etc/containerd/config.toml
Type=notify
Delegate=yes
KillMode=process
Restart=always
RestartSec=5
LimitNPROC=infinity
LimitCORE=infinity
TasksMax=infinity
OOMScoreAdjust=-999
[Install]
WantedBy=multi-user.target
EOF
```

启动服务

```
sudo systemctl daemon-reload
sudo systemctl enable --now containerd.service
```

查看状态

```
sudo systemctl status containerd.service
```

查看日志

```
sudo journalctl -f -u containerd.service
```



## 安装runc

`runc` 是一个符合 OCI 标准的容器运行时，负责在 Linux 系统上真正启动和管理容器进程。`containerd` 本身不直接运行容器，它通过调用 `runc` 来实现容器的创建与运行。因此，在使用 containerd 时必须安装 `runc`。

**下载软件包**

```
wget https://github.com/opencontainers/runc/releases/download/v1.2.5/runc.amd64
```

**解压并安装软件包**

```
sudo install -m 755 runc.amd64 /usr/bin/runc
```



## 安装CNI plugins

CNI（Container Network Interface）是一组标准和插件，用于为容器配置网络，如分配 IP、设置路由、桥接等。它由容器运行时（如 containerd）调用，不负责容器管理，仅处理网络接入。CNI 插件是实际执行网络配置的工具，必须安装并放在特定路径下供运行时调用。

**下载软件包**

```
wget https://github.com/containernetworking/plugins/releases/download/v1.6.2/cni-plugins-linux-amd64-v1.6.2.tgz
```

**解压并安装软件包**

```
sudo mkdir -p /opt/cni/bin
sudo tar Cxzvf /opt/cni/bin cni-plugins-linux-amd64-v1.6.2.tgz
```



## 安装BuildKit

BuildKit 是一个用于构建容器镜像的现代化工具，它通过优化构建过程，提供并行化、缓存、增量构建等特性，显著提升构建效率。它支持 Dockerfile 和其他构建方式，能够更高效地生成容器镜像。

**下载软件包**

```
wget https://github.com/moby/buildkit/releases/download/v0.21.0/buildkit-v0.21.0.darwin-amd64.tar.gz
```

**解压并安装软件包**

```
sudo tar -zxvf buildkit-v0.21.0.linux-amd64.tar.gz
sudo cp -v bin/* /usr/bin/
rm -rf bin/
```

**编辑配置文件**

```
sudo mkdir -p /etc/buildkit
sudo tee /etc/buildkit/buildkitd.toml <<EOF
[registry."docker.io"]
  mirrors = ["https://docker.m.daocloud.io"]
EOF
```

**使用systemd管理服务**

编辑 `buildkit.service` 

```
sudo tee /etc/systemd/system/buildkit.service <<EOF
[Unit]
Description=BuildKit
After=network-online.target containerd.service
[Service]
Type=simple
ExecStart=/usr/bin/buildkitd
Restart=on-failure
RestartSec=10
KillMode=control-group
KillSignal=SIGTERM
[Install]
WantedBy=multi-user.target
EOF
```

启动服务

```
sudo systemctl daemon-reload
sudo systemctl enable --now buildkit.service
```

查看状态

```
sudo systemctl status buildkit.service
```

查看日志

```
sudo journalctl -f -u buildkit.service
```



## 安装客户端工具

### nerdctl

`nerdctl` 是基于 containerd 的命令行工具，兼容 Docker 的常用用法，用于管理容器、镜像、网络等。

**下载软件包**

```
wget https://github.com/containerd/nerdctl/releases/download/v2.0.4/nerdctl-2.0.4-linux-amd64.tar.gz
```

**解压并安装软件包**

```
tar -zxvf nerdctl-2.0.4-linux-amd64.tar.gz
sudo mv nerdctl /usr/bin
rm -f containerd-rootless-setuptool.sh containerd-rootless.sh
```



### cri-tools

`crictl` 是 Kubernetes 官方提供的命令行工具，用于与容器运行时接口（CRI）交互，支持 containerd、CRI-O 等。它常用于调试和管理节点上的容器、镜像、Pod 等资源。

**下载软件包**

```
wget https://github.com/kubernetes-sigs/cri-tools/releases/download/v1.33.0/crictl-v1.33.0-linux-amd64.tar.gz
```

**解压并安装软件包**

```
sudo tar -zxvf crictl-v1.33.0-linux-amd64.tar.gz -C /usr/bin
```

**编辑配置文件**

```
sudo tee /etc/crictl.yaml <<"EOF"
runtime-endpoint: unix:///run/containerd/containerd.sock
image-endpoint: unix:///run/containerd/containerd.sock
timeout: 10
debug: false
EOF
```

**使用命令**

```
crictl info
```



## 运行容器

**HelloWorld**

```
nerdctl run --rm hello-world
```

**Nginx**

运行容器

```
nerdctl run --rm \
  --name nginx \
  -p 8080:80 \
  nginx:latest
```

访问服务

```
curl http://localhost:8080
```

**Busybox**

运行容器

```
nerdctl run --rm -it \
  --name busybox \
  busybox:latest \
  sh
```

查看IP信息

```
/ # ip a
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host
       valid_lft forever preferred_lft forever
2: eth0@if8: <BROADCAST,MULTICAST,UP,LOWER_UP,M-DOWN> mtu 1500 qdisc noqueue qlen 1000
    link/ether da:45:67:36:43:43 brd ff:ff:ff:ff:ff:ff
    inet 10.4.0.6/24 brd 10.4.0.255 scope global eth0
       valid_lft forever preferred_lft forever
    inet6 fe80::d845:67ff:fe36:4343/64 scope link
       valid_lft forever preferred_lft forever
```

## 自定义网卡

**编辑配置文件**

```
sudo mkdir -p /etc/cni/net.d/
sudo tee /etc/cni/net.d/10-mynet.conflist <<"EOF"
{
  "cniVersion": "0.4.0",
  "name": "mynet",
  "plugins": [
    {
      "type": "bridge",
      "bridge": "cni0",
      "isGateway": true,
      "ipMasq": true,
      "ipam": {
        "type": "host-local",
        "subnet": "10.128.0.0/16",
        "routes": [
          { "dst": "0.0.0.0/0" }
        ]
      }
    },
    {
      "type": "loopback"
    }
  ]
}
EOF
```

运行容器

```
nerdctl run --rm -it \
  --name busybox --net mynet \
  busybox:latest \
  sh
```

查看IP信息

```
/ # ip a
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host
       valid_lft forever preferred_lft forever
2: eth0@if11: <BROADCAST,MULTICAST,UP,LOWER_UP,M-DOWN> mtu 1500 qdisc noqueue qlen 1000
    link/ether e2:13:86:5b:a9:32 brd ff:ff:ff:ff:ff:ff
    inet 10.128.0.2/16 brd 10.128.255.255 scope global eth0
       valid_lft forever preferred_lft forever
    inet6 fe80::e013:86ff:fe5b:a932/64 scope link
       valid_lft forever preferred_lft forever
```



## 构建镜像

创建 `Dockerfile`

```
mkdir build && cd build
tee Dockerfile <<"EOF"
FROM alpine
CMD ["echo", "Hello from BuildKit"]
EOF
```

构建镜像

```
nerdctl build -t registry.lingo.local/service/alpine:demo .
```

登录镜像仓库

```
nerdctl --insecure-registry login http://registry.lingo.local:80 -u admin
nerdctl login registry.lingo.local -u admin -p Admin@123
```

推送镜像

```
nerdctl --insecure-registry push registry.lingo.local/service/alpine:demo
```

