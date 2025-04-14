# kkFileView

kkFileView为文件文档在线预览解决方案，该项目使用流行的spring boot搭建，易上手和部署，基本支持主流办公文档的在线预览，如doc,docx,xls,xlsx,ppt,pptx,pdf,txt,zip,rar,图片,视频,音频等等

- [官网链接](https://www.kkview.cn/zh-cn/index.html)

- [镜像构建文档](/work/docker/dockerfile/kkfileview/v4.4.0/)



**运行服务**

```
docker run -d --name ateng-kkfileview \
  -p 20023:8012 --restart=always \
  registry.lingo.local/service/kkfileview:v4.4.0
```

**查看日志**

```
docker logs -f ateng-kkfileview
```

**使用服务**

访问 Web 服务

```
URL: http://192.168.1.12:20023
```

**删除服务**

停止服务

```
docker stop ateng-kkfileview
```

删除服务

```
docker rm ateng-kkfileview
```

