# ZLMediaKit使用文档



## 推流

使用 FFmpeg 将视频推送到SRS服务器

```
ffmpeg -re -stream_loop -1 -i clip.mp4 -vf "scale=1280:720,fps=15" \
    -c:v libx264 -preset ultrafast -c:a aac -b:a 64k \
    -f flv rtmp://10.244.250.10/live/video
```

查看推流的视频

HTTP-fMP4/WS-fMP4

```
http://10.244.250.10/live/video.live.mp4
```

HLS(mpegts)

```
http://10.244.250.10/live/video/hls.m3u8
```

