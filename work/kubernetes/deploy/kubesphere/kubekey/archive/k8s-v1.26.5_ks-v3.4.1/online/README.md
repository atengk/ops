# KubeKey在线安装KubeSphere

安装kubekey

```
export KKZONE=cn
export VERSION=v3.0.13
curl -sfL https://get-kk.kubesphere.io | sh -
mv kk /usr/bin
```

安装依赖包

> 注意配置好yum源

```
kk init os -f kk-config-ks-online.yaml
```

创建集群

```
export KKZONE=cn
kk create cluster -f kk-config-ks-online.yaml
```

生成manifest清单

```
kk create manifest --filename manifest-sample.yaml
```

删除集群

> --all：删除所有的服务，不加的话仅删除k8s

```
kk delete cluster -f kk-config-ks-online.yaml --all
```

重启服务器

> 删除完后重启所有服务器

```
reboot
```
