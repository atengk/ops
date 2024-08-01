# 安装Nginx

查看版本

```
helm search repo bitnami/nginx -l
```

下载chart

```
helm pull bitnami/nginx --version 18.1.4
```

修改配置

> values.yaml是修改后的配置，可以根据环境做出适当修改，例如修改存储类global.storageClass

```
cat values.yaml
```

创建服务

```shell
helm install nginx -n kongyu -f values-nginx.yaml nginx-18.1.4.tgz
```

查看服务

```shell
kubectl get -n kongyu pod,svc,pvc -l app.kubernetes.io/instance=nginx
```

使用服务

> 添加**serverBlock**配置的server端口

```
kubectl patch service -n kongyu nginx -p '{"spec":{"ports":[{"name":"http-8888","port":8888,"targetPort":8888,"protocol":"TCP"}]}}'
kubectl patch service -n kongyu nginx -p '{"spec":{"ports":[{"name":"http-9999","port":9999,"targetPort":9999,"protocol":"TCP"}]}}'
```

> 获取nodePort

```
kubectl get service -n kongyu nginx -o jsonpath='{.spec.ports[?(@.port==8888)].nodePort}'
```

删除服务以及数据

```
helm uninstall -n kongyu nginx
```

