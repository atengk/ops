# Cloudreve 

Cloudreve 是一款开源的网盘系统，支持多种存储后端（如本地存储、阿里云 OSS、腾讯云 COS、OneDrive、S3 等），允许用户轻松搭建属于自己的文件分享和管理平台。它具备用户管理、权限控制、在线播放、目录打包下载等功能，界面美观，操作便捷，适合个人或小型团队使用。

- [官网链接](https://cloudreve.org/)



**下载镜像**

```
docker pull cloudreve/cloudreve:4.0.0-beta.9
```

**推送到仓库**

```
docker tag cloudreve/cloudreve:4.0.0-beta.9 registry.lingo.local/service/cloudreve:4.0.0-beta.9
docker push registry.lingo.local/service/cloudreve:4.0.0-beta.9
```

**保存镜像**

```
docker save registry.lingo.local/service/cloudreve:4.0.0-beta.9 | gzip -c > image-cloudreve_4.0.0-beta.9.tar.gz
```

**创建目录**

```
sudo mkdir -p /data/container/cloudreve
```

**运行服务**

```
docker run -d --name ateng-cloudreve \
  -p 20030:5212 --restart=always \
  -v /data/container/cloudreve:/cloudreve/data \
  registry.lingo.local/service/cloudreve:4.0.0-beta.9
```

**查看日志**

```
docker logs -f ateng-cloudreve
```

**使用服务**

```
URL: http://192.168.1.12:20030
```

![image-20250511101230534](./assets/image-20250511101230534.png)

![image-20250511101514727](./assets/image-20250511101514727.png)

**修改配置文件**

修改更多配置参考：[配置文件](https://docs.cloudreve.org/getting-started/config)

```
vi /data/container/cloudreve/conf.ini
```

修改完后重启服务

```
docker restart ateng-cloudreve
```

**删除服务**

停止服务

```
docker stop ateng-cloudreve
```

删除服务

```
docker rm ateng-cloudreve
```

删除目录

```
sudo rm -rf /data/container/cloudreve
```

