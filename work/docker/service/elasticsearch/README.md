# ElasticSearch

Elasticsearch 是一个开源的分布式搜索和分析引擎，基于 Apache Lucene 构建，支持全文搜索、结构化数据查询和实时分析。它以高性能和可扩展性著称，广泛应用于日志管理、网站搜索、实时监控和大数据分析场景。Elasticsearch 提供 RESTful API，易于集成和扩展。

- [官网链接](https://www.elastic.co/elasticsearch/)

## ElasticSearch 7

**下载镜像**

```
docker pull bitnami/elasticsearch:7.17.26
```

**下载插件（可选）**

如果不安装插件可以跳过此步骤。

将以下下载的插件上传到本地的HTTP服务上面，方便后续安装的时候加载插件。

```
mkdir -p plugins
export version=7.17.26
wget -P plugins https://artifacts.elastic.co/downloads/elasticsearch-plugins/analysis-phonetic/analysis-phonetic-${version}.zip
wget -P plugins https://artifacts.elastic.co/downloads/elasticsearch-plugins/analysis-icu/analysis-icu-${version}.zip
wget -P plugins https://artifacts.elastic.co/downloads/elasticsearch-plugins/analysis-smartcn/analysis-smartcn-${version}.zip
```

**推送到仓库**

```
docker tag bitnami/elasticsearch:7.17.26 registry.lingo.local/bitnami/elasticsearch:7.17.26
docker push registry.lingo.local/bitnami/elasticsearch:7.17.26
```

**保存镜像**

```
docker save registry.lingo.local/bitnami/elasticsearch:7.17.26 | gzip -c > image-elasticsearch_7.17.26.tar.gz
```

**创建目录**

```
sudo mkdir -p /data/container/elasticsearch7/{data,config}
sudo chown -R 1001 /data/container/elasticsearch7
```

**创建配置文件**

```
sudo tee /data/container/elasticsearch7/config/my_elasticsearch.yml <<"EOF"
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
docker run -d --name ateng-elasticsearch7 \
  -p 20018:9200 --restart=always \
  -v /data/container/elasticsearch7/config/my_elasticsearch.yml:/opt/bitnami/elasticsearch/config/my_elasticsearch.yml:ro \
  -v /data/container/elasticsearch7/data:/bitnami/elasticsearch/data \
  -e ELASTICSEARCH_HEAP_SIZE=2g \
  -e TZ=Asia/Shanghai \
  registry.lingo.local/bitnami/elasticsearch:7.17.26
```

插件模式

```
docker run -d --name ateng-elasticsearch7 \
  -p 20018:9200 --restart=always \
  -v /data/container/elasticsearch7/config/my_elasticsearch.yml:/opt/bitnami/elasticsearch/config/my_elasticsearch.yml:ro \
  -v /data/container/elasticsearch7/data:/bitnami/elasticsearch/data \
  -e ELASTICSEARCH_HEAP_SIZE=2g \
  -e ELASTICSEARCH_PLUGINS="http://miniserve.lingo.local/elasticsearch-plugins/v7.17.26/analysis-icu-7.17.26.zip http://miniserve.lingo.local/elasticsearch-plugins/v7.17.26/analysis-phonetic-7.17.26.zip http://miniserve.lingo.local/elasticsearch-plugins/v7.17.26/analysis-smartcn-7.17.26.zip" \
  -e TZ=Asia/Shanghai \
  registry.lingo.local/bitnami/elasticsearch:7.17.26
```

**查看日志**

```
docker logs -f ateng-elasticsearch7
```

**使用服务**

访问服务

```
curl http://192.168.1.12:20018/
```

查看集群节点信息

```
curl http://192.168.1.12:20018/_cat/nodes?v
```

查看集群健康状态

```
curl http://192.168.1.12:20018/_cluster/health?pretty
```

查看已安装的插件

```
curl http://192.168.1.12:20018/_cat/plugins?v
```

**删除服务**

停止服务

```
docker stop ateng-elasticsearch7
```

删除服务

```
docker rm ateng-elasticsearch7
```

删除目录

```
sudo rm -rf /data/container/elasticsearch7
```



## Kibana 7

**下载镜像**

```
docker pull bitnami/kibana:7.17.26
```

**推送到仓库**

```
docker tag bitnami/kibana:7.17.26 registry.lingo.local/bitnami/kibana:7.17.26
docker push registry.lingo.local/bitnami/kibana:7.17.26
```

**保存镜像**

```
docker save registry.lingo.local/bitnami/kibana:7.17.26 | gzip -c > image-kibana_7.17.26.tar.gz
```

**创建目录**

```
sudo mkdir -p /data/container/kibana7
sudo chown -R 1001 /data/container/kibana7
```

**运行服务**

```
docker run -d --name ateng-kibana7 \
  -p 20019:5601 --restart=always \
  -v /data/container/kibana7:/bitnami/kibana \
  -e KIBANA_ELASTICSEARCH_URL=http://192.168.1.12:20018 \
  -e TZ=Asia/Shanghai \
  registry.lingo.local/bitnami/kibana:7.17.26
```

**查看日志**

```
docker logs -f ateng-kibana7
```

**使用服务**

```
URL: http://192.168.1.12:20019
```

**删除服务**

停止服务

```
docker stop ateng-kibana7
```

删除服务

```
docker rm ateng-kibana7
```

删除目录

```
sudo rm -rf /data/container/kibana7
```



## ElasticSearch 8

**下载镜像**

```
docker pull bitnami/elasticsearch:8.16.1
```

**下载插件（可选）**

如果不安装插件可以跳过此步骤。

将以下下载的插件上传到本地的HTTP服务上面，方便后续安装的时候加载插件。

```
mkdir -p plugins
export version=8.16.1
wget -P plugins https://artifacts.elastic.co/downloads/elasticsearch-plugins/analysis-phonetic/analysis-phonetic-${version}.zip
wget -P plugins https://artifacts.elastic.co/downloads/elasticsearch-plugins/analysis-icu/analysis-icu-${version}.zip
wget -P plugins https://artifacts.elastic.co/downloads/elasticsearch-plugins/analysis-smartcn/analysis-smartcn-${version}.zip
```

**推送到仓库**

```
docker tag bitnami/elasticsearch:8.16.1 registry.lingo.local/bitnami/elasticsearch:8.16.1
docker push registry.lingo.local/bitnami/elasticsearch:8.16.1
```

**保存镜像**

```
docker save registry.lingo.local/bitnami/elasticsearch:8.16.1 | gzip -c > image-elasticsearch_8.16.1.tar.gz
```

**创建目录**

```
sudo mkdir -p /data/container/elasticsearch8/{data,config}
sudo chown -R 1001 /data/container/elasticsearch8
```

**创建配置文件**

```
sudo tee /data/container/elasticsearch8/config/my_elasticsearch.yml <<"EOF"
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
docker run -d --name ateng-elasticsearch8 \
  -p 20018:9200 --restart=always \
  -v /data/container/elasticsearch8/config/my_elasticsearch.yml:/opt/bitnami/elasticsearch/config/my_elasticsearch.yml:ro \
  -v /data/container/elasticsearch8/data:/bitnami/elasticsearch/data \
  -e ELASTICSEARCH_HEAP_SIZE=2g \
  -e TZ=Asia/Shanghai \
  registry.lingo.local/bitnami/elasticsearch:8.16.1
```

插件模式

```
docker run -d --name ateng-elasticsearch8 \
  -p 20018:9200 --restart=always \
  -v /data/container/elasticsearch8/config/my_elasticsearch.yml:/opt/bitnami/elasticsearch/config/my_elasticsearch.yml:ro \
  -v /data/container/elasticsearch8/data:/bitnami/elasticsearch/data \
  -e ELASTICSEARCH_HEAP_SIZE=2g \
  -e ELASTICSEARCH_PLUGINS="http://miniserve.lingo.local/elasticsearch-plugins/v8.16.1/analysis-icu-8.16.1.zip http://miniserve.lingo.local/elasticsearch-plugins/v8.16.1/analysis-phonetic-8.16.1.zip http://miniserve.lingo.local/elasticsearch-plugins/v8.16.1/analysis-smartcn-8.16.1.zip" \
  -e TZ=Asia/Shanghai \
  registry.lingo.local/bitnami/elasticsearch:8.16.1
```

**查看日志**

```
docker logs -f ateng-elasticsearch8
```

**使用服务**

访问服务

```
curl http://192.168.1.12:20018/
```

查看集群节点信息

```
curl http://192.168.1.12:20018/_cat/nodes?v
```

查看集群健康状态

```
curl http://192.168.1.12:20018/_cluster/health?pretty
```

查看已安装的插件

```
curl http://192.168.1.12:20018/_cat/plugins?v
```

**删除服务**

停止服务

```
docker stop ateng-elasticsearch8
```

删除服务

```
docker rm ateng-elasticsearch8
```

删除目录

```
sudo rm -rf /data/container/elasticsearch8
```



## Kibana 8

**下载镜像**

```
docker pull bitnami/kibana:8.16.1
```

**推送到仓库**

```
docker tag bitnami/kibana:8.16.1 registry.lingo.local/bitnami/kibana:8.16.1
docker push registry.lingo.local/bitnami/kibana:8.16.1
```

**保存镜像**

```
docker save registry.lingo.local/bitnami/kibana:8.16.1 | gzip -c > image-kibana_8.16.1.tar.gz
```

**创建目录**

```
sudo mkdir -p /data/container/kibana8
sudo chown -R 1001 /data/container/kibana8
```

**运行服务**

```
docker run -d --name ateng-kibana8 \
  -p 20019:5601 --restart=always \
  -v /data/container/kibana8:/bitnami/kibana \
  -e KIBANA_ELASTICSEARCH_URL=http://192.168.1.12:20018 \
  -e TZ=Asia/Shanghai \
  registry.lingo.local/bitnami/kibana:8.16.1
```

**查看日志**

```
docker logs -f ateng-kibana8
```

**使用服务**

```
URL: http://192.168.1.12:20019
```

**删除服务**

停止服务

```
docker stop ateng-kibana8
```

删除服务

```
docker rm ateng-kibana8
```

删除目录

```
sudo rm -rf /data/container/kibana8
```
