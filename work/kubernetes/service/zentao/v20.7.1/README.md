# ZenTao

禅道（ZenTao）是一款专注于项目管理和开发流程管理的开源软件，主要应用于软件开发领域。它由易软天创开发，提供了从项目规划、需求管理、任务分配、测试管理、到发布跟踪的完整解决方案。禅道采用PHP语言开发，支持MySQL作为数据库，界面友好且易于定制。

**配置修改**

- 修改storageClassName

**添加节点标签**

创建标签，运行在标签节点上

```
kubectl label nodes server03.lingo.local kubernetes.service/zentao="true"
```

**创建服务**

```
kubectl apply -n kongyu -f deploy.yaml
```

**查看服务**

```
kubectl get -n kongyu pod,svc,pvc -l app=zentao
kubectl logs -n kongyu -f --tail=200 zentao-0
```

**访问服务**

```
Address: http://192.168.1.10:31018
```

**删除服务**

```
kubectl delete -n kongyu -f deploy.yaml
kubectl delete -n kongyu pvc -l app=zentao
```


