# rtsptoweb

RTSPtoWeb将您的RTSP流转换为可在web浏览器中使用的格式，如MSE(媒体源扩展)，WebRTC或HLS。它完全是原生的Golang，没有使用FFmpeg或GStreamer，[官网](https://github.com/deepch/RTSPtoWeb/tree/master)



## 启动容器

- 使用docker run的方式

> $ docker run --name rtsp-to-web \
>     -v /PATH_TO_CONFIG/config.json:/config/config.json \
>     --network host \
>     ghcr.io/deepch/rtsptoweb:latest 


```
docker run -d --name kongyu-rtsptoweb --network host \
  --restart=always \
  -v /root/docker/service/rtsp_to_web/RTSPtoWeb-master/config.json:/config/config.json:ro \
  -e TZ=Asia/Shanghai \
  registry.lingo.local/service/rtsptoweb:v2.4.3
docker logs -f kongyu-rtsptoweb
```



## 访问服务

登录服务查看

```
http://192.168.1.101:8083/
```

使用html访问

```
修改index.html相应的地址，即可访问对应的rtsp流
```





## 删除服务

- 使用docker run的方式


```
docker rm -f kongyu-rtsptoweb
```

删除数据目录

```
rm -rf /data/service/rtsptoweb
```

