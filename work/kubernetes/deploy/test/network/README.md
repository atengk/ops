创建服务端

```
kubectl apply -f iperf3-server.yaml
```

安装软件包

```
yum -y install iperf3
```

测试外部访问k8s集群

```
iperf3 -c 192.168.1.101 -p 11475
```

测试内部访问k8s集群

```
kubectl apply -f iperf3-client.yaml
kubectl logs -f -l job-name=iperf3-client
```

