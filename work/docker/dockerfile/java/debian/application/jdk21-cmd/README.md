## SpringBoot应用

使用Dockerfile构建SpringBoot应用，将Jar文件拷贝到容器后自定义设置启动应用的命令。



**修改Dockerfile**

- 修改Jar包路径：JAR_FILE
- 设置应用的端口：EXPOSE
- 设置应用运行的参数：CMD

**构建镜像**

```shell
docker build -t registry.lingo.local/service/springboot3-demo:v1.0 .
```

**测试镜像**

使用默认启动命令

```shell
docker run --rm \
    -p 8080:8080 \
    registry.lingo.local/service/springboot3-demo:v1.0
```

自定义启动命令

```bash
docker run --rm \
    -p 8080:8080 \
    registry.lingo.local/service/springboot3-demo:v1.0 \
    -server \
    -Xms128m -Xmx1024m \
    -jar springboot3-demo-v1.0.jar \
    --server.port=8080
```

**推送镜像**

```shell
docker push registry.lingo.local/service/springboot3-demo:v1.0
```

