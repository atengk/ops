# Kubernetes 使用文档

## 1. Kubernetes 基础概念

### 1.1 Kubernetes 简介
Kubernetes（K8s）是一个用于自动化部署、扩展和管理容器化应用程序的开源系统。Kubernetes可以在多个主机间管理容器的生命周期，并为应用程序提供高可用性和弹性。

### 1.2 Kubernetes 核心架构
- **Master 节点**：用于集群的管理和控制，包括 API Server、Scheduler、Controller Manager 和 etcd。
- **Worker 节点**：运行用户应用负载的节点，包括 kubelet、kube-proxy 和容器运行时。
### 1.3 常用术语解释
- **Pod**：Kubernetes 中最小的可部署单元。每个 Pod 封装一个或多个容器，通常用于部署单个应用实例。
- **Node**：Kubernetes 集群中的一个工作节点，运行 Pod 并提供计算资源。
- **Namespace**：逻辑隔离空间，用于将资源分隔在不同的“区域”，便于管理和资源隔离。
- **Deployment**：用于管理无状态应用的资源，支持滚动更新和回滚。
- **ReplicaSet**：确保指定数量的 Pod 实例在运行，为 Deployment 提供副本控制。
- **Service**：定义一组 Pod 的访问策略，使得外部服务能够访问到这些 Pod。
- **Ingress**：管理外部 HTTP 和 HTTPS 访问的资源，提供基于主机名或路径的访问控制。
- **ConfigMap 和 Secret**：用于配置管理。ConfigMap 存储非敏感配置信息，Secret 存储敏感数据（如密码）。
- **Volume 和 Persistent Volume (PV)**：Volume 提供 Pod 内部数据持久化，PV 提供独立于 Pod 生命周期的持久存储。
- **Persistent Volume Claim (PVC)**：Pod 对 PV 的存储请求。
- **DaemonSet**：确保每个节点上都运行一个 Pod，通常用于系统服务。
- **StatefulSet**：用于有状态应用，提供稳定的网络标识和存储。
- **Job 和 CronJob**：Job 用于一次性任务，CronJob 用于定时任务。

---

## 2. 基本操作

### 2.1 集群上下文管理
当使用多集群或在多个环境中工作时，可以使用 `kubectl config` 命令切换不同的集群上下文。

- **查看当前上下文**：
  ```shell
  kubectl config current-context
  ```

- **切换上下文**：
  ```shell
  kubectl config use-context <context-name>
  ```

- **列出所有上下文**：
  ```shell
  kubectl config get-contexts
  ```

### 2.2 命名空间管理
Kubernetes 使用命名空间（Namespace）对资源进行逻辑隔离。命名空间适合用于将开发、测试和生产环境的资源隔离。

- **创建命名空间**：
  ```shell
  kubectl create namespace <namespace-name>
  ```

- **删除命名空间**：
  ```shell
  kubectl delete namespace <namespace-name>
  ```

- **切换默认命名空间**：
  可以在 `kubectl` 命令中指定 `-n <namespace-name>` 来切换命名空间。例如：
  ```shell
  kubectl get pods -n <namespace-name>
  ```

### 2.3 资源创建与管理
Kubernetes 使用声明式方式定义资源，通常采用 YAML 文件。

- **使用 YAML 文件创建资源**：
  ```shell
  kubectl apply -f <file-name>.yaml
  ```

- **查看资源详情**：
  ```shell
  kubectl get <resource-type> -o wide
  ```

- **更新资源**：
  修改 YAML 文件后重新应用更新：
  ```shell
  kubectl apply -f <file-name>.yaml
  ```

- **删除资源**：
  ```shell
  kubectl delete -f <file-name>.yaml
  ```

- **直接使用命令行创建资源**：
  例如，创建一个 Pod：
  ```shell
  kubectl run <pod-name> --image=<image-name>
  ```

### 2.4 常用 `kubectl` 操作示例
- **查看集群中所有 Pod**：
  ```shell
  kubectl get pods --all-namespaces
  ```

- **查看集群中所有节点**：
  ```shell
  kubectl get nodes
  ```

- **描述某个资源**（查看详细信息）：
  ```shell
  kubectl describe <resource-type> <resource-name>
  ```

- **获取 Pod 日志**：
  ```shell
  kubectl logs <pod-name>
  ```

## 3. Pod 操作

Pod 是 Kubernetes 中最小的部署单元，封装了一个或多个容器。

### 3.1 创建 Pod
通常使用 YAML 文件定义 Pod，以下是一个简单的 Pod 定义示例：

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: my-pod
spec:
  containers:
  - name: my-container
    image: nginx:latest
```

- **创建 Pod**：
  ```shell
  kubectl apply -f my-pod.yaml
  ```

- **查看 Pod 状态**：
  ```shell
  kubectl get pods
  ```

### 3.2 查看 Pod 状态
使用以下命令可以查看 Pod 的运行状态和详细信息：

- **查看 Pod 详情**：
  ```shell
  kubectl describe pod <pod-name>
  ```

- **查看 Pod 日志**：
  ```shell
  kubectl logs <pod-name>
  ```
  如果 Pod 中包含多个容器，可以指定容器名称：
  ```shell
  kubectl logs <pod-name> -c <container-name>
  ```

### 3.3 更新 Pod
Pod 通常不直接更新，因为它是不可变的单元。通常，您会使用 Deployment 或其他控制器来管理 Pod 的更新和重启。

如果需要更新，您可以删除并重新创建 Pod，或者通过 Deployment 管理。

### 3.4 删除 Pod
- **删除单个 Pod**：
  ```shell
  kubectl delete pod <pod-name>
  ```

- **强制删除 Pod**：
  在某些情况下，Pod 可能会卡住，可以使用 `--force` 和 `--grace-period=0` 强制删除：
  ```shell
  kubectl delete pod <pod-name> --force --grace-period=0
  ```

### 3.5 调试 Pod
调试 Pod 时，可以使用以下几种方式：

- **查看 Pod 日志**：使用 `kubectl logs <pod-name>` 获取容器的标准输出。
- **进入 Pod 内部**：使用 `exec` 命令进入 Pod，检查内部状态：
  ```shell
  kubectl exec -it <pod-name> -- /bin/bash
  ```
- **获取 Pod 事件**：在 `describe pod` 输出中查看事件信息，了解 Pod 状态变化。

---

## 4. Deployment 管理

Deployment 是 Kubernetes 中最常用的资源类型，用于管理无状态应用，并支持滚动更新、扩缩容等功能。

### 4.1 创建 Deployment
以下是一个简单的 Deployment YAML 配置示例：

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-deployment
spec:
  replicas: 3
  selector:
    matchLabels:
      app: my-app
  template:
    metadata:
      labels:
        app: my-app
    spec:
      containers:
      - name: my-container
        image: nginx:latest
```

- **创建 Deployment**：
  ```shell
  kubectl apply -f my-deployment.yaml
  ```

- **查看 Deployment 状态**：
  ```shell
  kubectl get deployments
  ```

### 4.2 更新 Deployment（滚动更新和回滚）
Deployment 支持滚动更新，以保证应用的持续可用性。

- **更新 Deployment**：
  更新 YAML 文件中的 `image` 或其他配置后重新应用：
  ```shell
  kubectl apply -f my-deployment.yaml
  ```

- **滚动更新**：
  直接通过 `kubectl set` 命令进行滚动更新：
  ```shell
  kubectl set image deployment/my-deployment my-container=nginx:1.19
  ```

- **回滚 Deployment**：
  如果更新失败或出现问题，可以将 Deployment 回滚到之前的版本：
  ```shell
  kubectl rollout undo deployment/my-deployment
  ```

- **查看更新状态**：
  使用以下命令查看滚动更新的状态和进度：
  ```shell
  kubectl rollout status deployment/my-deployment
  ```

### 4.3 扩缩容 Deployment
Deployment 提供扩缩容机制，可以快速调整 Pod 的数量。

- **扩容 Deployment**：
  将副本数量调整为指定值：
  ```shell
  kubectl scale deployment my-deployment --replicas=5
  ```

- **自动扩缩容**：
  Kubernetes 支持基于资源使用情况的自动扩缩容。您可以通过 HorizontalPodAutoscaler（HPA）配置扩缩容策略。例如，基于 CPU 利用率扩缩容：
  ```shell
  kubectl autoscale deployment my-deployment --min=2 --max=10 --cpu-percent=80
  ```

### 4.4 删除 Deployment
删除 Deployment 时，相关的 Pod 也会一同被删除。

- **删除 Deployment**：
  ```shell
  kubectl delete deployment my-deployment
  ```

### 4.5 Deployment 常见问题处理
- **查看 Deployment 事件和问题**：
  ```shell
  kubectl describe deployment my-deployment
  ```
- **查看 Pod 状态和问题**：
  可以通过 `kubectl get pods` 和 `kubectl describe pod <pod-name>` 查看具体 Pod 的状态，定位问题。

## 5. Service 与网络管理

### 5.1 Service 类型
Kubernetes 的 Service 是一种抽象，它将一组提供相同功能的 Pod 组合在一起并提供网络访问。常见的 Service 类型如下：

- **ClusterIP**：默认类型，仅在集群内部可访问。适合集群内部的服务通信。
- **NodePort**：将 Service 暴露在每个节点的特定端口，使得外部可以通过 `<NodeIP>:<NodePort>` 访问服务。
- **LoadBalancer**：在云平台（如 GCP、AWS）上提供基于负载均衡器的外部访问。云提供商会自动创建一个负载均衡器并分配一个外部 IP。
- **ExternalName**：将 Service 映射到外部 DNS 名称，而不是集群内部的 IP。适合集群内访问外部服务。

### 5.2 暴露应用（从 Deployment 到 Service）
通过 Service 将 Deployment 中的 Pod 暴露出来，使其他服务能够访问这些 Pod。

- 创建一个 Deployment 和对应的 Service：
  ```yaml
  apiVersion: apps/v1
  kind: Deployment
  metadata:
    name: my-deployment
  spec:
    replicas: 3
    selector:
      matchLabels:
        app: my-app
    template:
      metadata:
        labels:
          app: my-app
      spec:
        containers:
        - name: my-container
          image: nginx:latest
  ---
  apiVersion: v1
  kind: Service
  metadata:
    name: my-service
  spec:
    selector:
      app: my-app
    ports:
      - protocol: TCP
        port: 80
        targetPort: 80
    type: ClusterIP
  ```

- **应用 YAML 文件**：
  ```shell
  kubectl apply -f my-service.yaml
  ```

- **查看 Service 状态**：
  ```shell
  kubectl get services
  ```

### 5.3 Ingress 资源
Ingress 提供基于 HTTP/HTTPS 路由的外部访问。Ingress 可以根据路径或主机名将流量转发到不同的服务。

- **创建 Ingress**：
  ```yaml
  apiVersion: networking.k8s.io/v1
  kind: Ingress
  metadata:
    name: my-ingress
  spec:
    rules:
      - host: myapp.example.com
        http:
          paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: my-service
                port:
                  number: 80
  ```

- **应用 Ingress**：
  ```shell
  kubectl apply -f my-ingress.yaml
  ```

### 5.4 使用 TLS 保护 Ingress
为 Ingress 启用 TLS 需要配置证书，以下是一个示例：

1. 创建 Secret 来存储 TLS 证书和私钥：
   ```shell
   kubectl create secret tls my-tls-secret --cert=path/to/tls.crt --key=path/to/tls.key
   ```

2. 修改 Ingress 配置使用 TLS：
   ```yaml
   apiVersion: networking.k8s.io/v1
   kind: Ingress
   metadata:
     name: my-ingress
   spec:
     tls:
       - hosts:
           - myapp.example.com
         secretName: my-tls-secret
     rules:
       - host: myapp.example.com
         http:
           paths:
             - path: /
               pathType: Prefix
               backend:
                 service:
                   name: my-service
                   port:
                     number: 80
   ```

---

## 6. 配置管理

### 6.1 使用 ConfigMap 管理配置
ConfigMap 用于存储配置信息，可以将配置信息挂载到 Pod 中，使得应用无需硬编码配置信息。

- **创建 ConfigMap**：
  ```shell
  kubectl create configmap my-config --from-literal=key1=value1 --from-literal=key2=value2
  ```

- **在 Pod 中使用 ConfigMap**：
  可以将 ConfigMap 挂载到环境变量或文件系统中。例如：
  ```yaml
  apiVersion: v1
  kind: Pod
  metadata:
    name: my-pod
  spec:
    containers:
    - name: my-container
      image: nginx
      env:
        - name: MY_KEY
          valueFrom:
            configMapKeyRef:
              name: my-config
              key: key1
  ```

### 6.2 使用 Secret 管理敏感信息
Secret 用于存储敏感数据，例如密码和证书。Secret 数据会被 Base64 编码，但它的目的并不是提供完全的安全，而是防止敏感数据暴露在源码中。

- **创建 Secret**：
  ```shell
  kubectl create secret generic my-secret --from-literal=password=secretpass
  ```

- **在 Pod 中使用 Secret**：
  类似于 ConfigMap，Secret 可以以环境变量或文件的方式挂载到容器中。例如：
  ```yaml
  apiVersion: v1
  kind: Pod
  metadata:
    name: my-pod
  spec:
    containers:
    - name: my-container
      image: nginx
      env:
        - name: PASSWORD
          valueFrom:
            secretKeyRef:
              name: my-secret
              key: password
  ```

### 6.3 管理 ConfigMap 和 Secret
ConfigMap 和 Secret 都支持使用 YAML 文件创建和管理。

- **通过 YAML 创建 ConfigMap**：
  ```yaml
  apiVersion: v1
  kind: ConfigMap
  metadata:
    name: my-config
  data:
    key1: value1
    key2: value2
  ```

- **通过 YAML 创建 Secret**：
  ```yaml
  apiVersion: v1
  kind: Secret
  metadata:
    name: my-secret
  type: Opaque
  data:
    password: c2VjcmV0cGFzcw==  # 这是Base64编码的字符串
  ```

- **应用 YAML 配置**：
  ```shell
  kubectl apply -f my-config.yaml
  kubectl apply -f my-secret.yaml
  ```

## 7. 持久化存储管理

### 7.1 Volume 与持久化卷概念
Kubernetes 提供 Volume 的概念来支持 Pod 的数据持久化。Volume 可以为容器提供一个持续存在的存储空间，当容器被删除或重新启动时，数据不会丢失。与临时的 EmptyDir 类型 Volume 不同，Persistent Volume（PV）能够独立于 Pod 的生命周期存在，适合存储持久性数据。

### 7.2 Persistent Volume (PV) 和 Persistent Volume Claim (PVC)
- **Persistent Volume (PV)**：集群级别的存储资源，由管理员预先配置，PV 可以独立于 Pod 的生命周期而存在。
- **Persistent Volume Claim (PVC)**：是用户对 PV 的存储请求。Pod 通过 PVC 来请求和使用 PV。

### 7.3 创建 Persistent Volume 和 Persistent Volume Claim
以下是创建 PV 和 PVC 的示例：

- **Persistent Volume YAML 文件**：
  ```yaml
  apiVersion: v1
  kind: PersistentVolume
  metadata:
    name: my-pv
  spec:
    capacity:
      storage: 1Gi
    accessModes:
      - ReadWriteOnce
    persistentVolumeReclaimPolicy: Retain
    hostPath:
      path: /mnt/data
  ```

- **Persistent Volume Claim YAML 文件**：
  ```yaml
  apiVersion: v1
  kind: PersistentVolumeClaim
  metadata:
    name: my-pvc
  spec:
    accessModes:
      - ReadWriteOnce
    resources:
      requests:
        storage: 1Gi
  ```

- **创建 PV 和 PVC**：
  ```shell
  kubectl apply -f my-pv.yaml
  kubectl apply -f my-pvc.yaml
  ```

### 7.4 在 Pod 中挂载持久化卷
在创建 PV 和 PVC 之后，可以将 PVC 挂载到 Pod 中，使 Pod 能够使用持久存储。

- **Pod 使用 PVC 的 YAML 示例**：
  ```yaml
  apiVersion: v1
  kind: Pod
  metadata:
    name: my-pod
  spec:
    containers:
    - name: my-container
      image: nginx
      volumeMounts:
        - mountPath: "/data"
          name: my-storage
    volumes:
      - name: my-storage
        persistentVolumeClaim:
          claimName: my-pvc
  ```

### 7.5 StorageClass 使用（动态存储分配）
StorageClass 定义存储的类别和配置策略，提供动态分配 PV 的能力。StorageClass 可以指定不同的存储配置，例如快速存储、标准存储等。

- **StorageClass 示例 YAML 文件**：
  ```yaml
  apiVersion: storage.k8s.io/v1
  kind: StorageClass
  metadata:
    name: fast-storage
  provisioner: kubernetes.io/aws-ebs
  parameters:
    type: gp2
  ```

- **动态分配 PVC**：
  在 PVC 配置中指定 `storageClassName` 字段，Kubernetes 会根据该 StorageClass 自动创建 PV：
  ```yaml
  apiVersion: v1
  kind: PersistentVolumeClaim
  metadata:
    name: dynamic-pvc
  spec:
    storageClassName: fast-storage
    accessModes:
      - ReadWriteOnce
    resources:
      requests:
        storage: 5Gi
  ```

---

## 8. 资源调度与管理

Kubernetes 资源调度与管理机制可以控制 Pod 在集群内如何分布，以便优化资源利用和应用性能。

### 8.1 节点选择器和节点亲和性
Kubernetes 提供多种方式控制 Pod 的调度位置，包括节点选择器和节点亲和性：

- **节点选择器（Node Selector）**：通过 `nodeSelector` 字段，指定 Pod 只能调度到满足特定标签的节点上。
  ```yaml
  apiVersion: v1
  kind: Pod
  metadata:
    name: my-pod
  spec:
    nodeSelector:
      disktype: ssd
    containers:
    - name: my-container
      image: nginx
  ```

- **节点亲和性（Node Affinity）**：提供更灵活的调度策略，可以配置“硬性”和“软性”规则。
  ```yaml
  apiVersion: v1
  kind: Pod
  metadata:
    name: my-pod
  spec:
    affinity:
      nodeAffinity:
        requiredDuringSchedulingIgnoredDuringExecution:
          nodeSelectorTerms:
          - matchExpressions:
            - key: disktype
              operator: In
              values:
              - ssd
    containers:
    - name: my-container
      image: nginx
  ```

### 8.2 Pod 调度策略
调度策略控制 Pod 的具体分布方式，确保工作负载均匀或满足特定需求。

- **Taints 和 Tolerations**：用于防止某些 Pod 被调度到特定节点。Taint 是对节点的标记，Toleration 则允许 Pod 忽略某些 Taint。
  - **添加 Taint 到节点**：
    ```shell
    kubectl taint nodes <node-name> key=value:NoSchedule
    ```
  - **在 Pod 中添加 Toleration**：
    ```yaml
    apiVersion: v1
    kind: Pod
    metadata:
      name: my-pod
    spec:
      tolerations:
      - key: "key"
        operator: "Equal"
        value: "value"
        effect: "NoSchedule"
      containers:
      - name: my-container
        image: nginx
    ```

- **Pod Affinity 和 Anti-Affinity**：控制 Pod 之间的调度规则。可以实现将特定 Pod 调度在相同或不同节点上。

  - **Pod Affinity（在同一节点）**：
    ```yaml
    apiVersion: v1
    kind: Pod
    metadata:
      name: my-pod
    spec:
      affinity:
        podAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
            - labelSelector:
                matchLabels:
                  app: frontend
              topologyKey: "kubernetes.io/hostname"
      containers:
      - name: my-container
        image: nginx
    ```

### 8.3 Pod 资源限制和请求
Kubernetes 支持资源的请求和限制配置，以实现更好的资源控制和隔离。

- **资源请求**：定义 Pod 启动时需要的最小资源。
- **资源限制**：限制 Pod 使用的最大资源，避免过度消耗。

- **示例 YAML 文件**：
  ```yaml
  apiVersion: v1
  kind: Pod
  metadata:
    name: my-pod
  spec:
    containers:
    - name: my-container
      image: nginx
      resources:
        requests:
          memory: "64Mi"
          cpu: "250m"
        limits:
          memory: "128Mi"
          cpu: "500m"
  ```

### 8.4 ResourceQuota 和 LimitRange
Kubernetes 支持在命名空间级别限制资源使用，以实现资源管理和隔离。

- **ResourceQuota**：限制一个命名空间内的资源总量，适用于大型多租户环境。
  ```yaml
  apiVersion: v1
  kind: ResourceQuota
  metadata:
    name: example-quota
  spec:
    hard:
      pods: "10"
      requests.cpu: "4"
      requests.memory: "8Gi"
      limits.cpu: "10"
      limits.memory: "16Gi"
  ```

- **LimitRange**：限制单个 Pod 或容器的资源使用，为未指定请求或限制的 Pod 设置默认值。
  ```yaml
  apiVersion: v1
  kind: LimitRange
  metadata:
    name: example-limits
  spec:
    limits:
    - max:
        cpu: "2"
        memory: "1Gi"
      min:
        cpu: "200m"
        memory: "6Mi"
      type: Container
  ```

## 9. 日志与监控

### 9.1 日志管理
Kubernetes 提供了多种方法来收集和管理日志，帮助开发人员和运维人员排查问题。

- **查看 Pod 日志**：使用 `kubectl logs` 查看指定 Pod 中容器的日志。
  ```shell
  kubectl logs <pod-name>
  ```
  - 如果 Pod 有多个容器，可以指定容器名称：
    ```shell
    kubectl logs <pod-name> -c <container-name>
    ```

- **跟踪实时日志**：使用 `-f` 参数查看实时日志输出。
  ```shell
  kubectl logs -f <pod-name>
  ```

- **集群级日志管理**：在生产环境中，可以使用 ELK（Elasticsearch, Logstash, Kibana）或 EFK（Elasticsearch, Fluentd, Kibana）堆栈来集中收集、存储和分析日志。还可以使用 Prometheus 和 Grafana 进行更高级的日志和指标管理。

### 9.2 监控与指标
监控是 Kubernetes 生产环境的重要部分，可以通过监控来观察集群健康状况、资源使用情况以及应用性能。

- **cAdvisor**：Kubernetes 自带的容器资源收集工具，采集 CPU、内存、文件系统和网络使用信息。
- **Prometheus**：用于指标收集和报警的监控工具。可以通过 Prometheus Operator 部署在 Kubernetes 中，负责收集集群的性能指标。
- **Grafana**：常与 Prometheus 配合使用，用于数据可视化。通过 Grafana 可以在仪表盘上实时观察集群和 Pod 的性能状态。

### 9.3 配置 Prometheus 和 Grafana
以下是 Prometheus 和 Grafana 的常用部署步骤：

1. **安装 Prometheus**：可以使用 Helm chart 安装。
   ```shell
   helm install prometheus prometheus-community/prometheus
   ```

2. **安装 Grafana**：同样可以通过 Helm 安装。
   ```shell
   helm install grafana grafana/grafana
   ```

3. **配置监控数据源**：在 Grafana 中添加 Prometheus 数据源并配置图表，通过 Prometheus 数据源即可从 Kubernetes 收集监控指标数据。

### 9.4 事件管理
Kubernetes 支持通过事件记录集群中发生的状态变化和重要操作。

- **查看事件**：可以使用 `kubectl get events` 命令查看最近的事件信息。
  ```shell
  kubectl get events --sort-by=.metadata.creationTimestamp
  ```

- **事件过滤**：可以根据资源类型、名称等过滤事件。例如，查看特定 Pod 的事件：
  ```shell
  kubectl describe pod <pod-name>
  ```

---

## 10. 安全与权限管理

### 10.1 RBAC（基于角色的访问控制）
RBAC 是 Kubernetes 中用于权限控制的核心机制，通过角色（Role）和角色绑定（RoleBinding）来管理用户或应用的访问权限。

- **Role 和 ClusterRole**：Role 用于限定命名空间内的权限，ClusterRole 用于集群级别的权限。
- **RoleBinding 和 ClusterRoleBinding**：将用户或服务账户绑定到特定角色，实现权限的授予。

- **Role 示例**：
  ```yaml
  apiVersion: rbac.authorization.k8s.io/v1
  kind: Role
  metadata:
    namespace: default
    name: pod-reader
  rules:
  - apiGroups: [""]
    resources: ["pods"]
    verbs: ["get", "list"]
  ```

- **RoleBinding 示例**：
  ```yaml
  apiVersion: rbac.authorization.k8s.io/v1
  kind: RoleBinding
  metadata:
    name: read-pods
    namespace: default
  subjects:
  - kind: User
    name: "jane"  # 用户名
  roleRef:
    kind: Role
    name: pod-reader
    apiGroup: rbac.authorization.k8s.io
  ```

### 10.2 Service Account
Service Account 是 Kubernetes 中的特殊账户类型，主要用于应用程序的身份验证。

- **创建 Service Account**：
  ```shell
  kubectl create serviceaccount my-service-account
  ```

- **在 Pod 中使用 Service Account**：
  在 Pod 配置中指定 `serviceAccountName`，以便 Pod 使用指定的 Service Account：
  ```yaml
  apiVersion: v1
  kind: Pod
  metadata:
    name: my-pod
  spec:
    serviceAccountName: my-service-account
    containers:
    - name: my-container
      image: nginx
  ```

### 10.3 网络策略（Network Policy）
Network Policy 用于控制 Pod 之间或 Pod 与外部之间的网络访问。通过网络策略可以定义规则，限制流量来源和去向。

- **示例 Network Policy**：该策略只允许来自指定标签的 Pod 的入站流量。
  ```yaml
  apiVersion: networking.k8s.io/v1
  kind: NetworkPolicy
  metadata:
    name: allow-specific-pods
    namespace: default
  spec:
    podSelector:
      matchLabels:
        app: my-app
    ingress:
    - from:
      - podSelector:
          matchLabels:
            role: backend
  ```

- **应用 Network Policy**：
  ```shell
  kubectl apply -f my-network-policy.yaml
  ```

### 10.4 密钥管理与加密
Kubernetes 支持在集群内管理敏感数据，并可以启用数据加密以确保存储安全。

- **启用密钥加密**：Kubernetes 支持将 Secret 数据在 etcd 中加密存储，需要在 API 服务器的配置文件中启用加密设置。
- **管理 Secret**：使用 Secret 来存储和使用敏感数据，例如密码、证书等。

### 10.5 Pod 安全策略（Pod Security Policies）
Pod 安全策略用于限制 Pod 的创建和配置。它通过定义 Pod 的安全规则来控制哪些 Pod 可以运行在集群中。

- **示例 Pod Security Policy**：
  ```yaml
  apiVersion: policy/v1beta1
  kind: PodSecurityPolicy
  metadata:
    name: restricted
  spec:
    privileged: false
    allowPrivilegeEscalation: false
    runAsUser:
      rule: MustRunAsNonRoot
    seLinux:
      rule: RunAsAny
    fsGroup:
      rule: RunAsAny
    volumes:
    - 'configMap'
    - 'secret'
  ```

- **应用 Pod Security Policy**：
  Pod Security Policy 必须与 RBAC 配合使用，通过 Role 和 RoleBinding 授权用户或 Service Account 使用特定的安全策略。

### 11. 配置管理与 Secret 管理

#### 11.1 ConfigMap（配置管理）
ConfigMap 用于存储非机密的配置信息，比如环境变量、配置文件、命令行参数等，以便在应用程序部署时动态注入这些配置。

- **创建 ConfigMap**：可以通过文件、命令行或 YAML 文件创建。
  - **通过文件创建**：
    ```shell
    kubectl create configmap my-config --from-file=app-config.properties
    ```
  - **通过命令行指定 key-value 创建**：
    ```shell
    kubectl create configmap my-config --from-literal=key1=value1 --from-literal=key2=value2
    ```

- **ConfigMap YAML 示例**：
  ```yaml
  apiVersion: v1
  kind: ConfigMap
  metadata:
    name: my-config
  data:
    config.json: |
      {
        "key1": "value1",
        "key2": "value2"
      }
  ```

- **在 Pod 中使用 ConfigMap**：
  ConfigMap 可以作为环境变量、命令行参数或挂载为文件使用。
  ```yaml
  apiVersion: v1
  kind: Pod
  metadata:
    name: my-pod
  spec:
    containers:
    - name: my-container
      image: nginx
      env:
      - name: CONFIG_VALUE
        valueFrom:
          configMapKeyRef:
            name: my-config
            key: config.json
      volumeMounts:
      - mountPath: "/etc/config"
        name: config-volume
    volumes:
    - name: config-volume
      configMap:
        name: my-config
  ```

#### 11.2 Secret（敏感数据管理）
Secret 用于存储敏感数据，例如密码、密钥和证书。Secret 数据会以 Base64 编码存储并在 Pod 中安全注入。

- **创建 Secret**：可以通过文件、命令行或 YAML 文件创建。
  - **通过命令行创建**：
    ```shell
    kubectl create secret generic my-secret --from-literal=username=admin --from-literal=password='secret'
    ```

- **Secret YAML 示例**：
  ```yaml
  apiVersion: v1
  kind: Secret
  metadata:
    name: my-secret
  type: Opaque
  data:
    username: YWRtaW4=  # Base64 编码
    password: c2VjcmV0
  ```

- **在 Pod 中使用 Secret**：Secret 可以作为环境变量或文件使用。
  ```yaml
  apiVersion: v1
  kind: Pod
  metadata:
    name: my-pod
  spec:
    containers:
    - name: my-container
      image: nginx
      env:
      - name: USER_NAME
        valueFrom:
          secretKeyRef:
            name: my-secret
            key: username
      volumeMounts:
      - mountPath: "/etc/secret"
        name: secret-volume
    volumes:
    - name: secret-volume
      secret:
        secretName: my-secret
  ```

#### 11.3 加密 Secret 数据
在生产环境中，可以通过启用 etcd 数据加密配置，以确保 Secret 数据在存储时得到加密保护。

---

### 12. 自动扩展与负载均衡

#### 12.1 自动扩展概述
Kubernetes 支持多种扩展机制，可以根据负载情况动态增加或减少资源：

- **Horizontal Pod Autoscaler（HPA）**：根据 CPU 或自定义指标进行 Pod 的水平扩展。
- **Vertical Pod Autoscaler（VPA）**：动态调整 Pod 所需的 CPU 和内存，适应实际需求。
- **Cluster Autoscaler**：根据集群中 Pod 需求的变化自动调整节点数量。

#### 12.2 Horizontal Pod Autoscaler (HPA)
HPA 根据 CPU 使用率或自定义指标自动调整 Pod 数量，确保应用在负载增加时能自动扩展以维持服务质量。

- **HPA YAML 示例**：
  ```yaml
  apiVersion: autoscaling/v2beta2
  kind: HorizontalPodAutoscaler
  metadata:
    name: my-app-hpa
  spec:
    scaleTargetRef:
      apiVersion: apps/v1
      kind: Deployment
      name: my-app
    minReplicas: 2
    maxReplicas: 10
    metrics:
    - type: Resource
      resource:
        name: cpu
        target:
          type: Utilization
          averageUtilization: 70
  ```

- **创建 HPA**：
  ```shell
  kubectl apply -f my-app-hpa.yaml
  ```

#### 12.3 Vertical Pod Autoscaler (VPA)
VPA 动态调整容器的 CPU 和内存请求，可以更有效地使用资源。

- **VPA 示例**（通过 `vpa.yaml` 文件）：
  ```yaml
  apiVersion: autoscaling.k8s.io/v1
  kind: VerticalPodAutoscaler
  metadata:
    name: my-app-vpa
  spec:
    targetRef:
      apiVersion: apps/v1
      kind: Deployment
      name: my-app
    updatePolicy:
      updateMode: "Auto"
  ```

#### 12.4 Cluster Autoscaler
Cluster Autoscaler 会根据资源请求自动扩展集群中的节点数，特别适用于云平台（如 GKE、EKS 和 AKS），以确保集群容量满足 Pod 调度需求。

---

### 13. 高可用性与备份

#### 13.1 集群高可用性
Kubernetes 支持在多个节点上部署控制平面和工作负载，以实现高可用性。主要策略包括：

- **控制平面高可用**：将 etcd、API 服务器、控制器管理器和调度器部署在多个节点上。
- **负载均衡**：在 API 服务器前部署负载均衡器，确保客户端请求可以均衡分发到各个控制平面节点。

#### 13.2 应用高可用性
通过 Kubernetes 中的 ReplicaSet 或 Deployment 管理应用的副本数，保证服务的高可用性。当某个 Pod 出现故障时，ReplicaSet 或 Deployment 会自动重新调度新的 Pod。

- **Deployment 示例**：
  ```yaml
  apiVersion: apps/v1
  kind: Deployment
  metadata:
    name: my-app
  spec:
    replicas: 3
    selector:
      matchLabels:
        app: my-app
    template:
      metadata:
        labels:
          app: my-app
      spec:
        containers:
        - name: my-container
          image: nginx
  ```

#### 13.3 数据备份与恢复
对于关键数据，Kubernetes 提供了多种备份策略和工具来实现数据保护：

- **etcd 备份**：etcd 存储 Kubernetes 集群的所有配置信息和状态数据。可以通过定期备份 etcd 数据来确保集群的可靠恢复。
  - **etcd 备份命令**：
    ```shell
    ETCDCTL_API=3 etcdctl snapshot save snapshot.db
    ```

- **持久化卷备份**：如果应用使用了持久卷（PV），则需要使用存储系统的快照或备份工具来备份 PV 数据。

#### 13.4 恢复流程
在出现灾难性故障时，可以通过以下步骤恢复 Kubernetes 集群：

1. **恢复 etcd 数据**：使用备份的 etcd 数据恢复集群状态。
   ```shell
   ETCDCTL_API=3 etcdctl snapshot restore snapshot.db
   ```

2. **重新部署控制平面**：确保控制平面组件恢复正常，并重新连接到 etcd。

3. **重新部署工作负载**：检查 Pod 和工作负载的恢复情况，确保数据持久化卷与应用正常绑定。

## 项目实战

### 创建用户并导出kubeconfig

**创建 cloud-qijiang-admin.sh 脚本并执行**

Kubernetes 1.24及以上的方式

```shell
# 设置账户名称
export K8S_UserName=cloud-qijiang-admin
# 设置集群名称
export K8S_ClusterName=aliyun.com
# 设置集群地址
export K8S_API=https://47.108.39.131:6443
# 设置账户所在的命名空间
export K8S_NameSpace=kube-system

kubectl apply -f - <<EOF
apiVersion: v1
kind: ServiceAccount
metadata:
  name: ${K8S_UserName}
  namespace: ${K8S_NameSpace}
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: ${K8S_UserName}
rules:
- apiGroups: ["*"]
  resources: ["*"]
  verbs: ["*"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: ${K8S_UserName}
subjects:
- kind: ServiceAccount
  name: ${K8S_UserName}
  namespace: ${K8S_NameSpace}
roleRef:
  kind: ClusterRole
  name: ${K8S_UserName}
  apiGroup: rbac.authorization.k8s.io
EOF
k8s_token=$(kubectl create token --duration=8760h -n ${K8S_NameSpace} ${K8S_UserName})
k8s_ca=$(kubectl config view --minify --raw -o jsonpath='{.clusters[0].cluster.certificate-authority-data}')
cat > kubeconfig-${K8S_UserName}.yaml <<EOF
apiVersion: v1
kind: Config
clusters:
- cluster:
    certificate-authority-data: ${k8s_ca}
    server: ${K8S_API}
  name: ${K8S_ClusterName}
contexts:
- context:
    cluster: ${K8S_ClusterName}
    user: ${K8S_UserName}
    namespace: ${K8S_NameSpace}
  name: ${K8S_UserName}@${K8S_ClusterName}
current-context: ${K8S_UserName}@${K8S_ClusterName}
preferences: {}
users:
- name: ${K8S_UserName}
  user:
    token: ${k8s_token}
EOF
```

Kubernetes 1.24以下的方式

```shell
# 设置账户名称
export K8S_UserName=local-ateng-admin
# 设置集群名称
export K8S_ClusterName=lingo.local
# 设置集群地址
export K8S_API=https://192.168.1.18:6443
# 设置账户所在的命名空间
export K8S_NameSpace=kube-system

kubectl apply -f - <<EOF
apiVersion: v1
kind: ServiceAccount
metadata:
  name: ${K8S_UserName}
  namespace: ${K8S_NameSpace}
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: ${K8S_UserName}
rules:
- apiGroups: ["*"]
  resources: ["*"]
  verbs: ["*"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: ${K8S_UserName}-binding
subjects:
- kind: ServiceAccount
  name: ${K8S_UserName}
  namespace: ${K8S_NameSpace}
roleRef:
  kind: ClusterRole
  name: ${K8S_UserName}
  apiGroup: rbac.authorization.k8s.io
EOF
k8s_secret=$(kubectl get serviceaccount ${K8S_UserName} -n ${K8S_NameSpace} -o jsonpath='{.secrets[0].name}')
k8s_token=$(kubectl get -n ${K8S_NameSpace} secret ${k8s_secret} -n ${K8S_NameSpace} -o jsonpath='{.data.token}' | base64 -d)
k8s_ca=$(kubectl get secrets -n ${K8S_NameSpace} ${k8s_secret} -o "jsonpath={.data['ca\.crt']}")
cat > kubeconfig-${K8S_UserName}.yaml <<EOF
apiVersion: v1
kind: Config
clusters:
- cluster:
    certificate-authority-data: ${k8s_ca}
    server: ${K8S_API}
  name: ${K8S_ClusterName}
contexts:
- context:
    cluster: ${K8S_ClusterName}
    user: ${K8S_UserName}
    namespace: ${K8S_NameSpace}
  name: ${K8S_UserName}@${K8S_ClusterName}
current-context: ${K8S_UserName}@${K8S_ClusterName}
preferences: {}
users:
- name: ${K8S_UserName}
  user:
    token: ${k8s_token}
EOF
```

**使用kubeconfig**

```
kubectl --kubeconfig=kubeconfig-cloud-qijiang-admin.yaml get pods
```



### 证书过期处理（Kubelet证书过期）

节点的kubelet证书过期处理，需要从控制节点重新生成kubelet.conf配置文件，然后分发到相关节点

假如这里是 k8s-master01 节点的kubelet证书过期，需要按照以下步骤完成证书的更新

**kubelet服务日志现状**

使用命令 `journalctl -f -u kubelet` 查看kubelet，发现有大量的错误日志：

- User \"system:anonymous\" cannot ...
- tls: failed to verify certificate: x509: certificate signed by unknown authority

这些日志说明kubelet证书已过期或者集群的CA证书已更换，这几种情况都可以通过以下步骤完成证书的更新

**查看证书有效期**

从这里可以看到kubelet证书已过期

```
[root@k8s-master01 ~]# openssl x509 -in /var/lib/kubelet/pki/kubelet-client-current.pem -noout -dates
notBefore=Apr  1 00:31:04 2025 GMT
notAfter=Apr  1 00:36:04 2026 GMT
[root@k8s-master01 ~]# date
Fri May  1 12:02:51 AM CST 2026
```

**重新生成kubelet.conf**

在控制节点重新生成kubelet.conf配置文件，--node-name参数需要指定需要更新配置文件的节点名称

```
kubeadm init phase kubeconfig kubelet --node-name k8s-master01 --kubeconfig-dir /tmp
```

分发kubelet.conf

```
scp /tmp/kubelet.conf k8s-master01:/tmp
rm -f /tmp/kubelet.conf
```

**更新kubelet.conf**

在kubelet证书过期的节点更新证书

备份kubelet.conf配置文件

```
mkdir -p /data/backups/kubernetes/config
cp -a /etc/kubernetes/kubelet.conf /data/backups/kubernetes/config/kubelet.conf_$(date +"%Y-%m-%d")
```

在证书过期的节点更新该配置文件

```
mv /tmp/kubelet.conf /etc/kubernetes/kubelet.conf
rm -f /var/lib/kubelet/pki/kubelet-client-current.pem
```

**重新kubelet**

查看现有kubelet证书

```
[root@k8s-master01 ~]# ll /var/lib/kubelet/pki/
total 12
-rw------- 1 root root 2830 Apr  1  2025 kubelet-client-2025-04-01-08-36-09.pem
-rw-r--r-- 1 root root 2295 Apr  1  2025 kubelet.crt
-rw------- 1 root root 1679 Apr  1  2025 kubelet.key
```

重启kubelet服务后，会根据/etc/kubernetes/kubelet.conf配置文件重新生成证书文件

```
systemctl restart kubelet
```

查看现有kubelet证书，重启服务后发现已更新证书

```
[root@k8s-master01 ~]# ll /var/lib/kubelet/pki/
total 20
-rw------- 1 root root 2830 Apr  1  2025 kubelet-client-2025-04-01-08-36-09.pem
-rw------- 1 root root 1118 May  1 00:14 kubelet-client-2026-05-01-00-14-51.pem
lrwxrwxrwx 1 root root   59 May  1 00:14 kubelet-client-current.pem -> /var/lib/kubelet/pki/kubelet-client-2026-05-01-00-14-51.pem
-rw-r--r-- 1 root root 2295 Apr  1  2025 kubelet.crt
-rw------- 1 root root 1679 Apr  1  2025 kubelet.key
```

查看证书有效期，可以看到kubelet证书已续期成功

```
[root@k8s-master01 ~]# openssl x509 -in /var/lib/kubelet/pki/kubelet-client-current.pem -noout -dates
notBefore=Apr 30 16:09:51 2026 GMT
notAfter=Mar 30 00:36:04 2035 GMT
```

**查看日志**

观察日志

```
journalctl -f -u kubelet
```



### 证书过期处理（控制节点证书过期）

在Kubernetes集群中，默认的CA证书是10年有效期，其他服务端和客户端证书的有效期是1年

假如现在控制节点的证书过期了，需要按照以下步骤续期证书

**查看证书有效期**

可以看到证书已过期

```
[root@k8s-master01 ~]# kubeadm certs check-expiration --config=/etc/kubernetes/kubeadm-config.yaml
CERTIFICATE                EXPIRES                  RESIDUAL TIME   CERTIFICATE AUTHORITY   EXTERNALLY MANAGED
admin.conf                 Apr 01, 2026 01:26 UTC   <invalid>       ca                      no
apiserver                  Apr 01, 2026 01:26 UTC   <invalid>       ca                      no
apiserver-kubelet-client   Apr 01, 2026 01:26 UTC   <invalid>       ca                      no
controller-manager.conf    Apr 01, 2026 01:26 UTC   <invalid>       ca                      no
front-proxy-client         Apr 01, 2026 01:26 UTC   <invalid>       front-proxy-ca          no
scheduler.conf             Apr 01, 2026 01:26 UTC   <invalid>       ca                      no
super-admin.conf           Apr 01, 2026 01:26 UTC   <invalid>       ca                      no

CERTIFICATE AUTHORITY   EXPIRES                  RESIDUAL TIME   EXTERNALLY MANAGED
ca                      Mar 30, 2035 01:26 UTC   8y              no
front-proxy-ca          Mar 30, 2035 01:26 UTC   8y              no
```

**备份证书**

```
mkdir -p /data/backups/kubernetes/config
cp -a /etc/kubernetes/pki /data/backups/kubernetes/config/pki_$(date +"%Y-%m-%d")
```

**重新生成CA证书（可选）**

如果CA证书也过期了需要执行该步骤重新生成证书

删除旧的证书

```
rm -f /etc/kubernetes/pki/ca.crt /etc/kubernetes/pki/ca.key
rm -f /etc/kubernetes/pki/front-proxy-ca.crt /etc/kubernetes/pki/front-proxy-ca.key
```

重新生成 CA 证书

```
kubeadm init phase certs ca
kubeadm init phase certs front-proxy-ca
```

查看 CA 证书，RESIDUAL TIME是9y表示已经重新生成了CA证书

```
[root@k8s-master01 ~]# kubeadm certs check-expiration --config=/etc/kubernetes/kubeadm-config.yaml
CERTIFICATE                EXPIRES                  RESIDUAL TIME   CERTIFICATE AUTHORITY   EXTERNALLY MANAGED
admin.conf                 Apr 01, 2026 01:26 UTC   <invalid>       ca                      no
apiserver                  Apr 01, 2026 01:26 UTC   <invalid>       ca                      no
apiserver-kubelet-client   Apr 01, 2026 01:26 UTC   <invalid>       ca                      no
controller-manager.conf    Apr 01, 2026 01:26 UTC   <invalid>       ca                      no
front-proxy-client         Apr 01, 2026 01:26 UTC   <invalid>       front-proxy-ca          no
scheduler.conf             Apr 01, 2026 01:26 UTC   <invalid>       ca                      no
super-admin.conf           Apr 01, 2026 01:26 UTC   <invalid>       ca                      no

CERTIFICATE AUTHORITY   EXPIRES                  RESIDUAL TIME   EXTERNALLY MANAGED
ca                      May 28, 2036 16:04 UTC   9y              no
front-proxy-ca          May 28, 2036 16:04 UTC   9y              no
```

如果是多个控制节点的集群，需要将 CA 证书分发到其他控制节点上

```
scp /etc/kubernetes/pki/ca.crt /etc/kubernetes/pki/ca.key /etc/kubernetes/pki/front-proxy-ca.crt /etc/kubernetes/pki/front-proxy-ca.key k8s-master02:/etc/kubernetes/pki
```

更新 CA 证书到工作节点，更新了CA证书需要将证书同步到其他工作节点上，不然kubelet会报错证书验证失败

```
scp /etc/kubernetes/pki/ca.crt k8s-worker01:/etc/kubernetes/pki
scp /etc/kubernetes/pki/ca.crt k8s-worker02:/etc/kubernetes/pki
```

工作节点更新 CA 证书后需要重启kubelet服务

```
systemctl restart kubelet
journalctl -f -u kubelet
```

如果安装了，需要重启kube-proxy

```
kubectl -n kube-system rollout restart daemonset kube-proxy
```

更新了CA证书后出现的问题可能会有点多，注意查看集群的pod，主要查看kube-proxy和calico-node(网络)等的日志，一般来说重启相关应用就可以了

**手动更新证书**

在控制节点更新服务证书

```
kubeadm certs renew all --config=/etc/kubernetes/kubeadm-config.yaml
```

如果是多个控制节点的集群，需要将 CA 证书分发到其他控制节点上

```
scp /etc/kubernetes/pki/* k8s-master02:/etc/kubernetes/pki
```

**查看证书**

```
kubeadm certs check-expiration --config=/etc/kubernetes/kubeadm-config.yaml
```

**更新用户凭证**

```
rm -rf /root/.kube
mkdir -p /root/.kube && cp -f /etc/kubernetes/admin.conf /root/.kube/config
```

**重启相关服务**

在所有控制节点都需要重启这些服务

```
docker ps -af 'name=k8s_POD_(kube-apiserver|kube-controller-manager|kube-scheduler|etcd)-*' -q | xargs docker rm -f
systemctl restart kubelet
```

**查看日志**

查看kubelet日志

```
sudo journalctl -u kubelet -f
```

查看kube-apiserver日志

> 一般来说 kube-apiserver 能正常启动其他的服务基本上没啥问题
>
> 如果ETCD证书也过期了需要重新生成证书或续期

```
docker ps | grep kube-apiserver
docker logs -f k8s_kube-apiserver_kube-apiserver-k8s-master01_kube-system_e3a07e2b1472dc53e3c339c9aec936e8_22
```

**查看证书过期时间**

```
openssl x509 -in /etc/kubernetes/pki/ca.crt -text -noout | grep "Not After"
openssl x509 -in /etc/kubernetes/pki/apiserver.crt -text -noout | grep "Not After"
openssl x509 -in /etc/kubernetes/pki/apiserver-kubelet-client.crt -text -noout | grep "Not After"
```

**检查pod**

查看pod

```
kubectl get pod -A
```

将异常的pod删除

```
kubectl get pod -A | grep -E "CreateContainerError|CrashLoopBackOff" | awk '{print $1, $2}' | xargs -n 2 kubectl delete pod -n
```

