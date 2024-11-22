# **Samba**

Samba 是一个开源软件套件，用于在 Linux/Unix 系统与 Windows 系统之间实现文件和打印共享。它通过 SMB/CIFS 协议，让 Linux 系统既能作为文件服务器，也能作为域控制器或加入 Windows 域。Samba 提供了与 Windows 系统高度兼容的网络文件共享功能，并支持权限控制和用户认证。它在企业和个人环境中广泛使用。

**官网链接**: [Samba 官方网站](https://www.samba.org/)

---

## **安装服务**

### 安装与基础配置

1. **安装 Samba 服务**  
   使用以下命令安装指定版本的 Samba 软件包。确保系统支持该版本：
   ```bash
   sudo yum -y install samba
   ```

2. **配置全局参数**  
   编辑 `/etc/samba/smb.conf` 文件，先备份或删除原有文件内容，再新增以下配置：

   ```ini
   sudo tee /etc/samba/smb.conf <<"EOF"
   [global]
       client ipc max protocol = SMB3
       client ipc min protocol = SMB2
       client max protocol = SMB3
       client min protocol = SMB2
   
       disable spoolss = Yes
       dns proxy = No
       load printers = No
   
       log file = /dev/stdout
       max log size = 50
   
       map to guest = Bad User
       pam password change = Yes
       workgroup = MYGROUP
   
       create mask = 0664
       directory mask = 0755
       force create mode = 0664
       force directory mode = 0755
   
       fruit:time machine = yes
       recycle:repository = .deleted
       recycle:keeptree = yes
   EOF
   ```
   - **`client ipc max/min protocol` 和 `client max/min protocol`**：设置客户端与服务器的协议支持范围，建议使用 SMB2 和 SMB3，禁用不安全的 SMB1 协议。
   - **`disable spoolss` 和 `load printers`**：禁用打印相关服务，节约资源。
   - **`log file` 和 `max log size`**：定义日志存储路径及大小限制。
   - **`map to guest`**：将非法用户映射到访客账户。
   - **`workgroup`**：指定 Samba 服务所在的工作组，默认为 `MYGROUP`。
   - **`fruit` 和 `recycle` 配置项**：启用 Apple Time Machine 支持和回收站功能。
   
3. **创建用户与用户组**  
   创建共享资源的用户组 `smb` 及非登录用户 `smbuser`：
   ```bash
   sudo groupadd smb
   sudo useradd -g smb -s /sbin/nologin smbuser
   ```

4. **创建管理员账号**  
   创建 Samba 管理员，设置初始密码：
   
   ```bash
   sudo groupadd smb_admin
   sudo useradd -g smb_admin smb_admin
   echo -e "Admin@123\nAdmin@123" | sudo smbpasswd -a smb_admin
   ```
   
5. **启动并设置开机自启**  
   启动 Samba 服务并配置开机自动启动：
   ```bash
   sudo systemctl enable --now smb
   ```

---

## **配置服务**

### 公共目录配置

1. **编辑配置文件**  
   在 `/etc/samba/smb.conf` 中新增公共目录配置：
   
   ```shell
   sudo tee -a /etc/samba/smb.conf <<"EOF"
   [公共目录]
       comment = 公共共享文件夹
       guest ok = Yes
       path = /data/service/samba/public
       read only = No
       force user = smbuser
   EOF
   ```
   - **`comment`**：目录说明，用于帮助识别共享资源。
   - **`guest ok`**：允许访客访问该共享目录。
   - **`path`**：指定共享目录的实际路径。
   - **`read only`**：设置为 `No`，允许写入操作。
   
2. **创建目录并设置权限**  
   执行以下命令创建目录并为其分配用户与组权限：
   
   ```bash
   sudo mkdir -p /data/service/samba/public
   sudo chown smbuser:smb /data/service/samba/public
   ```
   
3. **重启服务**  
   让配置生效：
   ```bash
   sudo systemctl restart smb
   ```

---

### 用户专属目录配置

1. **编辑配置文件**  
   新增用户共享目录配置：
   ```shell
   sudo tee -a /etc/samba/smb.conf <<"EOF"
   [研发部]
       comment = 研发共享文件夹
       delete veto files = Yes
       path = /data/service/samba/dev
       read only = No
       valid users = smb_dev01 smb_dev02
   EOF
   ```
   - **`valid users`**：仅允许指定用户访问该目录。

2. **创建目录并设置权限**  
   使用以下命令创建目录和设置权限：

   ```bash
   sudo mkdir -p /data/service/samba/dev
   sudo chown smbuser:smb /data/service/samba/dev
   ```

3. **创建用户并设置密码**  
   创建共享目录用户并设置 Samba 密码：

   ```bash
   sudo groupadd smb_dev
   sudo useradd -g smb_dev -s /sbin/nologin smb_dev01
   sudo useradd -g smb_dev -s /sbin/nologin smb_dev02
   echo -e "password\npassword" | sudo smbpasswd -a smb_dev01
   echo -e "password\npassword" | sudo smbpasswd -a smb_dev02
   ```

4. **创建用户目录并设置权限**

   ```
   sudo mkdir -p /data/service/samba/dev/{研发01,研发02}
   sudo chown smb_dev01:smb_dev /data/service/samba/dev/研发01
   sudo chmod 700 /data/service/samba/dev/研发01
   sudo chown smb_dev02:smb_dev /data/service/samba/dev/研发02
   sudo chmod 700 /data/service/samba/dev/研发02
   ```

5. **创建所属公共目录**

   ```
   sudo mkdir -p /data/service/samba/dev/公共目录
   sudo chown :smb_dev /data/service/samba/dev/公共目录
   sudo chmod 770 /data/service/samba/dev/公共目录
   ```

6. **重启服务**  
   应用新配置：

   ```bash
   sudo systemctl restart smb
   ```

---

## **客户端使用**

### Windows 客户端

1. 打开资源管理器，输入共享路径：  
   ```
   \\192.168.1.114
   ```

2. 使用命令管理网络连接：
   ```bash
   # 查看所有已连接的共享
   net use
   # 删除指定共享连接
   net use /del /y \\192.168.1.114\研发部
   ```

---

### Linux 客户端

1. **安装 Samba 客户端工具**  
   使用以下命令安装工具包：
   ```bash
   sudo yum -y install cifs-utils
   ```

2. **挂载共享目录**  

   在使用 CIFS 挂载 Samba 共享目录时，`chown` 和 `chmod` 通常对挂载的目录和文件不起作用。这是由于 CIFS 协议的特性，文件和目录的权限在 Samba 服务器端控制，而不是客户端。

   - 挂载公共目录：
     
     ```bash
     sudo mount -t cifs //192.168.1.114/公共目录 -o username=none,password=none,uid=$(id -u admin),gid=$(getent group ateng | cut -d: -f3) /mnt
     ```
     
   - 挂载私有目录：
     ```bash
     sudo mount -t cifs //192.168.1.114/研发部/开发01 -o username=smb_dev01,password=Admin@123,uid=1001,gid=1001 /mnt
     ```

3. **配置开机自动挂载**  
   修改 `/etc/fstab` 文件以实现自动挂载：

   ```bash
   echo "//192.168.1.114/研发部/开发01 /mnt cifs defaults,username=smb_dev01,password=Admin@123,uid=1001,gid=1001 0 0" || sudo tee -a /etc/fstab
   sudo mount -a
   ```

---

## **账号管理**

### **1. 创建用户**

**创建系统用户（如果不存在）：**

```bash
sudo useradd -M -s /sbin/nologin smbuser
```

- `-M`：不创建主目录。  
- `-s /sbin/nologin`：禁止用户登录系统。

**添加为 Samba 用户：**

```bash
sudo smbpasswd -a smbuser
```

系统会提示输入 Samba 密码。

---

### **2. 修改用户密码**

使用以下命令修改 Samba 用户密码：

```bash
sudo smbpasswd smbuser
```

---

### **3. 禁用用户**

临时禁用用户的 Samba 访问：

```bash
sudo smbpasswd -d smbuser
```

---

### **4. 启用用户**

重新启用已禁用的用户：

```bash
sudo smbpasswd -e smbuser
```

---

### **5. 删除用户**

从 Samba 中移除用户：

```bash
sudo smbpasswd -x smbuser
```

如果需要同时删除系统用户：

```bash
sudo userdel smbuser
```

---

### **6. 查看所有用户**

列出所有 Samba 用户：

```bash
pdbedit -L
```



