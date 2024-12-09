# Windows

Docker 容器内的 Windows，[官网链接](https://github.com/dockur/windows)。

**特点✨**

- ISO下载器
- KVM加速
- 基于网络的查看器



## 基础配置

**检查是否支持 KVM**

检查 CPU 是否支持虚拟化 使用以下命令检查是否启用了虚拟化技术（例如 Intel VT 或 AMD-V）：

```shell
egrep -c '(vmx|svm)' /proc/cpuinfo
```

- 如果输出大于 0，则表示 CPU 支持虚拟化。

- 如果输出为 0，则表示 CPU 不支持虚拟化，或者该功能被禁用。

**拉取镜像**

```shell
docker pull dockurr/windows:4.06
```

**推送到仓库**

```
docker tag dockurr/windows:4.06 registry.lingo.local/service/windows:4.06
docker push registry.lingo.local/service/windows:4.06
```

**保存镜像**

```
docker save registry.lingo.local/service/windows:4.06 | gzip -c > image-windows_4.06.tar.gz
```

**添加节点标签**

创建标签，运行在标签节点上

```
kubectl label nodes server03.lingo.local kubernetes.service/win10="true"
```



## 在线安装win10

**运行服务**

注意修改以下配置

- 账号密码：USERNAME PASSWORD
- 系统配置：RAM_SIZE CPU_CORES
- 系统存储： DISK_SIZE，需要用到/storage目录
- 共享存储：需要用到/data目录，进入系统后打开“文件资源管理器”并单击“网络”部分
- 端口：3389是rdp端口，8006是VNC端口

- VERSION: 版本查看：[地址](https://github.com/dockur/windows?tab=readme-ov-file#how-do-i-select-the-windows-version)
- 其他配置参考官方文档
- 存储类：storageClassName

```
kubectl apply -n kongyu -f deploy-online.yaml
```

**查看服务**

```
kubectl get -n kongyu pod,pvc,svc -l app=win10
kubectl logs -n kongyu -f --tail=100 win10-0
```

**访问系统**

```
RDP: 192.168.1.12:20016
HTTP: http://192.168.1.12:20017
Username: admin
Password: Admin@123
```

**删除服务**

```
kubectl delete -n kongyu -f deploy.yaml
kubectl delete -n kongyu pvc -l app=win10
```



## 离线安装win10

**运行服务**

注意修改以下配置

- 账号密码：USERNAME PASSWORD
- 系统配置：RAM_SIZE CPU_CORES
- 系统存储： DISK_SIZE，需要用到/storage目录
- 共享存储：需要用到/data目录，进入系统后打开“文件资源管理器”并单击“网络”部分
- 端口：3389是rdp端口，8006是VNC端口

- [VERSION](https://github.com/dockur/windows?tab=readme-ov-file#how-do-i-install-a-custom-image): 使用本地地址，例如：http://192.168.1.12:9000/public-bucket/images/tiny10_x64_23h2.iso。或者挂载ISO镜像到 `/custom.iso` 来替代VERSION使用本地的镜像，例如：`-v /home/user/example.iso:/custom.iso`。离线下载ISO镜像参考链接：https://hellowindows.cn/
- 其他配置参考官方文档
- 存储类：storageClassName

```
kubectl apply -n kongyu -f deploy-offline.yaml
```

**查看服务**

```
kubectl get -n kongyu pod,pvc,svc -l app=win10
kubectl logs -n kongyu -f --tail=100 win10-0
```

**访问系统**

```
RDP: 192.168.1.12:20016
HTTP: http://192.168.1.12:20017
Username: admin
Password: Admin@123
```

**删除服务**

```
kubectl delete -n kongyu -f deploy.yaml
kubectl delete -n kongyu pvc -l app=win10
```
