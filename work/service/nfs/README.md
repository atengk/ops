# 安装使用 NFS

## 1. 安装 NFS 服务
首先，确保系统已更新，然后安装 NFS 服务相关的软件包。

```bash
sudo yum update -y
sudo yum install -y nfs-utils
```

## 2. 配置 NFS 服务
编辑 `/etc/exports` 文件，指定要共享的目录及其访问权限。

例如，要共享 `/data/service/nfs` 目录，添加以下行到 `/etc/exports` 文件：

```bash
sudo tee -a /etc/exports <<"EOF"
/data/service/nfs 192.168.1.0/24(rw,sync,no_root_squash,no_subtree_check) 
EOF
sudo mkdir -p /data/service/nfs
```

- `192.168.1.0/24`: 指定允许访问的网络或 IP 地址。
- `rw`: 允许读写权限。
- `sync`: 在完成数据写入磁盘后再返回客户端的写入完成信号。
- `no_root_squash`: 保持客户端 root 用户权限。
- `no_subtree_check`: 禁用子目录检查，提高性能。

保存并关闭文件。

## 3. 启动并启用 NFS 服务
启动 NFS 服务并设置开机自启：

```bash
sudo systemctl start nfs-server
sudo systemctl enable nfs-server
```

## 4. 导出 NFS 共享
运行以下命令以导出 NFS 共享：

```bash
sudo exportfs -r
```

可以使用以下命令查看已导出的共享目录：

```bash
sudo exportfs -v
```

## 5. 配置防火墙
确保防火墙允许 NFS 服务的流量。可以使用以下命令打开防火墙的相应端口：

```bash
sudo firewall-cmd --permanent --add-service=nfs
sudo firewall-cmd --permanent --add-service=mountd
sudo firewall-cmd --permanent --add-service=rpc-bind
sudo firewall-cmd --reload
```

## 6. 挂载 NFS 共享（客户端操作）
在需要访问 NFS 共享的客户端机器上，安装 `nfs-utils`：

```bash
sudo yum install -y nfs-utils
```

然后，创建一个挂载点并挂载 NFS 共享：

```bash
sudo mkdir -p /mnt/nfs_share
sudo mount -t nfs 192.168.1.100:/data/service/nfs /mnt/nfs_share
```

- `192.168.1.100`：NFS 服务器的 IP 地址。
- `/data/service/nfs`：服务器上共享的目录路径。
- `/mnt/nfs_share`：客户端上挂载的目录。

## 7. 设置自动挂载
要在客户端机器上设置开机自动挂载，可以在 `/etc/fstab` 文件中添加以下行：

```bash
192.168.1.100:/data/service/nfs /mnt/nfs_share nfs defaults 0 0
```

## 8. 验证挂载
使用 `df -h` 或 `mount | grep nfs` 命令验证是否成功挂载。

## 注意事项
- 在 Red Hat 系列系统中，SELinux 默认启用，可能会影响 NFS 的工作。如果遇到权限问题，可以尝试调整 SELinux 配置，或临时将其置于宽松模式。
- 可以使用 `showmount -e 192.168.1.100` 来查看 NFS 服务器上导出的共享目录。

这样，你就成功在 Red Hat 系列系统上安装和配置了 NFS 服务，并在客户端上访问共享目录。