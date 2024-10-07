# 安装使用CoreDNS

https://coredns.io/

CoreDNS 是一个灵活且可扩展的 DNS 服务器，广泛用于 Kubernetes 和其他云原生环境。它使用插件架构，可以轻松添加功能，如负载均衡、DNS 缓存和服务发现。CoreDNS 以其高性能、轻量级和易于配置而著称，支持多种协议，包括 DNS 和 gRPC。它的目标是为微服务架构提供可靠的 DNS 解决方案，适应现代云环境的需求。



## 安装服务

**下载软件包**

```
wget https://github.com/coredns/coredns/releases/download/v1.11.3/coredns_1.11.3_linux_amd64.tgz
```

**解压安装软件包**

```
sudo tar -zxvf coredns_1.11.3_linux_amd64.tgz -C /usr/local/bin
```

**查看版本**

```
coredns --version
```



## 配置服务

**编辑配置文件**

注意ETCD的证书中所包含的IP或者域名信息需要确保coredns节点在其中，不然无法解析ETCD中的DNS

```
sudo mkdir -p /etc/coredns
sudo tee /etc/coredns/Corefile <<"EOF"
.:53 {
    # 监听的IP地址
    bind 192.168.1.113
    bind 10.14.0.101

    # 静态主机映射
    hosts {
        192.168.1.13 registry.ateng.local
    }

    # 与 etcd 集群交互的配置
    etcd ateng.local kongyu.local {
        path /skydns
        endpoint https://192.168.1.101:2379
        tls /etc/ssl/etcd/ssl/admin-k8s-master01.pem /etc/ssl/etcd/ssl/admin-k8s-master01-key.pem /etc/ssl/etcd/ssl/ca.pem
        fallthrough
    }

    # 记录错误信息
    errors

    # 健康检查
    health {
        # 停止前的等待时间
        # lameduck 15s
    }

    # 健康检查页面的端口号
    health :9101

    # 启用日志记录
    #log

    # 转发请求到上游DNS服务器
    forward . /etc/resolv.conf {
        prefer_udp
    }

    # 插件缓存
    # cache 30
    # cache插件配置
    cache {
        # 成功记录的配置
        success 10240 600 60
        # 拒绝记录的配置
        denial 5120 60 5
    }

    # 循环查询
    loop

    # 重新加载配置
    reload

    # 负载均衡
    loadbalance
}
EOF
```

**拷贝ETCD的SSL文件**

```
sudo mkdir -p /etc/ssl/etcd/ssl
sudo scp 192.168.1.101:/etc/ssl/etcd/ssl/* /etc/ssl/etcd/ssl
```



## 启动服务

**编辑coredns.service**

```
sudo tee /etc/systemd/system/coredns.service <<"EOF"
[Unit]
Description=CoreDNS
Documentation=https://coredns.io/manual/toc/
After=network.target

[Service]
Type=simple
Restart=on-failure
RestartSec=5
ExecStart=/usr/local/bin/coredns -conf /etc/coredns/Corefile

[Install]
WantedBy=multi-user.target
EOF
```

**启动服务**

```
sudo systemctl daemon-reload
sudo systemctl enable --now coredns.service
```

**查看服务**状态

```
sudo systemctl status coredns.service
```



## 使用服务

### **使用dig命令**

```
[admin@localhost coredns]$ dig @192.168.1.113 registry.ateng.local

; <<>> DiG 9.18.21 <<>> @192.168.1.113 registry.ateng.local
; (1 server found)
;; global options: +cmd
;; Got answer:
;; WARNING: .local is reserved for Multicast DNS
;; You are currently testing what happens when an mDNS query is leaked to DNS
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 60804
;; flags: qr aa rd; QUERY: 1, ANSWER: 1, AUTHORITY: 0, ADDITIONAL: 1
;; WARNING: recursion requested but not available

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 1232
; COOKIE: ca86a17d0fa693a4 (echoed)
;; QUESTION SECTION:
;registry.ateng.local.          IN      A

;; ANSWER SECTION:
registry.ateng.local.   587     IN      A       192.168.1.13

;; Query time: 1 msec
;; SERVER: 192.168.1.113#53(192.168.1.113) (UDP)
;; WHEN: Thu Sep 26 17:45:46 CST 2024
;; MSG SIZE  rcvd: 97
```

### **使用nmcli命令**

使用nmcli命令配置系统DNS

查看当前连接

```
nmcli connection show
```

配置DNS

```
sudo nmcli connection modify ens33 ipv4.dns "192.168.1.113,8.8.8.8"
```

使配置生效

```
sudo nmcli connection up ens33
```

直接访问域名

```
[admin@localhost coredns]$ dig registry.ateng.local

; <<>> DiG 9.18.21 <<>> registry.ateng.local
;; global options: +cmd
;; Got answer:
;; WARNING: .local is reserved for Multicast DNS
;; You are currently testing what happens when an mDNS query is leaked to DNS
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 38627
;; flags: qr aa rd; QUERY: 1, ANSWER: 1, AUTHORITY: 0, ADDITIONAL: 1
;; WARNING: recursion requested but not available

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 1232
; COOKIE: 31bb785435313d4a (echoed)
;; QUESTION SECTION:
;registry.ateng.local.          IN      A

;; ANSWER SECTION:
registry.ateng.local.   600     IN      A       192.168.1.13

;; Query time: 2 msec
;; SERVER: 192.168.1.113#53(192.168.1.113) (UDP)
;; WHEN: Thu Sep 26 17:57:05 CST 2024
;; MSG SIZE  rcvd: 97
```

### 访问ETCD的映射

**查看ETCD的数据**

进入ETCD节点，使用命令查看**external-dns**服务创建的域名映射

```
[root@k8s-master01 external-dns]# etcdctl get /skydns --prefix --keys-only
/skydns/local/ateng/a-nginx/52cece18

/skydns/local/ateng/nginx/7a5ac87f

[root@k8s-master01 external-dns]# etcdctl get /skydns --prefix
/skydns/local/ateng/a-nginx/52cece18
{"text":"\"heritage=external-dns,external-dns/owner=default,external-dns/resource=ingress/default/nginx\"","targetstrip":1}
/skydns/local/ateng/nginx/7a5ac87f
{"host":"192.168.1.234","text":"\"heritage=external-dns,external-dns/owner=default,external-dns/resource=ingress/default/nginx\"","targetstrip":1}
```

访问**external-dns**服务创建的域名映射

```
curl nginx.ateng.local
```

