# OpenSSL

OpenSSL 是一个开源的加密工具包，提供了丰富的加密功能和协议实现，广泛用于 SSL/TLS 加密、数字证书管理等场景。以下文档介绍如何使用 OpenSSL 创建 CA 和服务端/客户端证书。

- [官网链接](https://www.openssl.org/)

------

## 创建 CA 证书

**创建 CA 配置文件**

创建 `ateng-ca.cnf` 文件，定义 CA 证书的基本信息和扩展：

```bash
cat > ateng-ca.cnf <<EOF
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
  -out ateng-ca.key \
  -pass pass:Admin@123 \
  -pkeyopt rsa_keygen_bits:2048
```

**生成 CA 证书**

使用 `ateng-ca.key` 自签名生成 CA 根证书，有效期设置为 10 年：

```bash
openssl req -x509 -new \
  -key ateng-ca.key \
  -out ateng-ca.crt \
  -days 3650 \
  -config ateng-ca.cnf \
  -passin pass:Admin@123
```

**查看 CA 证书信息**

使用以下命令查看 CA 证书的详细信息：

```bash
openssl x509 -in ateng-ca.crt -text
```

------

## 创建服务端证书

**创建服务端配置文件**

创建 `ateng-server.cnf` 文件，定义服务端证书的信息和扩展字段（如 `subjectAltName`）

注意修改 **dn** 和 **alt_names** 模块的内容，**alt_names**中需要填写会和集群有交互的域名和IP

```bash
cat > ateng-server.cnf <<EOF
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
OU=server
CN=server.ateng.local
[v3_req]
basicConstraints = CA:FALSE
keyUsage = nonRepudiation, digitalSignature, keyEncipherment
subjectAltName = @alt_names
[alt_names]
DNS.1 = localhost
DNS.2 = *.ateng.local
DNS.3 = nginx
DNS.4 = server
DNS.5 = minio.kongyu.local
IP.1 = 127.0.0.1
IP.2 = 192.168.1.11
IP.3 = 192.168.1.12
IP.4 = 192.168.1.13
IP.5 = 47.108.39.131
EOF
```

**生成服务端私钥**

```bash
openssl genpkey \
  -algorithm RSA \
  -out ateng-server.key \
  -pkeyopt rsa_keygen_bits:2048
```

**生成服务端证书请求**

```bash
openssl req -new \
  -key ateng-server.key \
  -out ateng-server.csr \
  -config ateng-server.cnf
```

**签发服务端证书**

使用 CA 证书签发服务端证书，有效期设置为 10 年：

```bash
openssl x509 -req \
  -in ateng-server.csr \
  -out ateng-server.crt \
  -CA ateng-ca.crt \
  -CAkey ateng-ca.key \
  -CAcreateserial \
  -days 3650 \
  -extensions v3_req \
  -extfile ateng-server.cnf \
  -passin pass:Admin@123
```

**查看服务端证书信息**

查看证书的所有信息

```bash
openssl x509 -in ateng-server.crt -text
```

查看证书的DN（Distinguished Name，专有名称）

```bash
openssl x509 -in ateng-server.crt -noout -subject
```

------

## 创建客户端证书

**创建客户端配置文件**

创建 `ateng-client.cnf` 文件，定义客户端证书的信息：

```bash
cat > ateng-client.cnf <<EOF
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
OU=client
CN=client.ateng.local
EOF
```

**生成客户端私钥**

```bash
openssl genpkey \
  -algorithm RSA \
  -out ateng-client.key \
  -pkeyopt rsa_keygen_bits:2048
```

**生成客户端证书请求**

```bash
openssl req -new \
  -key ateng-client.key \
  -out ateng-client.csr \
  -config ateng-client.cnf
```

**签发客户端证书**

使用 CA 证书签发客户端证书，有效期设置为 10 年：

```bash
openssl x509 -req \
  -in ateng-client.csr \
  -out ateng-client.crt \
  -CA ateng-ca.crt \
  -CAkey ateng-ca.key \
  -CAcreateserial \
  -days 3650 \
  -passin pass:Admin@123
```

**查看客户端证书信息**

查看证书的所有信息

```bash
openssl x509 -in ateng-client.crt -text
```

查看证书的DN（Distinguished Name，专有名称）

```bash
openssl x509 -in ateng-client.crt -noout -subject
```

------

## 客户端安装CA证书

### Windows 中安装 CA 证书

在 Windows 上，你可以通过“证书管理器”来导入 CA 证书，使其全局生效。具体步骤如下：

**步骤 1: 打开证书管理器**

1. 按下 `Win + R`，打开“运行”对话框。
2. 输入 `certmgr.msc`，然后按回车键，打开证书管理器。

**步骤 2: 导入 CA 证书**

1. 在证书管理器中，选择左侧栏中的 `受信任的根证书颁发机构`（Trusted Root Certification Authorities）文件夹。
2. 右键点击 `证书` 文件夹，选择 `所有任务` -> `导入`。
3. 在导入向导中，选择你的 CA 证书文件（例如 `.crt` 或 `.pem` 文件）。
4. 完成导入并点击 `下一步`，确保将证书放到 `受信任的根证书颁发机构` 文件夹中。
5. 完成导入后，你的证书将出现在该文件夹中。

**步骤 3: 验证 CA 证书**

重启浏览器或任何受信任的应用程序，然后访问一个由该 CA 签发的 HTTPS 网站。如果一切顺利，浏览器不会显示警告，说明 CA 证书已经成功生效。

### 在 Linux 中安装 CA 证书

**步骤 1: 将 CA 证书复制到系统证书目录**

1. 首先，你需要将 CA 证书文件（例如 `.crt` 文件）复制到系统的证书存储目录。对于 Red Hat 系列，标准的证书存储目录通常是 `/etc/pki/ca-trust/source/anchors/`。

    假设你的证书文件是 `ateng-ca.crt`，可以运行以下命令：

    ```bash
    sudo cp ateng-ca.crt /etc/pki/ca-trust/source/anchors/
    ```

    这会将证书放入一个系统可以识别的目录中。

**步骤 2: 更新系统证书存储**

1. 接下来，你需要更新证书存储，让系统信任新的 CA 证书。在 Red Hat 系列中，你可以使用 `update-ca-trust` 命令来完成这一操作。

    运行以下命令：

    ```bash
    sudo update-ca-trust extract
    ```

    这条命令会扫描 `/etc/pki/ca-trust/source/anchors/` 目录中的证书，并将它们添加到系统的信任存储中。

**步骤 3: 验证 CA 证书**

1. 你可以通过以下命令来验证 CA 证书是否已成功安装：

    ```bash
    openssl s_client -connect example.com:443 -CAfile /etc/pki/ca-trust/extracted/pem/tls-ca-bundle.pem
    ```

    如果没有出现证书验证错误，说明证书已经生效。

    另外，你也可以使用 `openssl` 检查 CA 是否在系统的证书存储中被列出：

    ```bash
    openssl x509 -in /etc/pki/ca-trust/extracted/pem/tls-ca-bundle.pem -text -noout
    ```

    这应该能列出证书的详细信息，确认它已经成功添加。

## 证书说明

以下是与证书相关文件的说明及作用

| **文件名**         | **类型**   | **作用**                                                   | **用途**                                          | **分发建议**                       |
| ------------------ | ---------- | ---------------------------------------------------------- | ------------------------------------------------- | ---------------------------------- |
| `ateng-ca.crt`     | CA 根证书  | 提供信任链的根，用于验证下级证书的有效性                   | 部署在客户端或服务端，用于验证 TLS 通信的对端证书 | 安全分发，提供给所有客户端和服务端 |
| `ateng-ca.key`     | CA 私钥    | 用于签发下级证书                                           | 用于签署服务端和客户端证书                        | 严格保密，不分发                   |
| `ateng-server.crt` | 服务端证书 | 提供 TLS 加密通信能力                                      | 部署到服务端，用于与客户端建立安全连接            | 部署到服务端                       |
| `ateng-server.key` | 服务端私钥 | 解密客户端发送的数据，与 `ateng-server.crt` 配对使用       | 部署到服务端，保护通信机密性                      | 严格保密，仅部署到服务端           |
| `ateng-client.crt` | 客户端证书 | 用于客户端身份认证                                         | 部署到客户端，用于双向认证场景                    | 部署到客户端                       |
| `ateng-client.key` | 客户端私钥 | 保护客户端发送数据的机密性，与 `ateng-client.crt` 配对使用 | 部署到客户端，用于与服务端建立安全连接            | 严格保密，仅部署到客户端           |

### 补充说明

1. **私钥文件（如 `ateng-ca.key`、`ateng-server.key` 和 `ateng-client.key`）**
     必须严格保密，不得泄露。建议通过加密存储、访问控制或硬件安全模块（HSM）保护。
2. **证书分发**
    - `ateng-ca.crt` 是信任链的基础，应分发给所有客户端和服务端。
    - 服务端和客户端证书及其私钥需仅限于相应节点存储。
3. **配置文件**
     配置文件仅用于生成证书过程，本地保存即可，无需分发。
