# webrtc-streamer

用于 V4L2 捕获设备、RTSP 源和屏幕捕获的 WebRTC 流媒体，[官网](https://github.com/mpromonet/webrtc-streamer)



## 环境准备

创建网络，将容器运行在该网络下，若已创建则忽略

```
```

准备目录和配置文件

```
mkdir -p /data/service/webrtc-streamer/{data,config}
chown -R 1001 /data/service/webrtc-streamer
cat > /data/service/webrtc-streamer/config/config.json <<"EOF"
{
    "urls":{       
        "Test" : { "video": "rtsp://demo:demo@ipvmdemo.dyndns.org:5541/onvif-media/media.amp?sessiontimeout=60&streamtype=unicast"},
        "Honk-Kong": {"video": "rtsp://weathercam.gsis.edu.hk/axis-media/media.amp", "position":"22.352734,114.1277", "options":"rtptransport=tcp&timeout=60"},
        "Vancouver": { "video": "rtsp://174.6.126.86/axis-media/media.amp", "position":"49.249660,-123.119340"},
        "rtmp": {"video": "rtmp://171.25.232.10/12d525bc9f014e209c1280bc0d46a87e" }
    }
}
EOF
```



## 启动容器

- 使用docker run的方式


```
docker run -d --name kongyu-webrtc-streamer --network host \
  --restart=always \
  -v /data/service/webrtc-streamer/config/config.json:/app/config.json:ro \
  -e TZ=Asia/Shanghai \
  registry.lingo.local/service/webrtc-streamer:v0.8.4
docker logs -f kongyu-webrtc-streamer
```

- 使用docker-compose的方式


```

```



## 访问服务

登录服务查看

```
http://192.168.1.101:20001/
```



## 删除服务

- 使用docker run的方式


```
docker rm -f kongyu-webrtc-streamer
```

- 使用docker-compose的方式


```

```

删除数据目录

```
rm -rf /data/service/webrtc-streamer
```

