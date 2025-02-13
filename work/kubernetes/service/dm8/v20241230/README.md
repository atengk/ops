# 达梦数据库

达梦数据库（DM）是一款国产关系型数据库管理系统，由达梦数据库公司开发，主要面向政府、金融、电力等行业。其具有高性能、高可靠性、强安全性和兼容性，支持SQL标准和多种数据库功能，如事务管理、数据备份、恢复等。DM数据库提供跨平台支持，能够在多种操作系统上运行，广泛应用于大规模数据处理和高并发场景。

- [官网地址](https://eco.dameng.com/document/dm/zh-cn/start/dm-install-docker.html)

**制作镜像**

参考文档：[自定义镜像](/work/docker/service/dm8/v20241230/)

**配置修改**

修改 `deploy.yaml` 文件

- 参数配置：spec.template.spec.containers[0].env[*]: 根据实际情况修改相关参数
- 存储类：spec.volumeClaimTemplates[*].spec.storageClassName
- 镜像地址：spec.template.spec.containers[0].image
- 其他：其他配置按照具体环境修改

**添加节点标签**

创建标签，运行在标签节点上

```
kubectl label nodes server03.lingo.local kubernetes.service/dm8="true"
```

**创建服务**

```
kubectl apply -n kongyu -f deploy.yaml
```

**查看服务**

```
kubectl get -n kongyu pod,pvc,svc -l app=dm8
kubectl logs -n kongyu -f --tail=100 dm8-0
```

**访问服务**

```
Address: http://192.168.1.10:12177
Username: SYSDBA
Password: Admin@123
```

**删除服务**

```
kubectl delete -n kongyu -f deploy.yaml
kubectl delete -n kongyu pvc -l app=dm8
```





