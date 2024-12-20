# Keepalived

Keepalived 是一款用于实现高可用性和负载均衡的服务，主要通过 VRRP（虚拟路由冗余协议）提供故障切换功能。它常用于为 Web 服务器、数据库、负载均衡器等服务配置虚拟 IP（VIP），确保在主节点故障时自动切换到备节点，保障服务连续性和稳定性。

- [官网链接](https://www.keepalived.org/index.html)



## 前置条件

- 参考：[基础配置](/work/service/00-basic/)



## 下载软件包

**下载源码包**

下载地址：[链接](https://www.keepalived.org/download.html)

```bash
wget https://www.keepalived.org/software/keepalived-2.3.2.tar.gz
```

**解压源码**

```bash
tar -zxvf keepalived-2.3.2.tar.gz
cd keepalived-2.3.2
```



## 编译安装

**安装编译软件**

```shell
sudo dnf -y install make gcc pcre-devel systemd-devel libnl3-devel net-snmp-devel
```

**运行 `configure` 脚本**

```
./configure --prefix=/usr/local/software/keepalived \
            --with-init=systemd \
            --enable-snmp
```

- `--prefix`: 指定安装路径，默认是 `/usr/local`。
- `--with-init=systemd`: 启用 Systemd 支持。
- `--enable-snmp`: 启用 SNMP 功能（如果需要监控支持）。

**编译源码**

```
make -j$(nproc)
```

**安装**

```
sudo make install
```

**查看版本**

```
/usr/local/software/keepalived/sbin/keepalived --version
```



## 编辑配置文件

**创建配置文件目录**

```
sudo mkdir -p /etc/keepalived
```

创建配置文件

```
sudo tee /etc/keepalived/keepalived.conf <<"EOF"
global_defs {
   router_id LVS_MASTER
}

vrrp_instance VI_1 {
    state MASTER
    interface enp1s0
    virtual_router_id 51
    priority 100
    advert_int 1
    authentication {
        auth_type PASS
        auth_pass 1234
    }
    virtual_ipaddress {
        10.244.100.100
    }
}
EOF
```



## 启动服务

```
sudo systemctl daemon-reload
sudo systemctl enable --now keepalived
sudo systemctl status keepalived
```



等待后续更新......
