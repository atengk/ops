# kkFileView

kkFileView为文件文档在线预览解决方案，该项目使用流行的spring boot搭建，易上手和部署，基本支持主流办公文档的在线预览，如doc,docx,xls,xlsx,ppt,pptx,pdf,txt,zip,rar,图片,视频,音频等等

- [官网链接](https://www.kkview.cn/zh-cn/index.html)
- [Git安装文档](/work/service/git/v2.49.0/)
- [JDK安装文档](/work/service/openjdk/openjdk21/)
- [Maven安装文档](/work/service/maven/v3.9.9/)
- [Docker安装文档](/work/docker/deploy/v27.3.1/)



**下载源码包**

从以下链接下载源码包

- https://gitee.com/kekingcn/file-online-preview/releases/tag/v4.4.0

**进入源码**

```
tar -zxvf file-online-preview-v4.4.0.tar.gz
cd file-online-preview-v4.4.0
KK_PWD=$(pwd)
```

**构建基础镜像**

```
cd docker/kkfileview-base/
docker build --tag keking/kkfileview-base:4.4.0 .
```

**编译打包**

```
cd ${KK_PWD}
mvn clean package -DskipTests
```

**构建镜像**

```
docker build -t registry.lingo.local/service/kkfileview:v4.4.0 .
```

**推送镜像到仓库**

```
docker push registry.lingo.local/service/kkfileview:v4.4.0
```

**清理环境**

```
cd ..
rm -rf ${KK_PWD}
```

**保存镜像**

```
docker save registry.lingo.local/service/kkfileview:v4.4.0 |
    gzip -c > image-kkfileview_v4.4.0.tar.gz
```

