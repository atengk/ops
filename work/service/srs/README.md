# SRS

SRS(Simple Realtime Server)是一个简单高效的实时视频服务器，支持RTMP、WebRTC、HLS、HTTP-FLV、SRT等多种实时流媒体协议。Oryx是一个一体化、开箱即用、开源的视频解决方案，可部署在云上或自建机房，以直播和WebRTC等能力赋能你的业务。

- [官网链接](https://ossrs.io/lts/zh-cn/)



## 安装服务

**下载软件包**

点击下载软件包：[链接](https://gitee.com/ossrs/srs/archive/refs/tags/v6.0-d5.tar.gz)

**安装编译依赖包**

```
sudo yum -y install gcc-c++ patch automake tcl cmake unzip
```

**解压软件包**

```
tar -xzf srs-v6.0-d5.tar.gz -C /usr/local/software
```

**编译并安装**

```
cd /usr/local/software/srs-v6.0-d5/trunk
./configure
make
```

## 编辑配置

**设置软链接**

```
ln -s /usr/local/software/srs-v6.0-d5 /usr/local/software/srs
```

**编辑配置文件**

```
cat > /usr/local/software/srs/trunk/conf/srs.conf <<"EOF"
listen              1935;
max_connections     1000;
daemon off;
srs_log_tank console;
daemon              off;
http_api {
    enabled         on;
    listen          1985;
}
http_server {
    enabled         on;
    listen          8080;
    dir             ./objs/nginx/html;
}
rtc_server {
    enabled on;
    listen 8000; # UDP port
    candidate $CANDIDATE;
}
vhost __defaultVhost__ {
    hls {
        enabled         on;
    }
    http_remux {
        enabled     on;
        mount       [vhost]/[app]/[stream].flv;
    }
    rtc {
        enabled     on;
        rtmp_to_rtc off;
        rtc_to_rtmp off;
    }

    play{
        gop_cache_max_frames 2500;
    }
}
EOF
```

## 启动服务

**编辑配置文件**

```
sudo tee /etc/systemd/system/srs.service <<"EOF"
[Unit]
Description=SRS
Documentation=https://ossrs.io/lts/zh-cn/
After=network.target
[Service]
Type=simple
WorkingDirectory=/usr/local/software/srs/trunk
ExecStartPre=/usr/local/software/srs/trunk/objs/srs -t -c conf/srs.conf
ExecStart=/usr/local/software/srs/trunk/objs/srs -c conf/srs.conf
ExecStop=/bin/kill -SIGTERM $MAINPID
Restart=on-failure
RestartSec=30
TimeoutStartSec=120
TimeoutStopSec=180
StartLimitIntervalSec=600
StartLimitBurst=3
KillMode=control-group
KillSignal=SIGTERM
SuccessExitStatus=143
User=admin
Group=ateng
[Install]
WantedBy=multi-user.target
EOF
```

**启动服务**

```
sudo systemctl daemon-reload
sudo systemctl enable srs.service
sudo systemctl start srs.service
```

**查看服务状态和日志**

```
sudo systemctl status srs.service
sudo journalctl -f -u srs.service
```

## 访问服务

**访问Web**

```
URL: http://10.244.251.10:8080
```

**端口说明**

- `tcp://1935`，用于 RTMP 直播流媒体服务器。
- `tcp://1985`，HTTP API 服务器，用于 HTTP API、WebRTC 等功能。
- `tcp://8080`，HTTP 流媒体服务器，用于 HTTP-FLV、HLS 等协议。
- `udp://8000`，WebRTC 媒体服务器。

更多说明参考官方文档：[端口和资源](https://ossrs.io/lts/zh-cn/docs/v6/doc/resource)



## Docker安装

```
docker run --rm -it -p 1935:1935 -p 1985:1985 -p 8080:8080 \
    registry.cn-hangzhou.aliyuncs.com/ossrs/srs:v6
```

