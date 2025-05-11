# NFS

NFS（Network File System）是Linux系统中的网络文件系统协议，允许不同主机之间通过网络共享文件，像本地磁盘一样访问远程文件系统。它基于客户端-服务器架构，广泛用于局域网数据共享。

- [官网链接](https://nfs.sourceforge.net/)



## 快速安装使用

### 服务端

**安装服务**

Debian/Ubuntu:

```
sudo apt update
sudo apt install -y nfs-kernel-server
```

CentOS/RHEL:

```bash
sudo yum install -y nfs-utils
```

**创建共享目录**

```
sudo mkdir -p /data/service/nfs
sudo chown nobody:nobody /data/service/nfs
```

**编辑配置文件**

```
sudo tee -a /etc/exports <<"EOF"
/data/service/nfs *(rw,sync,no_subtree_check)
EOF
```

**应用配置并启动服务**

```
sudo exportfs -a
sudo systemctl enable --now nfs-server
```

**查看共享信息**

```
sudo exportfs -v
```

### 客户端

**安装客户端工具**

Ubuntu/Debian：

```
sudo apt install -y nfs-common
```

CentOS/RHEL：

```
sudo yum install -y nfs-utils
```

**查看服务端信息**

```
showmount -e service01
```

输出以下内容：

```
Export list for service01:
/data/service/nfs *
```

**创建挂载点并挂载**

```
sudo mkdir -p /mnt/nfs
sudo mount service01:/data/service/nfs /mnt/nfs
```

**查看挂载**

```
df -hT /mnt/nfs/
```

输出以下内容：

```
Filesystem                  Type  Size  Used Avail Use% Mounted on
service01:/data/service/nfs nfs4   38G  4.7G   31G  14% /mnt/nfs
```

**设置开机自动挂载**

```
sudo tee -a /etc/fstab <<"EOF"
service01:/data/service/nfs /mnt/nfs nfs defaults 0 0
EOF
```



## NFS 配置文件示例

### 1️⃣ 基本格式说明

每一行定义一个共享目录及其访问权限：

```
<共享目录>  <客户端>(<选项列表>)
```

示例：

```
/data/share  192.168.1.0/24(rw,sync,no_subtree_check)
```

------

### 2️⃣ 常用导出选项说明

| 选项                  | 说明                                      |
| --------------------- | ----------------------------------------- |
| `rw` / `ro`           | 允许读写 / 只读访问                       |
| `sync` / `async`      | 同步 / 异步写入（建议使用 `sync` 更安全） |
| `no_subtree_check`    | 禁用子目录检查，提升性能                  |
| `root_squash`         | 默认：客户端 root 被映射为匿名用户，安全  |
| `no_root_squash`      | 客户端 root 拥有真实权限（风险高）        |
| `all_squash`          | 所有用户都映射为匿名用户                  |
| `anonuid` / `anongid` | 指定匿名用户 UID/GID                      |
| `secure` / `insecure` | 是否要求客户端使用特权端口                |
| `crossmnt`            | 允许共享嵌套挂载的目录                    |
| `fsid=0`              | 指定为 NFSv4 根目录                       |

------

### 3️⃣ 配置示例

------

#### 🟩 示例 1：基本读写共享（适用于内网环境）

```
/data/public  192.168.1.0/24(rw,sync,no_subtree_check)
```

- 向整个内网开放读写权限
- 使用 `sync` 和 `no_subtree_check` 保证数据一致性和性能

------

#### 🟦 示例 2：只读共享，适合共享网站资源等

```
/var/www  192.168.1.100(ro,sync,no_subtree_check)
```

- 限制指定主机只读访问，防止数据被修改

------

#### 🟨 示例 3：匿名访问共享（映射到特定用户）

```
/data/anon  *(rw,sync,no_subtree_check,all_squash,anonuid=1001,anongid=1001)
```

- 所有客户端都以 UID/GID 为 1001 的用户访问该目录
- 适合开放数据但希望服务端控制权限的场景

------

#### 🟥 示例 4：多个客户端权限不同

```
/opt/dev  192.168.1.101(rw,sync) 192.168.1.102(ro,sync)
```

- 指定每个客户端不同的访问权限

------

#### 🟧 示例 5：NFSv4 根导出配置（必须设置 fsid=0）

```
/export  192.168.1.0/24(rw,sync,fsid=0,no_subtree_check)
```

- NFSv4 客户端需从该导出点挂载作为虚拟根目录

------

#### 🟫 示例 6：跨挂载点导出（子目录是挂载点）

```
/data  192.168.1.0/24(rw,sync,no_subtree_check,crossmnt)
```

- 如果 `/data` 下有额外挂载的目录（如挂载了磁盘），必须加 `crossmnt`

------

#### ⚠️ 示例 7：使用特权端口限制客户端连接

```
/secure  192.168.1.200(rw,sync,secure,root_squash)
```

- 强制客户端使用 1024 以下端口（默认更安全）

------

#### 🚫 示例 8：允许不安全端口（不推荐）

```
/test/share  192.168.1.150(rw,insecure,sync)
```

- 允许客户端使用高位端口连接，仅限特殊用途

------

### 4️⃣ 配置后操作

```bash
# 使配置生效
sudo exportfs -ra

# 查看当前导出状态（包含详细信息）
exportfs -v
```

------

### 5️⃣ 客户端挂载示例

```bash
# 创建挂载点
sudo mkdir -p /mnt/nfs

# 挂载 NFS 目录
sudo mount -t nfs 192.168.1.10:/data/public /mnt/nfs
```

如使用 NFSv4，根导出应挂载 `/export`，如：

```bash
sudo mount -t nfs4 192.168.1.10:/ /mnt/nfs
```

