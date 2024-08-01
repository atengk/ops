# 安装etcd集群-https



## 生成ssl证书

### 安装cfssl

```
tar -zxvf cfssl-v1.6.1-binary.tar.gz -C /usr/bin/
```

### 创建证书目录

```
mkdir -p /etc/ssl/etcd/
cd /etc/ssl/etcd/
```

### 生成ca证书

signing：表示该证书可用于签名其他证书；生成的ca.pem证书中CA=TRUE

server auth：表示client可以使用该ca对server提供的证书进行验证

client auth：表示server可以用该ca对client提供的证书进行验证

```
cat > ca-config.json <<EOF
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

cat > ca-csr.json <<EOF
{
    "CA":{"expiry":"876000h"},
    "CN": "etcd.kongyu.local",
    "key": {
        "algo": "rsa",
        "size": 2048
    },
    "names": [
        {
            "C": "CN",
            "L": "Chongqing",
            "ST": "Chongqing",
            "O": "LK-KongYu-Cluster-Etcd",
            "OU": "KongYu-Cluster-Etcd"
        }
    ]
}
EOF

## 生成证书
cfssl gencert -initca ca-csr.json | cfssljson -bare ca -
cfssl certinfo -cert ca.pem | grep not
ls ca-key.pem ca.pem ca.csr
```

###  生成etcd服务端证书

etcd服务端证书用于加密etcd集群之间的通信

hosts填写etcd集群的地址，方便扩展，多写几个

```
cat > etcd-server-csr.json << EOF
{
    "CN": "etcd.kongyu.local",
    "hosts": [
        "apiserver.k8s.local",
        "*.kongyu.local",
        "192.168.1.101",
        "192.168.1.102",
        "192.168.1.103",
        "192.168.1.104",
        "192.168.1.105",
        "192.168.2.10"
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
            "O": "LK-KongYu-Cluster-Etcd",
            "OU": "KongYu-Cluster-Etcd"
        }
    ]
}
EOF

## 生成证书
cfssl gencert -ca=ca.pem -ca-key=ca-key.pem -config=ca-config.json -profile=etcd etcd-server-csr.json | cfssljson -bare etcd-server
cfssl certinfo -cert etcd-server.pem | grep not
ls etcd-server.csr etcd-server-key.pem etcd-server.pem
```

### 生成etcd客户端证书

etcd客户端证书用于etcd客户端连接etcd时提供验证方式

```
cat > etcd-client-csr.json << EOF
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
            "O": "LK-KongYu-Cluster-Etcd",
            "OU": "KongYu-Cluster-Etcd"
        }
    ]
}
EOF

## 生成证书
cfssl gencert -ca=ca.pem -ca-key=ca-key.pem -config=ca-config.json -profile=etcd etcd-client-csr.json | cfssljson -bare etcd-client
cfssl certinfo -cert etcd-client.pem | grep not 
ls etcd-client.csr etcd-client-key.pem etcd-client.pem
```

### 分发证书到其他etcd节点

```
scp -r /etc/ssl/etcd/ 192.168.1.102:/etc/ssl/
scp -r /etc/ssl/etcd/ 192.168.1.103:/etc/ssl/
```



## 安装etcd集群

### 安装etcd

```
tar -zxvf etcd-v3.5.1-binary.tar.gz -C /usr/bin/
```

### 编辑配置文件

需要修改以下的参数：ETCD_LISTEN_PEER_URLS、ETCD_LISTEN_CLIENT_URLS、ETCD_ADVERTISE_CLIENT_URLS、ETCD_INITIAL_ADVERTISE_PEER_URLS、ETCD_NAME、ETCD_INITIAL_CLUSTER

注意所有节点的IP和etcd配置修改正确！

```
mkdir -p /data/service/etcd/ /etc/etcd/
cp etcd.conf /etc/etcd/
```

### 编辑systemd启动

```
cp etcd.service /etc/systemd/system/etcd.service
```

### 启动服务

```
systemctl daemon-reload
systemctl start etcd.service
systemctl enable etcd.service
```

### 查看节点信息

设置客户端信息

```
cat > /etc/profile.d/99-etcd.sh <<EOF
export ETCDCTL_API=3
export ETCDCTL_ENDPOINTS=https://192.168.1.101:2379,https://192.168.1.102:2379,https://192.168.1.103:2379
export ETCDCTL_CACERT=/etc/ssl/etcd/ca.pem
export ETCDCTL_KEY=/etc/ssl/etcd/etcd-client-key.pem
export ETCDCTL_CERT=/etc/ssl/etcd/etcd-client.pem
EOF
source /etc/profile.d/99-etcd.sh
```

使用etcdctl查看节点

```
etcdctl endpoint status --write-out=table
etcdctl endpoint health --write-out=table
etcdctl member list --write-out=table
```



# 安装etcd集群-http+认证

## 安装etcd集群

### 安装etcd

```
tar -zxvf etcd-v3.5.1-binary.tar.gz -C /usr/bin/
```

### 编辑配置文件

需要修改以下的参数：ETCD_LISTEN_PEER_URLS、ETCD_LISTEN_CLIENT_URLS、ETCD_ADVERTISE_CLIENT_URLS、ETCD_INITIAL_ADVERTISE_PEER_URLS、ETCD_NAME、ETCD_INITIAL_CLUSTER

注意所有节点的IP和etcd配置修改正确，并且删除TLS部分的配置、https改为http即可！

```
mkdir -p /data/service/etcd/ /etc/etcd/
cp etcd.conf /etc/etcd/
```

http+用户认证的配置参考/etc/etcd/etcd.conf

```
ETCD_DATA_DIR="/data/service/etcd/"
ETCD_LISTEN_PEER_URLS="http://192.168.1.101:2380"
ETCD_LISTEN_CLIENT_URLS="http://192.168.1.101:2379,http://127.0.0.1:2379"
ETCD_ADVERTISE_CLIENT_URLS="http://192.168.1.101:2379"
ETCD_INITIAL_ADVERTISE_PEER_URLS="http://192.168.1.101:2380"
ETCD_NAME=etcd01
ETCD_INITIAL_CLUSTER="etcd01=http://192.168.1.101:2380,etcd02=http://192.168.1.102:2380,etcd03=http://192.168.1.103:2380"
ETCD_INITIAL_CLUSTER_TOKEN="2385569970"
ETCD_INITIAL_CLUSTER_STATE="new"
ETCD_QUOTA_BACKEND_BYTES=8589934592
ETCD_MAX_REQUEST_BYTES=10485760
ETCD_SNAPSHOT_COUNT=2000
ETCD_LOG_LEVEL=warn
ETCD_AUTO_COMPACTION_MODE=periodic
ETCD_AUTO_COMPACTION_RETENTION=1h
ETCD_MAX_TXN_OPS=1280
```

### 编辑systemd启动

```
cp etcd.service /etc/systemd/system/etcd.service
```

### 启动服务

```
systemctl daemon-reload
systemctl start etcd.service
systemctl enable etcd.service
```

### 查看节点信息

设置客户端信息

```
cat > /etc/profile.d/99-etcd.sh <<EOF
export ETCDCTL_API=3
export ETCDCTL_ENDPOINTS=http://192.168.1.101:2379,http://192.168.1.102:2379,http://192.168.1.103:2379
EOF
source /etc/profile.d/99-etcd.sh
```

使用etcdctl查看节点

```
etcdctl endpoint status --write-out=table
etcdctl endpoint health --write-out=table
etcdctl member list --write-out=table
```

### 开启认证

开启用户认证

```
etcdctl user add root --new-user-password="Admin@123"
etcdctl user grant-role root root
etcdctl auth enable
etcdctl --user=root:Admin@123 user list
```

