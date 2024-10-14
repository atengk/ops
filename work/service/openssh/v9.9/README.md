# OpenSSL+OpenSSH 编译安装指南

本文档已使用**OpenEuler24.03**、**CentOS7.9**完成安装。

## Telnet登录

在开始操作前，开启telnet登录，以防升级OpenSSH失败，可以通过telnet回退，升级成功后可以将telnet关闭。当然也可以跳过这一步，这只是为了保险起见。

使用root用户完成以下操作：

### 1. 添加sudo用户

如果已经有了sudo用户可以跳过该步骤

```
groupadd admin
useradd -m -G admin kongyu
echo "Admin@123" | passwd --stdin kongyu
cat >> /etc/sudoers <<"EOF"
kongyu ALL=(ALL) NOPASSWD: ALL
EOF
```

### 2. 安装并启动telnet

```
yum -y install telnet-server
systemctl enable --now telnet.socket
```

### 3. 关闭防火墙和selinux

```
setenforce 0
sed -i "s/SELINUX=.*/SELINUX=disabled/g" /etc/selinux/config
systemctl stop firewalld
systemctl disable firewalld
```

### 4. 使用telnet登录系统

telnet登录，使用特权kongyu用户

```
telnet 192.168.1.201 23
```

成功升级完OpenSSH后可以将telnet服务关闭

```
systemctl disable --now telnet.socket
```



## OpenSSL

如果操作系统的openssl>=1.1.1（`openssl version`）就不要再安装了，因为OpenSSH需要OpenSSL>=1.1.1，再者升级OpenSSL是有风险的，会影响操作系统的库依赖，谨慎操作！

### 1. 安装依赖包

首先，确保系统中安装了必要的依赖包：

```bash
sudo yum install -y gcc make libtool zlib-devel wget
sudo yum install -y perl-IPC-Cmd  # CentOS7中需要安装 Perl 模块
```

### 2. 下载并解压 OpenSSL 源码

从 OpenSSL 官方 GitHub 仓库下载所需版本的源码，并解压缩：

```bash
wget https://github.com/openssl/openssl/releases/download/openssl-3.3.1/openssl-3.3.1.tar.gz
tar -zxvf openssl-3.3.1.tar.gz
cd openssl-3.3.1
```

### 3. 创建构建目录

为编译创建单独的构建目录：

```bash
mkdir build
cd build
```

### 4. 配置编译选项

配置 OpenSSL 的编译选项并指定安装路径：

```bash
../config --prefix=/usr/local/software/openssl shared zlib
```

- `--prefix=/usr/local/software/openssl`: 指定安装路径为 `/usr/local/software/openssl`。
- `shared`: 生成共享库。
- `zlib`: 对 zlib 压缩库的支持。

### 5. 编译 OpenSSL

使用多线程进行编译：

```bash
make -j$(nproc)
```

### 6. 安装 OpenSSL

编译完成后，安装 OpenSSL：

```bash
sudo make install
```

### 7. 配置动态链接库路径

将 OpenSSL 的库文件路径添加到系统的动态链接库配置文件中，并重新加载配置：

```bash
echo "/usr/local/software/openssl/lib64" | sudo tee -a /etc/ld.so.conf.d/openssl.conf
sudo ldconfig
```

### 8. 替换OpenSSL

```
sudo mv /usr/bin/openssl{,_bak}
sudo ln -s /usr/local/software/openssl/bin/openssl /usr/bin/openssl
```

### 9. 验证安装

验证 OpenSSL 是否成功安装：

```bash
openssl version
```

输出：OpenSSL 3.3.1 4 Jun 2024 (Library: OpenSSL 3.3.1 4 Jun 2024)



## OpenSSH

### 1. 安装依赖包

首先，安装编译 OpenSSH 所需的依赖包。执行以下命令：

```bash
sudo yum install -y gcc make zlib-devel openssl-devel pam-devel libselinux-devel krb5-devel wget
```

### 2. 下载并解压 OpenSSL 源码

下载完成后，解压源码包：

```bash
wget https://cdn.openbsd.org/pub/OpenBSD/OpenSSH/portable/openssh-9.9p1.tar.gz
tar -zxvf openssh-9.9p1.tar.gz
cd openssh-9.9p1/
```

### 3. 创建并进入编译目录

在源码目录中创建一个名为 `build` 的目录，并进入该目录：

```bash
mkdir build
cd build
```

### 4. 配置编译选项

使用以下命令配置编译选项：

```bash
../configure --prefix=/usr/local/software/openssh --with-pam --with-selinux --with-kerberos5 --with-zlib
```

- 如果手动安装了openssl，需要指定路径：`--with-ssl-dir=/usr/local/software/openssl`

- `--prefix=/usr/local/software/openssh`：指定 OpenSSH 的安装目录为 `/usr/local/software/openssh`。
- `--with-pam`：启用 PAM（Pluggable Authentication Modules）支持，用于身份验证。
- `--with-selinux`：启用 SELinux（Security-Enhanced Linux）支持，增强系统安全性。
- `--with-kerberos5`：启用 Kerberos 5 支持，用于网络身份验证。
- `--with-zlib`：启用 zlib 库支持，用于压缩传输数据。

### 5. 编译 OpenSSH

配置完成后，使用 `make` 命令编译 OpenSSH：

```bash
make -j$(nproc)
```

### 6. 安装 OpenSSH

编译完成后，使用以下命令安装 OpenSSH：

```bash
sudo make install
```

### 7. 替换openssh文件

**替换sshd文件**

```
sudo mv /usr/sbin/sshd{,_bak}
sudo ln -s /usr/local/software/openssh/sbin/sshd /usr/sbin/sshd
```

**替换其他文件**（可选）

替换bin

```
sudo mv /usr/bin/scp{,_bak}
sudo ln -s /usr/local/software/openssh/bin/scp /usr/bin/scp
sudo mv /usr/bin/sftp{,_bak}
sudo ln -s /usr/local/software/openssh/bin/sftp /usr/bin/sftp
sudo mv /usr/bin/ssh{,_bak}
sudo ln -s /usr/local/software/openssh/bin/ssh /usr/bin/ssh
sudo mv /usr/bin/ssh-add{,_bak}
sudo ln -s /usr/local/software/openssh/bin/ssh-add /usr/bin/ssh-add
sudo mv /usr/bin/ssh-agent{,_bak}
sudo ln -s /usr/local/software/openssh/bin/ssh-agent /usr/bin/ssh-agent
sudo mv /usr/bin/ssh-keygen{,_bak}
sudo ln -s /usr/local/software/openssh/bin/ssh-keygen /usr/bin/ssh-keygen
sudo mv /usr/bin/ssh-keyscan{,_bak}
sudo ln -s /usr/local/software/openssh/bin/ssh-keyscan /usr/bin/ssh-keyscan
```

替换libexec

```
sudo mv /usr/libexec/openssh{,_bak}
sudo ln -s /usr/local/software/openssh/libexec /usr/libexec/openssh
```

### 8. 验证配置文件

安装完成后，使用以下命令验证 SSH 配置文件的正确性，如有错误按照提示修改

```bash
sudo sshd -t -f /etc/ssh/sshd_config
sudo grep -E -v "^$|^#" /etc/ssh/sshd_config
```

CentOS7.9解决秘钥权限问题

```
sudo chmod 400 /etc/ssh/ssh_host_*
```

OpenEuler24.03解决无效参数问题

```
sudo sed -i '/^GSSAPIKexAlgorithms/s/^/#/' /etc/ssh/sshd_config
```

### 9. 重启 SSH 服务

修改sshd.service指定配置文件

```
sudo vi +10 /usr/lib/systemd/system/sshd.service
```

修改ExecStart

```
ExecStart=/usr/sbin/sshd -f /etc/ssh/sshd_config -D $OPTIONS
```

最后，重启 SSH 服务以应用新的安装：

```bash
sudo systemctl daemon-reload
sudo systemctl restart sshd
```

如果没有关闭SELinux是无法登录的，需要关闭它

```
sudo setenforce 0
```

### 10. 生成秘钥

生成秘钥，然后拷贝到其他节点，实现免密登录

```
ssh-keygen -t rsa -P "" -f ~/.ssh/id_rsa -C "2385569970@qq.com"
cat ~/.ssh/id_rsa.pub > ~/.ssh/authorized_keys
scp -r ~/.ssh 192.168.1.102:~
```

