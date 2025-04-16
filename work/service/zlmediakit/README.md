# ZLMediaKit

ZLMediaKit 是一个高性能、轻量级的流媒体服务器，支持RTSP、RTMP、HTTP-FLV、HLS、WebRTC等多种流媒体协议。它基于C++开发，跨平台、易于部署，广泛应用于实时音视频传输与转发场景。项目开源，社区活跃，适合开发者二次开发与集成。

- [官网链接](https://docs.zlmediakit.com/zh/)



## 安装服务

**克隆源代码**

```
git clone --depth 1 https://gitee.com/xia-chu/ZLMediaKit
cd ZLMediaKit
git submodule update --init
```

**安装编译依赖包**

```
sudo yum -y install gcc-c++ cmake openssl-devel SDL-devel
```

**编译**

```
mkdir build
cd build
cmake ..
make -j4
```

**安装**

```
mkdir -p /usr/local/software/ZLMediaKit
cp -rvf ../release/linux/Debug/* /usr/local/software/ZLMediaKit
```



## 启动服务

**编辑配置文件**

```
sudo tee /etc/systemd/system/ZLMediaKit.service <<"EOF"
[Unit]
Description=ZLMediaKit
Documentation=https://docs.zlmediakit.com/zh
After=network.target
[Service]
Type=simple
WorkingDirectory=/usr/local/software/ZLMediaKit
ExecStart=/usr/local/software/ZLMediaKit/MediaServer
ExecStop=/bin/kill -SIGTERM $MAINPID
Restart=on-failure
RestartSec=30
TimeoutStartSec=120
TimeoutStopSec=180
StartLimitIntervalSec=600
StartLimitBurst=3
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
sudo systemctl daemon-reload
sudo systemctl enable ZLMediaKit.service
sudo systemctl start ZLMediaKit.service
```

**查看服务状态和日志**

```
sudo systemctl status ZLMediaKit.service
sudo journalctl -f -u ZLMediaKit.service
```

## 访问服务

**访问Web**

```
URL: http://10.244.250.10
```

默认secret=R6crPU7nNz5eiu52sIPKdVEWLDIUjHBL

**端口说明**

| 端口号                | 协议   | 用途说明                                                     |
| --------------------- | ------ | ------------------------------------------------------------ |
| **554**               | TCP    | RTSP（Real Time Streaming Protocol）默认端口，用于拉流、推流。 |
| **1935**              | TCP    | RTMP（Real-Time Messaging Protocol）默认端口，常用于直播推流或拉流（OBS 等软件用这个）。 |
| **80**                | TCP    | HTTP，用于 HTTP-FLV、网页拉流，或 API 服务。                 |
| **443**               | TCP    | HTTPS（加密的 HTTP），用于加密的 HLS/HTTP-FLV/WebRTC 信令等。 |
| **10000 (TCP & UDP)** | 自定义 | 默认用于 **WebRTC**（媒体数据传输）。UDP 是传输媒体流，TCP 是信令备份通道或 TURN。 |
| **9000 (UDP)**        | 自定义 | 可能是 ZLMediaKit 的 **多播或 RTP 推流中继端口**，或配置的备用端口（例如 RTP 端口池起始值）。需要根据配置文件具体确认。 |



## Docker安装

```
docker run -id -p 1935:1935 -p 8080:80 -p 8443:443 -p 8554:554 -p 10000:10000 -p 10000:10000/udp -p 8000:8000/udp -p 9000:9000/udp zlmediakit/zlmediakit:master
```

