# 安装Docker

安装依赖

```
yum -y install iptables procps xz
```

解压并安装软件包

```
tar -zxvf docker-v27.0.2-binary.tar.gz -C /usr/bin/
```

编辑配置文件

```
mkdir -p /etc/docker
cat > /etc/docker/daemon.json <<"EOF"
{
  "bip": "10.128.0.1/16",
  "data-root": "/data/service/docker",
  "features": { "buildkit": true },
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "200m",
    "max-file": "5"
  },
  "exec-opts": ["native.cgroupdriver=systemd"],
  "insecure-registries": ["0.0.0.0/0"],
  "registry-mirrors": ["https://docker.rainbond.cc"]
}
EOF
```

使用systemd管理服务

```
cat > /etc/systemd/system/docker.service <<"EOF"
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
RestartSec=2
Restart=always
StartLimitBurst=3
StartLimitInterval=60s
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

systemctl daemon-reload
systemctl start docker
systemctl enable docker
systemctl status docker
```

查看服务

```
docker info
```

配置自动补全

```
yum -y install bash-completion
source /usr/share/bash-completion/bash_completion
cp bash_completion /etc/bash_completion.d/docker
source <(cat /etc/bash_completion.d/docker)
```

