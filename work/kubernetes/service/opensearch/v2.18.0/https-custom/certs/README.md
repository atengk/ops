# OpenSSL

OpenSSL 是一个开源的加密工具包，提供了丰富的加密功能和协议实现，广泛用于 SSL/TLS 加密、数字证书管理等场景。以下文档介绍如何使用 OpenSSL 创建 CA 和服务端/客户端证书。

- [官网链接](https://www.openssl.org/)

------

## 创建 CA 证书

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
ST=Chongqing
L=Chongqing
O=Ateng
OU=ca
CN=ca.ateng.local
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

使用 `opensearch-ca.key` 自签名生成 CA 根证书，有效期设置为 10 年：

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

------

## 创建服务端证书

### 创建服务端配置文件

注意以下事项

- 注意命名空间，我这里是`kongyu`，根据实际安装的命名空间修改
- 需要配置集群宿主机的IP

#### opensearch-admin

```bash
cat > opensearch-admin.cnf <<EOF
[req]
default_bits = 2048
prompt = no
default_md = sha256
distinguished_name = dn
req_extensions = v3_req
utf8 = yes
[dn]
CN=admin
[v3_req]
basicConstraints = CA:FALSE
keyUsage = nonRepudiation, digitalSignature, keyEncipherment
EOF
```

#### opensearch-master

```bash
cat > opensearch-master.cnf <<EOF
[req]
default_bits = 2048
prompt = no
default_md = sha256
distinguished_name = dn
req_extensions = v3_req
utf8 = yes
[dn]
CN=opensearch-master
[v3_req]
basicConstraints = CA:FALSE
keyUsage = nonRepudiation, digitalSignature, keyEncipherment
subjectAltName = @alt_names
[alt_names]
DNS.1 = localhost
DNS.2 = *.ateng.local
DNS.3 = *.kongyu.local
DNS.4 = opensearch
DNS.5 = opensearch.kongyu.svc.cluster.local
DNS.6 = opensearch-master
DNS.7 = opensearch-master-hl.kongyu.svc.cluster.local
DNS.8 = *.opensearch-master-hl.kongyu.svc.cluster.local
IP.1 = 127.0.0.1
IP.2 = 192.168.1.10
IP.3 = 192.168.1.11
IP.4 = 192.168.1.12
IP.5 = 192.168.1.13
IP.6 = 47.108.39.131
EOF
```

#### opensearch-data

```bash
cat > opensearch-data.cnf <<EOF
[req]
default_bits = 2048
prompt = no
default_md = sha256
distinguished_name = dn
req_extensions = v3_req
utf8 = yes
[dn]
CN=opensearch-data
[v3_req]
basicConstraints = CA:FALSE
keyUsage = nonRepudiation, digitalSignature, keyEncipherment
subjectAltName = @alt_names
[alt_names]
DNS.1 = localhost
DNS.2 = *.ateng.local
DNS.3 = *.kongyu.local
DNS.4 = opensearch
DNS.5 = opensearch.kongyu.svc.cluster.local
DNS.6 = opensearch-data
DNS.7 = opensearch-data-hl.kongyu.svc.cluster.local
DNS.8 = *.opensearch-data-hl.kongyu.svc.cluster.local
IP.1 = 127.0.0.1
IP.2 = 192.168.1.10
IP.3 = 192.168.1.11
IP.4 = 192.168.1.12
IP.5 = 192.168.1.13
IP.6 = 47.108.39.131
EOF
```

#### opensearch-ingest

```bash
cat > opensearch-ingest.cnf <<EOF
[req]
default_bits = 2048
prompt = no
default_md = sha256
distinguished_name = dn
req_extensions = v3_req
utf8 = yes
[dn]
CN=opensearch-ingest
[v3_req]
basicConstraints = CA:FALSE
keyUsage = nonRepudiation, digitalSignature, keyEncipherment
subjectAltName = @alt_names
[alt_names]
DNS.1 = localhost
DNS.2 = *.ateng.local
DNS.3 = *.kongyu.local
DNS.4 = opensearch
DNS.5 = opensearch.kongyu.svc.cluster.local
DNS.6 = opensearch-ingest
DNS.7 = opensearch-ingest-hl.kongyu.svc.cluster.local
DNS.8 = *.opensearch-ingest-hl.kongyu.svc.cluster.local
IP.1 = 127.0.0.1
IP.2 = 192.168.1.10
IP.3 = 192.168.1.11
IP.4 = 192.168.1.12
IP.5 = 192.168.1.13
IP.6 = 47.108.39.131
EOF
```

#### opensearch-coordinating

```bash
cat > opensearch-coordinating.cnf <<EOF
[req]
default_bits = 2048
prompt = no
default_md = sha256
distinguished_name = dn
req_extensions = v3_req
utf8 = yes
[dn]
CN=opensearch-coordinating
[v3_req]
basicConstraints = CA:FALSE
keyUsage = nonRepudiation, digitalSignature, keyEncipherment
subjectAltName = @alt_names
[alt_names]
DNS.1 = localhost
DNS.2 = *.ateng.local
DNS.3 = *.kongyu.local
DNS.4 = opensearch
DNS.5 = opensearch.kongyu.svc.cluster.local
DNS.6 = opensearch-coordinating
DNS.7 = opensearch-coordinating-hl.kongyu.svc.cluster.local
DNS.8 = *.opensearch-coordinating-hl.kongyu.svc.cluster.local
IP.1 = 127.0.0.1
IP.2 = 192.168.1.10
IP.3 = 192.168.1.11
IP.4 = 192.168.1.12
IP.5 = 192.168.1.13
IP.6 = 47.108.39.131
EOF
```

### 生成服务端私钥

```bash
openssl genpkey \
  -algorithm RSA \
  -out opensearch-server.key \
  -pkeyopt rsa_keygen_bits:2048
```

### 生成服务端证书

#### opensearch-admin

**生成服务端证书请求**

```bash
openssl req -new \
  -key opensearch-server.key \
  -out opensearch-admin.csr \
  -config opensearch-admin.cnf
```

**签发服务端证书**

使用 CA 证书签发服务端证书，有效期设置为 10 年：

```bash
openssl x509 -req \
  -in opensearch-admin.csr \
  -out opensearch-admin.crt \
  -CA opensearch-ca.crt \
  -CAkey opensearch-ca.key \
  -CAcreateserial \
  -days 3650 \
  -extensions v3_req \
  -extfile opensearch-admin.cnf \
  -passin pass:Admin@123
```

**查看服务端证书信息**

查看证书的所有信息

```bash
openssl x509 -in opensearch-admin.crt -text
```

查看证书的DN（Distinguished Name，专有名称）

```bash
openssl x509 -in opensearch-admin.crt -noout -subject
```

#### opensearch-master

**生成服务端证书请求**

```bash
openssl req -new \
  -key opensearch-server.key \
  -out opensearch-master.csr \
  -config opensearch-master.cnf
```

**签发服务端证书**

使用 CA 证书签发服务端证书，有效期设置为 10 年：

```bash
openssl x509 -req \
  -in opensearch-master.csr \
  -out opensearch-master.crt \
  -CA opensearch-ca.crt \
  -CAkey opensearch-ca.key \
  -CAcreateserial \
  -days 3650 \
  -extensions v3_req \
  -extfile opensearch-master.cnf \
  -passin pass:Admin@123
```

**查看服务端证书信息**

查看证书的所有信息

```bash
openssl x509 -in opensearch-master.crt -text
```

查看证书的DN（Distinguished Name，专有名称）

```bash
openssl x509 -in opensearch-master.crt -noout -subject
```

#### opensearch-data

**生成服务端证书请求**

```bash
openssl req -new \
  -key opensearch-server.key \
  -out opensearch-data.csr \
  -config opensearch-data.cnf
```

**签发服务端证书**

使用 CA 证书签发服务端证书，有效期设置为 10 年：

```bash
openssl x509 -req \
  -in opensearch-data.csr \
  -out opensearch-data.crt \
  -CA opensearch-ca.crt \
  -CAkey opensearch-ca.key \
  -CAcreateserial \
  -days 3650 \
  -extensions v3_req \
  -extfile opensearch-data.cnf \
  -passin pass:Admin@123
```

**查看服务端证书信息**

查看证书的所有信息

```bash
openssl x509 -in opensearch-data.crt -text
```

查看证书的DN（Distinguished Name，专有名称）

```bash
openssl x509 -in opensearch-data.crt -noout -subject
```

#### opensearch-ingest

**生成服务端证书请求**

```bash
openssl req -new \
  -key opensearch-server.key \
  -out opensearch-ingest.csr \
  -config opensearch-ingest.cnf
```

**签发服务端证书**

使用 CA 证书签发服务端证书，有效期设置为 10 年：

```bash
openssl x509 -req \
  -in opensearch-ingest.csr \
  -out opensearch-ingest.crt \
  -CA opensearch-ca.crt \
  -CAkey opensearch-ca.key \
  -CAcreateserial \
  -days 3650 \
  -extensions v3_req \
  -extfile opensearch-ingest.cnf \
  -passin pass:Admin@123
```

**查看服务端证书信息**

查看证书的所有信息

```bash
openssl x509 -in opensearch-ingest.crt -text
```

查看证书的DN（Distinguished Name，专有名称）

```bash
openssl x509 -in opensearch-ingest.crt -noout -subject
```

#### opensearch-coordinating

**生成服务端证书请求**

```bash
openssl req -new \
  -key opensearch-server.key \
  -out opensearch-coordinating.csr \
  -config opensearch-coordinating.cnf
```

**签发服务端证书**

使用 CA 证书签发服务端证书，有效期设置为 10 年：

```bash
openssl x509 -req \
  -in opensearch-coordinating.csr \
  -out opensearch-coordinating.crt \
  -CA opensearch-ca.crt \
  -CAkey opensearch-ca.key \
  -CAcreateserial \
  -days 3650 \
  -extensions v3_req \
  -extfile opensearch-coordinating.cnf \
  -passin pass:Admin@123
```

**查看服务端证书信息**

查看证书的所有信息

```bash
openssl x509 -in opensearch-coordinating.crt -text
```

查看证书的DN（Distinguished Name，专有名称）

```bash
openssl x509 -in opensearch-coordinating.crt -noout -subject
```

## 上传到K8S的Secret

### 上传服务端证书

用于opensearch服务之间相互认证

#### opensearch-admin

```shell
kubectl create -n kongyu secret generic opensearch-admin-crt \
  --from-file=ca.crt=opensearch-ca.crt \
  --from-file=tls.key=opensearch-server.key \
  --from-file=tls.crt=opensearch-admin.crt
```

#### opensearch-master

```shell
kubectl create -n kongyu secret generic opensearch-master-crt \
  --from-file=ca.crt=opensearch-ca.crt \
  --from-file=tls.key=opensearch-server.key \
  --from-file=tls.crt=opensearch-master.crt
```

#### opensearch-data

```shell
kubectl create -n kongyu secret generic opensearch-data-crt \
  --from-file=ca.crt=opensearch-ca.crt \
  --from-file=tls.key=opensearch-server.key \
  --from-file=tls.crt=opensearch-data.crt
```

#### opensearch-ingest

```shell
kubectl create -n kongyu secret generic opensearch-ingest-crt \
  --from-file=ca.crt=opensearch-ca.crt \
  --from-file=tls.key=opensearch-server.key \
  --from-file=tls.crt=opensearch-ingest.crt
```

#### opensearch-coordinating

```shell
kubectl create -n kongyu secret generic opensearch-coordinating-crt \
  --from-file=ca.crt=opensearch-ca.crt \
  --from-file=tls.key=opensearch-server.key \
  --from-file=tls.crt=opensearch-coordinating.crt
```

### 
