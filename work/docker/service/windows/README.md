

# 容器安装Windows

https://github.com/dockur/windows

安装win10

```shell
docker run --name win10 \
    -it --rm -p 8006:8006 \
    -e VERSION="win10" \
    -e LANGUAGE="Chinese" \
    -e REGION="zh_CN" \
    -e KEYBOARD="zh_CN" \
    -e USERNAME="admin" \
    -e PASSWORD="Admin@123" \
    -e RAM_SIZE="4G" \
    -e CPU_CORES="2" \
    -e DISK_SIZE="100G" \
    -v /data/service/dockurr/win10:/storage \
    --device=/dev/kvm --cap-add NET_ADMIN \
    --stop-timeout 200 dockurr/windows
```

