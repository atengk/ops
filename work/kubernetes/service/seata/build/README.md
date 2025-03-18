# 构建Seata Server镜像

使用的架构是配置和注册使用的使Nacos，存储使用MySQL。



**下载并解压软件包**

```
wget https://dist.apache.org/repos/dist/release/incubator/seata/2.3.0/apache-seata-2.3.0-incubating-bin.tar.gz
tar -zxvf apache-seata-2.3.0-incubating-bin.tar.gz
cd apache-seata-2.3.0-incubating-bin
```

**下载数据库驱动**

- MySQL

```
wget -P seata-server/lib/jdbc/ https://repo1.maven.org/maven2/com/mysql/mysql-connector-j/8.0.33/mysql-connector-j-8.0.33.jar
```

- PostgreSQL

```
wget -P seata-server/lib/jdbc/ https://repo1.maven.org/maven2/org/postgresql/postgresql/42.7.1/postgresql-42.7.1.jar
```

**构建镜像**

```
cd seata-server
cp ../{LICENSE,NOTICE} .
docker pull eclipse-temurin:8u422-b05-jdk
docker build -t seata-server:2.3.0 .
```

**测试镜像**

运行后能访问 `http://192.168.1.12:17091/` 即可

```
docker run --rm \
    --name seata-server \
    -p 17091:7091 \
    seata-server:2.3.0
```

停止容器

```
docker stop seata-server
```

**推送镜像仓库**

```
docker tag seata-server:2.3.0 registry.lingo.local/service/seata-server:2.3.0
docker push registry.lingo.local/service/seata-server:2.3.0
```

**保存镜像**

```
docker save registry.lingo.local/service/seata-server:2.3.0 |
    gzip -c > image-seata-server_2.3.0.tar.gz
```

**清理文件**

```
rm -rf apache-seata-2.3.0-incubating-bin
```

