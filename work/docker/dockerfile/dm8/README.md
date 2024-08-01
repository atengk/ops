## 构建镜像

```shell
docker build -t registry.lingo.local/service/dm8_single:v20230417 .
```



## 测试镜像

```shell
docker run --rm -it -p 5236:5236 --name dm8_test \
    registry.lingo.local/service/dm8_single:v20230417

docker run -d -p 5236:5236 --restart=always --name dm8_test \
    -v $(pwd)/data:/data \
    registry.lingo.local/service/dm8_single:v20230417
docker rm -f dm8_test
```



## 推送镜像

```shell
docker push registry.lingo.local/service/dm8_single:v20230417
```

