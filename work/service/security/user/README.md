# 用户管理



## 普通用户管理

### 创建用户

**创建组**

```
sudo groupadd -g 1001 ateng
```

- `-g 1001`：指定组ID（GID）。

**创建用户**

```
sudo useradd -u 1001 -g ateng -m -s /bin/bash -c "Server Administrator" admin
```

- `-u 1001`：指定用户ID（UID）
- `-g ateng`：指定主组
- `-m`：创建主目录
- `-M`：不创建主目录
- `-s /bin/bash`：指定shell
- `-s /sbin/nologin`：禁止登录（服务用户）
- 可以加 `-c "描述信息"` 备注这个用户的用途
- `-d /home/admin`：指定主目录路径

**设置用户密码**

```
echo Admin@123 | sudo passwd --stdin admin
```

更通用的方式

```
echo "admin:Ateng@2025" | sudo chpasswd
```

**其他创建用户示例**

创建一个普通开发用户

```
sudo useradd -u 2001 -g devs -G docker,wheel -m -s /bin/bash -c "开发人员 John" dev_john
sudo passwd dev_john
```

创建一个系统服务用户（不能登录）

```
sudo useradd -r -u 800 -g services -M -s /sbin/nologin -c "Redis 服务用户" redis_svc
```

创建一个有过期时间的临时用户

```
sudo useradd -m -e 2025-05-01 -s /bin/bash temp_user
sudo passwd temp_user
```

### 删除用户

删除用户，但保留主目录

```
sudo userdel 用户名
```

删除用户和其主目录

```
sudo userdel -r 用户名
```

### 修改用户

修改用户名

```
sudo usermod -l 新用户名 旧用户名
```

修改主目录

```
sudo usermod -d /新目录 用户名
```

添加到组（覆盖原来的附加组）

```
sudo usermod -G 组名 用户名
```

添加到附加组（不覆盖）

```
sudo usermod -aG 组名 用户名
```

### 查看用户信息

查看用户UID、所属组等

```
id 用户名
```

当前用户名

```
whoami
```

查看用户详细信息

```
getent passwd 用户名
```



## sudo用户管理

### sudo最高权限

```
echo "admin ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/ateng-admin
chmod 440 /etc/sudoers.d/ateng-admin
```

### 其他配置示例

**全权限（等同 root）**

用户可以执行任何命令。

```bash
用户名 ALL=(ALL) ALL
```

示例：

```bash
alice ALL=(ALL) ALL
```

- 用户 `alice` 可以在任何主机上以任何身份执行任何命令，必须输入密码。

------

**免密码全权限**

用户可以执行任何命令，无需密码。

```bash
用户名 ALL=(ALL) NOPASSWD:ALL
```

示例：

```bash
alice ALL=(ALL) NOPASSWD:ALL
```

- 用户 `alice` 可以在任何主机上以任何身份执行任何命令，无需输入密码。

------

**指定命令权限**

用户只能执行指定命令，且无需密码。

```bash
用户名 ALL=(ALL) NOPASSWD:/bin/systemctl restart nginx
```

示例：

```bash
bob ALL=(ALL) NOPASSWD:/bin/systemctl restart nginx
```

- 用户 `bob` 可以重启 `nginx` 服务，且无需输入密码。

------

**限定组 sudo 权限**

组内所有成员可以执行特定命令，免密码。

```bash
%组名 ALL=(ALL) NOPASSWD:/usr/bin/docker
```

示例：

```bash
%devs ALL=(ALL) NOPASSWD:/usr/bin/docker
```

- `devs` 组内的所有成员可以执行 `/usr/bin/docker` 命令，且无需输入密码。

------

**禁止某用户使用 sudo（黑名单）**

明确禁止该用户使用 sudo。

```bash
用户名 ALL=(ALL) !ALL
```

示例：

```bash
alice ALL=(ALL) !ALL
```

- 用户 `alice` 无法使用任何 `sudo` 权限。

------

**允许切换为特定用户执行命令**

用户只能切换为指定用户执行特定命令。

```bash
用户名 ALL=(特定用户名) NOPASSWD:/bin/bash
```

示例：

```bash
bob ALL=(nginx) NOPASSWD:/bin/bash
```

- 用户 `bob` 只能以 `nginx` 用户身份执行 `/bin/bash` 命令，且无需输入密码。

------

**允许执行一组命令（指定路径）**

用户只能执行一组特定命令，禁止其他命令。

```bash
用户名 ALL=(ALL) NOPASSWD:/usr/bin/systemctl restart nginx, /usr/bin/systemctl restart apache2
```

示例：

```bash
bob ALL=(ALL) NOPASSWD:/usr/bin/systemctl restart nginx, /usr/bin/systemctl restart apache2
```

- 用户 `bob` 只能重启 `nginx` 和 `apache2` 服务，且无需输入密码。

------

**配置别名以简化命令**

为多个命令或用户、主机配置别名，简化配置。

用户别名：

```bash
User_Alias ADMIN_USERS = alice, bob
```

命令别名：

```bash
Cmnd_Alias SYSTEM_SERVICES = /usr/bin/systemctl restart nginx, /usr/bin/systemctl restart apache2
```

示例：

```bash
User_Alias ADMIN_USERS = alice, bob
Cmnd_Alias SYSTEM_SERVICES = /usr/bin/systemctl restart nginx, /usr/bin/systemctl restart apache2
ADMIN_USERS ALL=(ALL) NOPASSWD:SYSTEM_SERVICES
```

- `alice` 和 `bob` 可以在任何主机上执行 `nginx` 和 `apache2` 的重启命令，且无需密码。

