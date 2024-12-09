# Zookeeper

Zookeeper 是一个开源的分布式协调服务，用于构建分布式应用程序中的同步和协调机制。它提供了高可用的服务，可以用于分布式锁、配置管理、命名服务、选举机制等场景。Zookeeper 采用类似于文件系统的层次结构来存储数据，所有的数据都会同步到集群中的所有节点，确保一致性。它通常用于大规模分布式系统中，支持高效的协调和故障恢复。

- [官网链接](https://zookeeper.apache.org/)

**下载镜像**

```
docker pull bitnami/zookeeper:3.9.3
```

**推送到仓库**

```
docker tag bitnami/zookeeper:3.9.3 registry.lingo.local/bitnami/zookeeper:3.9.3
docker push registry.lingo.local/bitnami/zookeeper:3.9.3
```

**保存镜像**

```
docker save registry.lingo.local/bitnami/zookeeper:3.9.3 | gzip -c > image-zookeeper_3.9.3.tar.gz
```

**创建目录**

```
sudo mkdir -p /data/container/zookeeper/data
sudo chown -R 1001 /data/container/zookeeper
```

**运行服务**

```
docker run -d --name ateng-zookeeper \
  -p 20015:2181 --restart=always \
  -v /data/container/zookeeper/data:/bitnami/zookeeper \
  -e ALLOW_ANONYMOUS_LOGIN=yes \
  -e ZOO_HEAP_SIZE=2048 \
  -e ZOO_SNAPCOUNT=100000 \
  -e ZOO_MAX_CLIENT_CNXNS=60 \
  -e ZOO_LOG_LEVEL=ERROR \
  -e TZ=Asia/Shanghai \
  registry.lingo.local/bitnami/zookeeper:3.9.3
```

**查看日志**

```
docker logs -f ateng-zookeeper
```

**使用服务**

进入容器

```
docker exec -it ateng-zookeeper bash
```

访问服务

```
zkCli.sh -server 192.168.1.114:20015
```

使用命令

```
create /my_node "This is a test node"
get /my_node
```

**删除服务**

停止服务

```
docker stop ateng-zookeeper
```

删除服务

```
docker rm ateng-zookeeper
```

删除目录

```
sudo rm -rf /data/container/zookeeper
```

