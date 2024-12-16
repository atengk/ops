# OpenSearch

OpenSearch 是一个开源的分布式搜索和分析引擎，基于 Apache 2.0 许可，支持实时搜索、日志分析和数据可视化。它继承自 Elasticsearch，并提供强大的查询、索引、分析功能，适用于大规模数据处理和监控。OpenSearch 具有高可扩展性，支持插件扩展，广泛用于日志管理、应用搜索和安全监控。

OpenSearch2是ElasticSearch8的分支，起源于Elastic的开源版本，因许可变化而独立发展，保持兼容性。

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
  repo: /data/service/opensearch/snap
  logs: /data/service/opensearch/logs
transport:
  port: "9300"
network:
  host: service01.ateng.local
  publish_host: service01.ateng.local
  bind_host: 0.0.0.0
node:
  name: service01.ateng.local
cluster:
  name: opensearch
  initial_cluster_manager_nodes:
    - service01.ateng.local
discovery:
  seed_hosts: service01.ateng.local
  initial_state_timeout: 10m
plugins:
  security:
    disabled: "true"
EOF
```

参数说明：

- **`network.host`**：当前节点绑定的主机地址，可以是 IP 或主机名。
- **`network.publish_host`**：当前节点向其他节点公布的地址，其他节点通过此地址与该节点通信。
- **`network.bind_host`**：当前节点监听的网络接口（例如 `0.0.0.0` 表示监听所有接口）。
- **`http.port`**：HTTP 服务监听的端口（默认 `9200`），用于外部请求。
- **`transport.port`**：节点之间通信的端口（默认 `9300`），用于集群内部通信。
- **`cluster.name`**：集群名称，确保同一个集群的所有节点使用相同名称。
- **`node.name`**：当前节点的唯一名称，用于标识该节点。
- **`cluster.initial_cluster_manager_nodes`**：初始集群管理节点列表，指定哪些节点参与初始选举。
- **`discovery.seed_hosts`**：节点发现列表，用于引导集群中节点互相连接。
- **`path.data`**：数据存储目录，存储索引数据和事务日志。
- **`path.repo`**：快照存储路径，用于备份。
- **`path.logs`**：日志存储路径。
- **`http.cors.enabled`**：是否启用跨域资源共享 (CORS) 支持。
- **`http.cors.allow-origin`**：允许的跨域请求来源（`*` 表示所有来源）。
- **`http.cors.allow-credentials`**：是否允许跨域请求携带认证信息。
- **`plugins.security.disabled`**：是否禁用 OpenSearch 的内置安全功能（`true` 表示禁用）。

**编辑JVM配置文件**

```
cat > $OPENSEARCH_HOME/config/jvm.options.d/my_jvm.options <<"EOF"
-Xms4g
-Xmx4g
EOF
```

**创建目录**

```
mkdir -p /data/service/opensearch/{data,snap,logs}
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

**查看日志**

```
sudo journalctl -f -u opensearch
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



### 安装插件

**安装 `IK Analysis` 插件**

- 官网地址: https://github.com/infinilabs/analysis-ik
- 插件下载地址：https://release.infinilabs.com/analysis-ik/stable/

下载插件，注意需要和OpenSearch版本保持一致

```
wget https://release.infinilabs.com/analysis-ik/stable/opensearch-analysis-ik-2.18.0.zip
```

安装插件，注意这里得使用本地文件的绝对路径，安装时有个风险确认

```
opensearch-plugin install file://$(pwd)/opensearch-analysis-ik-2.18.0.zip
```

查看安装的插件

```
opensearch-plugin list
```

重启服务，安装好插件后需要重启服务加载插件

```
sudo systemctl restart opensearch
```

查看已安装的插件

```
curl http://service01.ateng.local:9200/_cat/plugins?v
```



## 安装 Dashboard

### 安装服务

**下载软件包**

```
wget https://artifacts.opensearch.org/releases/bundle/opensearch-dashboards/2.18.0/opensearch-dashboards-2.18.0-linux-x64.tar.gz
```

**解压并安装**

```
tar -zxvf opensearch-dashboards-2.18.0-linux-x64.tar.gz -C /usr/local/software/
ln -s /usr/local/software/opensearch-dashboards-2.18.0 /usr/local/software/opensearch-dashboards
```

**配置环境变量**

```
cat >> ~/.bash_profile <<"EOF"
## OPENSEARCH_DASHBOARD_HOME
export OPENSEARCH_DASHBOARD_HOME=/usr/local/software/opensearch-dashboards
export PATH=$PATH:$OPENSEARCH_DASHBOARD_HOME/bin
EOF
source ~/.bash_profile
```

**查看版本**

```
$OPENSEARCH_DASHBOARD_HOME/bin/opensearch-dashboards --version
```



### 编辑配置

**编辑服务配置文件**

常规HTTP模式，无密码认证。还需要移除dashboard的安全插件，访问时才会无验证。

```
mv $OPENSEARCH_DASHBOARD_HOME/plugins/securityDashboards $OPENSEARCH_DASHBOARD_HOME/data
cp $OPENSEARCH_DASHBOARD_HOME/config/opensearch_dashboards.yml{,_bak}
cat > $OPENSEARCH_DASHBOARD_HOME/config/opensearch_dashboards.yml <<"EOF"
path:
  data: /data/service/opensearch-dashboards/data
server:
  host: 0.0.0.0
  port: 5601
opensearch:
  hosts: 
    - http://service01.ateng.local:9200
EOF
```

安全模式HTTPS+用户认证，配置如下

```
mv $OPENSEARCH_DASHBOARD_HOME/data/securityDashboards $OPENSEARCH_DASHBOARD_HOME/plugins/
cat > $OPENSEARCH_DASHBOARD_HOME/config/opensearch_dashboards.yml <<"EOF"
path:
  data: /data/service/opensearch-dashboards/data
server:
  host: 0.0.0.0
  port: 5601
opensearch:
  hosts: 
    - https://service01.ateng.local:9200
  username: kibanaserver
  password: Admin@123
  ssl:
    verificationMode: certificate
    certificateAuthorities:
      - "/usr/local/software/opensearch/config/certs/ca.crt"
opensearch_security:
  multitenancy:
    enabled: true
    tenants.preferred: [Private, Global]
EOF
```

**创建目录**

```
mkdir -p /data/service/opensearch-dashboards/data
```



### 启动服务

**临时启动服务**

```
$OPENSEARCH_DASHBOARD_HOME/bin/opensearch-dashboards
```

**访问测试**

浏览器访问，测试没问题后就可以配置开启自启动。如果启用了OpenSearch的安全配置，还需要OpenSearch相关的账号密码。

```
URL: http://10.244.172.143:5601/
Username: kibana
Password: Admin@123
```

**配置开启自启动**

创建 `opensearch.service` 文件

```
sudo tee /etc/systemd/system/opensearch-dashboards.service <<"EOF"
[Unit]
Description=OpenSearch Dashboards Server
Documentation=https://opensearch.org/
After=network-online.target

[Service]
User=admin
Group=ateng
Type=simple
Restart=on-failure
RestartSec=10
WorkingDirectory=/usr/local/software/opensearch-dashboards
ExecStart=/usr/local/software/opensearch-dashboards/bin/opensearch-dashboards
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
sudo systemctl enable --now opensearch-dashboards
```

**查看日志**

```
sudo journalctl -f -u opensearch-dashboards
```



### 使用服务

**访问服务**

浏览器访问。如果启用了OpenSearch的安全配置，还需要OpenSearch相关的账号密码。

```
URL: http://10.244.172.143:5601/
```



## 安全配置

如果需要配置认证和HTTPS，可以参考本章节。

### 证书创建

#### 创建 CA 证书

**创建 CA 配置文件**

创建 `opensearch-ca.cnf` 文件，定义 CA 证书的基本信息和扩展：

```bash
cat > opensearch-ca.cnf <<EOF
[req]
default_bits = 2048
prompt = no
default_md = sha256
distinguished_name = dn
x509_extensions = v3_ca
utf8 = yes
[dn]
C=CN
L=Chongqing
O=Ateng
OU=Ateng
CN=ateng.local
[v3_ca]
basicConstraints = critical,CA:TRUE,pathlen:0
EOF
```

**生成 CA 私钥**

生成 CA 私钥文件，并使用 AES-256 加密保护私钥：

```bash
openssl genpkey -aes256 \
  -algorithm RSA \
  -out opensearch-ca.key \
  -pass pass:Admin@123 \
  -pkeyopt rsa_keygen_bits:2048
```

**生成 CA 证书**

使用 `opensearch-ca.key` 自签名生成 CA 根证书，有效期设置为 100 年：

```bash
openssl req -x509 -new \
  -key opensearch-ca.key \
  -out opensearch-ca.crt \
  -days 3650 \
  -config opensearch-ca.cnf \
  -passin pass:Admin@123
```

**查看 CA 证书信息**

使用以下命令查看 CA 证书的详细信息：

```bash
openssl x509 -in opensearch-ca.crt -text
```

#### 创建服务端证书

创建服务端证书用于集群节点之间的认证

**创建服务端配置文件**

创建 `opensearch-server.cnf` 文件，定义服务端证书的信息和扩展字段（如 `subjectAltName`）：

注意修改 **dn** 和 **alt_names** 模块的内容，**alt_names**中需要填写会和集群有交互的域名和IP

```bash
cat > opensearch-server.cnf <<EOF
[req]
default_bits = 2048
prompt = no
default_md = sha256
distinguished_name = dn
req_extensions = v3_req
utf8 = yes
[dn]
C=CN
ST=Chongqing
L=Chongqing
O=Ateng
OU=opensearch
CN=opensearch.ateng.local
[v3_req]
basicConstraints = CA:FALSE
keyUsage = nonRepudiation, digitalSignature, keyEncipherment
subjectAltName = @alt_names
[alt_names]
DNS.1 = localhost
DNS.2 = *.ateng.local
DNS.3 = service01
DNS.4 = service02
DNS.5 = service03
IP.1 = 127.0.0.1
IP.2 = 10.244.172.143
IP.3 = 10.244.172.7
IP.4 = 10.244.172.222
EOF
```

**生成服务端私钥**

```bash
openssl genpkey \
  -algorithm RSA \
  -out opensearch-server.key \
  -pkeyopt rsa_keygen_bits:2048
```

**生成服务端证书请求**

```bash
openssl req -new \
  -key opensearch-server.key \
  -out opensearch-server.csr \
  -config opensearch-server.cnf
```

**签发服务端证书**

使用 CA 证书签发服务端证书，有效期设置为 100 年：

```bash
openssl x509 -req \
  -in opensearch-server.csr \
  -out opensearch-server.crt \
  -CA opensearch-ca.crt \
  -CAkey opensearch-ca.key \
  -CAcreateserial \
  -days 3650 \
  -extensions v3_req \
  -extfile opensearch-server.cnf \
  -passin pass:Admin@123
```

**查看服务端证书信息**

查看证书的所有信息

```bash
openssl x509 -in opensearch-server.crt -text
```

查看证书的DN（Distinguished Name，专有名称）

```
openssl x509 -in opensearch-server.crt -noout -subject
```

#### 创建客户端证书

创建客户端端证书用于客户端与集群节点之间的认证

**创建客户端配置文件**

创建 `opensearch-client.cnf` 文件，定义客户端证书的信息：

```bash
cat > opensearch-client.cnf <<EOF
[req]
default_bits = 2048
prompt = no
default_md = sha256
distinguished_name = dn
utf8 = yes
[dn]
C=CN
ST=Chongqing
L=Chongqing
O=Ateng
OU=opensearch
CN=opensearch
EOF
```

**生成客户端私钥**

```bash
openssl genpkey \
  -algorithm RSA \
  -out opensearch-client.key \
  -pkeyopt rsa_keygen_bits:2048
```

**生成客户端证书请求**

```bash
openssl req -new \
  -key opensearch-client.key \
  -out opensearch-client.csr \
  -config opensearch-client.cnf
```

**签发客户端证书**

使用 CA 证书签发客户端证书，有效期设置为 100 年：

```bash
openssl x509 -req \
  -in opensearch-client.csr \
  -out opensearch-client.crt \
  -CA opensearch-ca.crt \
  -CAkey opensearch-ca.key \
  -CAcreateserial \
  -days 3650 \
  -passin pass:Admin@123
```

**查看客户端证书信息**

查看证书的所有信息

```bash
openssl x509 -in opensearch-client.crt -text
```

查看证书的DN（Distinguished Name，专有名称）

```
openssl x509 -in opensearch-client.crt -noout -subject
```

### 拷贝证书

最后需要的证书文件：`opensearch-ca.crt` 、`opensearch-server.crt`、`opensearch-server.key`、、`opensearch-client.crt`、`opensearch-client.key`

```
mkdir -p /usr/local/software/opensearch/config/certs
cp opensearch-ca.crt opensearch-server.crt opensearch-server.key opensearch-client.crt opensearch-client.key /usr/local/software/opensearch/config/certs
```

### 配置认证

#### 编辑配置文件

注意修改以下配置

- plugins.security.disabled 改为 false
- plugins.security.nodes_dn[0] 改为实际的CN信息，使用 `openssl x509 -in opensearch-server.crt -noout -subject` 查看，注意配置文件的格式不要变，根据命令查看的结果对应修改即可
- plugins.security.authcz.admin_dn[0] 改为实际的CN信息，使用 `openssl x509 -in opensearch-client.crt -noout -subject` 查看，注意配置文件的格式不要变，根据命令查看的结果对应修改即可
- 相关证书地址

```
$ vi $OPENSEARCH_HOME/config/opensearch.yml
# ...
plugins:
  security:
    disabled: "false"
    nodes_dn:
      - "CN=opensearch.ateng.local,OU=opensearch,O=Ateng,L=Chongqing,ST=Chongqing,C=CN"
    authcz:
      admin_dn:
        - "CN=opensearch,OU=opensearch,O=Ateng,L=Chongqing,ST=Chongqing,C=CN"
    ssl:
      http:
        enabled: true
        pemtrustedcas_filepath: /usr/local/software/opensearch/config/certs/opensearch-ca.crt
        pemcert_filepath: /usr/local/software/opensearch/config/certs/opensearch-server.crt
        pemkey_filepath: /usr/local/software/opensearch/config/certs/opensearch-server.key
      transport:
        enabled: true
        enforce_hostname_verification: false
        pemtrustedcas_filepath: /usr/local/software/opensearch/config/certs/opensearch-ca.crt
        pemcert_filepath: /usr/local/software/opensearch/config/certs/opensearch-server.crt
        pemkey_filepath: /usr/local/software/opensearch/config/certs/opensearch-server.key
```

配置文件说明

- **`disabled`**: 启用或禁用 Security 插件。`"false"` 启用，`"true"` 禁用。
- **`nodes_dn`**: 集群节点证书的 Distinguished Name (DN)，通常是节点的身份标识。
- **`authcz.admin_dn`**: 管理员权限的证书 DN，通常是具有管理员权限的用户证书。

- **`http.enabled`**: 启用或禁用 HTTP 层的 SSL 加密。`true` 启用，`false` 禁用。
- **`http.pem*`**: HTTP SSL 证书的文件路径。
- **`transport.enabled`**: 启用或禁用节点间传输层的 SSL 加密。`true` 启用，`false` 禁用。
- **`transport.enforce_hostname_verification`**: 是否强制进行主机名验证。`true` 强制，`false` 不强制。
- **`transport.pem*`**: 节点间的证书文件路径。

#### 重启服务

**使用systemd重启服务**

```
sudo systemctl restart opensearch
```

**查看日志**

服务启动成功后会输出为一些未安全配置的信息，下面的内容将进行初始化安全配置

```
sudo journalctl -f -u opensearch
```

#### 设置密码hash

使用内部工具获取密码的hash值，用于下面设置用户密码

```
cd $OPENSEARCH_HOME/plugins/opensearch-security/tools
chmod +x hash.sh
./hash.sh -p Ateng@2024
```

重新配置用户，这里设置了3个用户 `admin`、`kibanaserver` 、`logstash` 、 `kibana` ，根据需求使用上面的工具获取密码的hash值，然后修改对应的用户密码hash

> 默认密码：admin:Ateng@2024, 其他:Admin@123

```
cp $OPENSEARCH_HOME/plugins/opensearch-security/securityconfig/internal_users.yml{,_bak}
cat > $OPENSEARCH_HOME/plugins/opensearch-security/securityconfig/internal_users.yml <<"EOF"
_meta:
  type: internalusers
  config_version: "2"
admin:
  hash: $2y$12$.ic41QUBivEVj.R6azFLeeSQRc1Pa7TxsCVz2VhH3wKBF3ifFNlFa
  backend_roles:
    - admin
  reserved: true
  description: "管理员用户"
kibanaserver:
  hash: $2y$12$e/G/yP5Sflvv/iX0GaQz8OVvptarfedhktq9zZhXW7tSgBMKJ08Pm
  reserved: true
  description: "Dashboards服务使用的用户"
logstash:
  hash: $2y$12$e/G/yP5Sflvv/iX0GaQz8OVvptarfedhktq9zZhXW7tSgBMKJ08Pm
  backend_roles:
    - logstash
  reserved: true
  description: "Logstash服务使用的用户"
kibana:
  hash: $2y$12$e/G/yP5Sflvv/iX0GaQz8OVvptarfedhktq9zZhXW7tSgBMKJ08Pm
  reserved: false
  backend_roles:
  - "kibanauser"
  - "readall"
  description: "Dashboards的只读用户"
EOF
```

#### 初始化安全设置

**首次初始化安全设置**

在首次进行安全配置，需要以下操作

```
cd $OPENSEARCH_HOME/plugins/opensearch-security/tools
chmod +x securityadmin.sh
./securityadmin.sh \
  -cd "$OPENSEARCH_HOME/plugins/opensearch-security/securityconfig" \
  -icl -key "$OPENSEARCH_HOME/config/certs/opensearch-client.key" \
  -cert "$OPENSEARCH_HOME/config/certs/opensearch-client.crt" \
  -cacert "$OPENSEARCH_HOME/config/certs/opensearch-ca.crt" -nhnv
```

参数说明：

- `-cd`：配置文件目录。
- `-icl`：初始化集群。
- `-key`：服务器私钥。
- `-cert`：服务器证书。
- `-cacert`：CA 证书。
- `-nhnv`：不进行主机名验证（可选）。

**后续如需修改密码执行的命令**

如果后续要修改密码，可以参考以下命令，使用 `-f` 和 `-t  ` 只加载用户到索引中

```
cd $OPENSEARCH_HOME/plugins/opensearch-security/tools
./securityadmin.sh \
  -f "$OPENSEARCH_HOME/plugins/opensearch-security/securityconfig/internal_users.yml" \
  -t internalusers \
  -icl -key "$OPENSEARCH_HOME/config/certs/opensearch-client.key" \
  -cert "$OPENSEARCH_HOME/config/certs/opensearch-client.crt" \
  -cacert "$OPENSEARCH_HOME/config/certs/opensearch-ca.crt" -nhnv
```

也可以通过API请求修改密码

```
curl --cacert $OPENSEARCH_HOME/config/certs/opensearch-ca.crt \
     --cert $OPENSEARCH_HOME/config/certs/opensearch-client.crt \
     --key $OPENSEARCH_HOME/config/certs/opensearch-client.key \
     -X PUT "https://localhost:9200/_opendistro/_security/api/internalusers/logstash" \
     -H "Content-Type: application/json" \
     -u "admin:Ateng@2024" \
     -d '{
       "password": "Ateng@20241212",
       "backend_roles": ["logstash"]
     }'
```

查看用户

```
curl --cacert $OPENSEARCH_HOME/config/certs/opensearch-ca.crt \
     --cert $OPENSEARCH_HOME/config/certs/opensearch-client.crt \
     --key $OPENSEARCH_HOME/config/certs/opensearch-client.key \
     -X GET "https://localhost:9200/_opendistro/_security/api/internalusers?pretty" \
     -u "admin:Ateng@2024"
```



### 访问服务

**访问HTTPS**

```
$ curl --cacert $OPENSEARCH_HOME/config/certs/opensearch-ca.crt \
  -u admin:Ateng@2024 \
  https://service01.ateng.local:9200/
{
  "name" : "service01.ateng.local",
  "cluster_name" : "opensearch",
  "cluster_uuid" : "ZAUU0LB4SHuIlCiOUWyHPQ",
  "version" : {
    "distribution" : "opensearch",
    "number" : "1.3.19",
    "build_type" : "tar",
    "build_hash" : "3ce0904c5e452a18ba343eecf04005bfd91b3249",
    "build_date" : "2024-08-23T00:37:19.891640Z",
    "build_snapshot" : false,
    "lucene_version" : "8.10.1",
    "minimum_wire_compatibility_version" : "6.8.0",
    "minimum_index_compatibility_version" : "6.0.0-beta1"
  },
  "tagline" : "The OpenSearch Project: https://opensearch.org/"
}
```



### 关闭HTTPS

**编辑配置文件**

关闭这个后就可以使用http，并且需要用户认证

```
$ vi +36 $OPENSEARCH_HOME/config/opensearch.yml
# ...
plugins:
  security:
    ssl:
      http:
        enabled: false
```

**重启服务**

使用systemd重启服务

```
sudo systemctl restart opensearch
```

查看日志

```
sudo journalctl -f -u opensearch
```

**访问HTTP**

关闭HTTPS后就可以使用HTTP＋认证的方式访问服务了

```
$ curl -u admin:Ateng@2024 http://service01.ateng.local:9200/
{
  "name" : "service01.ateng.local",
  "cluster_name" : "opensearch",
  "cluster_uuid" : "ZAUU0LB4SHuIlCiOUWyHPQ",
  "version" : {
    "distribution" : "opensearch",
    "number" : "1.3.19",
    "build_type" : "tar",
    "build_hash" : "3ce0904c5e452a18ba343eecf04005bfd91b3249",
    "build_date" : "2024-08-23T00:37:19.891640Z",
    "build_snapshot" : false,
    "lucene_version" : "8.10.1",
    "minimum_wire_compatibility_version" : "6.8.0",
    "minimum_index_compatibility_version" : "6.0.0-beta1"
  },
  "tagline" : "The OpenSearch Project: https://opensearch.org/"
}
```



## 集群模式

**集群节点信息如下**

| IP             | 主机名                | 描述               |
| -------------- | --------------------- | ------------------ |
| 10.244.172.143 | service01.ateng.local | OpenSearch Cluster |
| 10.244.172.7   | service02.ateng.local | OpenSearch Cluster |
| 10.244.172.222 | service03.ateng.local | OpenSearch Cluster |

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
  repo: /data/service/opensearch/snap
  logs: /data/service/opensearch/logs
transport:
  port: "9300"
network:
  host: service01.ateng.local
  publish_host: service01.ateng.local
  bind_host: 0.0.0.0
node:
  name: service01.ateng.local
cluster:
  name: opensearch
  initial_cluster_manager_nodes:
    - service01.ateng.local
    - service02.ateng.local
    - service03.ateng.local
discovery:
  seed_hosts:
    - service01.ateng.local
    - service02.ateng.local
    - service03.ateng.local
  initial_state_timeout: 10m
plugins:
  security:
    disabled: "true"
EOF
```

不同节点需要修改的配置：

- **`network.host` 和 `network.publish_host`**：修改为当前节点的主机名或 IP（如 `service01.ateng.local`）。
- **`node.name`**：修改为当前节点的唯一名称（如 `service01.ateng.local`）。
- **`path.data`、`path.repo`、`path.logs`**（可选）：如果各节点的存储目录不同，需要分别指定。

集群信息配置，按照实际集群的信息填写列表

- **`cluster.initial_cluster_manager_nodes`**：初始集群管理节点列表，指定哪些节点参与初始选举。
- **`discovery.seed_hosts`**：节点发现列表，用于引导集群中节点互相连接。

**编辑JVM配置文件**

```
cat > $OPENSEARCH_HOME/config/jvm.options.d/my_jvm.options <<"EOF"
-Xms4g
-Xmx4g
EOF
```

**创建目录**

```
mkdir -p /data/service/opensearch/{data,snap,logs}
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
curl http://service02.ateng.local:9200/
curl http://service03.ateng.local:9200/
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

**查看日志**

```
sudo journalctl -f -u opensearch
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
    "number_of_shards": 3,
    "number_of_replicas": 2
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



### 安装插件

注意集群每个节点都需要安装插件

**安装 `IK Analysis` 插件**

- 官网地址: https://github.com/infinilabs/analysis-ik
- 插件下载地址：https://release.infinilabs.com/analysis-ik/stable/

下载插件，注意需要和OpenSearch版本保持一致

```
wget https://release.infinilabs.com/analysis-ik/stable/opensearch-analysis-ik-2.18.0.zip
```

安装插件，注意这里得使用本地文件的绝对路径，安装时有个风险确认

```
opensearch-plugin install file://$(pwd)/opensearch-analysis-ik-2.18.0.zip
```

查看安装的插件

```
opensearch-plugin list
```

重启服务，安装好插件后需要重启服务加载插件

```
sudo systemctl restart opensearch
```

查看已安装的插件

```
curl http://service01.ateng.local:9200/_cat/plugins?v
```



### 安全配置

参考上面的 **安全配置** 章节，注意以下事项即可：

- 操作和单节点的一致，就是初始化安全配置部分只需要在一个节点进行初始化即可
