# ETCD

etcd 是一个分布式键值存储系统，专为分布式系统提供一致性和高可用性的数据存储。它使用 [Raft](https://raft.github.io/) 一致性算法，确保多个节点间的数据一致性，适合在容器编排和微服务环境中管理配置数据、服务发现等任务。etcd 是 Kubernetes 的核心组件之一，为其提供数据存储和分布式协调服务。

- [GitHub 仓库](https://github.com/etcd-io/etcd)



## 前置条件

- 参考：[基础配置](/work/service/00-basic/)

**服务器节点信息**

| IP地址        | 主机名             | 说明 |
| ------------- | ------------------ | ---- |
| 192.168.1.112 | etcd01.ateng.local |      |
| 192.168.1.113 | etcd02.ateng.local |      |
| 192.168.1.114 | etcd03.ateng.local |      |



## 安装HTTPS模式集群

### SSL证书生成指南

本指南介绍如何使用 **Cloudflare CFSSL** 生成和管理SSL证书。CFSSL（Cloudflare's PKI and TLS toolkit）是一个开源的公钥基础设施（PKI）工具包，支持证书颁发、签名、验证等功能，方便集成到自动化流程中，尤其适用于需要大规模自动化管理TLS/SSL证书的场景。更多信息请参考：[CFSSL GitHub 仓库](https://github.com/cloudflare/cfssl)

---

#### 1. 安装 CFSSL

##### 1.1 下载CFSSL软件包

```bash
wget https://github.com/cloudflare/cfssl/releases/download/v1.6.5/cfssl_1.6.5_linux_amd64
wget https://github.com/cloudflare/cfssl/releases/download/v1.6.5/cfssljson_1.6.5_linux_amd64
wget https://github.com/cloudflare/cfssl/releases/download/v1.6.5/cfssl-certinfo_1.6.5_linux_amd64
```

> 以上命令用于下载 CFSSL 工具包的可执行文件，包括 `cfssl`、`cfssljson` 和 `cfssl-certinfo`。它们分别负责证书生成、JSON处理、和证书信息查看。

##### 1.2 安装CFSSL到系统路径

```bash
sudo cp cfssl_1.6.5_linux_amd64 /usr/bin/cfssl
sudo cp cfssljson_1.6.5_linux_amd64 /usr/bin/cfssljson
sudo cp cfssl-certinfo_1.6.5_linux_amd64 /usr/bin/cfssl-certinfo
sudo chmod +x /usr/bin/cfssl*
```

> 将下载的文件移动到系统可执行路径，并赋予执行权限，方便在命令行中直接调用。

##### 1.3 验证安装

```bash
cfssl version
```

> 执行以上命令后，如果安装成功，应输出版本信息，如：

```
Version: 1.6.5
Runtime: go1.22.0
```

---

#### 2. 创建证书目录

为证书和密钥创建存储目录：

```bash
sudo mkdir -p /etc/ssl/etcd/
sudo chown admin:ateng /etc/ssl/etcd/
cd /etc/ssl/etcd/
```

> 此步骤在 `/etc/ssl/` 下创建了 `etcd` 子目录，用于存储接下来生成的证书和密钥。

---

#### 3. 生成 CA 证书

CA（Certificate Authority）证书用于签署其他证书。该步骤包括创建配置文件 `ca-config.json` 和 `ca-csr.json`，以指定 CA 证书的有效期和用途。

##### 3.1 创建 CA 配置文件

1. **生成 `ca-config.json` 配置文件**

    ```bash
    tee ca-config.json <<EOF
    {
        "signing": {
            "default": {
                "expiry": "876000h"
            },
            "profiles": {
                "etcd": {
                    "expiry": "876000h",
                    "usages": [
                        "signing",
                        "key encipherment",
                        "server auth",
                        "client auth"
                    ]
                }
            }
        }
    }
    EOF
    ```

    > 配置说明：

    - `signing`：指定证书的签名用途。
    - `expiry`：设置证书有效期为 `876000h`（约100年），便于长期使用。
    - `profiles`：定义了名为 `etcd` 的证书配置文件，其用途包括签名、密钥加密、服务器认证和客户端认证。

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
                "OU": "Etcd"
            }
        ]
    }
    EOF
    ```
    
    > 配置说明：
    
    - `CN`：证书的通用名称(Common Name)为 `ateng.local`。
    - `key`：使用 RSA 算法和 2048 位的密钥长度。
    - `names`：包含证书的地理信息，如国家（C）、城市（L）、组织（O）等。

##### 3.2 生成 CA 证书

使用 `cfssl` 生成CA证书和私钥：

```bash
cfssl gencert -initca ca-csr.json | cfssljson -bare ca
cfssl certinfo -cert ca.pem | grep not
```

> 以上命令生成了 CA 证书和密钥文件，`ca.pem` 文件包含 CA 公钥，`ca-key.pem` 文件包含 CA 私钥。`cfssl certinfo` 用于查看证书详细信息，`grep not` 用于过滤“有效期”相关信息。

---

#### 4. 生成 ETCD 服务端证书

此步骤生成用于 ETCD 集群之间通信的服务端证书。需指定集群节点的 IP 地址。

##### 4.1 创建 ETCD 服务端配置文件

1. **生成 `etcd-server-csr.json` 文件**

    ```bash
    tee etcd-server-csr.json <<EOF
    {
        "CN": "etcd.ateng.local",
        "hosts": [
            "apiserver.k8s.local",
            "*.svc.cluster.local",
            "*.ateng.local",
            "localhost",
            "192.168.1.111",
            "192.168.1.112",
            "192.168.1.113",
            "192.168.1.114",
            "192.168.1.115",
            "192.168.2.10",
            "127.0.0.1"
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
                "OU": "Etcd Server"
            }
        ]
    }
    EOF
    ```

    > 配置说明：

    - `CN`：证书的通用名称为 `etcd.ateng.local`。
    - `hosts`：定义服务端的 IP 地址和域名，允许多个地址，便于集群节点扩展。
    - `key`：指定 RSA 算法和 2048 位密钥长度。
    - `names`：证书的地理信息，具体信息与 CA 配置相同。

##### 4.2 生成服务端证书

```bash
cfssl gencert -ca=ca.pem -ca-key=ca-key.pem -config=ca-config.json -profile=etcd etcd-server-csr.json | cfssljson -bare etcd-server
cfssl certinfo -cert etcd-server.pem | grep not
```

> 使用指定的 CA 证书和密钥生成服务端证书。输出文件 `etcd-server.pem` 和 `etcd-server-key.pem` 分别是服务端的公钥和私钥。

---

#### 5. 生成 ETCD 客户端证书

客户端证书用于ETCD客户端连接ETCD服务器时的身份验证。

##### 5.1 创建 ETCD 客户端配置文件

1. **生成 `etcd-client-csr.json` 文件**

    ```bash
    tee etcd-client-csr.json <<EOF
    {
        "CN": "etcd.kongyu.local",
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
                "OU": "Etcd Client"
            }
        ]
    }
    EOF
    ```

    > 配置说明：

    - `hosts`：由于客户端证书不需要绑定到特定 IP 地址，因此为空。
    - 其他字段与服务端配置相同。

##### 5.2 生成客户端证书

```bash
cfssl gencert -ca=ca.pem -ca-key=ca-key.pem -config=ca-config.json -profile=etcd etcd-client-csr.json | cfssljson -bare etcd-client
cfssl certinfo -cert etcd-client.pem | grep not
```

> 生成的 `etcd-client.pem` 是客户端的公钥文件，

`etcd-client-key.pem` 是私钥文件。

---

#### 6. 分发证书到其他 ETCD 节点

在其他节点创建证书目录

```bash
sudo mkdir -p /etc/ssl/etcd/
sudo chown admin:ateng /etc/ssl/etcd/
```

将生成的证书分发到其他ETCD节点上，以便这些节点可以进行加密通信：

```bash
scp -r /etc/ssl/etcd/* etcd02.ateng.local:/etc/ssl/etcd/
scp -r /etc/ssl/etcd/* etcd03.ateng.local:/etc/ssl/etcd/
```



### 安装ETCD集群

#### 1. 安装ETCD

##### 1.1 下载和解压ETCD软件包
```bash
wget https://github.com/etcd-io/etcd/releases/download/v3.5.16/etcd-v3.5.16-linux-amd64.tar.gz
tar -zxvf etcd-v3.5.16-linux-amd64.tar.gz
```

##### 1.2 将ETCD安装到系统路径
```bash
sudo cp etcd-v3.5.16-linux-amd64/etcd* /usr/bin
```
> 以上命令将`etcd`的二进制文件复制到系统可执行路径中。

##### 1.3 查看安装的ETCD版本
```bash
etcdctl version
```
> 命令输出应类似以下内容，表示安装成功：
```
etcdctl version: 3.5.16
API version: 3.5
```

#### 2. 配置ETCD

##### 2.1 创建配置和数据目录

数据目录最好放在SSD硬盘上

```bash
sudo mkdir -p /quickdata/service/etcd/ /etc/etcd/
sudo chmod 700 /quickdata/service/etcd/ /etc/etcd/
sudo chown admin:ateng /quickdata/service/etcd/ /etc/etcd/
```
> 创建存储 `etcd` 配置文件和数据的目录。

##### 2.2 编辑配置文件

编辑 `/etc/etcd/etcd.conf`，文件内容如下：

其他节点注意修改以下配置

- ETCD_LISTEN_PEER_URLS
- ETCD_LISTEN_CLIENT_URLS
- ETCD_ADVERTISE_CLIENT_URLS
- ETCD_INITIAL_ADVERTISE_PEER_URLS
- ETCD_NAME

```bash
tee /etc/etcd/etcd.conf <<"EOF"
ETCD_DATA_DIR="/quickdata/service/etcd/"
ETCD_LISTEN_PEER_URLS="https://192.168.1.112:2380"
ETCD_LISTEN_CLIENT_URLS="https://192.168.1.112:2379,https://127.0.0.1:2379"
ETCD_ADVERTISE_CLIENT_URLS="https://192.168.1.112:2379"
ETCD_INITIAL_ADVERTISE_PEER_URLS="https://192.168.1.112:2380"
ETCD_NAME="etcd01"
ETCD_INITIAL_CLUSTER="etcd01=https://192.168.1.112:2380,etcd02=https://192.168.1.113:2380,etcd03=https://192.168.1.114:2380"
ETCD_INITIAL_CLUSTER_TOKEN="2385569970"
ETCD_INITIAL_CLUSTER_STATE="new"
ETCD_TRUSTED_CA_FILE="/etc/ssl/etcd/ca.pem"
ETCD_CERT_FILE="/etc/ssl/etcd/etcd-server.pem"
ETCD_KEY_FILE="/etc/ssl/etcd/etcd-server-key.pem"
ETCD_CLIENT_CERT_AUTH=true
ETCD_PEER_TRUSTED_CA_FILE="/etc/ssl/etcd/ca.pem"
ETCD_PEER_CERT_FILE="/etc/ssl/etcd/etcd-server.pem"
ETCD_PEER_KEY_FILE="/etc/ssl/etcd/etcd-server-key.pem"
ETCD_PEER_CLIENT_CERT_AUTH=true
ETCD_QUOTA_BACKEND_BYTES=8589934592
ETCD_MAX_REQUEST_BYTES=10485760
ETCD_SNAPSHOT_COUNT=2000
ETCD_LOG_LEVEL="warn"
ETCD_AUTO_COMPACTION_MODE="periodic"
ETCD_AUTO_COMPACTION_RETENTION="1h"
ETCD_MAX_TXN_OPS=1280
EOF
```

> **参数说明**：
> - `ETCD_DATA_DIR`：数据存储目录。
> - `ETCD_LISTEN_PEER_URLS`：ETCD节点间的通信监听URL。
> - `ETCD_LISTEN_CLIENT_URLS`：客户端连接的监听URL。
> - `ETCD_ADVERTISE_CLIENT_URLS`：通告给集群中其他成员的客户端URL。
> - `ETCD_INITIAL_ADVERTISE_PEER_URLS`：通告给集群中其他成员的ETCD节点通信URL。
> - `ETCD_NAME`：本节点的唯一名称。
> - `ETCD_INITIAL_CLUSTER`：集群成员列表，格式为 `节点名称=节点通信URL`。
> - `ETCD_INITIAL_CLUSTER_TOKEN`：集群标识符，用于防止多个集群混淆。
> - `ETCD_INITIAL_CLUSTER_STATE`：集群状态，`new`表示创建新集群。
> - `ETCD_TRUSTED_CA_FILE`：TLS认证的CA证书路径。
> - `ETCD_CERT_FILE`：TLS证书文件路径。
> - `ETCD_KEY_FILE`：TLS私钥文件路径。
> - `ETCD_CLIENT_CERT_AUTH`：启用客户端证书认证。
> - `ETCD_PEER_TRUSTED_CA_FILE`：节点间通信的CA证书路径。
> - `ETCD_PEER_CERT_FILE`：节点间通信的TLS证书文件路径。
> - `ETCD_PEER_KEY_FILE`：节点间通信的TLS私钥文件路径。
> - `ETCD_PEER_CLIENT_CERT_AUTH`：启用节点间的客户端证书验证。
> - `ETCD_QUOTA_BACKEND_BYTES`：ETCD数据存储的大小限制（字节）。
> - `ETCD_MAX_REQUEST_BYTES`：允许的最大客户端请求大小。
> - `ETCD_SNAPSHOT_COUNT`：每隔多少事务触发快照。
> - `ETCD_LOG_LEVEL`：日志级别，可选`debug, info, warn, error, panic, fatal`。
> - `ETCD_AUTO_COMPACTION_MODE`：自动压缩模式，`periodic`表示按周期压缩。
> - `ETCD_AUTO_COMPACTION_RETENTION`：自动压缩的保留时间。
> - `ETCD_MAX_TXN_OPS`：允许的最大事务操作数。

#### 3. 配置systemd启动服务

##### 3.1 创建systemd服务文件

编辑 `/etc/systemd/system/etcd.service` 文件，内容如下：

```ini
sudo tee /etc/systemd/system/etcd.service <<"EOF"
[Unit]
Description=Etcd Server
Documentation=https://etcd.io/docs/v3.5/
After=network.target

[Service]
User=admin
Group=ateng
Type=notify
EnvironmentFile=/etc/etcd/etcd.conf
ExecStart=/usr/bin/etcd
ExecStop=/bin/kill -SIGTERM $MAINPID
KillSignal=SIGTERM
TimeoutStopSec=30
Restart=on-failure
RestartSec=10s

[Install]
WantedBy=multi-user.target
EOF
```

> **配置说明**：
> - `[Unit]`部分：`Description`用于描述服务，`After`确保服务在网络启动后启动。
> - `[Service]`部分：
>   - `EnvironmentFile`：指定加载的环境变量配置文件。
>   - `ExecStart`和`ExecStop`：分别为启动和停止服务的命令。
>   - `KillSignal`：指定的信号用于终止服务。
>   - `Restart`：设置服务失败时自动重启。
>   - `StandardOutput`和`StandardError`：将日志输出到syslog。
> - `[Install]`部分：定义服务的目标。

#### 4. 启动ETCD服务

##### 4.1 重新加载并启动服务
```bash
sudo systemctl daemon-reload
sudo systemctl start etcd.service
sudo systemctl enable etcd.service
```
> `systemctl daemon-reload` 重新加载systemd配置，`systemctl start`启动服务，`systemctl enable`设为开机自启。

#### 5. 查看ETCD节点状态

##### 5.1 配置ETCD客户端环境

创建客户端配置文件 `/etc/profile.d/00-etcd.sh`：
```bash
tee -a ~/.bash_profile <<EOF
## ETCD Config
export ETCDCTL_API=3
export ETCDCTL_ENDPOINTS="https://192.168.1.112:2379,https://192.168.1.113:2379,https://192.168.1.114:2379"
export ETCDCTL_CACERT="/etc/ssl/etcd/ca.pem"
export ETCDCTL_KEY="/etc/ssl/etcd/etcd-client-key.pem"
export ETCDCTL_CERT="/etc/ssl/etcd/etcd-client.pem"
EOF
source ~/.bash_profile
```
> 该文件将ETCD客户端命令行工具`etcdctl`的环境变量加载到系统环境中。

##### 5.2 使用 `etcdctl` 查看节点状态

```bash
etcdctl endpoint status --write-out=table
etcdctl endpoint health --write-out=table
etcdctl member list --write-out=table
```
> - `etcdctl endpoint status`：查看各个节点的状态。
> - `etcdctl endpoint health`：检查各节点健康状况。
> - `etcdctl member list`：列出集群成员。



## 安装HTTP+认证模式集群

### 安装ETCD集群

#### 1. 安装ETCD

##### 1.1 下载和解压ETCD软件包

```bash
wget http://github.com/etcd-io/etcd/releases/download/v3.5.16/etcd-v3.5.16-linux-amd64.tar.gz
tar -zxvf etcd-v3.5.16-linux-amd64.tar.gz
```

##### 1.2 将ETCD安装到系统路径

```bash
sudo cp etcd-v3.5.16-linux-amd64/etcd* /usr/bin
```

> 以上命令将`etcd`的二进制文件复制到系统可执行路径中。

##### 1.3 查看安装的ETCD版本

```bash
etcdctl version
```

> 命令输出应类似以下内容，表示安装成功：

```
etcdctl version: 3.5.16
API version: 3.5
```

#### 2. 配置ETCD

##### 2.1 创建配置和数据目录

数据目录最好放在SSD硬盘上

```bash
sudo mkdir -p /quickdata/service/etcd/ /etc/etcd/
sudo chmod 700 /quickdata/service/etcd/ /etc/etcd/
sudo chown admin:ateng /quickdata/service/etcd/ /etc/etcd/
```

> 创建存储 `etcd` 配置文件和数据的目录。

##### 2.2 编辑配置文件

编辑 `/etc/etcd/etcd.conf`，文件内容如下：

其他节点注意修改以下配置

- ETCD_LISTEN_PEER_URLS
- ETCD_LISTEN_CLIENT_URLS
- ETCD_ADVERTISE_CLIENT_URLS
- ETCD_INITIAL_ADVERTISE_PEER_URLS
- ETCD_NAME

```bash
tee /etc/etcd/etcd.conf <<"EOF"
ETCD_DATA_DIR="/quickdata/service/etcd/"
ETCD_LISTEN_PEER_URLS="http://192.168.1.112:2380"
ETCD_LISTEN_CLIENT_URLS="http://192.168.1.112:2379,http://127.0.0.1:2379"
ETCD_ADVERTISE_CLIENT_URLS="http://192.168.1.112:2379"
ETCD_INITIAL_ADVERTISE_PEER_URLS="http://192.168.1.112:2380"
ETCD_NAME="etcd01"
ETCD_INITIAL_CLUSTER="etcd01=http://192.168.1.112:2380,etcd02=http://192.168.1.113:2380,etcd03=http://192.168.1.114:2380"
ETCD_INITIAL_CLUSTER_TOKEN="2385569970"
ETCD_INITIAL_CLUSTER_STATE="new"
ETCD_QUOTA_BACKEND_BYTES=8589934592
ETCD_MAX_REQUEST_BYTES=10485760
ETCD_SNAPSHOT_COUNT=2000
ETCD_LOG_LEVEL="warn"
ETCD_AUTO_COMPACTION_MODE="periodic"
ETCD_AUTO_COMPACTION_RETENTION="1h"
ETCD_MAX_TXN_OPS=1280
EOF
```

> **参数说明**：
>
> - `ETCD_DATA_DIR`：数据存储目录。
> - `ETCD_LISTEN_PEER_URLS`：ETCD节点间的通信监听URL。
> - `ETCD_LISTEN_CLIENT_URLS`：客户端连接的监听URL。
> - `ETCD_ADVERTISE_CLIENT_URLS`：通告给集群中其他成员的客户端URL。
> - `ETCD_INITIAL_ADVERTISE_PEER_URLS`：通告给集群中其他成员的ETCD节点通信URL。
> - `ETCD_NAME`：本节点的唯一名称。
> - `ETCD_INITIAL_CLUSTER`：集群成员列表，格式为 `节点名称=节点通信URL`。
> - `ETCD_INITIAL_CLUSTER_TOKEN`：集群标识符，用于防止多个集群混淆。
> - `ETCD_INITIAL_CLUSTER_STATE`：集群状态，`new`表示创建新集群。
> - `ETCD_QUOTA_BACKEND_BYTES`：ETCD数据存储的大小限制（字节）。
> - `ETCD_MAX_REQUEST_BYTES`：允许的最大客户端请求大小。
> - `ETCD_SNAPSHOT_COUNT`：每隔多少事务触发快照。
> - `ETCD_LOG_LEVEL`：日志级别，可选`debug, info, warn, error, panic, fatal`。
> - `ETCD_AUTO_COMPACTION_MODE`：自动压缩模式，`periodic`表示按周期压缩。
> - `ETCD_AUTO_COMPACTION_RETENTION`：自动压缩的保留时间。
> - `ETCD_MAX_TXN_OPS`：允许的最大事务操作数。

#### 3. 配置systemd启动服务

##### 3.1 创建systemd服务文件

编辑 `/etc/systemd/system/etcd.service` 文件，内容如下：

```ini
sudo tee /etc/systemd/system/etcd.service <<"EOF"
[Unit]
Description=Etcd Server
Documentation=http://etcd.io/docs/v3.5/
After=network.target

[Service]
User=admin
Group=ateng
Type=notify
EnvironmentFile=/etc/etcd/etcd.conf
ExecStart=/usr/bin/etcd
ExecStop=/bin/kill -SIGTERM $MAINPID
KillSignal=SIGTERM
TimeoutStopSec=30
Restart=on-failure
RestartSec=10s

[Install]
WantedBy=multi-user.target
EOF
```

> **配置说明**：
>
> - `[Unit]`部分：`Description`用于描述服务，`After`确保服务在网络启动后启动。
> - `[Service]`部分：
>     - `EnvironmentFile`：指定加载的环境变量配置文件。
>     - `ExecStart`和`ExecStop`：分别为启动和停止服务的命令。
>     - `KillSignal`：指定的信号用于终止服务。
>     - `Restart`：设置服务失败时自动重启。
>     - `StandardOutput`和`StandardError`：将日志输出到syslog。
> - `[Install]`部分：定义服务的目标。

#### 4. 启动ETCD服务

##### 4.1 重新加载并启动服务

```bash
sudo systemctl daemon-reload
sudo systemctl start etcd.service
sudo systemctl enable etcd.service
```

> `systemctl daemon-reload` 重新加载systemd配置，`systemctl start`启动服务，`systemctl enable`设为开机自启。

#### 5. 查看ETCD节点状态

##### 5.1 配置ETCD客户端环境

创建客户端配置文件 `/etc/profile.d/00-etcd.sh`：

```bash
tee -a ~/.bash_profile <<EOF
## ETCD Config
export ETCDCTL_API=3
export ETCDCTL_ENDPOINTS="http://192.168.1.112:2379,http://192.168.1.113:2379,http://192.168.1.114:2379"
EOF
source ~/.bash_profile
```

> 该文件将ETCD客户端命令行工具`etcdctl`的环境变量加载到系统环境中。

##### 5.2 使用 `etcdctl` 查看节点状态

```bash
etcdctl endpoint status --write-out=table
etcdctl endpoint health --write-out=table
etcdctl member list --write-out=table
```

> - `etcdctl endpoint status`：查看各个节点的状态。
> - `etcdctl endpoint health`：检查各节点健康状况。
> - `etcdctl member list`：列出集群成员。

#### 6. 开启用户认证

1. **添加用户 `root` 并设置密码**：

    ```bash
    etcdctl user add root --new-user-password="Admin@123"
    ```

2. **授予 `root` 用户 `root` 角色**：

    ```bash
    etcdctl user grant-role root root
    ```

3. **启用认证**：

    ```bash
    etcdctl auth enable
    ```

4. **验证用户是否成功添加**：

    ```bash
    etcdctl --user=root:Admin@123 user list
    ```

说明：

- 以上命令假设 `etcdctl` 已正确配置并能够连接到 `etcd` 实例。
- 确保在启用认证后，后续的 `etcdctl` 操作都使用授权用户进行访问，如 `--user=root:Admin@123`。
- 在启用认证后，访问 `etcd` 的客户端和服务需要使用认证用户进行访问。

