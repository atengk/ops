# 使用kubernetes-operator部署Flink应用到Kubernetes

### 命名空间

**创建命名空间和serviceacount**

```
# 创建namespace
kubectl create ns flink-job
# 创建serviceaccount
kubectl create -n flink-job serviceaccount flink-service-account
kubectl create clusterrolebinding flink-role-binding-flink --clusterrole=edit --serviceaccount=flink:flink-service-account
```



## 配置文件

以**flink-standard-myapp.yaml**配置文件为例，建议修改以下参数：

**FlinkDeployment**

1. **spec.jobManager.resource.memory**：jobManager实际的内存分配，并不是配置文件的kubernetes.jobmanager.memory.limit-factor
2. **spec.jobManager.resource.cpu**：初始的cpu数量，实际能用的数量是配置文件的kubernetes.jobmanager.cpu.limit-factor
3. **spec.taskManager.resource.memory**：taskManager实际的内存分配，并不是配置文件的kubernetes.taskManager.memory.limit-factor。taskManager是运行任务的节点，可以根据任务需要的内存数合理分配，调整**spec.taskManager.resource.memory**的大小即可。
4. **spec.taskManager.resource.cpu**：初始的cpu数量，实际能用的数量是配置文件的kubernetes.jobmanager.cpu.limit-factor。taskManager是运行任务的节点，可以根据任务需要的cpu数合理分配，修改**kubernetes.jobmanager.cpu.limit-factor**的比值即可。

**FlinkSessionJob**

1. **spec.job.parallelism**：和参数**taskmanager.numberOfTaskSlots**决定容器**taskManager**的数量，并行度/numberOfTaskSlots(向上取整)=taskManager数量。

## 部署

如果已经部署了FlinkDeployment和FlinkSessionJob，需要更新的时候需要注意，只修改了FlinkSessionJob可以直接apply，其他情况先删除yaml再重新创建。

如果只是更新Flink jar包，只需要删除FlinkSessionJob再重新创建。