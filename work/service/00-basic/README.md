# 基础配置

再进行服务安装之前，请先参考该文档。其中 `用户创建` 这部分是必须要做的。

## 网络配置

### 使用配置文件

**使用配置文件**

```
# vi /etc/sysconfig/network-scripts/ifcfg-ens32
DEVICE="ens33"
BOOTPROTO="static"
ONBOOT="yes"
IPADDR="192.168.1.131"
PREFIX="24"
GATEWAY="192.168.1.1"
DNS1="114.114.114.114"
# systemctl restart network
```

### 使用 nmcli 配置网络

**使用nmcli命令**

还未配置网络的情况，配置ens37网卡

```
nmcli device
nmcli connection show
nmcli connection add \
  type ethernet ipv4.method manual \
  connection.autoconnect yes \
  ifname ens37 con-name ens37 \
  ipv4.addresses 10.14.0.100/24 \
  ipv4.gateway 10.14.0.1 \
  ipv4.dns "8.8.8.8 8.8.4.4"
nmcli connection up ens37
nmcli connection show
ip addr
```

已经配置了网络，需要修改的情况

```
nmcli connection modify ens37 ipv4.method manual
nmcli connection modify ens37 connection.autoconnect yes
nmcli connection modify ens37 ipv4.addresses 10.14.0.101/24
nmcli connection modify ens37 ipv4.gateway 10.14.0.254
nmcli connection modify ens37 ipv4.dns "1.1.1.1 1.0.0.1"
nmcli connection up ens37
nmcli connection show
ip addr
```



## 主机名与 Hosts 配置

### 修改主机名

每个节点修改相应的主机名

```
hostnamectl set-hostname service01.ateng.local
```

### 配置 Hosts 文件

```
cat >> /etc/hosts <<EOF
## Service Cluster Hosts
192.168.1.131 service01 service01.ateng.local
192.168.1.132 service02 service02.ateng.local
192.168.1.133 service03 service03.ateng.local
## Service Cluster Hosts
EOF
```



## 安全性设置

### 关闭防火墙

```
systemctl stop firewalld
systemctl disable firewalld
```

### 禁用 SELinux

```
setenforce 0
sed -i "s/SELINUX=.*/SELINUX=disabled/g" /etc/selinux/config
```

### 配置 SSH 服务优化

#### 禁用不必要的 SSH 功能

**不解析IP地址**

```
sed -i -e 's/#UseDNS yes/UseDNS no/g' \
    -e 's/GSSAPIAuthentication yes/GSSAPIAuthentication no/g' \
    /etc/ssh/sshd_config
```

**取消主机公钥确认**

```
sed -i 's/#   StrictHostKeyChecking ask/   StrictHostKeyChecking no/g' /etc/ssh/ssh_config
```

**重启服务**

```
systemctl restart sshd
```

#### 配置免密登录

生成秘钥

```
ssh-keygen -t rsa -P "" -f ~/.ssh/id_rsa -C "2385569970@qq.com"
cat ~/.ssh/id_rsa.pub > ~/.ssh/authorized_keys
```

将秘钥分发到其他节点

```
scp -r ~/.ssh service01:~
scp -r ~/.ssh service02:~
scp -r ~/.ssh service03:~
```



## 时间与时区配置

### 设置时区

```
timedatectl set-timezone Asia/Shanghai
clock -w
timedatectl set-local-rtc 1
```

### 同步时间

```
sed -i "/^server/d" /etc/chrony.conf
sed -i "3i server ntp.aliyun.com iburst" /etc/chrony.conf
systemctl restart chronyd
chronyc sources
```



## 存储管理

### parted 分区

```
parted /dev/sdb mklabel gpt
parted /dev/sdb mkpart part1 0% 20%
parted /dev/sdb mkpart part2 20% 100%
partprobe /dev/sdb
lsblk /dev/sdb
```

### 创建 LVM（逻辑卷管理）

```
yum install lvm2 -y
pvcreate -f /dev/sdb
vgcreate volumes /dev/sdb
lvcreate -l 100%FREE -n data volumes
```

### 挂载与开机自动挂载

**格式化并挂载**

```
mkfs.xfs -f /dev/volumes01/data01
mount /dev/volumes01/data01 /mnt
df -hT /mnt
```

**开机自动挂载**

```
cat >> /etc/fstab <<EOF
/dev/volumes01/data01 /mnt xfs defaults,nofail 0 0
EOF
```



## 性能与系统优化

### 配置内核参数

```
cat >> /etc/sysctl.d/99-service.conf <<EOF
vm.max_map_count = 2621440
fs.file-max = 655360
vm.swappiness = 0
EOF
sysctl -f /etc/sysctl.d/99-service.conf
```

### 关闭透明大页

```
echo never > /sys/kernel/mm/transparent_hugepage/enabled
echo never > /sys/kernel/mm/transparent_hugepage/defrag
```

### 关闭 Swap 分区

```
swapoff -a && sysctl -w vm.swappiness=0
sed -ri '/^[^#]*swap/s@^@#@' /etc/fstab
```

### 配置文件限制（Limits）

**设置 `limits.conf`**

```
cat > /etc/security/limits.d/99-service.conf <<EOF 
admin soft nofile 655360
admin hard nofile 655360
admin soft nproc 163840
admin hard nproc 163840
admin soft core 0
admin hard core 0
EOF
```

**设置 `system.conf`**

修改 `system.conf` 后需要重启系统

```
cat >> /etc/systemd/system.conf <<EOF
[Manager]
DefaultLimitNOFILE=655360
DefaultLimitNPROC=163840
DefaultLimitCORE=0
EOF
```



## 日志服务配置

### 配置 journald 服务

journald 是 systemd 管理的系统日志服务，用于收集、存储和管理系统的日志信息。它负责记录系统的各种事件、错误和消息，以便系统管理员进行故障排除和监控。

```
mkdir -p /var/log/journal /etc/systemd/journald.conf.d
cat << EOF > /etc/systemd/journald.conf.d/99-prophet.conf
[Journal]
Storage=persistent
Compress=yes
SyncIntervalSec=5m
RateLimitInterval=30s
RateLimitBurst=10000
SystemMaxUse=10G
SystemMaxFileSize=500M
MaxRetentionSec=100d
ForwardToSyslog=no
EOF
systemctl restart systemd-journald
```

配置说明

- **Storage=persistent**: 将日志持久化保存到磁盘。
- **Compress=yes**: 启用日志压缩功能。
- **SyncIntervalSec=5m**: 日志同步到磁盘的间隔时间为 5 分钟。
- **RateLimitInterval=30s**: 日志速率限制的时间间隔为 30 秒。
- **RateLimitBurst=10000**: 在 RateLimitInterval 时间内最多记录 10000 条日志。
- **SystemMaxUse=10G**: 限制日志的最大磁盘占用为 10 GB。
- **SystemMaxFileSize=500M**: 单个日志文件的最大大小为 500 MB。
- **MaxRetentionSec=100d**: 日志的保留时间为 100 天。
- **ForwardToSyslog=no**: 不将日志转发到 syslog。



## 用户与权限管理

### 创建服务用户与组

```
groupadd -g 1001 ateng
useradd -u 1001 -g ateng -m -s /bin/bash admin
echo Admin@123 | passwd --stdin admin
```

### 配置目录权限

```
mkdir -p /usr/local/software /data/service
chown admin:ateng /usr/local/software /data/service
chmod 755 /data
```

### 配置 sudo 权限

用户 "admin" 可以以任何用户身份，在任何主机上执行任何命令，并且在执行 sudo 命令时无需输入密码

```
echo "admin ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/ateng-admin
chmod 440 /etc/sudoers.d/ateng-admin
```



## 软件安装与配置

### 基础工具安装

```
sudo yum -y install net-tools rsync tar bash-completion
```

### 命令自动补全

```
source /usr/share/bash-completion/bash_completion
```

