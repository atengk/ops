# RTSPtoWeb

RTSPtoWeb将您的RTSP流转换为可在web浏览器中使用的格式，如MSE(媒体源扩展)，WebRTC或HLS。它完全是原生的Golang，没有使用FFmpeg或GStreamer，[官网](https://github.com/deepch/RTSPtoWeb/tree/master)



## 下载镜像

```bash
docker pull ghcr.io/deepch/rtsptoweb:v2.4.3
docker tag ghcr.io/deepch/rtsptoweb:v2.4.3 registry.lingo.local/service/rtsptoweb:v2.4.3
docker push registry.lingo.local/service/rtsptoweb:v2.4.3
docker save registry.lingo.local/service/rtsptoweb:v2.4.3 | gzip -c > image-rtsptoweb_v2.4.3.tar.gz
```



## 启动容器

**编辑配置文件**

```
mkdir -p /data/container/rtsptoweb
cat > /data/container/rtsptoweb/config.json <<"EOF"
{
  "server": {
    "debug": false,
    "log_level": "info",
    "http_demo": true,
    "http_debug": false,
    "http_login": "admin",
    "http_password": "Admin@123",
    "http_port": ":8083"
  },
  "streams": {},
  "channel_defaults": {
    "on_demand": true
  }
}
EOF
```

**启动容器**

```bash
docker run --name ateng-rtsptoweb \
    -d --restart=always -p 28083:8083 \
    -v /data/container/rtsptoweb/config.json:/config/config.json:rw \
    -e TZ=Asia/Shanghai \
    registry.lingo.local/service/rtsptoweb:v2.4.3
```

**查看日志**

```bash
docker logs -f ateng-rtsptoweb
```



## 配置通道

**添加stream**

接口地址：POST /stream/{STREAM_ID}/add

```
curl \
  --header "Content-Type: application/json" \
  --request POST \
  --data '{
              "name": "本地video",
              "channels": {
                  "0": {
                      "name": "本地通道1",
                      "url": "rtsp://192.168.1.10:18554/video-stream/traffic-regional",
                      "on_demand": true,
                      "debug": false,
                      "status": 0
                  },
                  "1": {
                      "name": "ch2",
                      "url": "rtsp://admin:admin@{YOUR_CAMERA_IP}/uri",
                      "on_demand": true,
                      "debug": false,
                      "status": 0
                  }
              }
          }' \
  -u admin:Admin@123 http://192.168.1.12:28083/stream/local/add
```

**查看stream**

```
curl -u admin:Admin@123 http://192.168.1.12:28083/streams
```

**更新stream**

接口地址：POST /stream/{STREAM_ID}/edit

> 就是新增的地址和内容，就接口最后的add改为edit

```
curl \
  --header "Content-Type: application/json" \
  --request POST \
  --data '{
              "name": "本地video",
              "channels": {
                  "0": {
                      "name": "本地通道1",
                      "url": "rtsp://192.168.1.10:18554/video-stream/traffic-regional",
                      "on_demand": true,
                      "debug": false,
                      "status": 0
                  },
                  "1": {
                      "name": "ch2",
                      "url": "rtsp://admin:admin@{YOUR_CAMERA_IP}/uri",
                      "on_demand": true,
                      "debug": false,
                      "status": 0
                  }
              }
          }' \
  -u admin:Admin@123 http://192.168.1.12:28083/stream/local/edit
```



## 访问服务

**登录服务查看**

```
URL: http://192.168.1.12:28083/
```

**使用html访问**

修改index.html相应的地址，即可访问对应的rtsp流

对应地址是：/stream/{STREAM_ID}/channel/{CHANNEL_ID}/webrtc

例如：http://192.168.1.12:28083/stream/local/channel/0/webrtc



## 删除服务

**删除服务**


```
docker rm -f ateng-rtsptoweb
```

**删除数据目录**

```
rm -rf /data/container/rtsptoweb
```

