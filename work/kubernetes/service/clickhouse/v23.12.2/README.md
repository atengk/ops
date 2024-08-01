# 安装clickhouse

修改配置

> values.yaml是修改后的配置，可以根据环境做出适当修改，例如修改存储类global.storageClass

```
cat values.yaml
```

创建服务

```shell
helm install clickhouse -n kongyu -f values.yaml clickhouse-4.2.0.tgz
```

查看服务

```
kubectl get -n kongyu pod,svc,pvc -l app.kubernetes.io/instance=clickhouse
kubectl logs -f -n kongyu clickhouse-shard0-0
```

使用服务

```
kubectl run clickhouse-client --rm --tty -i --restart='Never' --image  registry.lingo.local/service/clickhouse:23.12.2 --namespace kongyu --command -- clickhouse-client --host clickhouse --port 9000 --user admin --password Admin@123 --query "SELECT * FROM system.clusters;"
```

删除服务以及数据

```
helm uninstall -n kongyu clickhouse
kubectl delete -n kongyu pvc data-clickhouse-shard{0..1}-{0..2}
```

