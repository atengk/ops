# 构建KubeVirt容器镜像



**下载官方镜像**

```
wget http://cloud.centos.org/centos/7/images/CentOS-7-x86_64-GenericCloud-2009.qcow2c
mv CentOS-7-x86_64-GenericCloud-2009.qcow2c CentOS-7-x86_64-GenericCloud-2009.qcow2
```

**编辑Dockerfile**

```
# cat Dockerfile
FROM scratch
ADD --chown=107:107 CentOS-7-x86_64-GenericCloud-2009.qcow2 /disk/
```

**构建镜像**

```
docker build -t swr.cn-north-1.myhuaweicloud.com/kongyu/kubevirt/linux:centos-7-x86_64-genericcloud-2009 .
```

**推送到仓库**

```
docker push swr.cn-north-1.myhuaweicloud.com/kongyu/kubevirt/centos:centos7.9.2009
```

