# OpenSSH管理



## 秘钥生成

### 一、选择密钥类型

当前推荐的密钥类型有：

| 密钥类型                  | 安全性 | 推荐用途                    |
| ------------------------- | ------ | --------------------------- |
| **ED25519**               | 非常高 | 现代系统，高安全，性能好    |
| **RSA（3072 或 4096位）** | 高     | 兼容旧系统，广泛支持        |
| **ECDSA**                 | 一般   | 较少推荐，兼容性不如ED25519 |

👉 **推荐首选：`ED25519`**（除非你有兼容性要求）

### 二、命令行生成密钥对

#### 1. 生成 ED25519 密钥对

```bash
ssh-keygen -t ed25519 -P "" -f ~/.ssh/id_ed25519 -C "2385569970@qq.com - Server Key - $(date +%Y%m%d)"
```

#### 2. 生成 RSA（4096位）密钥对（兼容性需求）

```bash
ssh-keygen -t rsa -b 4096 -P "" -f ~/.ssh/id_rsa -C "2385569970@qq.com - Server Key - $(date +%Y%m%d)"
```

#### 参数说明：

- `-t`: 指定密钥类型（ed25519、rsa、ecdsa等）
- `-b`: 指定位数（RSA使用）
- `-C`: 注释信息，通常填写邮箱或用途
- `-P ""` 不设置密码短语
- `-f ~/.ssh/your_key_name` 指定密钥文件路径

#### 3. 配置公钥信任列表

将公钥配置在文件 `authorized_keys`  中，其公钥的私钥就可以免密登录到该主机

```
cat ~/.ssh/id_*.pub >> ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys
```

#### 4. 设置秘钥文件权限

生成的秘钥一般就是一下的文件权限

```
[root@ateng ~]# ll -d ~/.ssh/
drwx------ 2 root root 4096 Apr  9 08:29 /root/.ssh/
[root@ateng ~]# ll ~/.ssh/
total 12
-rw------- 1 root root 123 Apr  9 08:29 authorized_keys
-rw------- 1 root root 444 Apr  9 08:28 id_ed25519
-rw-r--r-- 1 root root 123 Apr  9 08:28 id_ed25519.pub
```

如果不是请修改相应的文件

```
chmod 700 ~/.ssh
chmod 600 ~/.ssh/authorized_keys
chmod 600 ~/.ssh/id_*
chmod 644 ~/.ssh/id_*.pub
```



## 免秘钥配置

### 免秘钥配置

从 **主机 A** 登录到 **主机 B**，不需要输入密码。

#### 自动配置

使用 `ssh-copy-id` 命令 把公钥从 主机A 复制到 主机B

系统会提示你输入密码（最后一次），之后就配置好了。

```
ssh-copy-id -i ~/.ssh/id_ed25519.pub root@10.244.172.126
```

主机 B 上发生了什么？你的公钥被追加到 `~/.ssh/authorized_keys` 

在进行远程连接就不需要密码了

```
ssh root@10.244.172.8
```

#### 手动配置

复制 主机A 的公钥

```
[root@server01 ~]# cat ~/.ssh/id_ed25519.pub
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAJWbM7GtX4KAeXi6AQfm6lGPbdDjfsuRH3uUSHWeRBy 2385569970@qq.com - Server Key - 20250409
```

将 主机A 的公钥 手动复制到 主机B

```
[root@ateng ~]# cat >> .ssh/authorized_keys <<"EOF"
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAJWbM7GtX4KAeXi6AQfm6lGPbdDjfsuRH3uUSHWeRBy 2385569970@qq.com - Server Key - 20250409
EOF
```

在进行远程连接就不需要密码了

```
ssh root@10.244.172.8
```



## 配置文件~/.ssh/config

### 配置实例

配置文件示例 `~/.ssh/config`

```
# 默认设置（适用于所有 Host）
Host *
    ForwardAgent no
    StrictHostKeyChecking ask
    UserKnownHostsFile ~/.ssh/known_hosts
    ServerAliveInterval 60
    ServerAliveCountMax 3
    Compression yes
    LogLevel ERROR
    PreferredAuthentications publickey
    IdentitiesOnly yes

# 配置：公司内网服务器
Host office-server
    HostName 192.168.10.10
    User devuser
    Port 22
    IdentityFile ~/.ssh/id_ed25519_office
    ProxyJump jump-host

# 配置：跳板机（Bastion Host）
Host jump-host
    HostName jump.mycompany.com
    User bastion
    IdentityFile ~/.ssh/id_rsa_bastion

# 配置：GitHub（自定义私钥）
Host github.com
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_ed25519_github

# 配置：云服务器（阿里云/腾讯云等）
Host aliyun-prod
    HostName 8.210.XX.XX
    User root
    Port 22
    IdentityFile ~/.ssh/id_rsa_aliyun
    ForwardAgent yes

# 配置：开发环境，端口转发 + X11
Host devbox
    HostName dev.example.com
    User dev
    IdentityFile ~/.ssh/id_ed25519_dev
    LocalForward 8888 localhost:8888   # 本地端口转发
    RemoteForward 3306 localhost:3306  # 远程端口转发
    ForwardX11 yes
    ForwardX11Trusted yes
```

**参数解释：**

| 参数名                    | 示例值                     | 作用                       | 说明 / 建议                                  |
| ------------------------- | -------------------------- | -------------------------- | -------------------------------------------- |
| **Host**                  | `*` / `server1`            | 定义匹配条件或别名         | `*` 表示通配，适用于所有连接                 |
| **HostName**              | `192.168.1.10`             | 实际主机名或 IP 地址       | 如果 `Host` 是别名，这里是目标地址           |
| **User**                  | `ubuntu`                   | SSH 登录用户名             | 避免每次手动指定用户名                       |
| **Port**                  | `22` / `2222`              | 目标 SSH 端口              | 默认是 22，修改后必须指定                    |
| **IdentityFile**          | `~/.ssh/id_ed25519`        | 使用的私钥路径             | 可为不同主机指定不同密钥                     |
| **IdentitiesOnly**        | `yes`                      | 强制只使用指定的密钥文件   | 避免系统尝试其他密钥导致连接失败（常见问题） |
| **ForwardAgent**          | `yes` / `no`               | 是否转发 SSH agent         | 通常用于跳板机后继续使用私钥认证             |
| **ProxyJump**             | `jump.example.com`         | 使用跳板机连接目标主机     | 等价于命令行 `-J` 参数                       |
| **ServerAliveInterval**   | `60`                       | 每隔多少秒发送心跳包       | 防止连接因长时间无操作被断开                 |
| **ServerAliveCountMax**   | `3`                        | 心跳失败几次后断开         | 和 `ServerAliveInterval` 配合使用            |
| **StrictHostKeyChecking** | `yes` / `no` / `ask`       | 是否检查主机指纹变化       | 建议设置为 `ask`，防止中间人攻击             |
| **UserKnownHostsFile**    | `~/.ssh/known_hosts`       | 记录信任主机的文件         | 可自定义或隔离环境                           |
| **Compression**           | `yes`                      | 启用 SSH 数据压缩          | 在网络慢时提升性能                           |
| **LogLevel**              | `ERROR` / `INFO` / `DEBUG` | SSH 输出日志等级           | 调试连接问题时可设为 `DEBUG`                 |
| **ForwardX11**            | `yes`                      | 允许图形界面转发（X11）    | 用于远程 GUI 程序运行                        |
| **ForwardX11Trusted**     | `yes`                      | 允许信任的 X11 转发        | 避免某些程序因安全限制无法运行               |
| **LocalForward**          | `8888 localhost:8888`      | 本地端口 → 远程端口映射    | 常用于访问远程服务（如 Jupyter）             |
| **RemoteForward**         | `3306 localhost:3306`      | 远程端口 → 本地端口映射    | 允许对方访问你本地服务                       |
| **AddKeysToAgent**        | `yes`                      | 把密钥自动添加到 ssh-agent | 登录后自动加入 agent，无需手动 `ssh-add`     |
| **ControlMaster**         | `auto`                     | 启用 SSH 多路复用          | 提高频繁 SSH 的性能                          |
| **ControlPath**           | `~/.ssh/cm-%r@%h:%p`       | 多路复用连接的 socket 路径 | 需配合 ControlMaster 使用                    |
| **ControlPersist**        | `10m`                      | 多路复用连接保持多久       | 可避免重复握手，提高效率                     |

### 使用示例

配置好之后，只需要这样连接：

```bash
ssh office-server
```

不用再记住 IP、用户名、密钥路径，也可以一键连接跳板机，非常适合团队协作、DevOps、远程开发等。



## sshd服务配置优化

### 优化配置（推荐）

| 配置项                            | 推荐值                    | 说明                                           |
| --------------------------------- | ------------------------- | ---------------------------------------------- |
| `Port`                            | `22`（或自定义如 `2222`） | 修改默认端口可减轻暴力扫描风险，但需防火墙放通 |
| `Protocol`                        | `2`                       | 强制使用 SSH 协议 v2，v1 已废弃                |
| `PermitRootLogin`                 | `no`                      | 禁止 root 直接登录，改用普通用户 + sudo        |
| `PasswordAuthentication`          | `no`                      | 禁用密码登录，仅使用公钥登录                   |
| `PermitEmptyPasswords`            | `no`                      | 禁止空密码用户登录                             |
| `PubkeyAuthentication`            | `yes`                     | 启用公钥认证                                   |
| `AuthorizedKeysFile`              | `.ssh/authorized_keys`    | 指定公钥文件路径                               |
| `ChallengeResponseAuthentication` | `no`                      | 禁用 keyboard-interactive 认证方式             |
| `UsePAM`                          | `yes`                     | 保留 PAM 支持（视需求可设为 `no`）             |
| `MaxAuthTries`                    | `3`                       | 限制认证尝试次数，防暴力破解                   |
| `LoginGraceTime`                  | `30`                      | 登录验证的最大时间（秒）                       |
| `ClientAliveInterval`             | `60`                      | 每隔多少秒发一次 keepalive                     |
| `ClientAliveCountMax`             | `3`                       | 客户端最多无响应次数（超出即断开）             |
| `AllowUsers`                      | `user1 user2`             | 限定允许登录的用户（可选）                     |
| `AllowGroups`                     | `sshusers`                | 限定允许登录的用户组（可选）                   |
| `UseDNS`                          | `no`                      | 禁止 DNS 反查，加速 SSH 登录                   |
| `X11Forwarding`                   | `no`                      | 如果不使用图形转发，建议关闭                   |
| `PermitTunnel`                    | `no`                      | 禁用 TUN/TAP 隧道（默认即关闭）                |
| `Compression`                     | `yes`                     | 启用压缩，提高低带宽环境性能                   |
| `MaxSessions`                     | `10`                      | 限制每个连接允许多少个 SSH session             |
| `MaxStartups`                     | `10:30:100`               | 限制并发认证连接，防止 DoS 攻击                |
| `LogLevel`                        | `VERBOSE`                 | 输出详细日志（如登录公钥指纹）                 |
| `Banner`                          | `/etc/issue.net`          | 登录欢迎语（可自定义告警语）                   |

### 操作流程

1. 修改配置文件：

    ```bash
    sudo vim /etc/ssh/sshd_config
    ```

2. 测试 SSH 配置无误（非常重要）：

    ```bash
    sudo sshd -t
    ```

3. 重启服务：

    ```bash
    sudo systemctl restart sshd
    ```



## SSH会话管理

### 一、列出当前的 SSH 会话连接

在服务器端，可以查看有哪些用户通过 SSH 登录了系统：

```bash
who -u
```

或：

```bash
w
```

还可以用 `ss` 或 `netstat` 查看 SSH 连接：

```bash
ss -tnp | grep ssh
```

------

### 二、断开某个 SSH 会话

如果你是管理员，可以使用 `kill` 命令结束某个 SSH 会话：

1. 查看 SSH 会话进程：

```bash
ss -tnp | grep ssh
```

1. 找到特定连接对应的 PID 后，使用 `kill`：

```bash
kill -9 <PID>
```

