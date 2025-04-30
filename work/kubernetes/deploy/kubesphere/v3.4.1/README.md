# 安装KubeSphere

基于k8s安装KubeSphere平台

https://kubesphere.io/zh/docs/v3.4/quick-start/minimal-kubesphere-on-k8s/



## 离线安装

### 下载文件

**下载配置文件**

```
wget https://github.com/kubesphere/ks-installer/releases/download/v3.4.1/kubesphere-installer.yaml
wget https://github.com/kubesphere/ks-installer/releases/download/v3.4.1/cluster-configuration.yaml
```

**下载镜像脚本和列表文件**

```
wget https://github.com/kubesphere/ks-installer/releases/download/v3.4.1/offline-installation-tool.sh
wget https://github.com/kubesphere/ks-installer/releases/download/v3.4.1/images-list.txt
chmod +x offline-installation-tool.sh
```

**下载卸载脚本**

```
curl -L -o kubesphere-delete.sh https://raw.githubusercontent.com/kubesphere/ks-installer/release-3.4/scripts/kubesphere-delete.sh
chmod +x kubesphere-delete.sh
```

**下载镜像包**

如果docker.io仓库无法下载，可以参考官网提供的[文档](https://kubesphere.io/zh/docs/v3.4/installing-on-kubernetes/on-prem-kubernetes/install-ks-on-linux-airgapped/)，在最下面有镜像清单，将其替换images-list.txt的内容。

```
./offline-installation-tool.sh -s -l images-list.txt -d ./kubesphere-images
```

### 推送镜像到仓库

将下载的镜像推送到镜像仓库中，可以参考安装[registry](https://atengk.github.io/work/#/work/kubernetes/deploy/harbor/registry/)或者[harbor](https://atengk.github.io/work/#/work/kubernetes/deploy/harbor/v2.11.1/)仓库

```shell
images_dir="./kubesphere-images" # 下载的镜像文件目录
images_list_file="./images-list.txt" # 镜像列表文件
registry_url="registry.lingo.local" # 镜像仓库地址，需要提前登录仓库
registry_namespace="kubesphereio" # 镜像仓库的命名空间
for file in $(ls ${images_dir})
do
	docker load -i ${images_dir}/${file}
done
for image in $(grep -E -v "^#|^$" ${images_list_file})
do
	image_local=$(echo ${image} | awk -F "/" '{print "'"${registry_url}/${registry_namespace}"'/"$NF}')
	docker tag ${image} ${image_local}
	docker push ${image_local}
done
```

### 修改配置文件

修改cluster-configuration.yaml

> 存储类安装参考[openebs-hostpath](https://atengk.github.io/work/#/work/kubernetes/deploy/storage/openebs/local/)

```shell
# vi +10 cluster-configuration.yaml
  persistence: # 存储类，为空则使用默认的
    storageClass: ""
  local_registry: "registry.lingo.local" # 镜像仓库地址
  namespace_override: "kubesphereio" # 镜像仓库的命名空间
  authentication:
    adminPassword: Admin@123 # KubeSphere的默认admin密码
    jwtSecret: ''
    oauthOptions:
      accessTokenMaxAge: 0h # 用户登录永不过期
```

修改kubesphere-installer.yaml

```
sed "s#kubesphere/ks-installer:v3.4.1#registry.lingo.local/kubesphereio/ks-installer:v3.4.1#" kubesphere-installer.yaml
```

### 安装KubeSphere

应用配置文件

```
kubectl apply -f kubesphere-installer.yaml
kubectl apply -f cluster-configuration.yaml
```

查看安装日志

```
kubectl logs -n kubesphere-system -f deploy/ks-installer
```

访问KubeSphere平台

```
URL: http://192.168.1.101:30880
Username: admin
Password: Admin@123
```



## 在线安装

### 下载文件

**下载配置文件**

```
wget https://github.com/kubesphere/ks-installer/releases/download/v3.4.1/kubesphere-installer.yaml
wget https://github.com/kubesphere/ks-installer/releases/download/v3.4.1/cluster-configuration.yaml
```

**下载卸载脚本**

```
curl -L -o kubesphere-delete.sh https://raw.githubusercontent.com/kubesphere/ks-installer/release-3.4/scripts/kubesphere-delete.sh
chmod +x kubesphere-delete.sh
```

### 修改配置文件

修改cluster-configuration.yaml

> 存储类安装参考[openebs-hostpath](https://atengk.github.io/work/#/work/kubernetes/deploy/storage/openebs/local/)

```shell
# vi +10 cluster-configuration.yaml
  persistence: # 存储类，为空则使用默认的
    storageClass: ""
  local_registry: "registry.cn-beijing.aliyuncs.com" # 镜像仓库地址
  namespace_override: "kubesphereio" # 镜像仓库的命名空间
  authentication:
    adminPassword: Admin@123 # KubeSphere的默认admin密码
    jwtSecret: ''
    oauthOptions:
      accessTokenMaxAge: 0h # 用户登录永不过期
```

修改kubesphere-installer.yaml

```
sed "s#kubesphere/ks-installer:v3.4.1#registry.cn-beijing.aliyuncs.com/kubesphereio/ks-installer:v3.4.1#" kubesphere-installer.yaml
```

### 安装KubeSphere

应用配置文件

```
kubectl apply -f kubesphere-installer.yaml
kubectl apply -f cluster-configuration.yaml
```

查看安装日志

```
kubectl logs --tail=200 -n kubesphere-system -f deploy/ks-installer
```

访问KubeSphere平台

```
URL: http://192.168.1.101:30880
Username: admin
Password: Admin@123
```



## 卸载KubeSphere

**先卸载可插拔组件，然后再卸载KubeSphere**

卸载可插拔组件：https://kubesphere.io/zh/docs/v3.4/pluggable-components/uninstall-pluggable-components/

从 Kubernetes 上卸载 KubeSphere：https://kubesphere.io/zh/docs/v3.4/installing-on-kubernetes/uninstall-kubesphere-from-k8s/