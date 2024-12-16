# 下载镜像

镜像列表

```
app=opensearch
version=1.3.19
cat > images-list.txt <<EOF
bitnami/os-shell:12
bitnami/opensearch:${version}
bitnami/opensearch-dashboards:${version}
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

| 插件         | 功能核心                 | 适用场景               |
| ------------ | ------------------------ | ---------------------- |
| analysis-icu | 多语言支持，复杂字符处理 | 国际化搜索，多语言系统 |

**设置版本**

```
export version=1.3.19
```

**创建目录**

```
mkdir plugins
```

**下载插件**

analysis-icu

> 注意这个包名，必须要插件名保持一致，不然安装插件会报错的

```
wget -O plugins/analysis-ik-${version}.zip https://release.infinilabs.com/analysis-ik/stable/opensearch-analysis-ik-${version}.zip
```

**上传到HTTP服务器**

将以上下载的插件上传到本地的HTTP服务上面，方便后续安装的时候加载插件。

