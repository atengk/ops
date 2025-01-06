# DolphinScheduler

DolphinScheduler 是一个开源的分布式工作流调度系统，专为数据处理和任务调度设计。支持 DAG 可视化任务编排，具备强大的任务依赖管理、高可用性和扩展性。它易于集成，支持多种任务类型，适合大规模数据工程和复杂工作流场景。

- [官网地址](https://dolphinscheduler.apache.org/zh-cn)



## 前置要求

- [PostgreSQL](/work/kubernetes/service/postgresql/v17.2.0/standalone/)
- [Zookeeper](/work/kubernetes/service/zookeeper/v3.9.3/)
- [MinIO](/work/kubernetes/service/minio/v2024.11.7/standalone/)
- 支持ReadWriteMany的存储类，[参考NFS](/work/kubernetes/deploy/storage/nfs/nfs-client/)

## 下载软件包

**下载源码包**

```
wget https://github.com/apache/dolphinscheduler/archive/refs/tags/3.2.2.tar.gz
```

**打包chart**

```
tar -zxf dolphinscheduler-3.2.2.tar.gz
# 将dolphinscheduler-3.2.2/deploy/kubernetes/dolphinscheduler/Chart.yaml文件的dependencies删除然后再打包
helm package dolphinscheduler-3.2.2/deploy/kubernetes/dolphinscheduler/
rm -rf dolphinscheduler-3.2.2/
```

**修改配置**

values.yaml是修改后的配置，可以根据环境做出适当修改

- 镜像地址：image.registry
- 数据库配置：externalDatabase.*
- Zookeeper配置：externalRegistry.*
- minio配置：conf.common.resource.aws.*
- 公共存储类配置：sharedStoragePersistence.storage fsFileResourcePersistence.storage
- master配置：master.replicas master.persistentVolumeClaim.storageClassName master.persistentVolumeClaim.storage master.env.*
- worker配置：worker.replicas worker.persistentVolumeClaim.dataPersistentVolume.storageClassName worker.dataPersistentVolume.persistentVolumeClaim.storage worker.env.*
- alert配置：alert.replicas alert.persistentVolumeClaim.storageClassName alert.persistentVolumeClaim.storage alert.env.*
- api配置：api.replicas alert.persistentVolumeClaim.storageClassName api.persistentVolumeClaim.storage api.env.*
- 其他配置：...

```
cat values.yaml
```

**创建服务**

```
helm install dolphinscheduler -n kongyu -f values.yaml dolphinscheduler-helm-3.2.2.tgz
```

**查看服务**

```
kubectl get -n kongyu pod,svc,pvc -l app.kubernetes.io/instance=dolphinscheduler
```

**访问服务**

> service/dolphinscheduler-api为12345端口的

```
URL: http://192.168.1.10:31882/dolphinscheduler/
Username: admin
Password: dolphinscheduler123
```

**删除服务**

```
helm uninstall -n kongyu dolphinscheduler
kubectl delete pvc -n kongyu -l app.kubernetes.io/instance=dolphinscheduler
```

