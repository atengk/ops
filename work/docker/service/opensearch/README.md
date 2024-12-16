# OpenSearch

OpenSearch 是一个开源的分布式搜索和分析引擎，基于 Apache 2.0 许可，支持实时搜索、日志分析和数据可视化。它继承自 Elasticsearch，并提供强大的查询、索引、分析功能，适用于大规模数据处理和监控。OpenSearch 具有高可扩展性，支持插件扩展，广泛用于日志管理、应用搜索和安全监控。

- [官网链接](https://opensearch.org)

## OpenSearch 1

**下载镜像**

```
docker pull bitnami/opensearch:1.3.19
```

**下载插件（可选）**

如果不安装插件可以跳过此步骤。

将下载的插件上传到本地的HTTP服务上面，方便后续安装的时候加载插件。

```
mkdir plugins
wget -O plugins/analysis-ik-1.3.19.zip https://release.infinilabs.com/analysis-ik/stable/opensearch-analysis-ik-1.3.19.zip
```

**推送到仓库**

```
docker tag bitnami/opensearch:1.3.19 registry.lingo.local/bitnami/opensearch:1.3.19
docker push registry.lingo.local/bitnami/opensearch:1.3.19
```

**保存镜像**

```
docker save registry.lingo.local/bitnami/opensearch:1.3.19 | gzip -c > image-opensearch_1.3.19.tar.gz
```

**创建目录**

```
sudo mkdir -p /data/container/opensearch1/{data,config}
sudo chown -R 1001 /data/container/opensearch1
```

**创建配置文件**

```
sudo tee /data/container/opensearch1/config/my_opensearch.yml <<"EOF"
http:
  cors:
    enabled: true
    allow-origin: "*"
    allow-headers: X-Requested-With,X-Auth-Token,Content-Type,Content-Length,Authorization
    allow-credentials: true
EOF
```

**运行服务**

普通模式

```
docker run -d --name ateng-opensearch1 \
  -p 20019:9200 --restart=always \
  -v /data/container/opensearch1/config/my_opensearch.yml:/opt/bitnami/opensearch/conf/my_opensearch.yml:ro \
  -v /data/container/opensearch1/data:/bitnami/opensearch/data \
  -e OPENSEARCH_HEAP_SIZE=2g \
  -e TZ=Asia/Shanghai \
  registry.lingo.local/bitnami/opensearch:1.3.19
```

插件模式

```
docker run -d --name ateng-opensearch1 \
  -p 20019:9200 --restart=always \
  -v /data/container/opensearch1/config/my_opensearch.yml:/opt/bitnami/opensearch/conf/my_opensearch.yml:ro \
  -v /data/container/opensearch1/data:/bitnami/opensearch/data \
  -e OPENSEARCH_HEAP_SIZE=2g \
  -e OPENSEARCH_PLUGINS="http://miniserve.lingo.local/opensearch-plugins/analysis-ik-1.3.19.zip" \
  -e TZ=Asia/Shanghai \
  registry.lingo.local/bitnami/opensearch:1.3.19
```

**查看日志**

```
docker logs -f ateng-opensearch1
```

**使用服务**

访问服务

```
curl http://192.168.1.12:20019/
```

查看集群节点信息

```
curl http://192.168.1.12:20019/_cat/nodes?v
```

查看集群健康状态

```
curl http://192.168.1.12:20019/_cluster/health?pretty
```

查看已安装的插件

```
curl http://192.168.1.12:20019/_cat/plugins?v
```

**删除服务**

停止服务

```
docker stop ateng-opensearch1
```

删除服务

```
docker rm ateng-opensearch1
```

删除目录

```
sudo rm -rf /data/container/opensearch1
```



## OpenSearch Dashboard 1

**下载镜像**

```
docker pull bitnami/opensearch-dashboards:1.3.19
```

**推送到仓库**

```
docker tag bitnami/opensearch-dashboards:1.3.19 registry.lingo.local/bitnami/opensearch-dashboards:1.3.19
docker push registry.lingo.local/bitnami/opensearch-dashboards:1.3.19
```

**保存镜像**

```
docker save registry.lingo.local/bitnami/opensearch-dashboards:1.3.19 | gzip -c > image-opensearch-dashboards_1.3.19.tar.gz
```

**创建目录**

```
sudo mkdir -p /data/container/opensearch-dashboards1
sudo chown -R 1001 /data/container/opensearch-dashboards1
```

**运行服务**

```
docker run -d --name ateng-opensearch-dashboards1 \
  -p 20020:5601 --restart=always \
  -v /data/container/opensearch-dashboards1:/bitnami/opensearch-dashboards \
  -e OPENSEARCH_DASHBOARDS_OPENSEARCH_URL=http://192.168.1.12:20019 \
  -e TZ=Asia/Shanghai \
  registry.lingo.local/bitnami/opensearch-dashboards:1.3.19
```

**查看日志**

```
docker logs -f ateng-opensearch-dashboards1
```

**使用服务**

```
URL: http://192.168.1.12:20020
```

**删除服务**

停止服务

```
docker stop ateng-opensearch-dashboards1
```

删除服务

```
docker rm ateng-opensearch-dashboards1
```

删除目录

```
sudo rm -rf /data/container/opensearch-dashboards1
```



## OpenSearch 2

**下载镜像**

```
docker pull bitnami/opensearch:2.18.0
```

**下载插件（可选）**

如果不安装插件可以跳过此步骤。

将下载的插件上传到本地的HTTP服务上面，方便后续安装的时候加载插件。

```
mkdir plugins
wget -O plugins/analysis-ik-2.18.0.zip https://release.infinilabs.com/analysis-ik/stable/opensearch-analysis-ik-2.18.0.zip
```

**推送到仓库**

```
docker tag bitnami/opensearch:2.18.0 registry.lingo.local/bitnami/opensearch:2.18.0
docker push registry.lingo.local/bitnami/opensearch:2.18.0
```

**保存镜像**

```
docker save registry.lingo.local/bitnami/opensearch:2.18.0 | gzip -c > image-opensearch_2.18.0.tar.gz
```

**创建目录**

```
sudo mkdir -p /data/container/opensearch2/{data,config}
sudo chown -R 1001 /data/container/opensearch2
```

**创建配置文件**

```
sudo tee /data/container/opensearch2/config/my_opensearch.yml <<"EOF"
http:
  cors:
    allow-headers: Authorization,X-Requested-With,Content-Length,Content-Type
    allow-origin: '*'
    enabled: true
EOF
```

**运行服务**

普通模式

```
docker run -d --name ateng-opensearch2 \
  -p 20019:9200 --restart=always \
  -v /data/container/opensearch2/config/my_opensearch.yml:/opt/bitnami/opensearch/conf/my_opensearch.yml:ro \
  -v /data/container/opensearch2/data:/bitnami/opensearch/data \
  -e OPENSEARCH_HEAP_SIZE=2g \
  -e TZ=Asia/Shanghai \
  registry.lingo.local/bitnami/opensearch:2.18.0
```

插件模式

```
docker run -d --name ateng-opensearch2 \
  -p 20019:9200 --restart=always \
  -v /data/container/opensearch2/config/my_opensearch.yml:/opt/bitnami/opensearch/conf/my_opensearch.yml:ro \
  -v /data/container/opensearch2/data:/bitnami/opensearch/data \
  -e OPENSEARCH_HEAP_SIZE=2g \
  -e OPENSEARCH_PLUGINS="http://miniserve.lingo.local/opensearch-plugins/analysis-ik-2.18.0.zip" \
  -e TZ=Asia/Shanghai \
  registry.lingo.local/bitnami/opensearch:2.18.0
```

**查看日志**

```
docker logs -f ateng-opensearch2
```

**使用服务**

访问服务

```
curl http://192.168.1.12:20019/
```

查看集群节点信息

```
curl http://192.168.1.12:20019/_cat/nodes?v
```

查看集群健康状态

```
curl http://192.168.1.12:20019/_cluster/health?pretty
```

查看已安装的插件

```
curl http://192.168.1.12:20019/_cat/plugins?v
```

**删除服务**

停止服务

```
docker stop ateng-opensearch2
```

删除服务

```
docker rm ateng-opensearch2
```

删除目录

```
sudo rm -rf /data/container/opensearch2
```



## OpenSearch Dashboard 2

**下载镜像**

```
docker pull bitnami/opensearch-dashboards:2.18.0
```

**推送到仓库**

```
docker tag bitnami/opensearch-dashboards:2.18.0 registry.lingo.local/bitnami/opensearch-dashboards:2.18.0
docker push registry.lingo.local/bitnami/opensearch-dashboards:2.18.0
```

**保存镜像**

```
docker save registry.lingo.local/bitnami/opensearch-dashboards:2.18.0 | gzip -c > image-opensearch-dashboards_2.18.0.tar.gz
```

**创建目录**

```
sudo mkdir -p /data/container/opensearch-dashboards2
sudo chown -R 1001 /data/container/opensearch-dashboards2
```

**运行服务**

```
docker run -d --name ateng-opensearch-dashboards2 \
  -p 20020:5601 --restart=always \
  -v /data/container/opensearch-dashboards2:/bitnami/opensearch-dashboards \
  -e OPENSEARCH_DASHBOARDS_OPENSEARCH_URL=http://192.168.1.12:20019 \
  -e TZ=Asia/Shanghai \
  registry.lingo.local/bitnami/opensearch-dashboards:2.18.0
```

**查看日志**

```
docker logs -f ateng-opensearch-dashboards2
```

**使用服务**

```
URL: http://192.168.1.12:20020
```

**删除服务**

停止服务

```
docker stop ateng-opensearch-dashboards2
```

删除服务

```
docker rm ateng-opensearch-dashboards2
```

删除目录

```
sudo rm -rf /data/container/opensearch-dashboards2
```

