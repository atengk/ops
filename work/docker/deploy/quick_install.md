# 脚本安装Docker



**安装Docker**

详情参考官网文档：[脚本官网地址](https://linuxmirrors.cn/other/)

```
bash <(curl -sSL https://linuxmirrors.cn/docker.sh)
```



**查看版本**

```
docker version
docker buildx version
docker compose version
```



**修改配置（可选）**

修改配置文件

```
sudo tee /etc/docker/daemon.json <<"EOF"
{
  "bip": "10.128.0.1/16",
  "data-root": "/data/service/container",
  "features": { "buildkit": true },
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "200m",
    "max-file": "5"
  },
  "exec-opts": ["native.cgroupdriver=systemd"],
  "insecure-registries": ["registry.lingo.local", "registry.ateng.local", "192.168.1.0/24"],
  "registry-mirrors": ["https://dockerproxy.net"]
}
EOF
```

重启服务

```
sudo systemctl restart docker
```

查看服务

```
docker info
```

