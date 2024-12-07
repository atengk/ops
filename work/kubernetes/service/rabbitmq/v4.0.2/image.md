# 下载镜像

镜像列表

```
app=rabbitmq
version=4.0.2
cat > images-list.txt <<EOF
bitnami/rabbitmq:${version}
bitnami/os-shell:12
EOF
```

下载镜像

```
images=$(cat images-list.txt)
for image in $images
do
    docker pull $image
done
```

设置镜像仓库和命名空间

```
registry_address="registry.lingo.local/bitnami"
```

设置镜像标签并推送到本地仓库

```shell
images=$(cat images-list.txt)
for image in $images
do
	image_local=$(echo ${image} | awk -F "/" '{print "'"${registry_address}"'/"$NF}')
	docker tag ${image} ${image_local}
	docker push ${image_local}
done
```

保存到本地文件

```
images=$(cat images-list.txt | awk -F "/" '{print "'"${registry_address}"'/"$NF}')
docker save $images | gzip -c > images-${app}_${version}.tar.gz
```



# 下载插件

| 插件                              | 功能核心           | 适用场景                             |
| --------------------------------- | ------------------ | ------------------------------------ |
| rabbitmq_delayed_message_exchange | 实现消息的延迟投递 | 延迟队列需求，例如订单超时、任务调度 |

**设置版本**

```
export version=4.0.2
```

**创建目录**

```
mkdir plugins
```

**下载插件**

rabbitmq-delayed-message-exchange

```
wget -P plugins https://github.com/rabbitmq/rabbitmq-delayed-message-exchange/releases/download/v${version}/rabbitmq_delayed_message_exchange-${version}.ez
```

**上传到HTTP服务器**

将以上下载的插件上传到本地的HTTP服务上面，方便后续安装的时候加载插件。
