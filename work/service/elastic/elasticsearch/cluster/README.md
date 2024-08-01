# 安装ElasticSearch



## 安装ES

新增用户

```
adduser elasticsearch
usermod -aG elasticsearch elasticsearch
```

解压软件包并设置所属者

```
mkdir /usr/local/software
tar -zxvf elasticsearch-7.17.16-linux-x86_64.tar.gz -C /usr/local/software
chown -R elasticsearch:elasticsearch /usr/local/software/elasticsearch-7.17.16
ln -s /usr/local/software/elasticsearch-7.17.16 /usr/local/software/elasticsearch
```

编辑环境变量

```
cat > /etc/profile.d/00-elasticsearch.sh <<"EOF"
export ES_HOME=/usr/local/software/elasticsearch
export PATH=$PATH:$ES_HOME/bin
EOF
source /etc/profile.d/00-elasticsearch.sh
##
cat > /etc/sysconfig/elasticsearch <<"EOF"
ES_JAVA_OPTS="-Xms10g -Xmx10g"
EOF
```

编辑内核参数

```
cat > /etc/sysctl.d/99-elasticsearch.conf <<"EOF"
vm.max_map_count=262144
fs.file-max=65536
EOF
sysctl -f /etc/sysctl.d/99-elasticsearch.conf
```

编辑配置文件

```
cat > /usr/local/software/elasticsearch/config/elasticsearch.yml <<"EOF"
# HTTP配置
http:
  port: "9200"  # Elasticsearch HTTP端口
  cors:
    allow-headers: Authorization,X-Requested-With,Content-Length,Content-Type  # 允许的HTTP请求头
    allow-origin: '*'  # 允许的来源地址
    enabled: true  # 启用HTTP
# 路径配置
path:
  data: /data/service/elasticsearch/data  # 数据存储路径
  logs: /data/service/elasticsearch/logs  # 日志存储路径
# 传输配置
transport:
  tcp:
    port: "9300"  # Elasticsearch传输层TCP端口
# 网络配置
network:
  host: 0.0.0.0  # 监听的网络接口地址，也可以监听指定IP
# 集群配置
cluster:
  name: es-cluster  # 集群名称
  initial_master_nodes:
    - k8s-master01  # 初始主节点列表
    - k8s-worker01
    - k8s-worker02
# 节点配置
node:
  name: k8s-master01  # 节点名称
  master: "true"  # 是否作为主节点
  data: "true"  # 是否存储数据
# 发现配置
discovery:
  seed_hosts:
    - k8s-master01  # 种子主机列表
    - k8s-worker01
    - k8s-worker02
  initial_state_timeout: 5m  # 初始状态超时时间
  zen:
    minimum_master_nodes: "2"  # 最小主节点数
EOF
```

创建数据目录

```
mkdir -p /var/run/elasticsearch /data/service/elasticsearch/{data,logs}
chown elasticsearch:elasticsearch /var/run/elasticsearch /data/service/elasticsearch/{data,logs}
```

编辑systemd配置文件

```
cat > /etc/systemd/system/elasticsearch.service <<"EOF"
[Unit]
Description=Elasticsearch
Documentation=https://www.elastic.co
Wants=network-online.target
After=network-online.target
[Service]
Type=simple 
Restart=on-failure
RestartSec=5
RuntimeDirectory=elasticsearch
PrivateTmp=true
Environment=ES_HOME=/usr/local/software/elasticsearch
Environment=ES_PATH_CONF=/usr/local/software/elasticsearch/config
Environment=ES_JAVA_HOME=/usr/local/software/elasticsearch/jdk
Environment=PID_DIR=/var/run/elasticsearch
Environment=ES_SD_NOTIFY=true
EnvironmentFile=-/etc/sysconfig/elasticsearch
WorkingDirectory=/usr/local/software/elasticsearch
User=elasticsearch
Group=elasticsearch
ExecStart=/usr/local/software/elasticsearch/bin/elasticsearch -p ${PID_DIR}/elasticsearch.pid
StandardOutput=journal
StandardError=inherit
LimitNOFILE=65535
LimitNPROC=65535
LimitAS=infinity
LimitFSIZE=infinity
TimeoutStopSec=0
KillSignal=SIGTERM
KillMode=process
SendSIGKILL=no
SuccessExitStatus=143
TimeoutStartSec=75
[Install]
WantedBy=multi-user.target
EOF
```

启动服务

```
systemctl daemon-reload
systemctl start elasticsearch
systemctl enable elasticsearch
```

访问服务

```
curl http://localhost:9200/
```

## 设置密码

xpack方式开启集群密码认证

```
elasticsearch-certutil ca -out /usr/local/software/elasticsearch/config/elastic-certificates.p12 -pass ""
chown -R elasticsearch:elasticsearch /usr/local/software/elasticsearch/config/elastic-certificates.p12
```

编辑配置文件

```
cat >> /usr/local/software/elasticsearch/config/elasticsearch.yml <<"EOF"
# X-Pack 安全配置
xpack:
  security:
    enabled: true  # 启用 X-Pack 安全特性
    transport:
      ssl:
        enabled: true  # 启用传输层 SSL 加密
        # 证书验证模式，这里使用 certificate 模式
        verification_mode: certificate
        # 密钥库的路径，包含节点证书和私钥
        keystore:
          path: /usr/local/software/elasticsearch/config/elastic-certificates.p12
        # 信任库的路径，包含可信任的证书用于验证对等节点
        truststore:
          path: /usr/local/software/elasticsearch/config/elastic-certificates.p12
EOF
```

重启服务

```
systemctl restart elasticsearch
```

生成密码

```
elasticsearch-setup-passwords auto
## 修改elastic用户的密码
export ELASTIC_PASSWORD="1vGqYhk9xXxWfYU6fpWp"
curl -H "Content-Type: application/json" -X POST http://localhost:9200/_security/user/elastic/_password -u elastic:${ELASTIC_PASSWORD} -d '{"password": "Admin@123"}'
```

访问服务

```
curl -u elastic:Admin@123 http://localhost:9200/
```

