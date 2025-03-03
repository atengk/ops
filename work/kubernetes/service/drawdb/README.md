# drawDB

免费，简单，直观的数据库模式编辑器和SQL生成器。

参考链接：

- [官网](https://www.drawdb.app/editor)
- [Github](https://github.com/drawdb-io/drawdb)
- [使用文档](https://drawdb-io.github.io/docs/create-diagram)



**自定义配置**

修改deploy.yaml配置文件

- 资源配置：Deployment中的resources和args中的相关参数


- 其他：其他配置按照具体环境修改

**添加节点标签**

创建标签，运行在标签节点上

```
kubectl label nodes server03.lingo.local kubernetes.service/drawdb="true"
```

**创建服务**

```
kubectl apply -n kongyu -f deploy.yaml
```

**查看服务**

```
kubectl get -n kongyu pod,svc -l app=drawdb
```

**查看日志**

```
kubectl logs -n kongyu -f --tail=100 deploy/drawdb
```

**访问服务**

```
URL: http://192.168.1.10:30128/editor
```

**删除服务**

```
kubectl delete -n kongyu -f deploy.yaml
```

