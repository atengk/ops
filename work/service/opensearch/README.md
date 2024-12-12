# OpenSearch

OpenSearch 是一个开源的分布式搜索和分析引擎，基于 Apache 2.0 许可，支持实时搜索、日志分析和数据可视化。它继承自 Elasticsearch，并提供强大的查询、索引、分析功能，适用于大规模数据处理和监控。OpenSearch 具有高可扩展性，支持插件扩展，广泛用于日志管理、应用搜索和安全监控。

- [官网链接](https://opensearch.org)

## 前置条件

- 参考：[基础配置](/work/service/00-basic/)

## 单节点模式

### 安装服务

**下载软件包**

```
wget https://artifacts.opensearch.org/releases/bundle/opensearch/2.18.0/opensearch-2.18.0-linux-x64.tar.gz
```

**解压并安装**

```
tar -zxvf opensearch-2.18.0-linux-x64.tar.gz -C /usr/local/software/
ln -s /usr/local/software/opensearch-2.18.0 /usr/local/software/opensearch
```

**配置环境变量**

```
cat >> ~/.bash_profile <<"EOF"
## OPENSEARCH_HOME
export OPENSEARCH_HOME=/usr/local/software/opensearch
export OPENSEARCH_JAVA_HOME=/usr/local/software/opensearch/jdk
export PATH=$PATH:$OPENSEARCH_HOME/bin
EOF
source ~/.bash_profile
```

**查看版本**

```
$OPENSEARCH_HOME/bin/opensearch --version
```



### 编辑配置

**编辑服务配置文件**

```
cp $OPENSEARCH_HOME/config/opensearch.yml{,_bak}
cat > $OPENSEARCH_HOME/config/opensearch.yml <<"EOF"
http:
  port: "9200"
  cors:
    allow-credentials: true
    allow-headers: X-Requested-With,X-Auth-Token,Content-Type,Content-Length,Authorization
    allow-origin: '*'
    enabled: true
path:
  data: /data/service/opensearch/data
transport:
  port: "9300"
network:
  host: service01.ateng.local
  publish_host: service01.ateng.local
  bind_host: 0.0.0.0
cluster:
  name: opensearch
  initial_cluster_manager_nodes:
    - service01.ateng.local
node:
  name: service01.ateng.local
discovery:
  seed_hosts: service01.ateng.local
  initial_state_timeout: 10m
plugins:
  security:
    disabled: "true"
EOF
```

**编辑JVM配置文件**

```
cat > $OPENSEARCH_HOME/config/jvm.options.d/my_jvm.options <<"EOF"
-Xms4g
-Xmx4g
EOF
```

**创建目录**

```
mkdir -p /data/service/opensearch/data
```



### 启动服务

**临时启动服务**

```
$OPENSEARCH_HOME/bin/opensearch
```

**访问测试**

测试没问题后就可以配置开启自启动

```
curl http://service01.ateng.local:9200/
```

**配置开启自启动**

需要先配置一个环境变量配置文件，否则在systemd里面无法找到一些变量

```
cat > $OPENSEARCH_HOME/config/opensearch.env <<EOF
OPENSEARCH_HOME=/usr/local/software/opensearch
OPENSEARCH_JAVA_HOME=/usr/local/software/opensearch/jdk
PATH=$PATH:$OPENSEARCH_HOME/bin
EOF
```

创建 `opensearch.service` 文件

```
sudo tee /etc/systemd/system/opensearch.service <<"EOF"
[Unit]
Description=OpenSearch Server
Documentation=https://opensearch.org/
After=network-online.target

[Service]
User=admin
Group=ateng
Type=simple
Restart=on-failure
RestartSec=10
WorkingDirectory=/usr/local/software/opensearch
EnvironmentFile=-/usr/local/software/opensearch/config/opensearch.env
ExecStart=/usr/local/software/opensearch/bin/opensearch
ExecStop=/bin/kill -SIGTERM $MAINPID
KillSignal=SIGTERM
TimeoutStopSec=60

[Install]
WantedBy=multi-user.target
EOF
```

**启动服务**

```
sudo systemctl daemon-reload
sudo systemctl enable --now opensearch
```



### 使用服务

访问服务

```
curl http://service01.ateng.local:9200/
```

查看集群节点信息

```
curl http://service01.ateng.local:9200/_cat/nodes?v
```

查看集群健康状态

```
curl http://service01.ateng.local:9200/_cluster/health?pretty
```

查看已安装的插件

```
curl http://service01.ateng.local:9200/_cat/plugins?v
```

创建索引

```
curl -X PUT "http://service01.ateng.local:9200/my_index" -H 'Content-Type: application/json' -d'
{
  "settings": {
    "number_of_shards": 1,
    "number_of_replicas": 0
  }
}'
```

查询索引的设置

```
curl -X GET "http://service01.ateng.local:9200/my_index/_settings?pretty"
```

写入数据

```
curl -X POST "http://service01.ateng.local:9200/my_index/_doc" -H 'Content-Type: application/json' -d'
{
  "title": "OpenSearch Introduction",
  "content": "OpenSearch is a distributed search engine.",
  "tags": ["search", "analytics", "open source"],
  "timestamp": "2024-12-05T10:00:00"
}'
```

查询数据

```
curl -X GET "http://service01.ateng.local:9200/my_index/_search?pretty" -H 'Content-Type: application/json' -d'
{
  "query": {
    "match_all": {}
  }
}'
```

删除索引

```
curl -X DELETE "http://service01.ateng.local:9200/my_index"
```



## 集群模式

**集群节点信息如下**

| IP             | 主机名                | 描述 |
| -------------- | --------------------- | ---- |
| 10.244.172.143 | service01.ateng.local |      |
| 10.244.172.7   | service02.ateng.local |      |
| 10.244.172.222 | service03.ateng.local |      |

**下载软件包**

```
wget https://artifacts.opensearch.org/releases/bundle/opensearch/2.18.0/opensearch-2.18.0-linux-x64.tar.gz
```

**解压并安装**

```
tar -zxvf opensearch-2.18.0-linux-x64.tar.gz -C /usr/local/software/
ln -s /usr/local/software/opensearch-2.18.0 /usr/local/software/opensearch
```

**配置环境变量**

```
cat >> ~/.bash_profile <<"EOF"
## OPENSEARCH_HOME
export OPENSEARCH_HOME=/usr/local/software/opensearch
export OPENSEARCH_JAVA_HOME=/usr/local/software/opensearch/jdk
export PATH=$PATH:$OPENSEARCH_HOME/bin
EOF
source ~/.bash_profile
```

**查看版本**

```
$OPENSEARCH_HOME/bin/opensearch --version
```



### 编辑配置

**编辑服务配置文件**

```
cp $OPENSEARCH_HOME/config/opensearch.yml{,_bak}
cat > $OPENSEARCH_HOME/config/opensearch.yml <<"EOF"
http:
  port: "9200"
  cors:
    allow-credentials: true
    allow-headers: X-Requested-With,X-Auth-Token,Content-Type,Content-Length,Authorization
    allow-origin: '*'
    enabled: true
path:
  data: /data/service/opensearch/data
transport:
  port: "9300"
network:
  host: service01.ateng.local
  publish_host: service01.ateng.local
  bind_host: 0.0.0.0
cluster:
  name: opensearch
  initial_cluster_manager_nodes:
    - service01.ateng.local
node:
  name: service01.ateng.local
discovery:
  seed_hosts: service01.ateng.local
  initial_state_timeout: 10m
plugins:
  security:
    disabled: "true"
EOF
```

**编辑JVM配置文件**

```
cat > $OPENSEARCH_HOME/config/jvm.options.d/my_jvm.options <<"EOF"
-Xms4g
-Xmx4g
EOF
```

**创建目录**

```
mkdir -p /data/service/opensearch/data
```



### 启动服务

**临时启动服务**

```
$OPENSEARCH_HOME/bin/opensearch
```

**访问测试**

测试没问题后就可以配置开启自启动

```
curl http://service01.ateng.local:9200/
```

**配置开启自启动**

需要先配置一个环境变量配置文件，否则在systemd里面无法找到一些变量

```
cat > $OPENSEARCH_HOME/config/opensearch.env <<EOF
OPENSEARCH_HOME=/usr/local/software/opensearch
OPENSEARCH_JAVA_HOME=/usr/local/software/opensearch/jdk
PATH=$PATH:$OPENSEARCH_HOME/bin
EOF
```

创建 `opensearch.service` 文件

```
sudo tee /etc/systemd/system/opensearch.service <<"EOF"
[Unit]
Description=OpenSearch Server
Documentation=https://opensearch.org/
After=network-online.target

[Service]
User=admin
Group=ateng
Type=simple
Restart=on-failure
RestartSec=10
WorkingDirectory=/usr/local/software/opensearch
EnvironmentFile=-/usr/local/software/opensearch/config/opensearch.env
ExecStart=/usr/local/software/opensearch/bin/opensearch
ExecStop=/bin/kill -SIGTERM $MAINPID
KillSignal=SIGTERM
TimeoutStopSec=60

[Install]
WantedBy=multi-user.target
EOF
```

**启动服务**

```
sudo systemctl daemon-reload
sudo systemctl enable --now opensearch
```



### 使用服务

访问服务

```
curl http://service01.ateng.local:9200/
```

查看集群节点信息

```
curl http://service01.ateng.local:9200/_cat/nodes?v
```

查看集群健康状态

```
curl http://service01.ateng.local:9200/_cluster/health?pretty
```

查看已安装的插件

```
curl http://service01.ateng.local:9200/_cat/plugins?v
```

创建索引

```
curl -X PUT "http://service01.ateng.local:9200/my_index" -H 'Content-Type: application/json' -d'
{
  "settings": {
    "number_of_shards": 1,
    "number_of_replicas": 0
  }
}'
```

查询索引的设置

```
curl -X GET "http://service01.ateng.local:9200/my_index/_settings?pretty"
```

写入数据

```
curl -X POST "http://service01.ateng.local:9200/my_index/_doc" -H 'Content-Type: application/json' -d'
{
  "title": "OpenSearch Introduction",
  "content": "OpenSearch is a distributed search engine.",
  "tags": ["search", "analytics", "open source"],
  "timestamp": "2024-12-05T10:00:00"
}'
```

查询数据

```
curl -X GET "http://service01.ateng.local:9200/my_index/_search?pretty" -H 'Content-Type: application/json' -d'
{
  "query": {
    "match_all": {}
  }
}'
```

删除索引

```
curl -X DELETE "http://service01.ateng.local:9200/my_index"
```

