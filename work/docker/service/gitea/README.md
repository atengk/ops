# Gitea

Gitea 是一个轻量级、开源的 Git 代码托管平台，提供类似 GitHub 的功能，如代码托管、版本控制、问题追踪和持续集成等。它易于安装和自托管，适合个人和小型团队使用。Gitea 支持多种语言，具有简洁的界面和高性能的特点。

- [官网链接](https://about.gitea.com/)

**前提条件**

- 需要 `postgresql` 数据库

**下载镜像**

```
docker pull bitnami/gitea:1.22.3
```

**推送到仓库**

```
docker tag bitnami/gitea:1.22.3 registry.lingo.local/bitnami/gitea:1.22.3
docker push registry.lingo.local/bitnami/gitea:1.22.3
```

**保存镜像**

```
docker save registry.lingo.local/bitnami/gitea:1.22.3 | gzip -c > image-gitea_1.22.3.tar.gz
```

**创建目录**

```
sudo mkdir -p /data/container/gitea/data
sudo chown -R 1001 /data/container/gitea
```

**运行服务**

注意以下配置

- Gitea账号密码
- 修改PostgreSQL的认证信息
- HTTP地址：GITEA_ROOT_URL
- SSH地址：GITEA_DOMAIN GITEA_SSH_PORT

```
docker run -d --name ateng-gitea \
  -p 20011:3000 -p 20012:2222 --restart=always \
  -v /data/container/gitea/data:/bitnami/gitea \
  -e GITEA_ADMIN_USER=root \
  -e GITEA_ADMIN_PASSWORD=Admin@123 \
  -e GITEA_ADMIN_EMAIL=2385569970@qq.com \
  -e GITEA_DATABASE_HOST=192.168.1.114 \
  -e GITEA_DATABASE_PORT_NUMBER=20002 \
  -e GITEA_DATABASE_NAME=ateng_gitea \
  -e GITEA_DATABASE_USERNAME=gitea \
  -e GITEA_DATABASE_PASSWORD=Gitea@123 \
  -e GITEA_ROOT_URL=http://192.168.1.114:20011 \
  -e GITEA_DOMAIN=192.168.1.114 \
  -e GITEA_SSH_PORT=20012 \
  -e TZ=Asia/Shanghai \
  registry.lingo.local/bitnami/gitea:1.22.3
```

**查看日志**

```
docker logs -f ateng-gitea
```

**使用服务**

```
HTTP Address: http://192.168.1.114:20011
SSH Address: ssh://gitea@192.168.1.114:20012
Username: root
Password: Admin@123
```

**删除服务**

停止服务

```
docker stop ateng-gitea
```

删除服务

```
docker rm ateng-gitea
```

删除目录

```
sudo rm -rf /data/container/gitea
```

