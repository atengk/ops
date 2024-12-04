# OpenSSL

OpenSSL 是一个开源的加密工具包，提供了丰富的加密功能和协议实现，广泛用于 SSL/TLS 加密、数字证书管理等场景。以下文档介绍如何使用 OpenSSL 创建 CA 和服务端/客户端证书。

- [官网链接](https://www.openssl.org/)

------

## 创建 CA 证书

### 创建 CA 配置文件

创建 `ca.cnf` 文件，定义 CA 证书的基本信息和扩展：

```bash
cat > ca.cnf <<EOF
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

### 生成 CA 私钥

生成 CA 私钥文件，并使用 AES-256 加密保护私钥：

```bash
openssl genpkey -algorithm RSA -out ca.key -aes256 -pass pass:Admin@123
```

### 生成 CA 证书

使用 `ca.key` 自签名生成 CA 根证书，有效期设置为 100 年：

```bash
openssl req -x509 -new -key ca.key -out ca.crt -days 36500 -config ca.cnf -passin pass:Admin@123
```

### 查看 CA 证书信息

使用以下命令查看 CA 证书的详细信息：

```bash
openssl x509 -in ca.crt -text
```

------

## 创建服务端证书

### 创建服务端配置文件

创建 `server.cnf` 文件，定义服务端证书的信息和扩展字段（如 `subjectAltName`）：

```bash
cat > server.cnf <<EOF
[req]
default_bits = 2048
prompt = no
default_md = sha256
distinguished_name = dn
req_extensions = v3_req
utf8 = yes
[dn]
C=CN
L=Chongqing
O=Ateng
OU=Ateng
CN=nginx.ateng.local
[v3_req]
basicConstraints = CA:FALSE
keyUsage = nonRepudiation, digitalSignature, keyEncipherment
subjectAltName = @alt_names
[alt_names]
DNS.1 = nginx.ateng.local
DNS.2 = localhost
IP.1 = 127.0.0.1
IP.2 = 192.168.1.10
EOF
```

### 生成服务端私钥

```bash
openssl genpkey -algorithm RSA -out server.key -pass pass:Admin@123
```

### 生成服务端证书请求

```bash
openssl req -new -key server.key -out server.csr -config server.cnf
```

### 签发服务端证书

使用 CA 证书签发服务端证书，有效期设置为 100 年：

```bash
openssl x509 -req -in server.csr -out server.crt -CA ca.crt -CAkey ca.key -CAcreateserial -days 36500 -extensions v3_req -extfile server.cnf -passin pass:Admin@123
```

### 查看服务端证书信息

```bash
openssl x509 -in server.crt -text
```

------

## 创建客户端证书

### 创建客户端配置文件

创建 `client.cnf` 文件，定义客户端证书的信息：

```bash
cat > client.cnf <<EOF
[req]
default_bits = 2048
prompt = no
default_md = sha256
distinguished_name = dn
utf8 = yes
[dn]
C=CN
L=Chongqing
O=Ateng
OU=Ateng
CN=client.ateng.local
EOF
```

### 生成客户端私钥

```bash
openssl genpkey -algorithm RSA -out client.key -pass pass:Admin@123
```

### 生成客户端证书请求

```bash
openssl req -new -key client.key -out client.csr -config client.cnf
```

### 签发客户端证书

使用 CA 证书签发客户端证书，有效期设置为 100 年：

```bash
openssl x509 -req -in client.csr -out client.crt -CA ca.crt -CAkey ca.key -CAcreateserial -days 36500 -passin pass:Admin@123
```

### 查看客户端证书信息

```bash
openssl x509 -in client.crt -text
```

------

## 证书说明

以下是与证书相关文件的说明及作用

| **文件名**   | **类型**   | **作用**                                             | **用途**                                          | **分发建议**                       |
| ------------ | ---------- | ---------------------------------------------------- | ------------------------------------------------- | ---------------------------------- |
| `ca.crt`     | CA 根证书  | 提供信任链的根，用于验证下级证书的有效性             | 部署在客户端或服务端，用于验证 TLS 通信的对端证书 | 安全分发，提供给所有客户端和服务端 |
| `ca.key`     | CA 私钥    | 用于签发下级证书                                     | 用于签署服务端和客户端证书                        | 严格保密，不分发                   |
| `server.crt` | 服务端证书 | 提供 TLS 加密通信能力                                | 部署到服务端，用于与客户端建立安全连接            | 部署到服务端                       |
| `server.key` | 服务端私钥 | 解密客户端发送的数据，与 `server.crt` 配对使用       | 部署到服务端，保护通信机密性                      | 严格保密，仅部署到服务端           |
| `client.crt` | 客户端证书 | 用于客户端身份认证                                   | 部署到客户端，用于双向认证场景                    | 部署到客户端                       |
| `client.key` | 客户端私钥 | 保护客户端发送数据的机密性，与 `client.crt` 配对使用 | 部署到客户端，用于与服务端建立安全连接            | 严格保密，仅部署到客户端           |

### 补充说明

1. **私钥文件（如 `ca.key`、`server.key` 和 `client.key`）**
     必须严格保密，不得泄露。建议通过加密存储、访问控制或硬件安全模块（HSM）保护。
2. **证书分发**
    - `ca.crt` 是信任链的基础，应分发给所有客户端和服务端。
    - 服务端和客户端证书及其私钥需仅限于相应节点存储。
3. **配置文件**
     配置文件仅用于生成证书过程，本地保存即可，无需分发。
