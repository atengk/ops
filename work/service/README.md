# 服务器部署服务

## 前提要求

在进行服务部署之前，首先参考 [基础配置文档](/work/service/00-basic/) 部分，再进行其他服务安装，

## 部署服务目录

- 存储服务
    - [网络文件共享 NFS](work/service/nfs/)
    - [网络文件共享 Samba](work/service/samba/)
    - [网络文件共享 VSFTP](work/service/ftp/)
    - 对象存储服务 MinIO
        - [安装文档](/work/service/minio/v20241107/)
        - [使用文档](/work/service/minio/OPS.md)
    - 分布式存储 JuiceFS
        - [安装文档](/work/service/juicefs/v1.2.1/)
        - [使用文档](/work/service/juicefs/OPS.md)
    - [备份工具 Restic](/work/service/restic/)
- 数据存储
    - MySQL
        - [安装文档](/work/service/mysql/v8.4.3/)
        - [编译安装文档](/work/service/mysql/v8.4.3/make/)
        - [使用文档](/work/service/mysql/OPS.md)
    - MariaDB Galera
        - [安装文档](/work/service/mariadb/v11.4.4/)
    - Redis
        - [安装文档](/work/service/redis/v7.4.1/)
        - [使用文档](/work/service/redis/OPS.md)
    - PostgreSQL
        - [编译安装文档](/work/service/postgresql/v17.2.0/)
        - [编译PostGIS](/work/service/postgresql/v17.2.0/postgis/)
        - [使用文档](/work/service/postgresql/OPS.md)
    - ETCD
        - [安装文档](/work/service/etcd/v3.5.17/)
        - [使用文档](/work/service/etcd/OPS.md)
    - FoundationDB
        - [安装文档](/work/service/foundationdb/v7.1.38/)
        - [使用文档](/work/service/foundationdb/OPS.md)
    - ElasticSearch
        - [安装单机模式](/work/service/elastic/elasticsearch/standalone/)
        - [安装集群模式](/work/service/elastic/elasticsearch/cluster/)
    - OpenSearch
        - [1.x安装文档](/work/service/opensearch/v1.3.19/)
        - [2.x安装文档](/work/service/opensearch/v2.18.0/)
        - [使用文档](/work/service/opensearch/OPS.md)
- Web服务
    - Nginx
        - [安装文档](/work/service/nginx/v1.27.3/)
        - [使用文档](/work/service/nginx/OPS.md)
    - Haproxy
        - [安装文档](/work/service/haproxy/)
        - [使用文档](/work/service/haproxy/OPS.md)
    - TLS证书
        - [cfssl创建证书](/work/service/tls/tls-cfssl/v1.6.5/)
        - [openssl创建证书](/work/service/tls/tls-openssl/)
- 监控服务
    - [Beszel](/work/service/beszel/)
- 其他服务
    - [内网穿透FRP](/work/service/frp/)
    - [CoreDNS](/work/service/coredns/)
- 开发服务
    - OpenJDK
        - [OpenJDK8](/work/service/openjdk/openjdk8/)
        - [OpenJDK11](/work/service/openjdk/openjdk11/)
        - [OpenJDK17](/work/service/openjdk/openjdk17/)
        - [OpenJDK21](/work/service/openjdk/openjdk21/)
        - [使用文档](/work/service/openjdk/OPS.md)
    - SpringCloud Alibaba
        - [Nacos](/work/service/springcloudalibaba/nacos)
        - [Sentinel](/work/service/springcloudalibaba/sentinel/)
        - [Seata](/work/service/springcloudalibaba/seata/)
        - [RocketMQ](/work/service/springcloudalibaba/rocketmq/standalone/)

