# SSL证书生成指南

本指南介绍如何使用 **Cloudflare CFSSL** 生成和管理SSL证书。CFSSL（Cloudflare's PKI and TLS toolkit）是一个开源的公钥基础设施（PKI）工具包，支持证书颁发、签名、验证等功能，方便集成到自动化流程中，尤其适用于需要大规模自动化管理TLS/SSL证书的场景。更多信息请参考：[CFSSL GitHub 仓库](https://github.com/cloudflare/cfssl)

---

## 1. 安装 CFSSL

### 1.1 下载CFSSL软件包

```bash
wget https://github.com/cloudflare/cfssl/releases/download/v1.6.5/cfssl_1.6.5_linux_amd64
wget https://github.com/cloudflare/cfssl/releases/download/v1.6.5/cfssljson_1.6.5_linux_amd64
wget https://github.com/cloudflare/cfssl/releases/download/v1.6.5/cfssl-certinfo_1.6.5_linux_amd64
```

> 以上命令用于下载 CFSSL 工具包的可执行文件，包括 `cfssl`、`cfssljson` 和 `cfssl-certinfo`。它们分别负责证书生成、JSON处理、和证书信息查看。

### 1.2 安装CFSSL到系统路径

```bash
sudo cp cfssl_1.6.5_linux_amd64 /usr/bin/cfssl
sudo cp cfssljson_1.6.5_linux_amd64 /usr/bin/cfssljson
sudo cp cfssl-certinfo_1.6.5_linux_amd64 /usr/bin/cfssl-certinfo
sudo chmod +x /usr/bin/cfssl*
```

> 将下载的文件移动到系统可执行路径，并赋予执行权限，方便在命令行中直接调用。

### 1.3 验证安装

```bash
cfssl version
```

> 执行以上命令后，如果安装成功，应输出版本信息，如：

```
Version: 1.6.5
Runtime: go1.22.0
```

---

## 3. 生成 CA 证书

CA（Certificate Authority）证书用于签署其他证书。该步骤包括创建配置文件 `ca-config.json` 和 `ca-csr.json`，以指定 CA 证书的有效期和用途。

### 3.1 创建 CA 配置文件

1. **生成 `ca-config.json` 配置文件**

    ```bash
    tee ca-config.json <<EOF
    {
      "signing": {
        "default": {
          "expiry": "876000h"
        },
        "profiles": {
          "default": {
            "expiry": "876000h",
            "usages": ["signing", "key encipherment", "server auth", "client auth"]
          },
          "server": {
            "expiry": "876000h",
            "usages": ["signing", "key encipherment", "server auth", "client auth"]
          },
          "client": {
            "expiry": "876000h",
            "usages": ["signing", "key encipherment", "client auth"]
          }
        }
      }
    }
    EOF
    ```

    > 配置说明：

    - `signing`：指定证书的签名用途。
    - `expiry`：设置证书有效期为 `876000h`（约100年），便于长期使用。
    - `profiles`：定义了名为 `opensearch` 的证书配置文件，其用途包括签名、密钥加密、服务器认证和客户端认证。

2. **生成 `ca-csr.json` 文件**

    ```bash
    tee ca-csr.json <<EOF
    {
        "CA": {
            "expiry": "876000h"
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
                "OU": "OpenSearch"
            }
        ]
    }
    EOF
    ```
    
    > 配置说明：
    
    - `CN`：证书的通用名称(Common Name)为 `ateng.local`。
    - `key`：使用 RSA 算法和 2048 位的密钥长度。
    - `names`：包含证书的地理信息，如国家（C）、城市（L）、组织（O）等。

### 3.2 生成 CA 证书

使用 `cfssl` 生成CA证书和私钥：

```bash
cfssl gencert -initca ca-csr.json | cfssljson -bare ca
cfssl certinfo -cert ca.pem | grep not
```

> 以上命令生成了 CA 证书和密钥文件，`ca.pem` 文件包含 CA 公钥，`ca-key.pem` 文件包含 CA 私钥。`cfssl certinfo` 用于查看证书详细信息，`grep not` 用于过滤“有效期”相关信息。

---

## 4. 生成 OpenSearch服务端证书

此步骤生成用于 OpenSearch集群之间通信的服务端证书。需指定集群节点的 IP 地址。

### 4.1 创建 OpenSearch服务端配置文件

- 注意命名空间，我这里是`kongyu`，根据实际安装的命名空间修改
- 需要配置集群宿主机的IP

**生成 `opensearch-admin-csr.json` 文件**

```bash
tee opensearch-admin-csr.json <<EOF
{
    "CN": "admin",
    "hosts": [""],
    "key": {
        "algo": "rsa",
        "size": 2048
    }
}
EOF
```

**生成 `opensearch-master-csr.json` 文件**

```bash
tee opensearch-master-csr.json <<EOF
{
    "CN": "opensearch-master",
    "hosts": [
        "*.opensearch-master-hl.kongyu.svc.cluster.local",
        "opensearch-master-hl.kongyu.svc.cluster.local",
        "opensearch-master",
        "opensearch.kongyu.svc.cluster.local",
        "opensearch",
        "*.kongyu.local",
        "*.ateng.local",
        "localhost",
        "127.0.0.1",
        "192.168.1.10",
        "192.168.1.12",
        "192.168.1.13"
    ],
    "key": {
        "algo": "rsa",
        "size": 2048
    }
}
EOF
```

**生成 `opensearch-data-csr.json` 文件**

```bash
tee opensearch-data-csr.json <<EOF
{
    "CN": "opensearch-data",
    "hosts": [
        "*.opensearch-data-hl.kongyu.svc.cluster.local",
        "opensearch-data-hl.kongyu.svc.cluster.local",
        "opensearch-data",
        "opensearch.kongyu.svc.cluster.local",
        "opensearch",
        "*.kongyu.local",
        "*.ateng.local",
        "localhost",
        "127.0.0.1",
        "192.168.1.10",
        "192.168.1.12",
        "192.168.1.13"
    ],
    "key": {
        "algo": "rsa",
        "size": 2048
    }
}
EOF
```

**生成 `opensearch-ingest-csr.json` 文件**

```bash
tee opensearch-ingest-csr.json <<EOF
{
    "CN": "opensearch-ingest",
    "hosts": [
        "*.opensearch-ingest-hl.kongyu.svc.cluster.local",
        "opensearch-ingest-hl.kongyu.svc.cluster.local",
        "opensearch-ingest",
        "opensearch.kongyu.svc.cluster.local",
        "opensearch",
        "*.kongyu.local",
        "*.ateng.local",
        "localhost",
        "127.0.0.1",
        "192.168.1.10",
        "192.168.1.12",
        "192.168.1.13"
    ],
    "key": {
        "algo": "rsa",
        "size": 2048
    }
}
EOF
```

**生成 `opensearch-coordinating-csr.json` 文件**

```bash
tee opensearch-coordinating-csr.json <<EOF
{
    "CN": "opensearch-coordinating",
    "hosts": [
        "*.opensearch-coordinating-hl.kongyu.svc.cluster.local",
        "opensearch-coordinating-hl.kongyu.svc.cluster.local",
        "opensearch-coordinating",
        "opensearch.kongyu.svc.cluster.local",
        "opensearch",
        "*.kongyu.local",
        "*.ateng.local",
        "localhost",
        "127.0.0.1",
        "192.168.1.10",
        "192.168.1.12",
        "192.168.1.13"
    ],
    "key": {
        "algo": "rsa",
        "size": 2048
    }
}
EOF
```



### 4.2 生成服务端证书

生成 opensearch-admin 证书

```bash
cfssl gencert -ca=ca.pem -ca-key=ca-key.pem -config=ca-config.json -profile=server opensearch-admin-csr.json | cfssljson -bare opensearch-admin
cfssl certinfo -cert opensearch-admin.pem | grep not
```

生成 opensearch-master 证书

```bash
cfssl gencert -ca=ca.pem -ca-key=ca-key.pem -config=ca-config.json -profile=server opensearch-master-csr.json | cfssljson -bare opensearch-master
cfssl certinfo -cert opensearch-master.pem | grep not
```

生成 opensearch-data 证书

```bash
cfssl gencert -ca=ca.pem -ca-key=ca-key.pem -config=ca-config.json -profile=server opensearch-data-csr.json | cfssljson -bare opensearch-data
cfssl certinfo -cert opensearch-data.pem | grep not
```

生成 opensearch-ingest 证书

```bash
cfssl gencert -ca=ca.pem -ca-key=ca-key.pem -config=ca-config.json -profile=server opensearch-ingest-csr.json | cfssljson -bare opensearch-ingest
cfssl certinfo -cert opensearch-ingest.pem | grep not
```

生成 opensearch-coordinating证书

```bash
cfssl gencert -ca=ca.pem -ca-key=ca-key.pem -config=ca-config.json -profile=server opensearch-coordinating-csr.json | cfssljson -bare opensearch-coordinating
cfssl certinfo -cert opensearch-coordinating.pem | grep not
```

---

## 5. 生成 OpenSearch客户端证书

客户端证书用于ETCD客户端连接ETCD服务器时的身份验证。

### 5.1 创建 OpenSearch客户端配置文件

1. **生成 `opensearch-client-csr.json` 文件**

    ```bash
    tee opensearch-client-csr.json <<EOF
    {
        "CN": "opensearch.ateng.local",
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
                "OU": "OpenSearch Client"
            }
        ]
    }
    EOF
    ```

    > 配置说明：

    - `hosts`：由于客户端证书不需要绑定到特定 IP 地址，因此为空。
    - 其他字段与服务端配置相同。

### 5.2 生成客户端证书

```bash
cfssl gencert -ca=ca.pem -ca-key=ca-key.pem -config=ca-config.json -profile=client opensearch-client-csr.json | cfssljson -bare opensearch-client
cfssl certinfo -cert opensearch-client.pem | grep not
```

> 生成的 `opensearch-client.pem` 是客户端的公钥文件，

`opensearch-client-key.pem` 是私钥文件。

---

## 6. 上传到K8S的Secret

### 6.1 上传服务端证书

用于opensearch服务之间相互认证

**上传opensearch-admin证书**

```shell
kubectl create -n kongyu secret generic opensearch-admin-crt \
  --from-file=ca.crt=ca.pem \
  --from-file=tls.key=opensearch-admin-key.pem \
  --from-file=tls.crt=opensearch-admin.pem
```

**上传opensearch-master证书**

```shell
kubectl create -n kongyu secret generic opensearch-master-crt \
  --from-file=ca.crt=ca.pem \
  --from-file=tls.key=opensearch-master-key.pem \
  --from-file=tls.crt=opensearch-master.pem
```

**上传opensearch-data证书**

```shell
kubectl create -n kongyu secret generic opensearch-data-crt \
  --from-file=ca.crt=ca.pem \
  --from-file=tls.key=opensearch-data-key.pem \
  --from-file=tls.crt=opensearch-data.pem
```

**上传opensearch-ingest证书**

```shell
kubectl create -n kongyu secret generic opensearch-ingest-crt \
  --from-file=ca.crt=ca.pem \
  --from-file=tls.key=opensearch-ingest-key.pem \
  --from-file=tls.crt=opensearch-ingest.pem
```

**上传opensearch-coordinating证书**

```shell
kubectl create -n kongyu secret generic opensearch-coordinating-crt \
  --from-file=ca.crt=ca.pem \
  --from-file=tls.key=opensearch-coordinating-key.pem \
  --from-file=tls.crt=opensearch-coordinating.pem
```

### 6.2 上传客户端证书

用于opensearch客户端认证

**上传证书**

```shell
kubectl create -n kongyu secret generic opensearch-client-crt \
  --from-file=ca.crt=ca.pem \
  --from-file=tls.key=opensearch-client-key.pem \
  --from-file=tls.crt=opensearch-client.pem
```

**查看证书**

```
[root@server02 cert]# kubectl describe -n kongyu secret/opensearch-client-crt
Name:         opensearch-client-crt
Namespace:    kongyu
Labels:       <none>
Annotations:  <none>

Type:  Opaque

Data
====
ca.crt:   1342 bytes
tls.crt:  1456 bytes
tls.key:  1679 bytes
```

