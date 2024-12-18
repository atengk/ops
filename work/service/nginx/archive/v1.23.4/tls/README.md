# 生成SSL证书

## cfssl 方式

### 安装cfssl

```
tar -zxvf cfssl-v1.6.1-binary.tar.gz -C /usr/bin/
```

### 创建 ca-config.json 文件

此配置文件定义了证书签名的默认配置和各个配置文件的有效期和用途。

```
cat > tls-cfssl-ca-config.json <<"EOF"
{
  "signing": {
    "default": {
      "expiry": "87600h"
    },
    "profiles": {
      "default": {
        "expiry": "87600h",
        "usages": ["signing", "key encipherment", "server auth", "client auth"]
      },
      "server": {
        "expiry": "87600h",
        "usages": ["signing", "key encipherment", "server auth"]
      },
      "client": {
        "expiry": "87600h",
        "usages": ["signing", "key encipherment", "client auth"]
      }
    }
  }
}
EOF
```

### 创建 ca-csr.json 文件

此配置文件包含了用于根证书的 CSR (Certificate Signing Request) 信息，包括根证书的有效期和组织信息。

```
cat > tls-cfssl-ca-csr.json <<"EOF"
{
  "CA": {
    "expiry": "876000h"
  },
  "CN": "kongyu.local",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "CN",
      "L": "重庆市",
      "O": "阿腾集团",
      "OU": "研发中心"
    }
  ]
}
EOF
```

### 生成根证书

这一步生成了根证书，并通过 cfssl certinfo 查看证书信息。

```
cfssl gencert -initca tls-cfssl-ca-csr.json | cfssljson -bare tls-cfssl-ca
cfssl certinfo -cert tls-cfssl-ca.pem
```

### 创建 server-csr.json 文件

此配置文件包含了用于 Elasticsearch 服务器的 CSR 信息，包括服务器的主机名、IP 地址等信息。

```
cat > tls-cfssl-nginx-server-csr.json <<"EOF"
{
  "CN": "nginx.kongyu.local",
  "hosts": [
    "nginx.kongyu.local",
    "192.168.1.101"
  ],
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "CN",
      "L": "重庆市",
      "O": "阿腾集团",
      "OU": "研发中心"
    }
  ]
}
EOF
```

### 生成服务器证书

这一步使用根证书生成了 Elasticsearch 服务器证书，并通过 cfssl certinfo 查看证书信息。

```
cfssl gencert -ca=tls-cfssl-ca.pem -ca-key=tls-cfssl-ca-key.pem -config=tls-cfssl-ca-config.json -profile=server tls-cfssl-nginx-server-csr.json | cfssljson -bare tls-cfssl-nginx-server
cfssl certinfo -cert tls-cfssl-nginx-server.pem
```

### 创建 client-csr.json 文件

此配置文件包含了用于客户端的 CSR 信息。

```
cat > tls-cfssl-client-csr.json <<"EOF"
{
  "CN": "client.kongyu.local",
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
      "L": "重庆市",
      "O": "阿腾集团",
      "OU": "研发中心"
    }
  ]
}
EOF
```

### 生成客户端证书

这一步使用根证书生成了客户端证书，并通过 cfssl certinfo 查看证书信息。

```
cfssl gencert -ca=tls-cfssl-ca.pem -ca-key=tls-cfssl-ca-key.pem -config=tls-cfssl-ca-config.json -profile=client tls-cfssl-client-csr.json | cfssljson -bare tls-cfssl-client
cfssl certinfo -cert tls-cfssl-client.pem
```

### 后续操作

**清理不必要的文件（可选）：** 在生成证书之后，可以删除证书请求文件，因为它们不再需要。

```
rm -f *.csr
```

确保妥善保存 CA 的私钥 (`tls-cfssl-ca-key.pem`)，因为它用于签署其他证书。此外，将生成的 `tls-cfssl-ca.pem`、`tls-cfssl-nginx-server.pem` 和 `tls-cfssl-client.pem` 文件用于配置 Elasticsearch 的 TLS/SSL。