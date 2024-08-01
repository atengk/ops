# elasticsearch 7.17.16



## 环境准备

创建网络，将容器运行在该网络下，若已创建则忽略

```
docker network create --subnet 10.188.0.1/24 kongyu
```

准备目录

```
mkdir -p /data/service/elasticsearch/{data,config,plugins}
chown -R 1001 /data/service/elasticsearch
```

编辑配置文件

```
cat > /data/service/elasticsearch/config/my_elasticsearch.yml <<"EOF"
http:
  cors:
    allow-headers: Authorization,X-Requested-With,Content-Length,Content-Type
    allow-origin: '*'
    enabled: true
EOF
chown -R 1001 /data/service/elasticsearch/config
```

配置插件

> 将相应的插件解压到plugins目录下

```
unzip plugins/analysis-ik.zip -d /data/service/elasticsearch/plugins
unzip plugins/analysis-icu.zip -d /data/service/elasticsearch/plugins
unzip plugins/analysis-phonetic.zip -d /data/service/elasticsearch/plugins
unzip plugins/analysis-smartcn.zip -d /data/service/elasticsearch/plugins
unzip plugins/repository-s3.zip -d /data/service/elasticsearch/plugins
chown -R 1001 /data/service/elasticsearch/plugins
```

编辑内核参数

```
cat > /etc/sysctl.d/99-elasticsearch.conf <<"EOF"
vm.max_map_count=262144
fs.file-max=65536
EOF
sysctl -f /etc/sysctl.d/99-elasticsearch.conf
```



## 启动容器

- 使用docker run的方式


```
docker run -d --name kongyu-elasticsearch \
    -p 20001:9200 --restart=always \
    -v /data/service/elasticsearch/config/my_elasticsearch.yml:/opt/bitnami/elasticsearch/config/my_elasticsearch.yml \
    -v /data/service/elasticsearch/data:/bitnami/elasticsearch/data \
    -v /data/service/elasticsearch/plugins:/opt/bitnami/elasticsearch/plugins \
    -e ELASTICSEARCH_HEAP_SIZE=2g \
    -e ELASTICSEARCH_NODE_NAME=es-standalone \
    -e TZ=Asia/Shanghai \
    registry.lingo.local/service/elasticsearch:7.17.16
docker logs -f kongyu-elasticsearch
```

- 使用docker-compose的方式


```
cat > /data/service/elasticsearch/docker-compose.yaml <<"EOF"
version: '3'

services:
  elasticsearch:
    image: registry.lingo.local/service/elasticsearch:7.17.16
    container_name: kongyu-elasticsearch
    networks:
      - kongyu
    ports:
      - "20001:9200"
    restart: always
    volumes:
      - /data/service/elasticsearch/config/my_elasticsearch.yml:/opt/bitnami/elasticsearch/config/my_elasticsearch.yml
      - /data/service/elasticsearch/data:/bitnami/elasticsearch/data
      - /data/service/elasticsearch/plugins:/opt/bitnami/elasticsearch/plugins
    environment:
      - ELASTICSEARCH_HEAP_SIZE=2g
      - ELASTICSEARCH_NODE_NAME=es-standalone
      - TZ=Asia/Shanghai

networks:
  kongyu:
    external: true

EOF

docker-compose -f /data/service/elasticsearch/docker-compose.yaml up -d 
docker-compose -f /data/service/elasticsearch/docker-compose.yaml logs -f
```



## 访问服务

登录服务查看

```
URL: http://192.168.1.101:20001/
```



## 可视化工具

[ElasticView](https://github.com/1340691923/ElasticView)

```
docker run --name kongyu-elasticview \
    --restart=unless-stopped -d -p 20002:8090 \
    -v /data/service/elastic_view/data:/data \
    -v /data/service/elastic_view/logs:/logs \
    registry.lingo.local/service/elastic_view:latest
docker logs -f kongyu-elasticview
## 访问
URL: http://192.168.1.101:20002/
Username: admin
Password: Admin@123
```

[elasticsearch-head](https://github.com/mobz/elasticsearch-head)

```
docker run --name kongyu-elastichead \
    --restart=unless-stopped -d -p 20003:9100 \
    registry.lingo.local/service/elasticsearch-head:kongyu
docker logs -f kongyu-elastichead
## 访问。如果有账号密码，需要在URL上加上参数：auth_user=elastic&auth_password=Admin@123
URL: http://192.168.1.101:20003/?base_uri=http://192.168.1.101:20001
```



## 删除服务

- 使用docker run的方式


```
docker rm -f kongyu-elasticsearch
docker rm -f kongyu-elasticview
docker rm -f kongyu-elastichead
```

- 使用docker-compose的方式


```
docker-compose -f /data/service/elasticsearch/docker-compose.yaml down
```

删除数据目录

```
rm -rf /data/service/elasticsearch
```

