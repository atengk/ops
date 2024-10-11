# frp

frp 是一个专注于内网穿透的高性能的反向代理应用，支持 TCP、UDP、HTTP、HTTPS 等多种协议，且支持 P2P 通信。可以将内网服务以安全、便捷的方式通过具有公网 IP 节点的中转暴露到公网。

https://github.com/fatedier/frp

https://gofrp.org/zh-cn/docs/



## 服务端安装

**下载并解压软件包**

```
curl -LO https://github.com/fatedier/frp/releases/download/v0.60.0/frp_0.60.0_linux_amd64.tar.gz
tar -zxvf frp_0.60.0_linux_amd64.tar.gz
cp frp_0.60.0_linux_amd64/frps /usr/bin/frps
```

**编辑配置文件**

```
mkdir -p /etc/frp
cat > /etc/frp/frps.toml <<EOF
# https://gofrp.org/zh-cn/docs/reference/server-configures/
# 服务端
bindAddr = "0.0.0.0"
bindPort = 7000

# 身份认证
auth.token = "8d45e98e-6ce3-4c73-acfa-d3d423a2df71"

# 服务端 Dashboard
webServer.addr = "0.0.0.0"
webServer.port = 7500
webServer.user = "admin"
webServer.password = "Admin@123"

# 端口白名单
allowPorts = [
  { start = 2000, end = 3000 },
  { single = 3001 },
  { single = 3003 },
  { start = 4000, end = 7000 }
]
EOF
```

**使用systemd管理frps服务**

```
cat > /etc/systemd/system/frps.service <<EOF
[Unit]
Description=Frp Server Service
After=network.target

[Service]
Type=simple
Restart=on-failure
RestartSec=5s
ExecStart=/usr/bin/frps -c /etc/frp/frps.toml

[Install]
WantedBy=multi-user.target
EOF
```

**启动frps服务**

```
systemctl daemon-reload
systemctl enable --now frps
systemctl status frps
```

## Linux客户端安装

**下载并解压软件包**

```
curl -LO https://github.com/fatedier/frp/releases/download/v0.60.0/frp_0.60.0_linux_amd64.tar.gz
tar -zxvf frp_0.60.0_linux_amd64.tar.gz
cp frp_0.60.0_linux_amd64/frpc /usr/bin/frpc
```

**编辑配置文件**

```
mkdir -p /etc/frp
cat > /etc/frp/frpc.toml <<EOF
# https://gofrp.org/zh-cn/docs/reference/client-configures/
# 服务端
serverAddr = "47.108.128.105"
serverPort = 7000

# 身份认证
auth.token = "8d45e98e-6ce3-4c73-acfa-d3d423a2df71"

# 开启 webServer
webServer.addr = "0.0.0.0"
webServer.port = 7400

# SSH 代理，https://gofrp.org/zh-cn/docs/examples/ssh/
[[proxies]]
name = "ssh"
type = "tcp"
localIP = "127.0.0.1"
localPort = 22
remotePort = 6000
EOF
```

**使用systemd管理frps服务**

```
cat > /etc/systemd/system/frpc.service <<EOF
[Unit]
Description=Frp Client Service
After=network.target

[Service]
Type=simple
Restart=on-failure
RestartSec=5s
ExecStart=/usr/bin/frpc -c /etc/frp/frpc.toml
ExecReload=/usr/bin/frpc reload -c /etc/frp/frpc.toml

[Install]
WantedBy=multi-user.target
EOF
```

**启动frps服务**

```
systemctl daemon-reload
systemctl enable --now frpc
systemctl status frpc
```

## Windows客户端安装

**下载并解压软件包**

将解压目录下的 `frpc.exe` 拷贝导 `C:\software\frp` 目录下

```
https://github.com/fatedier/frp/releases/download/v0.60.0/frp_0.60.0_windows_amd64.zip
```

**编辑配置文件**

创建文件于 `C:\software\frp\frpc.toml`

```
# https://gofrp.org/zh-cn/docs/reference/client-configures/
# 服务端
serverAddr = "47.108.128.105"
serverPort = 7000

# 身份认证
auth.token = "8d45e98e-6ce3-4c73-acfa-d3d423a2df71"

# 开启 webServer
webServer.addr = "0.0.0.0"
webServer.port = 7400

# SSH 代理，https://gofrp.org/zh-cn/docs/examples/ssh/
[[proxies]]
name = "rdp"
type = "tcp"
localIP = "127.0.0.1"
localPort = 3389
remotePort = 6001
```

**配置开机自启**

下载软件，将该软件放在frp同级目录C:\software\frp，并重命名为 `frpc-service.exe`

```
https://github.com/winsw/winsw/releases/download/v2.12.0/WinSW-x64.exe
```

编辑配置文件，和该软件同级目录，名称为 `frpc-service.xml`

```xml
<service>
  <!-- ID 唯一就可-->
  <id>frpc-service</id>
  <!-- 服务名称 -->
  <name>frpc-service</name>
  <!-- 服务说明 -->
  <description>frpc-service</description>
  <!-- 开机自动启动模式:Automatic(默认) -->
  <!-- 手动启动: Manual -->
  <startmode>Automatic</startmode>
  <executable>C:\\software\\frp\\frpc</executable>
  <!-- 启动命令 -->
  <arguments>-c C:\\software\\frp\\frpc.toml</arguments>
  <!-- 日志模式 -->
   <log mode="none"></log>
</service>
```

安装服务，在当前窗口输入 cmd ，运行以下命令

```
frpc-service.exe install
```

启动服务

```
frpc-service.exe start
```

查看服务

```
frpc-service.exe status
```



## 公网访问客户端服务

**访问服务端的dashboard**

```
URL: http://47.108.128.105:7500
Username: admin
Password: Admin@123
```

**使用公网IP访问客户端ssh服务**

```
ssh root@47.108.128.105 -p 6000
```

**使用公网IP访问客户端rdp服务**

win + r 输入 mstsc

```
Address: 47.108.128.105:6001
```



## 免费的服务端

- https://freefrp.net/
- https://frp.104300.xyz/
- https://www.chmlfrp.cn/
