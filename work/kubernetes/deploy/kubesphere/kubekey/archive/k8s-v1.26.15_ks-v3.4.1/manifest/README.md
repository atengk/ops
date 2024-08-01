# 制作离线包

> 只适用于centos7系统，其他系统需要重新制作，参考[官网](https://github.com/kubesphere/kubekey/blob/master/docs/manifest-example.md)

查看支持的k8s版本

```
./kk version --show-supported-k8s
```

生成制品清单示例

```
./kk create manifest --with-kubernetes v1.26.15 --arch amd64 --with-registry -f kk-manifest-ks-sample.yaml
```

设置时区变量

```
export KKZONE=cn
```

构建最小制品

> 这三种选其一即可，其实也就是KubeSphere的镜像的变化

```
./kk artifact export -m kk-manifest-ks.yaml -o kubekey-artifact-ks.tar.gz
```

构建最大制品

```
./kk artifact export -m kk-manifest-ks-max.yaml -o kubekey-artifact-ks-max.tar.gz
```

构建所有制品

```
./kk artifact export -m kk-manifest-ks-all.yaml -o kubekey-artifact-ks-all.tar.gz
```

