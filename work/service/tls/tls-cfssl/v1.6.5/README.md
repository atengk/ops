# CFSSL

CFSSL（Cloudflare's PKI and TLS toolkit）是一个开源的公钥基础设施（PKI）工具包，支持证书颁发、签名、验证等功能，方便集成到自动化流程中，尤其适用于需要大规模自动化管理TLS/SSL证书的场景。

- [CFSSL GitHub 仓库](https://github.com/cloudflare/cfssl)

------

## 安装 CFSSL

**下载 CFSSL 软件包**

以下命令用于下载 CFSSL 工具包的可执行文件，包括：

- **`cfssl`**：证书生成工具。
- **`cfssljson`**：用于处理 JSON 格式的输出。
- **`cfssl-certinfo`**：用于查看证书信息。

执行以下命令下载所需文件：

```bash
wget https://github.com/cloudflare/cfssl/releases/download/v1.6.5/cfssl_1.6.5_linux_amd64
wget https://github.com/cloudflare/cfssl/releases/download/v1.6.5/cfssljson_1.6.5_linux_amd64
wget https://github.com/cloudflare/cfssl/releases/download/v1.6.5/cfssl-certinfo_1.6.5_linux_amd64
```

**安装 CFSSL 到系统路径**

将下载的文件移动到系统的可执行路径 `/usr/bin/` 中，并赋予执行权限：

```bash
sudo cp cfssl_1.6.5_linux_amd64 /usr/bin/cfssl
sudo cp cfssljson_1.6.5_linux_amd64 /usr/bin/cfssljson
sudo cp cfssl-certinfo_1.6.5_linux_amd64 /usr/bin/cfssl-certinfo
sudo chmod +x /usr/bin/cfssl*
```

**验证安装**

运行以下命令，确认 CFSSL 安装成功并检查版本信息：

```bash
cfssl version
```

输出示例：

```
Version: 1.6.5
Runtime: go1.22.0
```

------

## 创建 CA 证书

**生成配置文件**

`ateng-ca-config.json` 定义了 CA 的签名策略和证书有效期配置：

```bash
tee ateng-ca-config.json <<EOF
{
    "signing": {
        "default": {
            "expiry": "87600h"
        },
        "profiles": {
            "default": {
                "expiry": "87600h",
                "usages": [
                    "signing",
                    "key encipherment",
                    "server auth",
                    "client auth"
                ]
            },
            "server": {
                "expiry": "87600h",
                "usages": [
                    "signing",
                    "key encipherment",
                    "server auth"
                ]
            },
            "client": {
                "expiry": "87600h",
                "usages": [
                    "signing",
                    "key encipherment",
                    "client auth"
                ]
            }
        }
    }
}
EOF
```

**生成请求文件**

`ateng-ca-csr.json` 定义了 CA 的基本信息，例如组织名、国家、省份等：

```bash
tee ateng-ca-csr.json <<EOF
{
    "CA": {
        "expiry": "87600h"
    },
    "CN": "ateng.local",
    "key": {
        "algo": "rsa",
        "size": 2048
    },
    "names": [
        {
            "C": "CN",
            "L": "Chongqing",
            "ST": "Chongqing",
            "O": "Ateng",
            "OU": "Ateng"
        }
    ]
}
EOF
```

**生成证书和私钥**

使用以下命令生成 CA 的证书和私钥：

```bash
cfssl gencert -initca ateng-ca-csr.json | cfssljson -bare ateng-ca
```

验证生成的 CA 证书：

```bash
cfssl certinfo -cert ateng-ateng-ca.pem
```

------

## 创建服务端证书

**生成请求文件**

`ateng-server-csr.json` 定义了服务端证书的通用名（CN）以及主机名信息：

```bash
tee ateng-server-csr.json <<EOF
{
    "CN": "server.ateng.local",
    "hosts": [
        "localhost",
        "*.ateng.local",
        "nginx",
        "server",
        "minio.kongyu.local",
        "127.0.0.1",
        "192.168.1.11",
        "192.168.1.12",
        "192.168.1.13",
        "47.108.39.131"
    ],
    "key": {
        "algo": "rsa",
        "size": 2048
    },
    "names": [
        {
            "C": "CN",
            "L": "Chongqing",
            "ST": "Chongqing",
            "O": "Ateng",
            "OU": "server"
        }
    ]
}
EOF
```

**生成服务端证书和私钥**

执行以下命令生成服务端证书和私钥：

```bash
cfssl gencert \
  -ca=ateng-ca.pem -ca-key=ateng-ca-key.pem \
  -config=ateng-ca-config.json \
  -profile=server \
  ateng-server-csr.json | cfssljson -bare ateng-server
```

验证生成的服务端证书：

```bash
cfssl certinfo -cert ateng-server.pem
```

cfssl默认生成的是 `PKCS#1` 格式，某些服务不支持这种格式，需要转换成 `PKCS#8` ，转换后其他证书不受影响

```bash
openssl pkcs8 -topk8 \
  -inform PEM \
  -outform PEM \
  -in ateng-server-key.pem \
  -out ateng-server-key-pkcs8.pem \
  -nocrypt
```

转换后的文件 ateng-server-key-pkcs8.pem 内容为：

```
-----BEGIN PRIVATE KEY-----
...
-----END PRIVATE KEY-----
```

---

## 创建客户端证书

**生成请求文件**

`ateng-client-csr.json` 定义了客户端证书的通用名（CN）和基本信息：

```bash
tee ateng-client-csr.json <<EOF
{
    "CN": "client.ateng.local",
    "hosts": [
        ""
    ],
    "key": {
        "algo": "rsa",
        "size": 2048
    },
    "names": [
        {
            "C": "CN",
            "L": "Chongqing",
            "ST": "Chongqing",
            "O": "Ateng",
            "OU": "client"
        }
    ]
}
EOF
```

**生成客户端证书和私钥**

执行以下命令生成客户端证书和私钥：

```bash
cfssl gencert \
  -ca=ateng-ca.pem \
  -ca-key=ateng-ca-key.pem \
  -config=ateng-ca-config.json \
  -profile=client \
  ateng-client-csr.json | cfssljson -bare ateng-client
```

验证生成的客户端证书：

```bash
cfssl certinfo -cert ateng-client.pem
```

cfssl默认生成的是 `PKCS#1` 格式，某些服务不支持这种格式，需要转换成 `PKCS#8` ，转换后其他证书不受影响

```bash
openssl pkcs8 -topk8 \
  -inform PEM \
  -outform PEM \
  -in ateng-client-key.pem \
  -out ateng-client-key-pkcs8.pem \
  -nocrypt
```

转换后的文件 ateng-client-key-pkcs8.pem 内容为：

```
-----BEGIN PRIVATE KEY-----
...
-----END PRIVATE KEY-----
```

---

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

    假设你的证书文件是 `ateng-ca.pem`，可以运行以下命令：

    ```bash
    sudo cp ateng-ca.pem /etc/pki/ca-trust/source/anchors/
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

| **文件名**             | **类型**   | **作用**                                                   | **用途**                                          | **分发建议**                       |
| ---------------------- | ---------- | ---------------------------------------------------------- | ------------------------------------------------- | ---------------------------------- |
| `ateng-ca.pem`         | CA 根证书  | 提供信任链的根，用于验证下级证书的有效性                   | 部署在客户端或服务端，用于验证 TLS 通信的对端证书 | 安全分发，提供给所有客户端和服务端 |
| `ateng-ca-key.pem`     | CA 私钥    | 用于签发下级证书                                           | 用于签署服务端和客户端证书                        | 严格保密，不分发                   |
| `ateng-server.pem`     | 服务端证书 | 提供 TLS 加密通信能力                                      | 部署到服务端，用于与客户端建立安全连接            | 部署到服务端                       |
| `ateng-server-key.pem` | 服务端私钥 | 解密客户端发送的数据，与 `ateng-server.pem` 配对使用       | 部署到服务端，保护通信机密性                      | 严格保密，仅部署到服务端           |
| `ateng-client.pem`     | 客户端证书 | 用于客户端身份认证                                         | 部署到客户端，用于双向认证场景                    | 部署到客户端                       |
| `ateng-client-key.pem` | 客户端私钥 | 保护客户端发送数据的机密性，与 `ateng-client.pem` 配对使用 | 部署到客户端，用于与服务端建立安全连接            | 严格保密，仅部署到客户端           |

### 补充说明

1. **私钥文件（如 `ateng-ca-key.pem`、`ateng-server-key.pem` 和 `ateng-client-key.pem`）**
    必须严格保密，不得泄露。建议通过加密存储、访问控制或硬件安全模块（HSM）保护。
2. **证书分发**
    - `ateng-ca.pem` 是信任链的基础，应分发给所有客户端和服务端。
    - 服务端和客户端证书及其私钥需仅限于相应节点存储。
3. **配置文件**
    配置文件仅用于生成证书过程，本地保存即可，无需分发。

