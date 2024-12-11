# 网络配置



## 使用 `nmcli` 配置网络

`nmcli`是NetworkManager的命令行工具，可以动态管理网络连接。

### 1. 配置静态 IPv4 地址

#### 1.1 查看当前网络设备

首先，使用 `nmcli device` 查看系统中现有的网络设备。

```bash
nmcli device
```

假设设备名称为 `eth0`，如果不确定设备名称，请从输出中找到正确的设备名。

#### 1.2 配置静态 IPv4 地址
接下来，为 `eth0` 配置静态 IP、网关和 DNS 信息：

```bash
nmcli connection add \
  type ethernet \
  connection.autoconnect yes \
  ifname eth0 con-name eth0 \
  ipv4.addresses 192.168.1.100/24 \
  ipv4.gateway 192.168.1.1 \
  ipv4.dns "8.8.8.8 8.8.4.4" \
  ipv4.method manual
```

其中：
- `connection.autoconnect yes` 让网卡在启动时自动连接
- `192.168.1.100/24` 是要配置的静态 IP 和子网掩码。
- `192.168.1.1` 是网关地址。
- `8.8.8.8` 和 `8.8.4.4` 是 DNS 服务器地址。
- `manual` 表示静态 IP 配置方式。

#### 1.3 启用静态 IP 配置
```bash
nmcli connection up eth0
```

---

### 2. 配置 DHCP 地址

#### 2.1 为设备添加 DHCP 连接
使用以下命令为 `eth0` 添加 DHCP 连接：

```bash
nmcli connection add \
  type ethernet \
  connection.autoconnect yes \
  ifname eth0 con-name eth0 \
  ipv4.method auto
```

`auto` 表示通过 DHCP 自动获取 IP 地址。

#### 2.2 启用 DHCP 连接
```bash
nmcli connection up eth0
```

---

### 3. 修改现有的静态 IP 配置

#### **3.1 修改配置方法为手动**

```
nmcli connection modify eth0 ipv4.method manual
```

#### 3.2 启用自动连接

让网卡在启动时自动连接

```bash
nmcli connection modify eth0 connection.autoconnect yes
```

#### 3.3 修改已存在的静态 IP 地址

假设当前连接名称为 `eth0`，修改 IP 地址如下：
```bash
nmcli connection modify eth0 ipv4.addresses 192.168.1.101/24
```

#### 3.4 修改网关地址
```bash
nmcli connection modify eth0 ipv4.gateway 192.168.1.254
```

#### 3.5 修改 DNS 服务器
```bash
nmcli connection modify eth0 ipv4.dns "1.1.1.1 1.0.0.1"
```

#### 3.6 应用修改

```bash
nmcli connection up eth0
```

---

### 4. 删除网络配置

#### 4.1 删除指定的连接
例如，删除名为 `eth0` 的连接：

```bash
nmcli connection delete eth0
```

#### 4.2 删除所有连接
```bash
nmcli connection delete $(nmcli -t -f NAME connection show)
```



## 双网卡配置步骤

在多网卡环境中，系统通常使用一个默认网关，而其他网卡则使用静态路由来配置特定的流量。假设有两个网卡`ens33`和`ens34`，下面的步骤将介绍如何配置这两个网卡。

### 1. 配置网卡1（ens33）

1. **添加ens33的连接配置**

    使用`nmcli`命令创建新的以太网连接，并配置IP地址、子网掩码、网关和DNS服务器。

    ```bash
    nmcli connection add type ethernet ifname ens33 con-name ens33
    ```

2. **设置IP地址和子网掩码**

    为`ens33`配置静态IP地址（例如`192.168.1.10`）和子网掩码（`/24`）。

    ```bash
    nmcli connection modify ens33 ipv4.addresses 192.168.1.10/24
    ```

3. **设置默认网关**

    配置默认网关（例如`192.168.1.1`）。通常，系统会使用一个默认网关。

    ```bash
    nmcli connection modify ens33 ipv4.gateway 192.168.1.1
    ```

4. **设置DNS服务器**

    配置DNS服务器（例如`8.8.8.8`）。

    ```bash
    nmcli connection modify ens33 ipv4.dns 8.8.8.8
    ```

5. **启用自动连接**

    让网卡在启动时自动连接。

    ```bash
    nmcli connection modify ens33 connection.autoconnect yes
    ```

### 2. 配置网卡2（ens34）

1. **添加ens34的连接配置**

    创建`ens34`的以太网连接，并为其配置IP地址、子网掩码和DNS服务器。

    ```bash
    nmcli connection add type ethernet ifname ens34 con-name ens34
    ```

2. **设置IP地址和子网掩码**

    为`ens34`配置静态IP地址（例如`192.168.2.10`）和子网掩码（`/24`）。

    ```bash
    nmcli connection modify ens34 ipv4.addresses 192.168.2.10/24
    ```

3. **不配置默认网关**

    通常情况下，`ens34`不需要设置默认网关，因为系统通常只使用一个默认网关。

4. **设置静态路由**

    如果需要将特定的流量通过`ens34`发送，可以使用静态路由配置。例如：

    ```bash
    nmcli connection modify ens34 +ipv4.routes "192.168.3.0/24 192.168.2.1 99"
    ```

    这个命令表示，将到`192.168.3.0/24`网段的流量通过`192.168.2.1`网关路由，并从`ens34`发出，度量值为 99（值越小优先级越高）。

5. **设置DNS服务器**

    配置另一个DNS服务器（例如`8.8.4.4`）。

    ```bash
    nmcli connection modify ens34 ipv4.dns 8.8.4.4
    ```

6. **启用自动连接**

    让`ens34`在启动时自动连接。

    ```bash
    nmcli connection modify ens34 connection.autoconnect yes
    ```

### 3. 应用修改

1. **激活ens33连接**

    使`ens33`的配置生效。

    ```bash
    nmcli connection up ens33
    ```

2. **激活ens34连接**

    使`ens34`的配置生效。

    ```bash
    nmcli connection up ens34
    ```

### 4. 查看网络配置和路由

1. **查看IP地址配置**

    检查网卡的IP配置，确保已经生效。

    ```bash
    ip addr
    ```

2. **查看路由表**

    检查系统的路由配置，以确保默认网关和其他路由设置正确。

    ```bash
    ip route
    ```

