# ClamAV

ClamAV® 是一个开源的反病毒引擎，用于检测木马、病毒、恶意软件和其他恶意威胁。

官网: [ClamAV](http://www.clamav.net/)

## 1. 安装 ClamAV

### 下载并安装 ClamAV 软件包

下载最新的ClamAV RPM包并安装：

```bash
wget http://www.clamav.net/downloads/production/clamav-1.4.1.linux.x86_64.rpm
rpm -ivh clamav-1.4.1.linux.x86_64.rpm
```

### 创建运行用户和组

为ClamAV创建独立的用户和用户组，以提高系统安全性：

```bash
groupadd clamav
useradd -r -s /usr/sbin/nologin -g clamav clamav
```

### 创建必要的目录并设置权限

创建数据目录、日志目录、以及运行时目录，并设置适当的权限：

```bash
mkdir -p /var/lib/clamav /var/log/clamav /var/run/clamav /run/clamav
chown clamav:clamav /var/lib/clamav /var/log/clamav /var/run/clamav /run/clamav
```

## 2. 配置 ClamAV

### 配置 `clamd`

编辑 `clamd.conf` 配置文件，以便设置日志、数据库路径等：

```bash
tee /usr/local/etc/clamd.conf <<"EOF"
LogFile /var/log/clamav/clamd.log
LogFileMaxSize 2M
PidFile /var/run/clamav/clamd.pid
DatabaseDirectory /var/lib/clamav
LocalSocket /run/clamav/clamd.sock
EOF
```

### 配置 `freshclam`

配置 `freshclam.conf` 以定期更新病毒数据库：

```bash
tee /usr/local/etc/freshclam.conf <<"EOF"
DatabaseDirectory /var/lib/clamav
UpdateLogFile /var/log/clamav/freshclam.log
PidFile /var/run/clamav/freshclam.pid
DatabaseMirror database.clamav.net
Checks 12
EOF
```

### 初始化病毒数据库

首次运行 `freshclam` 以下载病毒数据库：

```bash
freshclam
```

## 3. 设置 Systemd 服务

### 配置 `clamd` 服务

为 `clamd` 创建 Systemd 服务单元文件，以便系统启动时自动启动 `clamd` 服务：

```bash
tee /etc/systemd/system/clamd.service <<"EOF"
[Unit]
Description=Clam AntiVirus Daemon
Documentation=man:clamd(8) man:clamd.conf(5) https://www.clamav.net/documents/
After=network.target

[Service]
Type=simple
ExecStart=/usr/local/sbin/clamd --foreground=true
Restart=on-failure
PrivateTmp=true

[Install]
WantedBy=multi-user.target
EOF

# 重新加载Systemd配置并启动服务
systemctl daemon-reload
systemctl start clamd
systemctl enable clamd
```

### 配置 `freshclam` 更新服务

同样为 `freshclam` 创建 Systemd 服务，以便自动更新病毒数据库：

```bash
tee /etc/systemd/system/freshclam.service <<"EOF"
[Unit]
Description=ClamAV Freshclam Update Service
Documentation=man:freshclam(1) https://www.clamav.net/documents/
After=network.target

[Service]
ExecStart=/usr/local/bin/freshclam -d --foreground=true
Restart=on-failure
User=clamav
Group=clamav
PrivateTmp=true

[Install]
WantedBy=multi-user.target
EOF

# 重新加载Systemd配置并启动服务
systemctl daemon-reload
systemctl start freshclam
systemctl enable freshclam
```

## 4. 手动扫描与自动化配置

### 手动扫描

可以使用以下命令进行手动扫描：

- 使用 `clamscan` 进行本地扫描：
    ```bash
    clamscan -i /data/vsftp/
    ```

- 使用 `clamdscan` 利用 `clamd` 服务进行更高效的扫描：
    ```bash
    clamdscan -i /data/vsftp/
    ```

### 配置定时扫描脚本

为了自动化病毒扫描，可创建脚本并通过 `cron` 定时任务调度。

#### 编写扫描脚本

```bash
cat > /data/shell/clamscan.sh <<"EOF"
#!/bin/bash

# 设置扫描的目录
SCAN_DIR="/data/vsftp/"
SUMMARY=""

# 检查clamdscan命令是否存在
if ! command -v clamdscan &> /dev/null; then
    echo "clamdscan命令未找到，请确保ClamAV已安装并且clamdscan在路径中。"
    exit 1
fi

# 使用clamdscan扫描目录，并将结果重定向到临时文件
SCAN_RESULT=$(mktemp)
clamdscan -i "$SCAN_DIR" > "$SCAN_RESULT"

# 读取扫描结果文件并分析
INFECTED_COUNT=$(grep "FOUND" "$SCAN_RESULT" | wc -l)
INFECTED_FILES=$(grep "FOUND" "$SCAN_RESULT" | awk -F': ' '{print $1}')

# 获取服务器信息
HOSTNAME=$(hostname)
IP_ADDRESSES=$(hostname -I | tr ' ' '\n' | grep -v "^127\.")
OS_INFO=$(uname -a)
CURRENT_TIME=$(date)

# 检查FTP服务状态
FTP_STATUS=$(systemctl is-active vsftpd)

# 统计FTP目录下的文件数量
FILE_COUNT=$(find "$SCAN_DIR" -type f | wc -l)

# 生成总结报告
SUMMARY+="ClamAV扫描总结报告\n"
SUMMARY+="扫描目录: $SCAN_DIR\n"
SUMMARY+="感染文件数量: $INFECTED_COUNT\n\n"

if [ "$INFECTED_COUNT" -gt 0 ]; then
    SUMMARY+="感染文件列表:\n"
    SUMMARY+="$INFECTED_FILES\n\n"
else
    SUMMARY+="没有发现感染文件。\n\n"
fi

SUMMARY+="服务器信息:\n"
SUMMARY+="主机名: $HOSTNAME\n"
SUMMARY+="IP地址:\n$IP_ADDRESSES\n"
SUMMARY+="操作系统信息: $OS_INFO\n"
SUMMARY+="当前时间: $CURRENT_TIME\n"
SUMMARY+="FTP服务状态: $FTP_STATUS\n"
SUMMARY+="FTP目录下的文件数量: $FILE_COUNT\n"

# 输出总结
echo -e "$SUMMARY"

# 发送报告到企业微信
WEBHOOK_URL='https://qyapi.weixin.qq.com/cgi-bin/webhook/send?key=xxxxxx-8542-469a-a903-fc50d7be4c2b'
curl "$WEBHOOK_URL" \
   -H 'Content-Type: application/json' \
   -d "$(echo -e '
   {
        "msgtype": "text",
        "text": {
            "content": "'"$SUMMARY"'"
        }
   }')"

# 清理临时文件
rm -f "$SCAN_RESULT"
EOF
```

### 配置定时任务

通过 `cron` 设置定时任务，每天上午9点和下午6点自动执行脚本：

1. 打开 `cron` 配置文件：

    ```bash
    crontab -e
    ```

2. 添加定时任务：

    ```bash
    0 9,18 * * * /bin/bash /data/shell/clamscan.sh
    ```

    解释：

    - `0 9,18 * * *`：在每天的9:00和18:00执行任务。
    - `/bin/bash /data/shell/clamscan.sh`：执行脚本的完整路径，确保使用正确的Shell环境运行。

3. 保存并退出。

配置完成后，系统会自动在设定时间执行 `/data/shell/clamscan.sh`，实现定时病毒扫描和报告推送。

