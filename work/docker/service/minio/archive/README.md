# MinIO 2023-12-09

使用docker运行minio集群，针对服务器没有多余的硬盘的情况。

这里示例两台服务器，分别在两台服务器上执行一下命令。



## 环境准备

准备数据目录

```
mkdir -p /data/service/minio/{01,02}
chown -R 1001 /data/service/minio
```



## 启动容器

```
docker run -d --restart=always --network host --name kongyu-minio \
    -v /data/service/minio/01:/data01 \
    -v /data/service/minio/02:/data02 \
    registry.lingo.local/service/minio:my_custom \
    minio server --address :9000 --console-address :9001 http://192.168.1.101:9000/data0{1...2} http://192.168.1.102:9000/data0{1...2}
```



## 访问服务

登录服务查看

```
URL: http://192.168.1.101:9001
Username: admin
Password: Admin@123
```



## 删除服务


```
docker rm -f kongyu-minio
rm -rf /data/service/minio
```



