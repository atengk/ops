# VSFTP

vsftp（Very Secure FTP）是一个轻量、高效、安全的FTP服务器，常用于Linux系统下的文件传输服务，支持多种配置和安全特性。
 官网链接：[vsftpd](https://security.appspot.com/vsftpd.html)

------

## 一、服务安装

### 1. 安装vsftp

```bash
sudo yum -y install vsftpd
```

通过`yum`安装vsftp服务。

------

### 2. 备份配置文件

```bash
sudo cp /etc/vsftpd/vsftpd.conf{,_bak}
```

备份配置文件，避免因修改错误导致不可用。

------

### 3. 启动并设置开机自启

```bash
sudo systemctl enable --now vsftpd
```

启动vsftp服务并设置为开机自启。

------

## 二、服务配置

以下几种模式选其中一种配置

### 1. 本地用户配置

#### (1) 修改配置文件

编辑`/etc/vsftpd/vsftpd.conf`，添加以下内容：

```shell
sudo tee /etc/vsftpd/vsftpd.conf <<"EOF"
write_enable=YES
anonymous_enable=NO
local_enable=YES
local_root=/data/service/vsftp
chroot_local_user=YES
local_umask=022
pam_service_name=vsftpd
EOF
```

**说明：**

- `write_enable=YES`：允许用户进行写操作。
- `anonymous_enable=NO`：禁止匿名用户登录。
- `local_enable=YES`：允许本地用户登录。
- `local_root=/data/service/vsftp`：设置本地用户的主目录为`/data/service/vsftp`。
- `chroot_local_user=YES`：锁定本地用户的活动范围在其主目录内。
- `local_umask=022`：设置文件上传后的权限掩码为`022`（新文件权限为`755`）。
- `pam_service_name=vsftpd`：指定使用默认的PAM认证服务。

------

#### (2) 创建数据目录

```bash
mkdir -p /data/service/vsftp/public
chmod 777 /data/service/vsftp/public
```

**说明：**

- `/data/service/vsftp/public`：创建公共目录，用于存放可供所有用户访问的数据。
- `chmod 777`：设置公共目录的权限为`777`，确保所有用户均可读写该目录。

------

#### (3) 创建用户组

```bash
sudo groupadd ftp
sudo mkdir -p /data/service/vsftp/ftp
sudo chown :ftp /data/service/vsftp/ftp
sudo chmod 770 /data/service/vsftp/ftp
```

**说明：**

- `groupadd ftp`：创建用户组`ftp`，用于管理FTP用户。
- `mkdir -p /data/service/vsftp/ftp`：创建FTP的基础目录。
- `chown :ftp /data/service/vsftp/ftp`：将目录的组所有权更改为`ftp`组。
- `chmod 770 /data/service/vsftp/ftp`：限制目录权限，仅允许目录的所有者和组用户访问。

------

#### (4) 创建本地用户

```bash
sudo useradd -g ftp -m ftp_user01
echo "000000" | sudo passwd --stdin ftp_user01
sudo mkdir -p /data/service/vsftp/ftp/ftp_user01
sudo chown ftp_user01:ftp /data/service/vsftp/ftp/ftp_user01
sudo chmod 700 /data/service/vsftp/ftp/ftp_user01
```

**说明：**

- `useradd -g ftp -m ftp_user01`：创建用户`ftp_user01`，主组为`ftp`。
- `passwd --stdin ftp_user01`：通过管道设置用户密码为`000000`（仅适用于支持此选项的系统）。
- `mkdir -p /data/service/vsftp/ftp/ftp_user01`：为用户创建独立的FTP数据目录。
- `chown ftp_user01:ftp /data/service/vsftp/ftp/ftp_user01`：设置目录所有权归用户`ftp_user01`，组为`ftp`。
- `chmod 700 /data/service/vsftp/ftp/ftp_user01`：仅允许用户自身访问其数据目录。

------

#### (5) 重启vsftp服务

```bash
sudo systemctl restart vsftpd
```

重启vsftp服务以应用新的配置。

------

### 2. 匿名用户配置

#### (1) 修改配置文件

编辑`/etc/vsftpd/vsftpd.conf`，添加以下内容：

```shell
sudo tee /etc/vsftpd/vsftpd.conf <<"EOF"
write_enable=YES
anonymous_enable=YES
anon_root=/data/service/vsftp
anon_upload_enable=YES
anon_world_readable_only=YES
anon_mkdir_write_enable=YES
anon_other_write_enable=YES
anon_umask=022
EOF
```

**说明：**

- `write_enable=YES`：允许写操作。
- `anonymous_enable=YES`：允许匿名用户登录。
- `anon_root=/data/service/vsftp`：设置匿名用户的登录目录为`/data/service/vsftp`。
- `anon_upload_enable=YES`：允许匿名用户上传文件。
- `anon_world_readable_only=YES`：仅允许匿名用户下载可读文件。
- `anon_mkdir_write_enable=YES`：允许匿名用户创建目录。
- `anon_other_write_enable=YES`：允许匿名用户删除和重命名文件。
- `anon_umask=022`：设置文件上传后的权限掩码为`022`。

------

#### (2) 创建数据目录

```bash
mkdir -p /data/service/vsftp/public
chmod 777 /data/service/vsftp/public
```

**说明：**

- `/data/service/vsftp/public`：公共目录，用于匿名用户上传和下载文件。
- `chmod 777`：确保匿名用户具有读写权限。

------

#### (3) 重启vsftp服务

```bash
sudo systemctl restart vsftpd
```

重启服务以应用新配置。

------

### 3. 虚拟用户配置

#### (1) 创建虚拟用户文件

```bash
echo -e "user01\n000000\nuser02\n000000" | sudo tee /etc/vsftpd/virtual_users.txt
```

**说明：**

- `user01`和`user02`：虚拟用户账号。
- `000000`：对应的密码。
- 以账号和密码交替排列。

------

#### (2) 生成数据库认证文件

**安装软件包**

```
sudo yum install libdb-utils -y
```

**生成认证文件**

```bash
sudo db_load -T -t hash -f /etc/vsftpd/virtual_users.txt /etc/vsftpd/virtual_users.db
sudo chmod 700 /etc/vsftpd/virtual_users.db
```

**说明：**

- 使用`db_load`生成数据库文件`/etc/vsftpd/virtual_users.db`。
- 设置数据库文件权限为`700`，提高安全性。

------

#### (3) 配置PAM认证文件

编辑`/etc/pam.d/vsftpd_virtual`，添加以下内容：

```shell
sudo tee /etc/pam.d/vsftpd_virtual <<EOF
auth required pam_userdb.so db=/etc/vsftpd/virtual_users
account required pam_userdb.so db=/etc/vsftpd/virtual_users
EOF
```

**说明：**

- 使用PAM模块`pam_userdb`进行认证，指定数据库路径为`/etc/vsftpd/virtual_users`。

------

#### (4) 修改vsftp配置

编辑`/etc/vsftpd/vsftpd.conf`，添加以下内容：

```shell
sudo tee /etc/vsftpd/vsftpd.conf <<EOF
anonymous_enable=NO
local_enable=YES
chroot_local_user=YES
pam_service_name=vsftpd_virtual
virtual_use_local_privs=YES
guest_enable=YES
guest_username=ftp
user_config_dir=/etc/vsftpd/user_conf
EOF
```

**说明：**

- `guest_enable=YES`：启用虚拟用户支持。
- `guest_username=ftp`：将虚拟用户映射到本地用户`ftp`。
- `user_config_dir=/etc/vsftpd/user_conf`：指定不同虚拟用户的独立配置文件目录。

------

#### (5) 配置虚拟用户独立目录

```bash
sudo mkdir -p /etc/vsftpd/user_conf
echo -e "write_enable=YES\nlocal_root=/data/service/vsftp/user01\nlocal_umask=022" | sudo tee /etc/vsftpd/user_conf/user01
echo -e "write_enable=YES\nlocal_root=/data/service/vsftp/user02\nlocal_umask=022" | sudo tee /etc/vsftpd/user_conf/user02
```

**说明：**

- 为每个虚拟用户设置独立的登录目录和权限配置。

#### (6) 创建虚拟用户的数据目录

```bash
sudo mkdir -p /data/service/vsftp/user01/data
sudo mkdir -p /data/service/vsftp/user02/data
sudo chown ftp:ftp /data/service/vsftp/user01/data
sudo chown ftp:ftp /data/service/vsftp/user02/data
```

**说明：**

- `/data/service/vsftp/user01/data`和`/data/service/vsftp/user02/data`分别为虚拟用户`user01`和`user02`的数据目录。
- 使用`chown ftp:ftp`将目录的所有权设置为`ftp`用户和组，以支持虚拟用户映射。

------

#### (7) 重启vsftp服务

```bash
sudo systemctl restart vsftpd
```

重启vsftp服务，确保所有配置生效。

------

## 三、客户端使用

### 1. Linux客户端操作

#### (1) 安装FTP客户端

```bash
sudo yum -y install ftp
```

安装FTP命令行客户端工具。

------

#### (2) 登录FTP服务器

```bash
ftp 192.168.1.114
```

**说明：**

- 对于匿名用户：使用账号`ftp`或`anonymous`，无需密码即可登录。
- 对于本地用户：使用`ftp_user01`账号和密码`000000`登录。
- 对于虚拟用户：使用`user01`或`user02`和对应的密码`000000`登录。

------

#### (3) 查看目录

```bash
ftp> dir
```

列出当前目录下的所有文件和文件夹。

------

#### (4) 创建目录

```bash
ftp> mkdir /data/test
```

在FTP服务器上创建`/data/test`目录。

------

#### (5) 上传文件

```bash
ftp> cd /data/test
ftp> put 1.txt
ftp> ls
```

**说明：**

- 使用`put`命令上传本地文件`1.txt`到FTP服务器上的`/data/test`目录中。
- 使用`ls`命令查看已上传的文件。

------

### 2. Linux挂载FTP为本地目录

#### (1) 安装挂载工具

```bash
yum -y install curlftpfs
```

安装`curlftpfs`工具，用于将FTP服务器挂载为本地目录。

------

#### (2) 挂载FTP目录

```bash
curlftpfs -o rw,allow_other,uid=0,gid=0 ftp://user01:000000@192.168.1.201 /mnt
```

**说明：**

- 使用`curlftpfs`将FTP服务器挂载到本地的`/mnt`目录。
- `rw,allow_other`选项允许其他用户访问挂载目录。
- `uid=0,gid=0`确保挂载后的目录归属`root`用户。

------

#### (3) 查看挂载情况

```bash
df -hT /mnt
```

**说明：**

- 使用`df`命令查看`/mnt`挂载目录的空间使用情况及挂载信息。

------

#### (4) 开机自动挂载

```bash
echo "curlftpfs#user01:000000@192.168.1.201 /mnt fuse allow_other,uid=0,gid=0 0 0" >> /etc/fstab
```

**说明：**

- 将挂载命令添加到`/etc/fstab`中，系统启动时会自动挂载FTP目录。

------

#### (5) 取消挂载

```bash
fusermount -u /mnt || umount /mnt
```

**说明：**

- 使用`fusermount -u`或`umount`命令卸载`/mnt`目录。

## 四、云服务器安装 FTP 及主动模式与被动模式的注意事项

------

### 1. 云服务器安装 FTP 的情况与注意事项

在云服务器上安装和使用 FTP 服务，需要特别注意网络配置、安全设置以及性能优化。

#### （1）开放必要端口

FTP 服务需要以下端口通信：

- **控制端口**：21（FTP 客户端与服务器的控制连接）。
- **数据端口**：根据模式不同，主动模式使用端口 20，被动模式使用一组动态端口（需手动指定）。

**注意事项：**

- 确保云服务商安全组规则中，开放所需的端口。

- 配置文件中明确指定被动模式端口范围：

    ```plaintext
    pasv_min_port=30000
    pasv_max_port=31000
    ```

- 在本地防火墙中开放这些端口：

    ```bash
    sudo firewall-cmd --add-port=21/tcp --permanent
    sudo firewall-cmd --add-port=30000-31000/tcp --permanent
    sudo firewall-cmd --reload
    ```

#### （2）配置公网 IP 地址

FTP 的被动模式需要向客户端提供服务器的公网 IP 地址。如果没有正确配置，客户端可能无法建立数据连接。

**解决方案：**

- 在 

    ```
    /etc/vsftpd/vsftpd.conf
    ```

     中设置服务器的公网 IP 地址：

    ```plaintext
    pasv_address=<服务器公网IP>
    pasv_addr_resolve=YES
    ```

- 如果使用域名访问，也可以设置为域名。

#### （3）启用 TLS 加密

FTP 默认是明文传输，云服务器环境中存在泄露敏感数据的风险，建议启用 TLS/SSL 加密。

**配置方法：**

1. 生成自签名证书：

    ```bash
    sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/vsftpd/vsftpd.pem -out /etc/vsftpd/vsftpd.pem
    ```

2. 修改 

    ```
    /etc/vsftpd/vsftpd.conf
    ```

     启用 TLS：

    ```plaintext
    ssl_enable=YES
    allow_anon_ssl=NO
    force_local_data_ssl=YES
    force_local_logins_ssl=YES
    rsa_cert_file=/etc/vsftpd/vsftpd.pem
    ```

3. 重启服务：

    ```bash
    sudo systemctl restart vsftpd
    ```

#### （4）性能优化

- 调整 FTP 的超时配置以提升性能：

    ```plaintext
    idle_session_timeout=600
    data_connection_timeout=120
    ```

- 选择更高性能的云主机和磁盘配置以支持大量文件传输。

------

### 2. 主动模式与被动模式的注意事项

#### （1）主动模式（Active Mode）

在主动模式下：

- 客户端通过端口 21 与服务器建立控制连接。
- 服务器从端口 20 发起数据连接至客户端的随机端口。

**注意事项：**

- 如果客户端位于 NAT 网络（如家庭网络），随机端口可能无法通过路由映射到客户端。
- 云服务器通常不推荐使用主动模式，因为对客户端的回连可能被防火墙或安全组规则阻挡。

**解决方案：**

- 配置服务器防火墙允许端口 20 的出站连接：

    ```bash
    sudo firewall-cmd --add-port=20/tcp --permanent
    sudo firewall-cmd --reload
    ```

- 在客户端配置明确允许主动模式，并设置适当的端口映射。

------

#### （2）被动模式（Passive Mode）

在被动模式下：

- 客户端通过端口 21 与服务器建立控制连接。
- 服务器在被动模式下会选择一组动态端口，与客户端建立数据连接。

**注意事项：**

- 被动模式对客户端更友好，但需要配置服务器明确的端口范围。
- 如果未配置公网 IP 地址，客户端可能接收错误的内部 IP。

**解决方案：**

1. 在 

    ```
    /etc/vsftpd/vsftpd.conf
    ```

     中配置端口范围：

    ```plaintext
    pasv_min_port=30000
    pasv_max_port=31000
    ```

2. 在云服务器防火墙和安全组中开放这些端口：

    ```bash
    sudo firewall-cmd --add-port=30000-31000/tcp --permanent
    sudo firewall-cmd --reload
    ```

3. 配置公网 IP 地址或域名：

    ```plaintext
    pasv_address=<服务器公网IP>
    pasv_addr_resolve=YES
    ```

------

#### （3）总结对比

| 模式     | 数据传输方式               | 优点               | 缺点                                  |
| -------- | -------------------------- | ------------------ | ------------------------------------- |
| 主动模式 | 服务器主动连接客户端的端口 | 服务器配置简单     | 客户端位于 NAT 时可能无法通信         |
| 被动模式 | 客户端主动连接服务器的端口 | 兼容性好，推荐使用 | 需要配置服务器的动态端口范围和公网 IP |

**推荐**：在云服务器环境中，优先使用 **被动模式**，并确保配置端口范围和公网 IP 地址。
