# Argo CD 使用文档

🚀 Jenkins + Argo CD 实现 CI/CD 的整体流程

---

1. 👨‍💻 **开发人员推送代码到代码仓库**（如 GitLab/GitHub）
     开发人员将修改后的代码提交并推送到主分支或其他指定分支（如 `master`、`production`）。
2. 🌐 **代码仓库通过 Webhook 通知 Jenkins**
     仓库配置的 Webhook 会在每次代码推送时，向 Jenkins 指定的 Job URL 发送一个 HTTP 请求，携带 push 事件的详细信息（如提交信息、分支名等）。
3. ⚙️ **Jenkins 接收到 Webhook，触发 CI 流程**
     Jenkins 中配置好的 Job 使用 Generic Webhook Trigger 插件解析请求内容，并根据条件（如分支、commit message）决定是否继续执行构建流程。
4. 📦 **Jenkins 拉取代码并进行构建测试**
     Jenkins 克隆代码仓库中的最新代码，并执行自动化构建与测试流程。例如编译 Java 应用、运行单元测试等。
5. 🐳 **Jenkins 构建 Docker 镜像并推送到镜像仓库**
     构建成功后，Jenkins 使用 `Dockerfile` 生成容器镜像，并打上唯一 tag（如构建号或 commit hash），然后将镜像推送到配置好的镜像仓库（如 Harbor、Docker Hub）。
6. ✏️ **Jenkins 在同一代码仓库中更新部署文件（如 Deployment YAML）**
     Jenkins 构建完镜像后，直接在当前仓库中修改 Kubernetes 部署文件（如 `deployment.yaml` 或 Helm `values.yaml`），将镜像地址更新为刚刚构建的新版本， 然后将这些变更 **再次提交并推送到当前仓库**。
7. 👁️ **Argo CD 监听到 GitOps 仓库的变更**
     Argo CD 持续监控配置的 GitOps 仓库路径，一旦发现部署文件发生变更（如镜像版本更新），立即进行同步。
8. 🚀 **Argo CD 自动将变更部署到 Kubernetes 集群**
     Argo CD 根据更新后的配置文件，将新版本的镜像部署到目标 Kubernetes 环境中，实现自动化发布。

------

这个流程实现了从 **代码提交 → 自动构建 → 镜像推送 → 自动部署** 的完整闭环，开发人员只需要推一次代码，后面的构建、部署都无需手动干预。



## 快速开始

### 添加 Git 仓库

Argo CD 通过 Kubernetes Secret 来声明 Git 仓库的认证信息。

#### HTTP

使用 Secret 声明 Git 仓库的 HTTP 信息

```
kubectl apply -f - <<EOF
apiVersion: v1
kind: Secret
metadata:
  name: my-springboot-repo
  namespace: argocd
  labels:
    argocd.argoproj.io/secret-type: repository
type: Opaque
stringData:
  type: git
  url: http://gitlab.lingo.local/kongyu/springboot-demo.git
  username: kongyu
  password: Admin@12345
EOF
```

#### SSH（跳过验证）

使用 Secret 声明 Git 仓库的 SSH 信息

使用 `insecure: "true"` 跳过 host 验证

```
kubectl apply -f - <<EOF
apiVersion: v1
kind: Secret
metadata:
  name: my-springboot-repo-ssh
  namespace: argocd
  labels:
    argocd.argoproj.io/secret-type: repository
type: Opaque
stringData:
  type: git
  url: ssh://git@192.168.1.51:22/kongyu/springboot-demo.git
  sshPrivateKey: |
    -----BEGIN OPENSSH PRIVATE KEY-----
    b3BlbnNzaC1rZXktdjEAAAAABG5vbmUAAAAEbm9uZQAAAAAAAAABAAAAMwAAAAtzc2gtZW
    QyNTUxOQAAACCz/8+IsXTRvPTIFG/Aolc01zjlj5974+yQDryhR7NZEAAAALAOVh0TDlYd
    EwAAAAtzc2gtZWQyNTUxOQAAACCz/8+IsXTRvPTIFG/Aolc01zjlj5974+yQDryhR7NZEA
    AAAEDbLxmQQzqUOHi7Isbf01cbajIFhsuKcsHAqfzcrDfpw7P/z4ixdNG89MgUb8CiVzTX
    OOWPn3vj7JAOvKFHs1kQAAAAKTIzODU1Njk5NzBAcXEuY29tIC0gU2VydmVyIEtleSAtID
    IwMjUwNDExAQIDBA==
    -----END OPENSSH PRIVATE KEY-----
  insecure: "true"
EOF
```

#### SSH

**获取git仓库的主机密钥**

```
ssh-keyscan -p 22 192.168.1.51 2>/dev/null
```

**Argo CD添加git仓库的主机密钥**

- 修改configmap，添加到 `data.ssh_known_hosts` 中

```
kubectl -n argocd edit configmap argocd-ssh-known-hosts-cm
```

- 在Dashboard中

![image-20250411145531238](./assets/image-20250411145531238.png)

使用 Secret 声明 Git 仓库的 SSH 信息

```
kubectl apply -f - <<EOF
apiVersion: v1
kind: Secret
metadata:
  name: my-springboot-repo-ssh
  namespace: argocd
  labels:
    argocd.argoproj.io/secret-type: repository
type: Opaque
stringData:
  type: git
  url: ssh://git@192.168.1.51:22/kongyu/springboot-demo.git
  sshPrivateKey: |
    -----BEGIN OPENSSH PRIVATE KEY-----
    b3BlbnNzaC1rZXktdjEAAAAABG5vbmUAAAAEbm9uZQAAAAAAAAABAAAAMwAAAAtzc2gtZW
    QyNTUxOQAAACCz/8+IsXTRvPTIFG/Aolc01zjlj5974+yQDryhR7NZEAAAALAOVh0TDlYd
    EwAAAAtzc2gtZWQyNTUxOQAAACCz/8+IsXTRvPTIFG/Aolc01zjlj5974+yQDryhR7NZEA
    AAAEDbLxmQQzqUOHi7Isbf01cbajIFhsuKcsHAqfzcrDfpw7P/z4ixdNG89MgUb8CiVzTX
    OOWPn3vj7JAOvKFHs1kQAAAAKTIzODU1Njk5NzBAcXEuY29tIC0gU2VydmVyIEtleSAtID
    IwMjUwNDExAQIDBA==
    -----END OPENSSH PRIVATE KEY-----
  insecure: "false"
EOF
```



### 创建 Application 资源

#### git仓库的yaml配置

```
[root@k8s-master01 deploy]# cat kustomization.yaml
resources:
  - deployment.yaml
  - service.yaml

[root@k8s-master01 deploy]# cat deployment.yaml
kind: Deployment
apiVersion: apps/v1
metadata:
  name: ateng-springboot3-demo
  labels:
    app: ateng-springboot3-demo
spec:
  replicas: 1
  selector:
    matchLabels:
      app: ateng-springboot3-demo
  template:
    metadata:
      labels:
        app: ateng-springboot3-demo
    spec:
      containers:
        - name: app
          image: registry.lingo.local/ateng/springboot3:develop-build-1
          command:
            - java
          args:
            - -server
            - -Xms512m
            - -Xmx2048m
            - -jar
            - /opt/app/app.jar
            - --server.port=8080
            - --spring.profiles.active=dev
          ports:
            - name: web
              containerPort: 8080
              protocol: TCP
          resources:
            limits:
              cpu: '2'
              memory: 2Gi
            requests:
              cpu: 500m
              memory: 512Mi
          #livenessProbe:
          #  httpGet:
          #    path: /actuator/health
          #    port: 8080
          #    scheme: HTTP
          #  initialDelaySeconds: 30
          #  timeoutSeconds: 1
          #  periodSeconds: 10
          #  successThreshold: 1
          #  failureThreshold: 3
          #readinessProbe:
          #  httpGet:
          #    path: /actuator/health
          #    port: 8080
          #    scheme: HTTP
          #  initialDelaySeconds: 10
          #  timeoutSeconds: 1
          #  periodSeconds: 10
          #  successThreshold: 1
          #  failureThreshold: 3
          imagePullPolicy: IfNotPresent
      terminationGracePeriodSeconds: 60
      affinity:
        podAntiAffinity:
          preferredDuringSchedulingIgnoredDuringExecution:
            - podAffinityTerm:
                labelSelector:
                  matchLabels:
                    app: ateng-springboot3-demo
                topologyKey: kubernetes.io/hostname
              weight: 1
        nodeAffinity:
          preferredDuringSchedulingIgnoredDuringExecution:
            - preference:
                matchExpressions:
                  - key: kubernetes.service/ateng-springboot3-demo
                    operator: In
                    values:
                      - "true"
              weight: 1
[root@k8s-master01 deploy]# cat service.yaml 
apiVersion: v1
kind: Service
metadata:
  name: ateng-springboot3-demo-service
  labels:
    app: ateng-springboot3-demo
spec:
  type: NodePort
  selector:
    app: ateng-springboot3-demo
  ports:
  - name: web
    protocol: TCP
    port: 8080
    targetPort: 8080
    nodePort: 30808
```

🔍 Argo CD 支持的 Source Type 类型一览：

| Source Type     | 自动识别方式                                        | 说明                                |
| --------------- | --------------------------------------------------- | ----------------------------------- |
| `kustomize`     | 目录下有 `kustomization.yaml` / `kustomization.yml` | 用于基于 Kustomize 的配置管理       |
| `helm`          | 目录下有 `Chart.yaml`                               | Helm chart                          |
| `directory`     | 没有上面两个文件但包含纯 YAML 文件                  | 纯 YAML 文件（kubectl apply）       |
| `jsonnet`       | 目录下有 `.jsonnet` 或 `jsonnetfile.json`           | 用于使用 Jsonnet 的项目             |
| `plugin`        | 需要手动设置，在 Application 里指定                 | 自定义工具（如 kpt、cue、cdk8s 等） |
| `ksonnet`（旧） | 旧版本支持，使用 `.ks.yaml` 文件结构                | 已弃用                              |
| `custom tool`   | 配置 plugin，结合 `argocd-cm` 添加 plugin 配置使用  | 高级玩法：可以支持你自己的生成逻辑  |



#### 创建 Application 资源

**创建apps**

注意 `spec.source.repoURL` 需要和使用 Secret 创建的 url 保持一致

这里将git仓库的应用部署到 kongyu 命名空间

```
kubectl apply -f - <<EOF
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: my-springboot
  namespace: argocd
spec:
  project: default
  source:
    repoURL: ssh://git@192.168.1.51:22/kongyu/springboot-demo.git
    targetRevision: master
    path: deploy/
  destination:
    server: https://kubernetes.default.svc
    namespace: kongyu
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
EOF
```

 **参数说明：**

- `apiVersion`: Argo CD 的资源版本，`argoproj.io/v1alpha1` 是当前 `Application` 的 API 版本
- `kind`: 资源类型，这里是 `Application`，代表一个 GitOps 应用声明
- `metadata.name`: `my-springboot`，这是这个 Application 的名称
- `metadata.namespace`: 应用资源存在的命名空间，这里放在 `argocd` 中（推荐做法）

------

🔧 `spec` 段：

- `project`: 应用所属的 Argo CD 项目，这里是默认的 `default`
- `source.repoURL`: Git 仓库地址（使用 SSH 协议）
- `source.targetRevision`: Git 分支或 Tag，这里是 `develop` 分支
- `source.path`: Git 仓库中部署资源所在的子路径，这里是 `deploy/`

------

📦 `destination` 段：

- `destination.server`: Kubernetes API 的地址，`https://kubernetes.default.svc` 是集群内部的默认地址
- `destination.namespace`: 要部署到哪个 Kubernetes 命名空间，这里是 `kongyu`

------

🔄 `syncPolicy.automated` 段：

- `automated`: 启用自动同步功能（Auto Sync）
- `prune`: 如果 Git 仓库中删除了某个资源，Argo CD 也会从集群中删除它
- `selfHeal`: 如果集群中资源被手动修改，Argo CD 会自动将其回滚为 Git 中的版本

**查看列表**

```
kubectl get -n argocd apps
```

**查看信息**

```
kubectl describe -n argocd apps my-springboot
```

**查看部署的应用**

```
kubectl get -n kongyu pod -l app=ateng-springboot3-demo
```



#### 其他参数

```

```



## 多集群

### 注册目标集群到 Argo CD

在你的 Argo CD 控制的机器上执行（前提是你能 `kubectl` 控制目标集群）：

```bash
argocd cluster add <context-name>
```

比如：

```bash
argocd cluster add my-dev-cluster
```

> ⚠️ `context-name` 来自 `kubectl config get-contexts`，表示你 kubeconfig 中的目标集群上下文。

这一步会创建一个 `ServiceAccount` 并配置权限，注册到 Argo CD 中。

------

### 查看已注册集群

```bash
argocd cluster list
```

你会看到一个或多个集群的 `SERVER` 地址，像这样：

```
SERVER                          NAME              ...
https://10.1.2.3:6443           my-dev-cluster    ...
https://kubernetes.default.svc  in-cluster        ...
```

------

### 修改 Application 配置

只要改 `destination.server` 为你注册的新集群地址就行，比如：

```yaml
destination:
  server: https://10.1.2.3:6443
  namespace: kongyu
```

> 👆 这个地址要和 `argocd cluster list` 中显示的 `SERVER` 一致。

------

🔐 小提示：

- Argo CD 是通过一个 ServiceAccount 来控制其他集群的，所以必须有权限。
- 如果你想用不同的 kubeconfig 文件注册，请用 `--kubeconfig` 参数。
- 如果你有多个环境（如 dev、staging、prod），这是实现 GitOps 多集群部署的神器。



## Jenkins实现CI

更多Jenkins的用法参考文档：[Jenkins使用文档](/work/service/jenkins/OPS.md)

### 配置Generic Webhook Trigger

**安装插件**

Generic Webhook Trigger

**配置插件**

在 `Pipeline` 任务中，配置 `Triggers` 的 `Generic Webhook Trigger` 部分

**Post content parameters 部分**

```
- Variable 1:
    Name: ref
    Expression: $.ref
    JSONPath: √
- Variable 2:
    Name: commit_message
    Expression: $.commits[0].message
    JSONPath: √
```

**Optional filter部分**

```
Expression: ^(refs/heads/(master|production))\|\|(?!.*\[skip-ci\]).*$
Text: ${ref}||${commit_message}
```

✅ 字段解释：

- **Expression**：写一个正则表达式，用来匹配下方的 `Text` 字段
- **Text**：用配置好的变量（如 `${ref}`、`${commit_message}`）拼出你想测试的字符串

这个判断逻辑是：if (Text matches Expression) → 构建触发

✅ 最终效果：

只有在分支是 `master` 或 `production`，**且 commit message 不含 `[skip-ci]`** 的时候才会触发构建。



### 编辑流水线脚本

通过Webhook或者手动触发流水线后，从远程仓库拉取代码、打包、构建镜像并推送镜像仓库，最后修改部署文件的镜像名称再提交更改到git仓库。

```groovy
pipeline {
    agent {
        kubernetes {
            label 'jenkins-agent-ateng-k8s-springboot3'  // Pod templates中设置的标签
        }
    }

    // 环境变量
    environment {
        // Git仓库
        GIT_CREDENTIALS_ID = "gitlab_ssh"  // Jenkins 中配置的 GitLab 凭据 ID
        GIT_URL = "ssh://git@192.168.1.51:22/kongyu/springboot-demo.git"  // GitLab 仓库地址
        GIT_BRANCH = "master"  // 要拉取的分支
        
        // Docker镜像和仓库
        DOCKER_IMAGE = "springboot3"  // 构建的镜像名称，标签自动生成
        DOCKER_REGISTRY = "registry.lingo.local/ateng"  // 镜像仓库地址
        DOCKER_CREDENTIALS_ID = "harbor_admin"  // 镜像仓库凭证
    }

    stages {

        stage('设置并查看环境变量') {
            steps {
                container('maven') {
                    script {
                        // 镜像标签生成规则
                        env.DOCKER_TAG = "$GIT_BRANCH-build-$BUILD_NUMBER"
                        sh "env"
                    }
                }
            }
        }

       stage('拉取代码') {
            steps {
                // maven、node、golang 这些基础容器中包含有git命令
                container('maven') {
                    script {
                        checkout([$class: "GitSCM",
                            branches: [[name: "*/${GIT_BRANCH}"]],
                            userRemoteConfigs: [[
                                url: "${GIT_URL}",
                                credentialsId: "${GIT_CREDENTIALS_ID}"
                            ]]
                        ])
                    }
                }
            }
        }

        stage('项目打包') {
            steps {
                container('maven') {
                    script {
                        sh 'mvn clean package -DskipTests'
                    }
                }
            }
        }

        stage('构建容器镜像') {
            steps {
                container('docker') {
                    script {
                        sh 'docker build -f Dockerfile -t $DOCKER_REGISTRY/$DOCKER_IMAGE:$DOCKER_TAG .'
                    }
                }
            }
        }

        stage('推送镜像到仓库') {
            steps {
                container('docker') {
                    withDockerRegistry([credentialsId: "$DOCKER_CREDENTIALS_ID", url: "http://$DOCKER_REGISTRY"]) {
                        sh 'docker push $DOCKER_REGISTRY/$DOCKER_IMAGE:$DOCKER_TAG'
                    }
                }
            }
        }

        stage('更新部署文件并推送到仓库') {
            steps {
                container('maven') {
                    sshagent (credentials: ["$GIT_CREDENTIALS_ID"]) {
                        // 替换 deployment.yaml 中的镜像地址
                        sh """
                            sed -i 's|image: .*|image: $DOCKER_REGISTRY/$DOCKER_IMAGE:$DOCKER_TAG|' deploy/deployment.yaml
                        """
                        // 更新部署文件并推送到仓库
                        sh """
                            git config --global --add safe.directory $WORKSPACE
                            git config user.name "Jenkins CI"
                            git config user.email "jenkins@ci.local"
                            export GIT_SSH_COMMAND="ssh -o StrictHostKeyChecking=no"
                            git fetch origin
                            git checkout -B $GIT_BRANCH origin/$GIT_BRANCH
                            git add deploy/
                            git commit -m "更新镜像为 $DOCKER_TAG [skip-ci]"
                            git push origin $GIT_BRANCH
                        """
                    }
                }
            }
        }


    }
    
}
```

