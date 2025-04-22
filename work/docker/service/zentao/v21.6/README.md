# ZenTao

禅道（ZenTao）是一款专注于项目管理和开发流程管理的开源软件，主要应用于软件开发领域。它由易软天创开发，提供了从项目规划、需求管理、任务分配、测试管理、到发布跟踪的完整解决方案。禅道采用PHP语言开发，支持MySQL作为数据库，界面友好且易于定制。

- [官网地址](https://zentao.net/)



**前提条件**

- 需要 [mysql](/work/docker/service/mysql/) 数据库

```
export MYSQL_PWD=Admin@123
mysql -h192.168.1.13 -P20001 -uroot
CREATE DATABASE ateng_zentao;
```

**下载镜像**

```
docker pull easysoft/zentao:21.6
```

**推送到仓库**

```
docker tag easysoft/zentao:21.6 registry.lingo.local/service/zentao:21.6
docker push registry.lingo.local/service/zentao:21.6
```

**保存镜像**

```
docker save registry.lingo.local/service/zentao:21.6 | gzip -c > image-zentao_21.6.tar.gz
```

**创建目录**

```
sudo mkdir -p /data/container/zentao
```

**运行服务**

修改以下配置：

- `ZT_MYSQL_*`: MySQL的信息
- `-v /data/container/zentao:/data`: 挂载数据目录

```
docker run -d --name ateng-zentao \
  -p 20024:80 --restart=always \
  -e ZT_MYSQL_HOST="192.168.1.13" \
  -e ZT_MYSQL_PORT="20001" \
  -e ZT_MYSQL_USER="root" \
  -e ZT_MYSQL_PASSWORD="Admin@123" \
  -e ZT_MYSQL_DB="ateng_zentao" \
  -v /data/container/zentao:/data \
  registry.lingo.local/service/zentao:21.6
```

**查看日志**

```
docker logs -f ateng-zentao
```

**使用服务**

访问 Web 服务，安装引导初始化系统

```
URL: http://192.168.1.12:20024
```

**删除服务**

停止服务

```
docker stop ateng-zentao
```

删除服务

```
docker rm ateng-zentao
```

删除数据目录

```
sudo rm -rf /data/container/zentao
```

