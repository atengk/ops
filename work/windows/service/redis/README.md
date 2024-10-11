# Windows安装使用Redis

**下载Redis**

```
https://github.com/tporadowski/redis/releases/download/v5.0.14.1/Redis-x64-5.0.14.1.zip
```

**解压Redis文件**

将下载的Redis压缩包解压到一个方便的位置，例如 `C:\software\redis`。

**配置Redis**

编辑 `C:\software\redis\redis.windows.conf ` 覆盖写入以下内容

```
bind 0.0.0.0
port 6379
databases 20
dir C:\software\redis
requirepass Admin@123
protected-mode no
daemonize no
save ""
appendonly yes
```

**设置Redis为Windows服务**

如果你希望Redis自动作为Windows服务启动，可以使用以下步骤。

1. 在命令提示符中，导航到Redis目录：

    ```cmd
    cd c:\software\redis
    ```

2. 运行以下命令将Redis安装为Windows服务：

    ```cmd
    redis-server --service-install redis.windows.conf
    ```

3. 启动Redis服务：

    ```cmd
    redis-server --service-start
    ```

4. 停止Redis服务：

    ```cmd
    redis-server --service-stop
    ```

5. 删除Redis服务：

    ```cmd
    redis-server --service-uninstall
    ```

