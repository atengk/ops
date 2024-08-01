# 安装harbor镜像仓库



解压harbor

```
mkdir -p /data/service/
tar -zxvf harbor-offline-installer-v2.5.4.tgz -C /data/service/
cd /data/service/harbor
```

安装docker-compose

```
cp docker-compose-linux-v2.10.2-x86_64 /usr/local/bin/docker-compose
docker-compose -v
```

运行脚本，启动harbor

```
./install.sh --with-chartmuseum
```

设置开启自启

```
cp harbor.service /etc/systemd/system/
systemctl daemon-reload
systemctl enable harbor
```

访问harbor

```
URL: http://192.168.1.101/
Username: admin
Password: Admin@123
```

登录harbor

```
## 配置hosts映射
echo "192.168.1.101 registry.lingo.local" >> /etc/hosts
docker login registry.lingo.local -u admin -p Admin@123
```

退出登录

```
docker logout registry.lingo.local
```

