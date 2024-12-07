# 下载镜像

镜像列表

```
app=elasticsearch
version=7.17.26
cat > images-list.txt <<EOF
bitnami/os-shell:12
bitnami/elasticsearch:${version}
bitnami/kibana:${version}
bitnami/elasticsearch-exporter:1.8.0
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

| 插件              | 功能核心                 | 适用场景                         |
| ----------------- | ------------------------ | -------------------------------- |
| analysis-icu      | 多语言支持，复杂字符处理 | 国际化搜索，多语言系统           |
| analysis-phonetic | 音标编码，发音匹配       | 拼音搜索、语音识别、拼写错误纠正 |
| analysis-smartcn  | 中文分词，停用词处理     | 中文内容索引和搜索               |

**设置版本**

```
export version=7.17.26
```

**创建目录**

```
mkdir plugins
```

**下载插件**

analysis-phonetic

```
wget -P plugins https://artifacts.elastic.co/downloads/elasticsearch-plugins/analysis-phonetic/analysis-phonetic-${version}.zip
```

analysis-icu

```
wget -P plugins https://artifacts.elastic.co/downloads/elasticsearch-plugins/analysis-icu/analysis-icu-${version}.zip
```

analysis-smartcn

```
wget -P plugins https://artifacts.elastic.co/downloads/elasticsearch-plugins/analysis-smartcn/analysis-smartcn-${version}.zip
```

**上传到HTTP服务器**

将以上下载的插件上传到本地的HTTP服务上面，方便后续安装的时候加载插件。
