# kkFileView

kkFileView为文件文档在线预览解决方案，该项目使用流行的spring boot搭建，易上手和部署，基本支持主流办公文档的在线预览，如doc,docx,xls,xlsx,ppt,pptx,pdf,txt,zip,rar,图片,视频,音频等等

- [官网链接](https://www.kkview.cn/zh-cn/index.html)

- [镜像构建文档](/work/docker/dockerfile/kkfileview/v4.4.0/)



**配置修改**

- `containers`容器的resources、探针、亲和性等

**添加节点标签**

创建标签，运行在标签节点上

```
kubectl label nodes server03.lingo.local kubernetes.service/kkfileview="true"
```

**创建服务**

```
kubectl apply -n kongyu -f deploy.yaml
```

**查看服务**

```
kubectl get -n kongyu pod,svc -l app=kkfileview
kubectl logs -n kongyu -f --tail=200 deploy/kkfileview
```

**访问服务**

获取访问IP和端口

```
NODE_PORT=$(kubectl -n kongyu get svc kkfileview-service -o jsonpath='{.spec.ports[?(@.port==8012)].nodePort}')
NODE_IP=$(kubectl get nodes -o jsonpath='{.items[0].status.addresses[?(@.type=="InternalIP")].address}')
```

输出访问地址

```
echo "http://$NODE_IP:$NODE_PORT"
```

**删除服务**

```
kubectl delete -n kongyu -f deploy.yaml
```