# KubeKey离线安装KubeSphere

> 参考[官方文档](https://github.com/kubesphere/kubekey/blob/master/README_zh-CN.md)

安装kubekey

```
tar -zxvf kubekey-v3.0.13-linux-amd64.tar.gz -C /usr/bin/
```

初始化镜像仓库

```
kk init registry -f kk-config-ks.yaml -a kubekey-artifact-ks.tar.gz
```

查看镜像仓库

> 数据存放在/mnt/registry下，这个镜像仓库只做临时安装用，正常情况下是用harbor

```
systemctl status registry
```

推送镜像到私有镜像仓库

```
kk artifact image push -f kk-config-ks.yaml -a kubekey-artifact-ks.tar.gz
```

创建集群安装k8s和ks

> 注意修改相应的主机信息

```
kk create cluster -f kk-config-ks.yaml -a kubekey-artifact-ks.tar.gz --with-packages
```

命令补全

```
kubectl completion bash > /etc/bash_completion.d/kubectl
source <(kubectl completion bash)
kubeadm completion bash > /etc/bash_completion.d/kubeadm
source <(kubeadm completion bash)
helm completion bash > /etc/bash_completion.d/helm
source <(helm completion bash)
```

访问kubesphere

```
URL: http://192.168.1.101:30880/
Username: admin
Password: Admin@123
```

删除集群

> --all：删除所有的服务，不加的话仅删除k8s

```
kk delete cluster -f kk-config-ks.yaml --all
```

重启服务器

> 删除完后重启所有服务器

```
reboot
```

