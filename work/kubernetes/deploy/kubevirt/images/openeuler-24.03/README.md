# 构建KubeVirt容器镜像



**下载官方镜像**

```
wget https://mirror.iscas.ac.cn/openeuler/openEuler-24.03-LTS/virtual_machine_img/x86_64/openEuler-24.03-LTS-x86_64.qcow2.xz
tar -xvf openEuler-24.03-LTS-x86_64.qcow2.xz
```

**编辑Dockerfile**

```
# cat Dockerfile
FROM scratch
ADD --chown=107:107 openEuler-24.03-LTS-x86_64.qcow2 /disk/
```

**构建镜像**

```
docker build -t swr.cn-north-1.myhuaweicloud.com/kongyu/kubevirt/linux:openeuler-24.03-lts-x86_64 .
```

**推送到仓库**

```
docker push swr.cn-north-1.myhuaweicloud.com/kongyu/kubevirt/linux:openeuler-24.03-lts-x86_64
```

