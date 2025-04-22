# chrony

`chrony` 是 Linux 系统中的一种高效时间同步服务，替代传统的 `ntpd`。它支持快速启动和精准同步，适合虚拟机、间歇网络连接等场景。`chrony` 可作为客户端同步网络时间，也能作为服务器为局域网提供时间服务。

- [官网地址](https://chrony.tuxfamily.org/documentation.html)



## 安装和配置

**安装服务**

```
sudo yum install chrony -y
```

**配置服务**

配置文件路径为：/etc/chrony.conf

```
server ntp.aliyun.com iburst
server cn.ntp.org.cn iburst
driftfile /var/lib/chrony/drift
rtcsync
makestep 1.0 3
local stratum 10
allow 192.168.1.0/24
logdir /var/log/chrony
```

- `server ntp.aliyun.com iburst`: 设置阿里云 NTP 服务器为时间源，`iburst` 加快初次同步速度
- `server cn.ntp.org.cn iburst`: 设置中国国家授时中心为第二个时间源
- `driftfile /var/lib/chrony/drift`: 指定记录系统时钟漂移数据的文件路径
- `rtcsync`: 启用系统时间与硬件时钟（RTC）的自动同步
- `makestep 1.0 3`: 在前3次同步中，如果时间差大于1秒，则立即调整系统时间
- `local stratum 10`: 启用本地时钟作为时间源（仅在无外部源可用时），层级为10
- `allow 192.168.1.0/24`: 允许该子网中的设备访问本机进行时间同步
- `logdir /var/log/chrony`: 指定 chrony 日志文件的存放目录



## 时间同步

**启动服务**

第一次启动或者重启会触发一次时间同步

```
sudo systemctl enable chronyd --now
```

**查看服务状态**

```
sudo journalctl -f -u chronyd
```

**查看时间同步状态**

```
chronyc tracking
```

输出示例：

```
Reference ID    : B65C0C0B (time5.aliyun.com)
Stratum         : 3
Ref time (UTC)  : Sat Apr 19 00:53:10 2025
System time     : 0.000243336 seconds slow of NTP time
Last offset     : +0.000064221 seconds
RMS offset      : 12187555.000000000 seconds
Frequency       : 12.140 ppm fast
Residual freq   : -0.154 ppm
Skew            : 2.984 ppm
Root delay      : 0.032123305 seconds
Root dispersion : 0.011086497 seconds
Update interval : 65.3 seconds
Leap status     : Normal
```

**查看连接的服务器**

```
chronyc sources
```

看到一条 `^*` 开头的行，表示与服务器同步成功：

输出示例：

```
MS Name/IP address         Stratum Poll Reach LastRx Last sample
===============================================================================
^+ 203.107.6.88                  2   6   377    56  -1562us[-1497us] +/-   33ms
^* time5.aliyun.com              2   6   377    55  +2061us[+2126us] +/-   27ms
```



## 内网时间同步

如果在一个**内网环境**中，客户端需要从**内网 NTP 服务器**同步时间，进行以下配置

**配置服务**

配置文件路径为：/etc/chrony.conf

```
server 192.168.100.1 iburst
driftfile /var/lib/chrony/drift
rtcsync
makestep 1.0 3
logdir /var/log/chrony
```

- `server 192.168.1.100 iburst`：指定内网 NTP 服务器的 IP 地址（比如你的服务器），`iburst` 提升初次同步速度。
- `driftfile`、`rtcsync`、`makestep`：和服务端一样，用于校时和同步设置。
- `logdir`：可选，指定日志目录。

**启动服务**

```
sudo systemctl enable chronyd --now
```

**查看同步状态**

```
chronyc tracking
chronyc sources
```



## 其他设置

**手动同步时间**

立刻校正系统时间

```
sudo chronyc -a makestep
```

**防火墙设置**

如果你的服务器需要作为 NTP 服务端，还需开放 UDP 123 端口：

```
sudo firewall-cmd --add-service=ntp --permanent
sudo firewall-cmd --reload
```

