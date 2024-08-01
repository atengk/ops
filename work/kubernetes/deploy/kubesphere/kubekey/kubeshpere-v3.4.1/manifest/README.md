# 制作离线包

> 只适用于centos7和OpenEuler24.03系统，其他系统需要重新制作，参考[官网](https://github.com/kubesphere/kubekey/blob/master/docs/manifest-example.md)
> 镜像包就是将这依赖软件包做成离线yum包，保证其根目录能使用yum安装，最后打成ISO镜像就行了，以下给出关键命令
> dnf download --resolve --alldeps --downloaddir=openEuler-24.03-amd64/packages nfs-utils net-tools bash-completion openssl socat conntrack ipset ebtables chrony ipvsadm tar zip unzip wget curl vim
> createrepo openEuler-24.03-amd64/packages
> 将openEuler-24.03-amd64/目录下的数据做成ISO

查看支持的k8s版本

```
kk version --show-supported-k8s
```

生成制品清单示例

```
kk create manifest --with-kubernetes v1.23.17,v1.24.17,v1.25.16,v1.26.15,v1.27.12,v1.28.8,v1.29.3 --arch amd64 --with-registry -f kk-manifest-ks-sample.yaml
## 生成支持多个
```

设置时区变量

```
export KKZONE=cn
```

构建最小制品

> 这三种选其一即可，其实也就是KubeSphere的镜像的变化

```
kk artifact export -m kk-manifest-ks.yaml -o kubekey-artifact-ks.tar.gz
```

构建最大制品

```
kk artifact export -m kk-manifest-ks-max.yaml -o kubekey-artifact-ks-max.tar.gz
```

构建所有制品

```
kk artifact export -m kk-manifest-ks-all.yaml -o kubekey-artifact-ks-all.tar.gz
```

