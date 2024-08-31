# 安装Harbor镜像仓库

https://goharbor.io/docs/2.11.0/install-config/

## 下载并安装软件包

**下载软件包**

下载harbor软件包

```
wget https://github.com/goharbor/harbor/releases/download/v2.11.1/harbor-offline-installer-v2.11.1.tgz
```

下载docker-compose

```
wget https://github.com/docker/compose/releases/download/v2.29.2/docker-compose-linux-x86_64
```

**解压harbor**

```
tar -zxvf harbor-offline-installer-v2.11.1.tgz -C /data/service
```

**安装docker-compose**

```
cp docker-compose-linux-x86_64.docker-compose-linux-x86_64 /usr/local/bin/docker-compose
docker-compose -v
```



## 编辑配置文件

拷贝配置文件

```
cd /data/service/harbor/
cp harbor.yml.tmpl harbor.yml
vi harbor.yml
```

配置域名

```
# 第5行
hostname: registry.lingo.local
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



## 启动Harbor

**运行脚本，启动harbor**

```
./install.sh
```

**设置开启自启**

编辑harbor.service

```
tee /etc/systemd/system/harbor.service <<"EOF"
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
ExecStart=/usr/local/bin/docker-compose -f /data/service/harbor/docker-compose.yml up -d
ExecStop=/usr/local/bin/docker-compose -f /data/service/harbor/docker-compose.yml down
ExecReload=/usr/local/bin/docker-compose -f /data/service/harbor/docker-compose.yml restart

[Install]
WantedBy=multi-user.target
EOF
```

启动服务

```
systemctl daemon-reload
systemctl enable harbor
```



## 访问Harbor

**访问harbor**

```
URL: http://192.168.1.101/
Username: admin
Password: Admin@123
```

**登录harbor**

```
echo "192.168.1.101 registry.lingo.local" >> /etc/hosts
docker login registry.lingo.local -u admin -p Admin@123
```

**上传镜像**

```
docker pull nginx
docker tag nginx registry.lingo.local/library/nginx
docker push registry.lingo.local/library/nginx:latest
```

**退出登录**

```
docker logout registry.lingo.local
```

