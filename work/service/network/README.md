# 网络配置



## 使用 `nmcli` 配置网络

#### 1. 配置静态 IPv4 地址

##### 1.1 查看当前网络设备
首先，使用 `nmcli device` 查看系统中现有的网络设备。

```bash
nmcli device
```

假设设备名称为 `eth0`，如果不确定设备名称，请从输出中找到正确的设备名。

##### 1.2 配置静态 IPv4 地址
接下来，为 `eth0` 配置静态 IP、网关和 DNS 信息：

```bash
nmcli connection add type ethernet ifname eth0 con-name eth0 ipv4.addresses 192.168.1.100/24 ipv4.gateway 192.168.1.1 ipv4.dns "8.8.8.8 8.8.4.4" ipv4.method manual
```

其中：
- `192.168.1.100/24` 是要配置的静态 IP 和子网掩码。
- `192.168.1.1` 是网关地址。
- `8.8.8.8` 和 `8.8.4.4` 是 DNS 服务器地址。
- `manual` 表示静态 IP 配置方式。

##### 1.3 启用静态 IP 配置
```bash
nmcli connection up eth0
```

---

#### 2. 配置 DHCP 地址

##### 2.1 为设备添加 DHCP 连接
使用以下命令为 `eth0` 添加 DHCP 连接：

```bash
nmcli connection add type ethernet ifname eth0 con-name eth0 ipv4.method auto
```

`auto` 表示通过 DHCP 自动获取 IP 地址。

##### 2.2 启用 DHCP 连接
```bash
nmcli connection up eth0
```

---

#### 3. 修改现有的静态 IP 配置

**3.0 修改配置方法为手动**

```
nmcli connection modify eth0 ipv4.method manual
```

##### 3.1 修改已存在的静态 IP 地址
假设当前连接名称为 `eth0`，修改 IP 地址如下：
```bash
nmcli connection modify eth0 ipv4.addresses 192.168.1.101/24
```

##### 3.2 修改网关地址
```bash
nmcli connection modify eth0 ipv4.gateway 192.168.1.254
```

##### 3.3 修改 DNS 服务器
```bash
nmcli connection modify eth0 ipv4.dns "1.1.1.1 1.0.0.1"
```

##### 3.4 应用修改
```bash
nmcli connection up eth0
```

---

#### 4. 删除网络配置

##### 4.1 删除指定的连接
例如，删除名为 `eth0` 的连接：

```bash
nmcli connection delete eth0
```

##### 4.2 删除 DHCP 连接
```bash
nmcli connection delete eth0
```

##### 4.3 删除所有连接
```bash
nmcli connection delete $(nmcli -t -f NAME connection show)
```

---

### 总结

- 配置 **静态 IP** 和 **DHCP** 是相互独立的操作，通过 `nmcli` 可以轻松管理。
- 通过 `nmcli connection modify` 可以随时调整配置，无需删除重新创建。