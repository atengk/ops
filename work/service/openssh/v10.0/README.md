# OpenSSL+OpenSSH 编译安装

本文档已通过 **OpenEuler24.03**、**CentOS7.9 ** 完成编译安装。

## 配置Telnet登录

在开始操作前，开启telnet登录，以防升级OpenSSH失败，可以通过telnet回退，升级成功后可以将telnet关闭。当然也可以跳过这一步，这只是为了保险起见。

**添加sudo用户**

如果已经有了sudo用户可以跳过该步骤

```bash
sudo groupadd admin
sudo useradd -m -G admin kongyu
echo "Admin@123" | sudo passwd --stdin kongyu
sudo tee -a /etc/sudoers <<"EOF"
kongyu ALL=(ALL) NOPASSWD: ALL
EOF
```

**安装并启动telnet**

```bash
sudo yum -y install telnet-server telnet
sudo systemctl enable --now telnet.socket
```

**配置防火墙策略**

如果操作系统没有开启防火墙则忽略这一步

```bash
sudo firewall-cmd --permanent --add-port=23/tcp
sudo firewall-cmd --reload
```

**使用telnet登录系统**

telnet登录，使用特权用户

```bash
telnet 192.168.116.128 23
```

后续的操作都使用root用户

```bash
sudo su -
```

**关闭telnet服务**

成功升级完OpenSSH后可以将telnet服务关闭

```bash
sudo systemctl disable --now telnet.socket
```



## 方案一：替换原有OpenSSL和OpenSSH

### OpenSSL

如果操作系统的openssl>=1.1.就不要再安装了，因为OpenSSH需要OpenSSL>=1.1.1，再者升级OpenSSL是有风险的，会影响操作系统的库依赖，谨慎操作！

查看版本

```
openssl version
```

#### 编译准备

**安装依赖包**

安装了必要的依赖包

```bash
yum install -y gcc make libtool zlib-devel wget
```

特定系统安装

- CentOS7

```bash
yum install -y perl-IPC-Cmd
```

**下载并解压源码**

从 OpenSSL 官方 GitHub 仓库下载所需版本的源码，并解压缩：

```bash
wget https://github.com/openssl/openssl/releases/download/openssl-3.5.0/openssl-3.5.0.tar.gz
tar -zxvf openssl-3.5.0.tar.gz
cd openssl-3.5.0
```

**创建构建目录**

为编译创建单独的构建目录：

```bash
mkdir build
cd build
```

#### 编译和安装

**配置编译选项**

配置 OpenSSL 的编译选项并指定安装路径：

```bash
../config \
    --prefix=/usr/local/software/openssl-3.5.0 \
    shared zlib
```

- `--prefix=xxx`: 指定安装路径。
- `shared`: 生成共享库。
- `zlib`: 对 zlib 压缩库的支持。

**编译**

使用多线程进行编译：

```bash
make -j$(nproc)
```

**安装**

编译完成后，安装 OpenSSL：

```bash
make install
ln -s /usr/local/software/openssl-3.5.0 /usr/local/software/openssl
```

#### 服务配置

**配置动态链接库路径**

将 OpenSSL 的库文件路径添加到系统的动态链接库配置文件中，并重新加载配置：

```bash
echo "/usr/local/software/openssl/lib64" | tee -a /etc/ld.so.conf.d/openssl.conf
ldconfig
```

**替换OpenSSL**

```bash
mv /usr/bin/openssl{,_$(date +%Y%m%d)}
ln -s /usr/local/software/openssl/bin/openssl /usr/bin/openssl
```

#### 查看服务

**验证安装**

验证 OpenSSL 是否成功安装：

```bash
openssl version
```

输出以下内容：

```
OpenSSL 3.5.0 8 Apr 2025 (Library: OpenSSL 3.5.0 8 Apr 2025)
```



### OpenSSH

#### 编译准备

**安装依赖包**

首先，安装编译 OpenSSH 所需的依赖包。执行以下命令：

```bash
yum install -y gcc make zlib-devel openssl-devel pam-devel libselinux-devel krb5-devel wget
```

**下载并解压源码**

下载完成后，解压源码包：

```bash
wget https://cdn.openbsd.org/pub/OpenBSD/OpenSSH/portable/openssh-10.0p1.tar.gz
tar -zxvf openssh-10.0p1.tar.gz
cd openssh-10.0p1/
```

**创建并进入编译目录**

在源码目录中创建一个名为 `build` 的目录，并进入该目录：

```bash
mkdir build
cd build
```

#### 编译和安装

**配置编译选项**

使用以下命令配置编译选项：

```bash
../configure \
    --prefix=/usr/local/software/openssh-10.0p1 \
    --with-pam \
    --with-selinux \
    --with-kerberos5 \
    --with-zlib \
    --with-md5-passwords
```

如果单独配置了openssl，需要指定路径

```bash
../configure \
    --prefix=/usr/local/software/openssh-10.0p1 \
    --with-ssl-dir=/usr/local/software/openssl \
    --with-pam \
    --with-selinux \
    --with-kerberos5 \
    --with-zlib \
    --with-md5-passwords
```

- `--prefix=xxx`：指定 OpenSSH 的安装目录。
- `--with-pam`：启用 PAM（Pluggable Authentication Modules）支持，用于身份验证。
- `--with-selinux`：启用 SELinux（Security-Enhanced Linux）支持，增强系统安全性。
- `--with-kerberos5`：启用 Kerberos 5 支持，用于网络身份验证。
- `--with-zlib`：启用 zlib 库支持，用于压缩传输数据。
- `--with-md5-passwords`：允许 OpenSSH 支持 MD5 加密格式的密码（$1$ 开头的 hash）

**编译**

配置完成后，使用 `make` 命令编译 OpenSSH：

```bash
make -j$(nproc)
```

**安装**

编译完成后，使用以下命令安装 OpenSSH：

```bash
make install
ln -s /usr/local/software/openssh-10.0p1 /usr/local/software/openssh
```

#### 替换文件

替换sshd文件

```bash
mv /usr/sbin/sshd{,_$(date +%Y%m%d)}
ln -s /usr/local/software/openssh/sbin/sshd /usr/sbin/sshd
```

替换bin

```bash
mv /usr/bin/scp{,_$(date +%Y%m%d)}
ln -s /usr/local/software/openssh/bin/scp /usr/bin/scp
mv /usr/bin/sftp{,_$(date +%Y%m%d)}
ln -s /usr/local/software/openssh/bin/sftp /usr/bin/sftp
mv /usr/bin/ssh{,_$(date +%Y%m%d)}
ln -s /usr/local/software/openssh/bin/ssh /usr/bin/ssh
mv /usr/bin/ssh-add{,_$(date +%Y%m%d)}
ln -s /usr/local/software/openssh/bin/ssh-add /usr/bin/ssh-add
mv /usr/bin/ssh-agent{,_$(date +%Y%m%d)}
ln -s /usr/local/software/openssh/bin/ssh-agent /usr/bin/ssh-agent
mv /usr/bin/ssh-keygen{,_$(date +%Y%m%d)}
ln -s /usr/local/software/openssh/bin/ssh-keygen /usr/bin/ssh-keygen
mv /usr/bin/ssh-keyscan{,_$(date +%Y%m%d)}
ln -s /usr/local/software/openssh/bin/ssh-keyscan /usr/bin/ssh-keyscan
```

替换libexec

```bash
mv /usr/libexec/openssh{,_$(date +%Y%m%d)}
ln -s /usr/local/software/openssh/libexec /usr/libexec/openssh
```

#### 验证配置文件

**问题处理**

CentOS7.9解决秘钥权限问题

```bash
chmod 600 /etc/ssh/ssh_host_*
chmod 644 /etc/ssh/ssh_host_*.pub
```

OpenEuler24.03解决无效参数问题

```bash
sed -i '/^GSSAPIKexAlgorithms/s/^/#/' /etc/ssh/sshd_config
```

**验证和修改配置文件**

安装完成后，使用以下命令验证 SSH 配置文件的正确性，如有错误按照提示修改

注意是否允许使用root连接的配置，低版本的SSH是默认为yes，高版本默认为no

```bash
sshd -t -f /etc/ssh/sshd_config
grep -E -v "^$|^#" /etc/ssh/sshd_config
```

#### SELinux配置

有以下2种方式，根据实际情况选择一种

**关闭SELinux**

```bash
setenforce 0
```

**设置SELinux策略**

安装 semanage 所需组件

在 CentOS 7 或 8 上：

```bash
yum install -y policycoreutils-python
```

在 CentOS Stream 8/9 或 基于 DNF 的系统：

```bash
dnf install -y policycoreutils-python-utils
```

设置 SELinux 上下文为 `sshd_exec_t`

```bash
semanage fcontext -a -t sshd_exec_t '/usr/local/software/openssh-10.0p1(/.*)?'
restorecon -Rv /usr/local/software/openssh-10.0p1
```

设置 SELinux 上下文，设置端口，如果端口是默认的22就不用设置

```
semanage port -a -t ssh_port_t -p tcp 2222
```

#### 配置防火墙策略

如果操作系统没有开启防火墙则忽略这一步

```bash
sudo firewall-cmd --permanent --add-port=2222/tcp
sudo firewall-cmd --reload
```

#### 重启服务

修改sshd.service指定配置文件

```bash
vi +10 /usr/lib/systemd/system/sshd.service
```

修改ExecStart

```bash
ExecStart=/usr/sbin/sshd -f /etc/ssh/sshd_config -D $OPTIONS
```

最后，重启 SSH 服务以应用新的安装：

```bash
systemctl daemon-reload
systemctl restart sshd
```

#### 连接SSH

再次连接SSH测试是否正常

```
ssh root@192.168.116.128 -p 2222
```



## 方案二：额外安装OpenSSL和OpenSSH

保留操作系统自带的OpenSSL和OpenSSH，新安装的OpenSSH和原有的互不影响

### OpenSSL

如果操作系统的openssl>=1.1.就不要再安装了，因为OpenSSH需要OpenSSL>=1.1.1，再者升级OpenSSL是有风险的，会影响操作系统的库依赖，谨慎操作！

查看版本

```
openssl version
```

#### 编译准备

**安装依赖包**

安装了必要的依赖包

```bash
yum install -y gcc make libtool zlib-devel wget
```

CentOS7中还需需要安装的依赖包

```bash
yum install -y perl-IPC-Cmd
```

**下载并解压源码**

从 OpenSSL 官方 GitHub 仓库下载所需版本的源码，并解压缩：

```bash
wget https://github.com/openssl/openssl/releases/download/openssl-3.5.0/openssl-3.5.0.tar.gz
tar -zxvf openssl-3.5.0.tar.gz
cd openssl-3.5.0
```

**创建构建目录**

为编译创建单独的构建目录：

```bash
mkdir build
cd build
```

#### 编译和安装

**配置编译选项**

配置 OpenSSL 的编译选项并指定安装路径：

```bash
../config \
    --prefix=/usr/local/software/openssl-3.5.0 \
    shared zlib
```

- `--prefix=xxx`: 指定安装路径。
- `shared`: 生成共享库。
- `zlib`: 对 zlib 压缩库的支持。

**编译**

使用多线程进行编译：

```bash
make -j$(nproc)
```

**安装**

编译完成后，安装 OpenSSL：

```bash
make install
ln -s /usr/local/software/openssl-3.5.0 /usr/local/software/openssl
```

#### 查看服务

**验证安装**

临时设置动态链接库路径

```bash
export LD_LIBRARY_PATH=/usr/local/software/openssl/lib64
```

验证 OpenSSL 是否成功安装：

```bash
/usr/local/software/openssl/bin/openssl version
```

输出以下内容：

```
OpenSSL 3.5.0 8 Apr 2025 (Library: OpenSSL 3.5.0 8 Apr 2025)
```



### OpenSSH

#### 编译准备

**安装依赖包**

首先，安装编译 OpenSSH 所需的依赖包。执行以下命令：

```bash
yum install -y gcc make zlib-devel openssl-devel pam-devel libselinux-devel krb5-devel wget
```

**下载并解压源码**

下载完成后，解压源码包：

```bash
wget https://cdn.openbsd.org/pub/OpenBSD/OpenSSH/portable/openssh-10.0p1.tar.gz
tar -zxvf openssh-10.0p1.tar.gz
cd openssh-10.0p1/
```

**创建并进入编译目录**

在源码目录中创建一个名为 `build` 的目录，并进入该目录：

```bash
mkdir build
cd build
```

#### 编译和安装

**配置编译选项**

使用以下命令配置编译选项：

```bash
../configure \
    --prefix=/usr/local/software/openssh-10.0p1 \
    --with-pam \
    --with-selinux \
    --with-kerberos5 \
    --with-zlib \
    --with-md5-passwords
```

如果单独配置了openssl，需要指定路径

```bash
export LD_LIBRARY_PATH=/usr/local/software/openssl/lib64
../configure \
    --prefix=/usr/local/software/openssh-10.0p1 \
    --with-ssl-dir=/usr/local/software/openssl \
    --with-pam \
    --with-selinux \
    --with-kerberos5 \
    --with-zlib \
    --with-md5-passwords
```

- `--prefix=xxx`：指定 OpenSSH 的安装目录。
- `--with-pam`：启用 PAM（Pluggable Authentication Modules）支持，用于身份验证。
- `--with-selinux`：启用 SELinux（Security-Enhanced Linux）支持，增强系统安全性。
- `--with-kerberos5`：启用 Kerberos 5 支持，用于网络身份验证。
- `--with-zlib`：启用 zlib 库支持，用于压缩传输数据。
- `--with-md5-passwords`：允许 OpenSSH 支持 MD5 加密格式的密码（$1$ 开头的 hash）

**编译**

配置完成后，使用 `make` 命令编译 OpenSSH：

```bash
make -j$(nproc)
```

**安装**

编译完成后，使用以下命令安装 OpenSSH：

```bash
make install
ln -s /usr/local/software/openssh-10.0p1 /usr/local/software/openssh
```

#### 替换文件

**拷贝ssh host秘钥**

将现在有ssh host秘钥拷贝到新编译安装的目录中

```
rm -f /usr/local/software/openssh/etc/ssh_host_*
cp /etc/ssh/ssh_host_* /usr/local/software/openssh/etc/
```

设置权限

```
chmod 600 /usr/local/software/openssh/etc/ssh_host_*
chmod 644 /usr/local/software/openssh/etc/ssh_host_*.pub
```

**重新配置sshd_config**

查看原有的配置文件，将该配置文件的内容拷贝到新的配置文件中

```
grep -E -v "^$|^#" /etc/ssh/sshd_config
```

修改配置文件，最好是一个配置对着一个修改，不要直接将原有配置全部搞到新的配置中，可能会不兼容

常用设置

- 设置端口：Port 22
- 开启密码认证：PasswordAuthentication yes
- 运行root用户登录：PermitRootLogin yes

```
vi /usr/local/software/openssh/etc/sshd_config
```

查看新的配置文件

```
grep -E -v "^$|^#" /usr/local/software/openssh/etc/sshd_config
```

配置如下：

```
Port 2222
PermitRootLogin yes
AuthorizedKeysFile      .ssh/authorized_keys
PasswordAuthentication yes
UsePAM yes
PidFile /var/run/openssh10/sshd.pid
Subsystem       sftp    /usr/local/software/openssh-10.0p1/libexec/sftp-server
```

**检查配置文件**

检查配置文件是否正确

```
/usr/local/software/openssh/sbin/sshd -t -f /usr/local/software/openssh/etc/sshd_config
```

**创建PID目录**

```
mkdir -p /var/run/openssh10
```

#### SELinux配置

有以下2种方式，根据实际情况选择一种

**关闭SELinux**

```bash
setenforce 0
```

**设置SELinux策略**

安装 semanage 所需组件

在 CentOS 7 或 8 上：

```bash
yum install -y policycoreutils-python
```

在 CentOS Stream 8/9 或 基于 DNF 的系统：

```bash
dnf install -y policycoreutils-python-utils
```

设置 SELinux 上下文为 `sshd_exec_t`，设置sshd服务

```bash
semanage fcontext -a -t sshd_exec_t '/usr/local/software/openssh-10.0p1(/.*)?'
restorecon -Rv /usr/local/software/openssh-10.0p1
```

设置 SELinux 上下文，设置端口

```
semanage port -a -t ssh_port_t -p tcp 2222
```

设置 SELinux 上下文为 `var_run_t`，设置PID文件的

```
semanage fcontext -a -t var_run_t '/var/run/openssh10(/.*)?'
restorecon -Rv /var/run/openssh10
```

#### 配置防火墙策略

如果操作系统没有开启防火墙则忽略这一步

```bash
sudo firewall-cmd --permanent --add-port=2222/tcp
sudo firewall-cmd --reload
```

#### 启动服务

**编辑配置文件**

```
tee /etc/systemd/system/openssh-server10.service <<"EOF"
[Unit]
Description=OpenSSH Server
Documentation=https://www.openssh.com/
After=network.target
[Service]
Type=simple
WorkingDirectory=/usr/local/software/openssh
Environment="LD_LIBRARY_PATH=/usr/local/software/openssl/lib64"
ExecStartPre=/usr/local/software/openssh/sbin/sshd -t -f /usr/local/software/openssh/etc/sshd_config
ExecStart=/usr/local/software/openssh/sbin/sshd -D -f /usr/local/software/openssh/etc/sshd_config
ExecStop=/bin/kill -SIGTERM $MAINPID
Restart=on-failure
RestartSec=10
KillMode=control-group
KillSignal=SIGTERM
User=root
Group=root
[Install]
WantedBy=multi-user.target
EOF
```

**启动服务**

```
systemctl daemon-reload
systemctl enable openssh-server10.service
systemctl start openssh-server10.service
systemctl status openssh-server10.service
```

#### 连接SSH

再次连接SSH测试是否正常

```
ssh root@192.168.116.128 -p 2222
```

如果源码安装的SSH服务能够正常使用，那么就可以把系统自带的SSH服务关闭

```
systemctl disable --now sshd
```

