# **Restic**

**Restic** 则是一款专门为备份而生的工具，尤其适合需要对数据进行高效备份、加密、去重和恢复的场景。它在备份和恢复的增量与性能优化上表现优秀，提供了数据完整性检查和可靠的加密保护，确保数据安全。

https://github.com/restic/restic

## Linux安装使用

### **安装Restic**

可以从 Restic 的 GitHub release 页面下载最新的二进制文件。

```
wget https://github.com/restic/restic/releases/download/v0.17.1/restic_0.17.1_linux_amd64.bz2
bunzip2 restic_0.17.1_linux_amd64.bz2
mv restic_0.17.1_linux_amd64 /usr/local/bin/restic
chmod +x /usr/local/bin/restic
```

验证安装

```
restic version
```

命令补全

```
yum install -y bash-completion
source /usr/share/bash-completion/bash_completion
restic generate --bash-completion /etc/bash_completion.d/restic
source /etc/bash_completion.d/restic
```

配置restic环境

```
cat > /etc/profile.d/restic.sh <<"EOF"
export AWS_ACCESS_KEY_ID=admin
export AWS_SECRET_ACCESS_KEY=Admin@123
export RESTIC_PASSWORD=Admin@123
export RESTIC_REPOSITORY=s3:http://dev.minio.lingo.local:80/data/restic
EOF
source /etc/profile.d/restic.sh
```

初始化仓库

```
restic init
```

### 备份数据

https://restic.readthedocs.io/en/latest/040_backup.html

1. 备份目录

  ```
  restic backup /root/service/
  ```

2. 查看备份

  ```
  restic snapshots
  ```

3. 查看文件列表

  ```
  restic ls -l 23d8d603
  ```

4. 查找文件

  ```
  restic find *.md
  ```

5. 查看文件内容

  ```
  restic dump 23d8d603 /root/service/doris/README.md
  ```

6. 挂载快照内容到本地

  ```
  yum -y install fuse
  restic mount /mnt
  ll /mnt/snapshots/latest/
  umount /mnt
  ```

### 恢复数据

https://restic.readthedocs.io/en/latest/050_restore.html

1. 恢复目录

```
restic restore 23d8d603 --target /data02
```

### 删除备份

https://restic.readthedocs.io/en/latest/060_forget.html

1. 只保留最新的一次数据

  ```
  restic forget --keep-last 1 --prune
  ```

2. 只保留最新的3个快照

  ```
  restic forget --keep-last=3 --prune
  ```

3. 只保留前两小时的备份

  ```
  restic forget --keep-hourly 2 --prune
  ```

4. 只保留2周的数据备份

  ```
  restic forget --keep-weekly 2 --prune
  ```

 5. 实现每天、每周、每月和每年保留一份备份的策略

    ```
    restic forget --keep-daily 7 --keep-weekly 4 --keep-monthly 12 --keep-yearly 5 --prune
    ```

### 其他远端存储

1. 阿里云OSS配置

  ```
  cat > /etc/profile.d/restic.sh <<"EOF"
  export AWS_ACCESS_KEY_ID=LTAI5tEtWTBhkFUxxxxxxx
  export AWS_SECRET_ACCESS_KEY=aVnuhpJ8OENeX2CgBJDZYb2lbxxxxx
  export RESTIC_PASSWORD=Admin@123
  export RESTIC_REPOSITORY=s3:https://oss-cn-chengdu.aliyuncs.com/facility-backup01
  EOF
  source /etc/profile.d/restic.sh
  restic -o s3.bucket-lookup=dns -o s3.region=oss-cn-chengdu init
  ```

2. SFTP配置

  ```
  cat > /etc/profile.d/restic.sh <<"EOF"
  export RESTIC_REPOSITORY=sftp:root@192.168.1.210:22//data/
  EOF
  source /etc/profile.d/restic.sh
  restic init
  ```



## Windows安装使用

### 安装Restic

可以从 Restic 的 GitHub release 页面下载最新的二进制文件。

```
https://github.com/restic/restic/releases/download/v0.17.1/restic_0.17.1_windows_amd64.zip
```

将软件解压到 `C:\Windows\System32` 并重命名为 `restic.exe`

打开命令提示符或 PowerShell，验证安装

```
restic version
```

### 配置环境变量

在 Windows 中，您可以通过系统设置来添加环境变量

1. **打开系统属性**：
   - 右键点击“此电脑”或“计算机”图标，选择“属性”。
   - 点击“高级系统设置”链接。
   - 在“系统属性”对话框中，选择“环境变量”。

2. **添加环境变量**：
   - 在“环境变量”对话框中，您可以选择为当前用户添加变量或为所有用户添加变量（系统变量）。
   - 点击“新建”按钮，添加以下环境变量：

   | 变量名                  | 变量值                                               |
   | ----------------------- | ---------------------------------------------------- |
   | `AWS_ACCESS_KEY_ID`     | `admin`                                              |
   | `AWS_SECRET_ACCESS_KEY` | `Admin@123`                                          |
   | `RESTIC_PASSWORD`       | `Admin@123`                                          |
   | `RESTIC_REPOSITORY`     | `s3:http://dev.minio.lingo.local:80/data/restic-win` |

3. **确认更改**：
   - 点击“确定”保存更改，关闭所有对话框。

### **初始化存储库**

在环境变量设置完成后，您可以使用 Restic 初始化存储库。以下是在命令提示符中执行的步骤：

1. **打开命令提示符**：
   
   - 按 `Win + R`，输入 `cmd`，然后按 Enter。
   
2. **运行初始化命令**：
   
   ```cmd
   restic init
   ```
   
   如果一切正常，您应该会看到类似以下内容的输出，表示存储库已成功初始化：
   
   ```
   created restic repository 01234567
   ```



