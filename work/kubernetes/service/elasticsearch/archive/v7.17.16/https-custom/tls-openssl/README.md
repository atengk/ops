# 生成SSL证书

## openssl 方式（证书加密）

### 创建 CA 证书

创建 CA 配置

```
cat > tls-openssl-ca.cnf <<EOF
[req]
default_bits = 2048
prompt = no
default_md = sha256
distinguished_name = dn
x509_extensions = v3_ca
utf8 = yes
[dn]
C=CN
L=重庆市
O=阿腾集团
OU=研发中心
CN=kongyu.local
[v3_ca]
basicConstraints = critical,CA:TRUE,pathlen:0
EOF
```

生成 CA 私钥

```
openssl genpkey -algorithm RSA -out tls-openssl-ca.key -aes256 -pass pass:Admin@123
```

生成 CA 证书请求并自签名

```
openssl req -x509 -new -key tls-openssl-ca.key -out tls-openssl-ca.crt -days 36500 -config tls-openssl-ca.cnf -passin pass:Admin@123
```

显示 CA 证书信息

```
openssl x509 -in tls-openssl-ca.crt -text
```

### 创建服务器证书

创建服务器配置

```
cat > tls-openssl-elasticsearch-server.cnf <<EOF
[req]
default_bits = 2048
prompt = no
default_md = sha256
distinguished_name = dn
req_extensions = v3_req
utf8 = yes
[dn]
C=CN
L=重庆市
O=阿腾集团
OU=研发中心
CN=elasticsearch.kongyu.local
[v3_req]
basicConstraints = CA:FALSE
keyUsage = nonRepudiation, digitalSignature, keyEncipherment
subjectAltName = @alt_names
[alt_names]
DNS.1 = *.elasticsearch-master-hl.kongyu.svc.cluster.local
DNS.2 = elasticsearch-master-hl.kongyu.svc.cluster.local
DNS.3 = elasticsearch-master
DNS.4 = *.elasticsearch-coordinating-hl.kongyu.svc.cluster.local
DNS.5 = elasticsearch-coordinating-hl.kongyu.svc.cluster.local
DNS.6 = elasticsearch-coordinating
DNS.7 = *.elasticsearch-data-hl.kongyu.svc.cluster.local
DNS.8 = elasticsearch-data-hl.kongyu.svc.cluster.local
DNS.9 = elasticsearch-data
DNS.10 = *.elasticsearch-ingest-hl.kongyu.svc.cluster.local
DNS.11 = elasticsearch-ingest-hl.kongyu.svc.cluster.local
DNS.12 = elasticsearch-ingest
DNS.13 = 127.0.0.1
DNS.14 = localhost
DNS.15 = elasticsearch
DNS.16 = elasticsearch.lingo.local
DNS.17 = elasticsearch.kongyu.local
IP.1 = 192.168.1.10
IP.2 = 192.168.1.11
IP.3 = 192.168.1.12
IP.4 = 192.168.1.13
IP.5 = 192.168.1.14
IP.6 = 192.168.1.15
EOF
```

生成服务器私钥

```
openssl genpkey -algorithm RSA -out tls-openssl-elasticsearch-server.key -pass pass:Admin@123
```

生成服务器证书请求

```
openssl req -new -key tls-openssl-elasticsearch-server.key -out tls-openssl-elasticsearch-server.csr -config tls-openssl-elasticsearch-server.cnf
```

签发服务器证书并使用 CA 证书

```
openssl x509 -req -in tls-openssl-elasticsearch-server.csr -out tls-openssl-elasticsearch-server.crt -CA tls-openssl-ca.crt -CAkey tls-openssl-ca.key -CAcreateserial -days 3650 -extensions v3_req -extfile tls-openssl-elasticsearch-server.cnf -passin pass:Admin@123
```

显示服务器证书信息

```
openssl x509 -in tls-openssl-elasticsearch-server.crt -text
```

### 创建客户端证书

创建客户端配置

```
cat > tls-openssl-client.cnf <<EOF
[req]
default_bits = 2048
prompt = no
default_md = sha256
distinguished_name = dn
utf8 = yes
[dn]
C=CN
L=重庆市
O=阿腾集团
OU=研发中心
CN=client.kongyu.local
EOF
```

生成客户端私钥

```
openssl genpkey -algorithm RSA -out tls-openssl-client.key -pass pass:Admin@123
```

生成客户端证书请求

```
openssl req -new -key tls-openssl-client.key -out tls-openssl-client.csr -config tls-openssl-client.cnf
```

签发客户端证书并使用 CA 证书

```
openssl x509 -req -in tls-openssl-client.csr -out tls-openssl-client.crt -CA tls-openssl-ca.crt -CAkey tls-openssl-ca.key -CAcreateserial -days 3650 -extfile tls-openssl-client.cnf -passin pass:Admin@123
```

显示客户端证书信息

```
openssl x509 -in tls-openssl-client.crt -text
```

### 后续操作

**清理不必要的文件（可选）：** 在生成证书之后，可以删除证书请求文件，因为它们不再需要。

```
rm -f *.csr tls-openssl-ca.srl
```

确保妥善保存 CA 的私钥 (`tls-openssl-ca.key`)，因为它用于签署其他证书。此外，将生成的 `tls-openssl-ca.crt`、`tls-openssl-elasticsearch-server.crt` 和 `tls-openssl-client.crt` 文件用于配置 Elasticsearch 的 TLS/SSL。

