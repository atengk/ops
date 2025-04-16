# FFmpeg 

FFmpeg 是一个开源的多媒体框架，能够对音视频进行录制、转换、剪辑、流式传输等操作。它支持几乎所有主流的音视频格式，常用于开发、转码和媒体处理。FFmpeg 提供命令行工具和开发库，广泛应用于视频处理和流媒体解决方案中。

- [官网链接](https://ffmpeg.org/)
- [下载地址](https://github.com/BtbN/FFmpeg-Builds/releases)

## 前提条件

glibc版本>=2.18

```
# rpm -qa glibc
glibc-2.38-29.oe2403.x86_64
```

如果小于2.18的，下载这个软件包：[下载链接](https://johnvansickle.com/ffmpeg/)



## 安装服务

**下载软件包**

```
wget https://github.com/BtbN/FFmpeg-Builds/releases/download/autobuild-2025-04-14-12-59/ffmpeg-N-119262-g3b2a9410ef-linux64-gpl.tar.xz
```

**解压软件包**

```
tar -xvf ffmpeg-N-119262-g3b2a9410ef-linux64-gpl.tar.xz
```

**安装软件包**

```
cp -v ffmpeg-N-119262-g3b2a9410ef-linux64-gpl/bin/ff* /usr/bin/
```

**清理目录**

```
rm -rf ffmpeg-N-119262-g3b2a9410ef-linux64-gpl/
```

**查看版本**

```
ffmpeg -version
```



## 使用服务

### 视频裁剪

**截取前10秒的视频片段**

```
ffmpeg -i video.mp4 -ss 00:00:00 -t 10 -c copy clip.mp4
```

**裁剪画面（x,y,w,h）**

```
ffmpeg -i clip.mp4 -filter:v "crop=640:360:100:50" output_1.mp4
```

**快速剪辑（不转码，加快速度）**

```
ffmpeg -ss 00:01:00 -to 00:01:30 -i video.mp4 -c copy output_2.mp4
```

### 视频转换/转码

**转换格式（比如 MP4 转 AVI）**

```
ffmpeg -i clip.mp4 output.avi
```

**指定编码格式（H.264 视频 + AAC 音频）**

```
ffmpeg -i input.mkv -c:v libx264 -c:a aac output.mp4
```

**调整视频分辨率**

```
ffmpeg -i clip.mp4 -vf scale=1280:720 output_3.mp4
```

**修改帧率（比如设为 30fps）**

```
ffmpeg -i clip.mp4 -r 30 output_4.mp4
```

**视频转图片序列**

```
ffmpeg -i clip.mp4 frame_%03d.png
```

**视频转 GIF（10秒、大小限制）**

```
ffmpeg -i clip.mp4 -ss 00:00:05 -t 10 -vf "fps=10,scale=320:-1" output.gif
```

### 推流

**推送 MP4 文件到 RTMP**

```
ffmpeg -re -i video.mp4 -c:v libx264 -c:a aac -f flv rtmp://192.168.1.12/live/stream
```

- `-re`：按原始帧率读取（模拟直播）
- `-f flv`：RTMP 只能用 FLV 封装格式
- `rtmp://...`：RTMP 服务器地址

参数优化

```
ffmpeg -re -stream_loop -1 -i clip.mp4 -vf "scale=1280:720,fps=15" ^
-c:v libx264 -preset ultrafast -c:a aac -b:a 64k ^
-f flv rtmp://192.168.1.12/live/stream
```

- `-re`: 按原始帧率读取（模拟直播）
- `-stream_loop -1`: 无限循环输入文件
- `-i video.mp4`: 输入文件路径
- `-vf "scale=1280:720,fps=15"`: 缩放视频为 720p 并设置帧率为 15fps
- `-c:v libx264`: 使用 libx264 进行视频编码（H.264）
- `-preset ultrafast`: 设置编码速度为最快，降低 CPU 占用
- `-c:a aac`: 音频使用 AAC 编码
- `-b:a 64k`: 设置音频码率为 64kbps
- `-f flv`: 指定封装格式为 FLV（适用于 RTMP）
- `rtmp://192.168.1.12/live/stream`: RTMP 推流地址（服务器 IP + 应用名 + 流名）

**推送摄像头画面（Linux）**

```
ffmpeg -f v4l2 -i /dev/video0 -f alsa -i hw:0 \
-c:v libx264 -c:a aac -f flv rtmp://your_server/live/cam
```

**Windows 摄像头 + 麦克风推流**

```
ffmpeg -f dshow -i video="USB Camera":audio="Microphone" \
-c:v libx264 -c:a aac -f flv rtmp://your_server/live/stream
```

**Windows 摄像头 + 麦克风推流**

```
ffmpeg -f dshow -i video="USB Camera":audio="Microphone" -c:v libx264 -c:a aac -f flv rtmp://192.168.1.12/live/stream
```

**Linux 桌面直播（全屏）**

```
ffmpeg -f x11grab -i :0.0 -c:v libx264 -f flv rtmp://your_server/live/desktop
```

**Windows 桌面直播（全屏）**

```
ffmpeg -f gdigrab -i desktop -c:v libx264 -f flv rtmp://192.168.1.12/live/screen
```



## 拉流

✅ 1. 拉 RTMP 流（最常用）

```bash
ffmpeg -i rtmp://192.168.1.12/live/stream -c copy output.mp4
```

- 拉取 RTMP 流并保存为 MP4
- `-c copy`: 视频/音频直接拷贝（不重新编码）

------

✅ 2. 拉 HLS 流（`.m3u8`）

```bash
ffmpeg -i https://example.com/live/playlist.m3u8 -c copy output.ts
```

- HLS 拉流常用于直播平台（如哔哩哔哩、抖音直播）

------

✅ 3. 拉 RTSP 流（监控摄像头常用）

```bash
ffmpeg -rtsp_transport tcp -i rtsp://admin:password@192.168.1.100:554/stream -c copy output.mp4
```

- 使用 TCP 拉取 RTSP 更稳定（默认 UDP）

保存指定时长

```
ffmpeg -rtsp_transport tcp -i rtsp://xxx -t 00:10:00 -c copy output.mp4
```

- `-t 00:10:00`：只录制前 10 分钟（格式 hh:mm:ss）

自动分段保存（循环录像，按时间切段）

```
ffmpeg -rtsp_transport tcp -i rtsp://xxx -c copy -f segment -segment_time 300 -reset_timestamps 1 output_%03d.mp4
```

- `-segment_time 300`：每段 300 秒（5 分钟）
- `output_%03d.mp4`：自动命名为 output_000.mp4, output_001.mp4...

分段 + 自动覆盖旧文件（环形录像），例如只保留 6 个文件（模拟循环录像）：

```
ffmpeg -rtsp_transport tcp -i rtsp://xxx -c copy -f segment -segment_time 300 -segment_wrap 6 output_%03d.mp4
```

重新编码保存（适用于码流不兼容的情况）

```
ffmpeg -rtsp_transport tcp -i rtsp://xxx -c:v libx264 -preset ultrafast -c:a aac output.mp4
```

- 用 `libx264` 重新编码视频，可跨平台兼容性好
- 如果设备编码格式怪异、浏览器无法播放，可使用此方式

只截帧保存图片（监控抓拍）

```
ffmpeg -rtsp_transport tcp -i rtsp://xxx -r 1 -q:v 2 image_%04d.jpg
```

- `-r 1`：每秒截 1 张图（调整为你需要的频率）
- `-q:v 2`：图片质量，1-31，越小越清晰

------

✅ 4. 拉 HTTP 流（例如网络视频或 HTTP-FLV）

```bash
ffmpeg -i http://example.com/stream.flv -c copy output.flv
```

- 适用于部分直播平台开放的 `.flv` 地址

------

✅ 5. 拉 UDP 流（例如局域网广播）

```bash
ffmpeg -i udp://239.0.0.1:1234 -c copy output.ts
```

------

📺 实时播放拉流（不保存）

```bash
ffplay rtmp://192.168.1.12/live/stream
```

- 用 `ffplay` 直接播放，非常方便调试
     （Windows 上直接双击打开 cmd，执行即可）

------

🔄 拉流并推流（转发）

拉 RTSP → 推 RTMP：

```bash
ffmpeg -rtsp_transport tcp -i rtsp://xxx -c:v libx264 -f flv rtmp://192.168.1.12/live/forwarded
```

------

⚙️ 拉流参数推荐补充（可选）

- `-timeout 10000000`: 拉流超时控制（微秒）
- `-rw_timeout 10000000`: 读取超时
- `-fflags nobuffer`: 减少延迟
- `-an`: 不处理音频（如果不需要）

