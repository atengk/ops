# KubeSphere LuBan

KubeSphere，是基于 Kubernetes 内核的分布式多租户商用云原生操作系统。在开源能力的基础上，在多云集群管理、微服务治理、应用管理等多个核心业务场景进行功能延伸。商用扩展中心实现高度模块化，满足不同场景业务需求。以强大的企业级云原生底座，完善的专家级解决方案和服务支持，赋能企业数字化转型和规模化运营。

自 KubeSphere v4.0 起，引入扩展机制，推出了全新的 KubeSphere 架构：**KubeSphere LuBan**，它构建在 [Kubernetes](https://kubernetes.io/zh-cn/docs/concepts/extend-kubernetes/) 之上，支持高度可配置和可扩展。KubeSphere LuBan，是一个分布式的云原生可扩展开放架构，为扩展组件提供一个可热插拔的微内核。自此，KubeSphere 所有功能组件及第三方组件都会基于 KubeSphere LuBan，以扩展组件的方式无缝融入到 KubeSphere 控制台中，并独立维护版本，真正实现即插即用的应用级云原生操作系统。

参考链接：

- [官网](https://kubesphere.io/zh/docs/v4.1/01-intro/01-introduction/)



## 在K8S上安装

**服务依赖**

- Kubernetes 版本\>=1.19.0

**安装KubeSphere Core**

```
helm upgrade --install \
    -n kubesphere-system --create-namespace ks-core \
    --set global.imageRegistry=swr.cn-southwest-2.myhuaweicloud.com/ks \
    --set extension.imageRegistry=swr.cn-southwest-2.myhuaweicloud.com/ks \
    https://charts.kubesphere.io/main/ks-core-1.1.3.tgz --debug --wait
```

**查看服务**

```
[root@k8s-master01 ~]# kubectl get pods -n kubesphere-system
NAME                                     READY   STATUS    RESTARTS   AGE
extensions-museum-699887b7d-fq8ts        1/1     Running   0          80s
ks-apiserver-7fb7f58d77-gtdgc            1/1     Running   0          80s
ks-console-846db56dd4-xqnvh              1/1     Running   0          80s
ks-controller-manager-5d96d7864f-4tk84   1/1     Running   0          80s
```

**访问KubeSphere Web 控制台**

```
URL: http://192.168.1.101:30880
Account: admin
Password: P@88w0rd
```



