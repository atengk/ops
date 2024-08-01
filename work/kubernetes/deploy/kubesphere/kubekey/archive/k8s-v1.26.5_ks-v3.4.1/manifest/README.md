# 制作离线包

> 先是以在线安装，就能得到镜像清单，然后就可以根据清单构建制品
>
> 只适用于centos7系统，其他系统需要重新制作，参考[官网](https://github.com/kubesphere/kubekey/blob/master/docs/manifest-example.md)

设置时区变量

```
export KKZONE=cn
```

构建最小制品

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

