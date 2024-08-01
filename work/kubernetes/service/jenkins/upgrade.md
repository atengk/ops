

# 2.426.2 -> 2.452.3

在2.452.3的版本下执行升级命令

```
helm upgrade jenkins -n kongyu -f values.yaml jenkins-13.4.9.tgz
```

查看服务

```shell
kubectl get -n kongyu pod,svc,pvc -l app.kubernetes.io/instance=jenkins
kubectl logs -f -n kongyu -l app.kubernetes.io/instance=jenkins
```

