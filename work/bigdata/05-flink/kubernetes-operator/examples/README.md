# Flink Operator使用文档



## 最小化部署

### 无依赖模式

在使用Maven打包时，Flink相关的依赖作用域都是设置为provided，适用于这种情况，但是要注意涉及到的相关依赖要保证image镜像中存在，如果不存在参考依赖模式或者重新制作镜像将相关依赖COPY进去。

**创建应用**

```bash
kubectl apply -f flink-spring.yaml
```

**查看应用**

查看应用

```bash
kubectl get -n ateng-flink flinkdep flink-spring
```

查看pod

```bash
kubectl get -n ateng-flink pod,svc -l app=flink-spring
kubectl logs -n ateng-flink -f --tail=200 -l app=flink-spring
```

**删除应用**

```bash
kubectl delete -f flink-spring.yaml
```

### 依赖模式

将任务需要的依赖作用域设置为compile，例如我这里是需要用到Kafka Connector，pom.xml的依赖配置如下

```xml
<!-- Apache Flink 连接器基础库库 -->
<dependency>
    <groupId>org.apache.flink</groupId>
    <artifactId>flink-connector-base</artifactId>
    <version>${flink.version}</version>
    <scope>compile</scope>
</dependency>
<!-- Apache Flink Kafka 连接器库 -->
<dependency>
    <groupId>org.apache.flink</groupId>
    <artifactId>flink-connector-kafka</artifactId>
    <version>${flink-kafka.version}</version>
    <scope>compile</scope>
</dependency>
```

**创建应用**

```bash
kubectl apply -f flink-spring-dep.yaml
```

**查看应用**

查看应用

```bash
kubectl get -n ateng-flink flinkdep flink-spring-dep
```

查看pod

```bash
kubectl get -n ateng-flink pod,svc -l app=flink-spring-dep
kubectl logs -n ateng-flink -f --tail=200 -l app=flink-spring-dep
```

**删除应用**

```bash
kubectl delete -f flink-spring-dep.yaml
```



## 标准部署

以生成模拟数据并打印中的任务为例

**创建应用**

```bash
kubectl apply -f flink-standard-myapp.yaml
```

**查看应用**

查看pod

```bash
kubectl get -n ateng-flink pod,svc,pvc -l app=flink-standard
kubectl logs -n ateng-flink -f --tail=200 -l app=flink-standard
```

查看应用

```bash
kubectl get -n ateng-flink flinkdep flink-standard
kubectl get -n ateng-flink sessionjob flink-spring-datagen
```

**单独创建任务**

当 `Total Task Slots` 无法满足当前任务时，Flink Operator会自动扩展 `Task Managers` 节点数量

```bash
kubectl apply -f flink-standard-myapp-job.yaml
```

**删除应用**

```bash
kubectl delete -n ateng-flink sessionjob flink-spring-datagen flink-spring-kafka
kubectl delete -n ateng-flink flinkdep flink-standard
```



## 参数优化部署

### 编辑配置文件

以**flink-standard-myapp.yaml**配置文件为例，建议修改以下参数：

**FlinkDeployment**

1. **spec.jobManager.resource.memory**：jobManager实际的内存分配，并不是配置文件的kubernetes.jobmanager.memory.limit-factor
2. **spec.jobManager.resource.cpu**：初始的cpu数量，实际能用的数量是配置文件的kubernetes.jobmanager.cpu.limit-factor
3. **spec.taskManager.resource.memory**：taskManager实际的内存分配，并不是配置文件的kubernetes.taskManager.memory.limit-factor。taskManager是运行任务的节点，可以根据任务需要的内存数合理分配，调整**spec.taskManager.resource.memory**的大小即可。
4. **spec.taskManager.resource.cpu**：初始的cpu数量，实际能用的数量是配置文件的kubernetes.jobmanager.cpu.limit-factor。taskManager是运行任务的节点，可以根据任务需要的cpu数合理分配，修改**kubernetes.jobmanager.cpu.limit-factor**的比值即可。

**FlinkSessionJob**

1. **spec.job.parallelism**：和参数**taskmanager.numberOfTaskSlots**决定容器**taskManager**的数量，并行度/numberOfTaskSlots(向上取整)=taskManager数量。

### 部署应用

**创建应用**

```bash
kubectl apply -f flink-standard-myapp-prod.yaml
```

**查看应用**

查看pod

```bash
kubectl get -n ateng-flink pod,svc,pvc -l app=flink-standard
kubectl logs -n ateng-flink -f --tail=200 -l app=flink-standard
```

查看应用

```bash
kubectl get -n ateng-flink flinkdep flink-standard
kubectl get -n ateng-flink sessionjob flink-spring-datagen
```

**删除应用**

```bash
kubectl delete -n ateng-flink sessionjob flink-spring-datagen
kubectl delete -n ateng-flink flinkdep flink-standard
```



