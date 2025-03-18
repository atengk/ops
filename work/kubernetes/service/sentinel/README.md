# Sentinel

**Sentinel** 是阿里巴巴开源的 **流量控制** 和 **熔断降级** 框架，专注于保障 **分布式系统稳定性**。它提供 **限流**（QPS/并发控制）、**熔断降级**（失败率、响应时间触发）、**热点参数限流**、**系统自适应保护** 等功能，并支持 **Sentinel Dashboard** 进行可视化监控和动态规则管理。Sentinel 可与 **Spring Cloud、Dubbo、Nacos** 等无缝集成，广泛应用于 **高并发场景**，如电商、支付系统等，有效防止流量突增导致的系统崩溃。

- [官网链接](https://sentinelguard.io/zh-cn/index.html)



**拉取镜像**

```
docker pull bladex/sentinel-dashboard:1.8.8
```

**推送到本地仓库**

```
docker tag bladex/sentinel-dashboard:1.8.8 registry.lingo.local/service/sentinel-dashboard:1.8.8
docker push registry.lingo.local/service/sentinel-dashboard:1.8.8
```

**保存镜像**

```
docker save registry.lingo.local/service/sentinel-dashboard:1.8.8 | gzip -c > image-sentinel-dashboard_1.8.8.tar.gz
```

**自定义配置**

修改deploy.yaml配置文件

- 资源配置：resources相关参数
- 命令参数：根据实际情况修改java的相关参数


- 其他：其他配置按照具体环境修改

**创建标签，运行在标签节点上**

```
kubectl label nodes server03.lingo.local kubernetes.service/sentinel-dashboard="true"
```

**创建服务**

```
kubectl apply -n kongyu -f deploy.yaml
```

**查看服务**

```
kubectl get -n kongyu pod,svc -l app=sentinel-dashboard
```

**查看日志**

```
kubectl logs -f -n kongyu deploy/sentinel-dashboard
```

**使用服务**

```
URL: http://192.168.1.10:23255
Username: sentinel
Password: sentinel
```

**删除服务以及数据**

```
kubectl delete -n kongyu -f deploy.yaml
```

