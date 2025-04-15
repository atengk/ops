# Helm使用文档



## 制作JavaAPP Chart

### 目录结构

```
./springboot-app/
├── Chart.lock
├── charts
│   └── common-2.30.0.tgz
├── Chart.yaml
├── templates
│   ├── deployment.yaml
│   ├── extra-list.yaml
│   ├── hpa.yaml
│   ├── ingress.yaml
│   ├── networkpolicy.yaml
│   ├── pdb.yaml
│   ├── pvc.yaml
│   ├── rolebinding.yaml
│   ├── role.yaml
│   ├── serviceaccount.yaml
│   └── svc.yaml
└── values.yaml
```

### 基础文件创建

#### 创建目录

```
mkdir springboot-app
cd springboot-app
```

#### Chart.yaml

```yaml
apiVersion: v2
name: springboot-app
description: A Helm chart for deploying a Spring Boot application
type: application
version: 0.1.0
appVersion: "1.0.0"
dependencies:
- name: common
  repository: oci://registry-1.docker.io/bitnamicharts
  tags:
  - bitnami-common
  version: 2.x.x
```

#### values.yaml

```yaml
# Copyright Broadcom, Inc. All Rights Reserved.
# SPDX-License-Identifier: APACHE-2.0

## @section Global parameters
## Global Docker image parameters
## Please, note that this will override the image parameters, including dependencies, configured to use the global value
## Current available global Docker image parameters: imageRegistry, imagePullSecrets and storageClass

## @param global.imageRegistry Global Docker image registry
## @param global.imagePullSecrets Global Docker registry secret names as an array
## @param global.defaultStorageClass Global default StorageClass for Persistent Volume(s)
## @param global.storageClass DEPRECATED: use global.defaultStorageClass instead
##
global:
  imageRegistry: ""
  ## E.g.
  ## imagePullSecrets:
  ##   - myRegistryKeySecretName
  ##
  imagePullSecrets: []
  defaultStorageClass: ""
  storageClass: ""
## @param kubeVersion Override Kubernetes version
##
kubeVersion: ""
## @param nameOverride String to partially override common.names.fullname
##
nameOverride: ""
## @param fullnameOverride String to fully override common.names.fullname
##
fullnameOverride: ""
## @param replicaCount Number of container replicas
##
replicaCount: 1
## @param commonLabels Labels to add to all deployed objects
## Example:
## commonLabels:
##   team: devops
##   environment: production
##   owner: alice
commonLabels: {}
## @param commonAnnotations Annotations to add to all deployed objects
## Example:
## commonAnnotations:
##   prometheus.io/scrape: "true"
##   prometheus.io/port: "8080"
##   example.com/owner: "alice"
commonAnnotations: {}
## @param clusterDomain Kubernetes cluster domain name
##
clusterDomain: cluster.local
## @param extraDeploy Array of extra objects to deploy with the release
## Example:
## extraDeploy:
##   - |
##     apiVersion: v1
##     kind: ConfigMap
##     metadata:
##       name: my-custom-config
##     data:
##       MY_ENV: "production"
##   - |
##     apiVersion: batch/v1
##     kind: CronJob
##     metadata:
##       name: my-cron
##     spec:
##       schedule: "*/5 * * * *"
##       jobTemplate:
##         spec:
##           template:
##             spec:
##               containers:
##                 - name: job
##                   image: busybox
##                   command: ["echo", "hello from cron"]
##               restartPolicy: OnFailure
extraDeploy: []
## Enable diagnostic mode in the deployment
##
diagnosticMode:
  ## @param diagnosticMode.enabled Enable diagnostic mode (all probes will be disabled and the command will be overridden)
  ##
  enabled: false
  ## @param diagnosticMode.command Command to override all containers in the deployment
  ##
  command:
    - sleep
  ## @param diagnosticMode.args Args to override all containers in the deployment
  ##
  args:
    - infinity

## 镜像设置
image:
  registry: swr.cn-north-1.myhuaweicloud.com
  repository: kongyu/java-app-integrated-cmd
  tag: debian12_temurin_openjdk-jdk-21-jre
  digest: ""
  pullPolicy: IfNotPresent
  pullSecrets: []

## @param command Override default container command (useful when using custom images)
##
command: []
## @param args Override default container args (useful when using custom images)
##
args: []
## @param extraEnvVars Array with extra environment variables to add to the Jenkins container
## Example:
## extraEnvVars:
##   - name: SPRING_PROFILES_ACTIVE
##     value: "prod"
##   - name: JAVA_OPTS
##     value: "-Xms512m -Xmx1024m"
##   - name: CUSTOM_VAR
##     valueFrom:
##       configMapKeyRef:
##         name: my-config
##         key: custom-value
extraEnvVars: []
## @param extraEnvVarsCM Name of existing ConfigMap containing extra env vars
##
extraEnvVarsCM: ""
## @param extraEnvVarsSecret Name of existing Secret containing extra env vars
##
extraEnvVarsSecret: ""
## @param updateStrategy.type Jenkins deployment strategy type
## ref: https://kubernetes.io/docs/concepts/workloads/controllers/deployment/#strategy
## NOTE: Set it to `Recreate` if you use a PV that cannot be mounted on multiple pods
## Example:
## updateStrategy:
##  type: RollingUpdate
##  rollingUpdate:
##    maxSurge: 25%
##    maxUnavailable: 25%
## updateStrategy:
##   type: Recreate
updateStrategy:
  type: RollingUpdate
## @param priorityClassName Jenkins pod priority class name
## Example:
## priorityClassName: "high-priority"
priorityClassName: ""
## @param schedulerName Name of the k8s scheduler (other than default)
## ref: https://kubernetes.io/docs/tasks/administer-cluster/configure-multiple-schedulers/
## Example:
## schedulerName: my-custom-scheduler
schedulerName: ""
## @param topologySpreadConstraints Topology Spread Constraints for pod assignment
## https://kubernetes.io/docs/concepts/workloads/pods/pod-topology-spread-constraints/
## The value is evaluated as a template
## Example:
## topologySpreadConstraints:
##   - maxSkew: 1
##     topologyKey: "topology.kubernetes.io/zone"
##     whenUnsatisfiable: "ScheduleAnyway"
##     labelSelector:
##       matchLabels:
##         app.kubernetes.io/name: my-app
topologySpreadConstraints: []
## @param hostAliases Jenkins pod host aliases
## https://kubernetes.io/docs/concepts/services-networking/add-entries-to-pod-etc-hosts-with-host-aliases/
## Example:
## hostAliases:
##   - ip: "127.0.0.1"
##     hostnames:
##     - "foo.local"
##     - "bar.local"
##   - ip: "10.1.2.3"
##     hostnames:
##     - "foo.remote"
##     - "bar.remote"
hostAliases: []
## @param extraVolumes Optionally specify extra list of additional volumes for Jenkins pods
## Example:
## extraVolumes:
##   - name: extra-volume
##     emptyDir: {}
##   - name: config-volume
##     configMap:
##       name: config-map-name
extraVolumes: []
## @param extraVolumeMounts Optionally specify extra list of additional volumeMounts for Jenkins container(s)
## Example:
## extraVolumeMounts:
##   - name: extra-volume
##     mountPath: /data
##     subPath: data-dir
##   - name: config-volume
##     mountPath: /etc/config
extraVolumeMounts: []
## @param sidecars Add additional sidecar containers to the Jenkins pod
## e.g:
## sidecars:
##   - name: your-image-name
##     image: your-image
##     imagePullPolicy: Always
##     ports:
##       - name: portname
##         containerPort: 1234
##
sidecars: []
## @param initContainers Add additional init containers to the Jenkins pods
## ref: https://kubernetes.io/docs/concepts/workloads/pods/init-containers/
## e.g:
## initContainers:
##  - name: your-image-name
##    image: your-image
##    imagePullPolicy: Always
##    ports:
##      - name: portname
##        containerPort: 1234
##
initContainers: []
## Pod Disruption Budget configuration
## ref: https://kubernetes.io/docs/tasks/run-application/configure-pdb
## @param pdb.create Enable/disable a Pod Disruption Budget creation
## @param pdb.minAvailable Minimum number/percentage of pods that should remain scheduled
## @param pdb.maxUnavailable Maximum number/percentage of pods that may be made unavailable. Defaults to `1` if both `pdb.minAvailable` and `pdb.maxUnavailable` are empty.
##
pdb:
  create: false
  minAvailable: ""
  maxUnavailable: ""
## Apache Autoscaling parameters
## ref: https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/
## @param autoscaling.enabled Enable Horizontal POD autoscaling for Apache
## @param autoscaling.minReplicas Minimum number of Apache replicas
## @param autoscaling.maxReplicas Maximum number of Apache replicas
## @param autoscaling.targetCPU Target CPU utilization percentage
## @param autoscaling.targetMemory Target Memory utilization percentage
##
autoscaling:
  enabled: false
  minReplicas: 1
  maxReplicas: 11
  targetCPU: 50
  targetMemory: 50

## @param lifecycleHooks Add lifecycle hooks to the Jenkins deployment
## Example:
## lifecycleHooks:
##   postStart:
##     exec:
##       command:
##         - "/bin/sh"
##         - "-c"
##         - "echo Container started at $(date)"
##   preStop:
##     exec:
##       command:
##         - "/bin/sh"
##         - "-c"
##         - "echo Container stopping at $(date) && sleep 5"
lifecycleHooks: {}
## @param podLabels Extra labels for Jenkins pods
## ref: https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/
## Example:
## podLabels:
##   app.kubernetes.io/name: my-app
##   app.kubernetes.io/instance: my-app
##   app.kubernetes.io/component: backend
podLabels: {}
## @param podAnnotations Annotations for Jenkins pods
## ref: https://kubernetes.io/docs/concepts/overview/working-with-objects/annotations/
## Example:
## podAnnotations:
##   prometheus.io/scrape: "true"
##   prometheus.io/port: "8080"
##   example.com/owner: "alice"
podAnnotations: {}
## @param podAffinityPreset Pod affinity preset. Ignored if `affinity` is set. Allowed values: `soft` or `hard`
## ref: https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#inter-pod-affinity-and-anti-affinity
## Example:
## podAffinityPreset: "soft"  ## 调度到同一节点
## podAffinityPreset: "hard"  ## 调度到同一节点（强制）
podAffinityPreset: ""
## @param podAntiAffinityPreset Pod anti-affinity preset. Ignored if `affinity` is set. Allowed values: `soft` or `hard`
## Ref: https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#inter-pod-affinity-and-anti-affinity
## Example:
## podAntiAffinityPreset: "soft"  ## 调度到不同节点
## podAntiAffinityPreset: "hard"  ## 调度到不同节点（强制）
podAntiAffinityPreset: soft
## Node affinity preset
## Ref: https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#node-affinity
## Example:
## nodeAffinityPreset:  ## 调度到包含指定标签的节点，例如创建节点标签：kubectl label node server02.lingo.local kubernetes.service/springboot-app="true"
##   type: "soft"
##   key: "kubernetes.service/springboot-app"
##   values:
##     - "true"
##     - "yes"
nodeAffinityPreset:
  ## @param nodeAffinityPreset.type Node affinity preset type. Ignored if `affinity` is set. Allowed values: `soft` or `hard`
  ##
  type: ""
  ## @param nodeAffinityPreset.key Node label key to match. Ignored if `affinity` is set
  ##
  key: ""
  ## @param nodeAffinityPreset.values Node label values to match. Ignored if `affinity` is set
  ## E.g.
  ## values:
  ##   - e2e-az1
  ##   - e2e-az2
  ##
  values: []
## @param affinity Affinity for pod assignment
## Ref: https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#affinity-and-anti-affinity
## NOTE: podAffinityPreset, podAntiAffinityPreset, and nodeAffinityPreset will be ignored when it's set
## Example:
## affinity:
##   podAffinity:
##     preferredDuringSchedulingIgnoredDuringExecution:
##       - podAffinityTerm:
##           labelSelector:
##             matchLabels:
##               app.kubernetes.io/instance: my-app
##               app.kubernetes.io/name: springboot-app
##               app.kubernetes.io/component: springboot-app
##           topologyKey: kubernetes.io/hostname
##         weight: 1
##   podAntiAffinity:
##     preferredDuringSchedulingIgnoredDuringExecution:
##       - podAffinityTerm:
##           labelSelector:
##             matchLabels:
##               app.kubernetes.io/instance: my-app
##               app.kubernetes.io/name: springboot-app
##               app.kubernetes.io/component: springboot-app
##           topologyKey: kubernetes.io/hostname
##         weight: 1
##   nodeAffinity:
##     preferredDuringSchedulingIgnoredDuringExecution:
##       - preference:
##           matchExpressions:
##             - key: kubernetes.service/springboot-app
##               operator: In
##               values:
##                 - "true"
##                 - "yes"
##         weight: 1
affinity: {}
## @param nodeSelector Node labels for pod assignment
## ref: https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/
## Example:
## nodeSelector:
##   kubernetes.io/os: linux
##   node-role.kubernetes.io/worker: "true"
nodeSelector: {}
## @param tolerations Tolerations for pod assignment
## ref: https://kubernetes.io/docs/concepts/configuration/taint-and-toleration/
## Example:
## tolerations:
##   - key: "node.kubernetes.io/not-ready"
##     operator: "Exists"
##     effect: "NoExecute"
##     tolerationSeconds: 300
##   - key: "node-role.kubernetes.io/infra"
##     operator: "Equal"
##     value: "true"
##     effect: "NoSchedule"
tolerations: []
## Jenkins containers' resource requests and limits
## ref: https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/
## @param resourcesPreset Set container resources according to one common preset (allowed values: none, nano, micro, small, medium, large, xlarge, 2xlarge). This is ignored if resources is set (resources is recommended for production).
## More information: https://github.com/bitnami/charts/blob/main/bitnami/common/templates/_resources.tpl#L15
##
resourcesPreset: "none"
## @param resources Set container requests and limits for different resources like CPU or memory (essential for production workloads)
## Example:
## resources:
##   requests:
##     cpu: 2
##     memory: 512Mi
##   limits:
##     cpu: 3
##     memory: 1024Mi
##
resources: {}
## Container ports
## Example:
## containerPorts:
##   - name: http
##     containerPort: 8080
##     protocol: TCP
##   - name: metrics
##     containerPort: 9100
##     protocol: TCP
##   - name: grpc
##     containerPort: 9090
##     protocol: TCP
##
containerPorts:
  - name: http
    containerPort: 8080
    protocol: TCP
## Configure Pods Security Context
## ref: https://kubernetes.io/docs/tasks/configure-pod-container/security-context/#set-the-security-context-for-a-pod
## @param podSecurityContext.enabled Enabled Jenkins pods' Security Context
## @param podSecurityContext.fsGroupChangePolicy Set filesystem group change policy
## @param podSecurityContext.sysctls Set kernel settings using the sysctl interface
## @param podSecurityContext.supplementalGroups Set filesystem extra groups
## @param podSecurityContext.fsGroup Set Jenkins pod's Security Context fsGroup
##
podSecurityContext:
  enabled: false
  fsGroupChangePolicy: Always
  sysctls: []
  supplementalGroups: []
  fsGroup: 1001
## Configure Container Security Context (only main container)
## ref: https://kubernetes.io/docs/tasks/configure-pod-container/security-context/#set-the-security-context-for-a-container
## @param containerSecurityContext.enabled Enabled containers' Security Context
## @param containerSecurityContext.seLinuxOptions [object,nullable] Set SELinux options in container
## @param containerSecurityContext.runAsUser Set containers' Security Context runAsUser
## @param containerSecurityContext.runAsGroup Set containers' Security Context runAsGroup
## @param containerSecurityContext.runAsNonRoot Set container's Security Context runAsNonRoot
## @param containerSecurityContext.privileged Set container's Security Context privileged
## @param containerSecurityContext.readOnlyRootFilesystem Set container's Security Context readOnlyRootFilesystem
## @param containerSecurityContext.allowPrivilegeEscalation Set container's Security Context allowPrivilegeEscalation
## @param containerSecurityContext.capabilities.drop List of capabilities to be dropped
## @param containerSecurityContext.seccompProfile.type Set container's Security Context seccomp profile
##
containerSecurityContext:
  enabled: false
  seLinuxOptions: {}
  runAsUser: 1001
  runAsGroup: 1001
  runAsNonRoot: true
  privileged: false
  readOnlyRootFilesystem: true
  allowPrivilegeEscalation: false
  capabilities:
    drop: ["ALL"]
  seccompProfile:
    type: "RuntimeDefault"
## Configure extra options for Jenkins containers' startup, liveness and readiness probes
## ref: https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-probes/#configure-probes
## @param customStartupProbe Custom startupProbe that overrides the default one
## Example:
## customStartupProbe:
##   httpGet:
##     path: /actuator/health
##     port: http
##   initialDelaySeconds: 5
##   periodSeconds: 10
##   failureThreshold: 30
customStartupProbe: {}
## @param customLivenessProbe Custom livenessProbe that overrides the default one
## Example:
## customLivenessProbe:
##   httpGet:
##     path: /actuator/health
##     port: http
##   initialDelaySeconds: 10
##   periodSeconds: 10
##   timeoutSeconds: 2
##   failureThreshold: 3
customLivenessProbe: {}
## @param customReadinessProbe Custom readinessProbe that overrides the default one
## Example:
## customReadinessProbe:
##   httpGet:
##     path: /actuator/health
##     port: http
##   initialDelaySeconds: 5
##   periodSeconds: 5
##   timeoutSeconds: 1
##   failureThreshold: 3
customReadinessProbe: {}

## Jenkins service parameters
##
service:
  ## @param service.type Jenkins service type
  ##
  type: ClusterIP
  ## @param service.ports
  ## Example:
  ## ports:
  ## - name: http
  ##   port: 80
  ##   targetPort: 8080
  ##   protocol: TCP
  ##   nodePort: 38083
  ## - name: metrics
  ##   port: 9100
  ##   targetPort: 9100
  ##   protocol: TCP
  ##   nodePort: null
  ports:
    - name: http
      port: 80
      targetPort: 8080
      protocol: TCP
      nodePort: 38083
  ## @param service.clusterIP Jenkins service Cluster IP
  ## e.g.:
  ## clusterIP: None
  ##
  clusterIP: ""
  ## @param service.loadBalancerIP Jenkins service Load Balancer IP
  ## ref: https://kubernetes.io/docs/concepts/services-networking/service/#type-loadbalancer
  ##
  loadBalancerIP: ""
  ## @param service.loadBalancerSourceRanges Jenkins service Load Balancer sources
  ## ref: https://kubernetes.io/docs/tasks/access-application-cluster/configure-cloud-provider-firewall/#restrict-access-for-loadbalancer-service
  ## e.g:
  ## loadBalancerSourceRanges:
  ##   - 10.10.10.0/24
  ##
  loadBalancerSourceRanges: []
  ## @param service.externalTrafficPolicy Jenkins service external traffic policy
  ## ref https://kubernetes.io/docs/tasks/access-application-cluster/create-external-load-balancer/#preserving-the-client-source-ip
  ##
  externalTrafficPolicy: Cluster
  ## @param service.annotations Additional custom annotations for Jenkins service
  ##
  annotations: {}
  ## @param service.extraPorts Extra ports to expose (normally used with the `sidecar` value)
  ##
  extraPorts: []
  ## @param service.sessionAffinity Session Affinity for Kubernetes service, can be "None" or "ClientIP"
  ## If "ClientIP", consecutive client requests will be directed to the same Pod
  ## ref: https://kubernetes.io/docs/concepts/services-networking/service/#virtual-ips-and-service-proxies
  ##
  sessionAffinity: None
  ## @param service.sessionAffinityConfig Additional settings for the sessionAffinity
  ## sessionAffinityConfig:
  ##   clientIP:
  ##     timeoutSeconds: 300
  ##
  sessionAffinityConfig: {}
networkPolicy:
  ## @param networkPolicy.enabled Specifies whether a NetworkPolicy should be created
  ##
  enabled: false
  ## @param networkPolicy.allowExternal Don't require server label for connections
  ## The Policy model to apply. When set to false, only pods with the correct
  ## server label will have network access to the ports server is listening
  ## on. When true, server will accept connections from any source
  ## (with the correct destination port).
  ##
  allowExternal: true
  ## @param networkPolicy.allowExternalEgress Allow the pod to access any range of port and all destinations.
  ##
  allowExternalEgress: true
  ## @param networkPolicy.kubeAPIServerPorts [array] List of possible endpoints to kube-apiserver (limit to your cluster settings to increase security)
  ##
  kubeAPIServerPorts: [443, 6443, 8443]
  ## @param networkPolicy.extraIngress [array] Add extra ingress rules to the NetworkPolicy
  ## e.g:
  ## extraIngress:
  ##   - ports:
  ##       - port: 1234
  ##     from:
  ##       - podSelector:
  ##           - matchLabels:
  ##               - role: frontend
  ##       - podSelector:
  ##           - matchExpressions:
  ##               - key: role
  ##                 operator: In
  ##                 values:
  ##                   - frontend
  extraIngress: []
  ## @param networkPolicy.extraEgress [array] Add extra ingress rules to the NetworkPolicy
  ## e.g:
  ## extraEgress:
  ##   - ports:
  ##       - port: 1234
  ##     to:
  ##       - podSelector:
  ##           - matchLabels:
  ##               - role: frontend
  ##       - podSelector:
  ##           - matchExpressions:
  ##               - key: role
  ##                 operator: In
  ##                 values:
  ##                   - frontend
  ##
  extraEgress: []
  ## @param networkPolicy.ingressNSMatchLabels [object] Labels to match to allow traffic from other namespaces
  ## @param networkPolicy.ingressNSPodMatchLabels [object] Pod labels to match to allow traffic from other namespaces
  ##
  ingressNSMatchLabels: {}
  ingressNSPodMatchLabels: {}
  
ingress:
  ## @param ingress.enabled Enable ingress record generation for Jenkins
  ##
  enabled: false
  ## @param ingress.pathType Ingress path type
  ##
  pathType: ImplementationSpecific
  ## @param ingress.apiVersion Force Ingress API version (automatically detected if not set)
  ##
  apiVersion: ""
  ## @param ingress.hostname Default host for the ingress record
  ##
  hostname: ateng.local
  ## @param ingress.path Default path for the ingress record
  ## NOTE: You may need to set this to '/*' in order to use this with ALB ingress controllers
  ##
  path: /
  ## @param ingress.annotations Additional annotations for the Ingress resource. To enable certificate autogeneration, place here your cert-manager annotations.
  ## For a full list of possible ingress annotations, please see
  ## ref: https://github.com/kubernetes/ingress-nginx/blob/main/docs/user-guide/nginx-configuration/annotations.md
  ## Use this parameter to set the required annotations for cert-manager, see
  ## ref: https://cert-manager.io/docs/usage/ingress/#supported-annotations
  ##
  ## e.g:
  ## annotations:
  ##   kubernetes.io/ingress.class: nginx
  ##   cert-manager.io/cluster-issuer: cluster-issuer-name
  ##
  annotations: {}
  ## @param ingress.tls Enable TLS configuration for the host defined at `ingress.hostname` parameter
  ## TLS certificates will be retrieved from a TLS secret with name: `{{- printf "%s-tls" .Values.ingress.hostname }}`
  ## You can:
  ##   - Use the `ingress.secrets` parameter to create this TLS secret
  ##   - Rely on cert-manager to create it by setting the corresponding annotations
  ##   - Rely on Helm to create self-signed certificates by setting `ingress.selfSigned=true`
  ##
  tls: false
  ## @param ingress.selfSigned Create a TLS secret for this ingress record using self-signed certificates generated by Helm
  ##
  selfSigned: false
  ## @param ingress.extraHosts An array with additional hostname(s) to be covered with the ingress record
  ## e.g:
  ## extraHosts:
  ##   - name: jenkins.local
  ##     path: /
  ##
  extraHosts: []
  ## @param ingress.extraPaths An array with additional arbitrary paths that may need to be added to the ingress under the main host
  ## e.g:
  ## extraPaths:
  ## - path: /*
  ##   backend:
  ##     serviceName: ssl-redirect
  ##     servicePort: use-annotation
  ##
  extraPaths: []
  ## @param ingress.extraTls TLS configuration for additional hostname(s) to be covered with this ingress record
  ## ref: https://kubernetes.io/docs/concepts/services-networking/ingress/#tls
  ## e.g:
  ## extraTls:
  ## - hosts:
  ##     - jenkins.local
  ##   secretName: jenkins.local-tls
  ##
  extraTls: []
  ## @param ingress.secrets Custom TLS certificates as secrets
  ## NOTE: 'key' and 'certificate' are expected in PEM format
  ## NOTE: 'name' should line up with a 'secretName' set further up
  ## If it is not set and you're using cert-manager, this is unneeded, as it will create a secret for you with valid certificates
  ## If it is not set and you're NOT using cert-manager either, self-signed certificates will be created valid for 365 days
  ## It is also possible to create and manage the certificates outside of this helm chart
  ## Please see README.md for more information
  ## e.g:
  ## secrets:
  ##   - name: jenkins.local-tls
  ##     key: |-
  ##       -----BEGIN RSA PRIVATE KEY-----
  ##       ...
  ##       -----END RSA PRIVATE KEY-----
  ##     certificate: |-
  ##       -----BEGIN CERTIFICATE-----
  ##       ...
  ##       -----END CERTIFICATE-----
  ##
  secrets: []
  ## @param ingress.ingressClassName IngressClass that will be be used to implement the Ingress (Kubernetes 1.18+)
  ## This is supported in Kubernetes 1.18+ and required if you have more than one IngressClass marked as the default for your cluster .
  ## ref: https://kubernetes.io/blog/2020/04/02/improvements-to-the-ingress-api-in-kubernetes-1.18/
  ##
  ingressClassName: ""
  ## @param ingress.extraRules Additional rules to be covered with this ingress record
  ## ref: https://kubernetes.io/docs/concepts/services-networking/ingress/#ingress-rules
  ## e.g:
  ## extraRules:
  ## - host: example.local
  ##     http:
  ##       path: /
  ##       backend:
  ##         service:
  ##           name: example-svc
  ##           port:
  ##             name: http
  ##
  extraRules: []
## @section Persistence Parameters

## Persistence Parameters
## ref: https://kubernetes.io/docs/concepts/storage/persistent-volumes/
##
persistence:
  ## @param master.persistence.enabled Enable persistence on Redis&reg; master nodes using Persistent Volume Claims
  ##
  enabled: false
  ## @param master.persistence.path The path the volume will be mounted at on Redis&reg; master containers
  ## NOTE: Useful when using different Redis&reg; images
  ##
  path: /data
  ## @param master.persistence.subPath The subdirectory of the volume to mount on Redis&reg; master containers
  ## NOTE: Useful in dev environments
  ##
  subPath: ""
  ## @param master.persistence.subPathExpr Used to construct the subPath subdirectory of the volume to mount on Redis&reg; master containers
  ##
  subPathExpr: ""
  ## @param master.persistence.storageClass Persistent Volume storage class
  ## If defined, storageClassName: <storageClass>
  ## If set to "-", storageClassName: "", which disables dynamic provisioning
  ## If undefined (the default) or set to null, no storageClassName spec is set, choosing the default provisioner
  ##
  storageClass: ""
  ## @param master.persistence.accessModes Persistent Volume access modes
  ##
  accessModes:
    - ReadWriteOnce
  ## @param master.persistence.size Persistent Volume size
  ##
  size: 8Gi
  ## @param master.persistence.annotations Additional custom annotations for the PVC
  ##
  annotations: {}
  ## @param master.persistence.labels Additional custom labels for the PVC
  ##
  labels: {}
  ## @param master.persistence.selector Additional labels to match for the PVC
  ## e.g:
  ## selector:
  ##   matchLabels:
  ##     app: my-app
  ##
  selector: {}
  ## @param master.persistence.existingClaim Use a existing PVC which must be created manually before bound
  ## NOTE: requires master.persistence.enabled: true
  ##
  existingClaim: ""

## RBAC configuration
##
rbac:
  ## @param rbac.create Specifies whether RBAC resources should be created
  ##
  create: false
  ## @param rbac.rules Custom RBAC rules to set
  ## e.g:
  ## rules:
  ##   - apiGroups:
  ##       - ""
  ##     resources:
  ##       - pods
  ##     verbs:
  ##       - get
  ##       - list
  ##
  rules: []
## ServiceAccount configuration
##
serviceAccount:
  ## @param serviceAccount.create Specifies whether a ServiceAccount should be created
  ##
  create: false
  ## @param serviceAccount.name The name of the ServiceAccount to use.
  ## If not set and create is true, a name is generated using the common.names.fullname template
  ##
  name: ""
  ## @param serviceAccount.annotations Additional Service Account annotations (evaluated as a template)
  ##
  annotations: {}
  ## @param serviceAccount.automountServiceAccountToken Automount service account token for the server service account
  ##
  automountServiceAccountToken: false
```

### templates文件

#### deployment.yaml

```yaml
apiVersion: {{ include "common.capabilities.deployment.apiVersion" . }}
kind: Deployment
metadata:
  name: {{ include "common.names.fullname" . }}
  namespace: {{ include "common.names.namespace" . | quote }}
  labels: {{- include "common.labels.standard" ( dict "customLabels" .Values.commonLabels "context" $ ) | nindent 4 }}
  {{- if .Values.commonAnnotations }}
  annotations: {{- include "common.tplvalues.render" ( dict "value" .Values.commonAnnotations "context" $ ) | nindent 4 }}
  {{- end }}
spec:
  {{- $podLabels := include "common.tplvalues.merge" ( dict "values" ( list .Values.podLabels .Values.commonLabels ) "context" . ) }}
  selector:
    matchLabels: {{- include "common.labels.matchLabels" ( dict "customLabels" $podLabels "context" $ ) | nindent 6 }}
  replicas: {{ .Values.replicaCount | default 1 }}
  strategy: {{- include "common.tplvalues.render" (dict "value" .Values.updateStrategy "context" $ ) | nindent 4 }}
  template:
    metadata:
      labels: {{- include "common.labels.standard" ( dict "customLabels" $podLabels "context" $ ) | nindent 8 }}
        app.kubernetes.io/component: springboot-app
      annotations:
        {{- if .Values.podAnnotations }}
        {{- include "common.tplvalues.render" (dict "value" .Values.podAnnotations "context" $) | nindent 8 }}
        {{- end }}
    spec:
      {{- if .Values.serviceAccount.create }}
      serviceAccountName: {{ default (include "common.names.fullname" .) .Values.serviceAccount.name }}
      {{- else }}
      serviceAccountName: {{ default "default" .Values.serviceAccount.name }}
      {{- end }}
      automountServiceAccountToken: {{ .Values.serviceAccount.automountServiceAccountToken }}
      {{- include "common.images.renderPullSecrets" (dict "images" (list .Values.image) "context" $) | nindent 6 }}
      {{- if .Values.hostAliases }}
      hostAliases: {{- include "common.tplvalues.render" (dict "value" .Values.hostAliases "context" $) | nindent 8 }}
      {{- end }}
      {{- if .Values.affinity }}
      affinity: {{- include "common.tplvalues.render" (dict "value" .Values.affinity "context" $) | nindent 8 }}
      {{- else }}
      affinity:
        podAffinity: {{- include "common.affinities.pods" (dict "type" .Values.podAffinityPreset "component" "springboot-app" "customLabels" $podLabels "context" $) | nindent 10 }}
        podAntiAffinity: {{- include "common.affinities.pods" (dict "type" .Values.podAntiAffinityPreset "component" "springboot-app" "customLabels" $podLabels "context" $) | nindent 10 }}
        nodeAffinity: {{- include "common.affinities.nodes" (dict "type" .Values.nodeAffinityPreset.type "key" .Values.nodeAffinityPreset.key "values" .Values.nodeAffinityPreset.values) | nindent 10 }}
      {{- end }}
      {{- if .Values.nodeSelector }}
      nodeSelector: {{- include "common.tplvalues.render" (dict "value" .Values.nodeSelector "context" $) | nindent 8 }}
      {{- end }}
      {{- if .Values.tolerations }}
      tolerations: {{- include "common.tplvalues.render" (dict "value" .Values.tolerations "context" $) | nindent 8 }}
      {{- end }}
      {{- if .Values.schedulerName }}
      schedulerName: {{ .Values.schedulerName }}
      {{- end }}
      {{- if .Values.topologySpreadConstraints }}
      topologySpreadConstraints: {{- include "common.tplvalues.render" (dict "value" .Values.topologySpreadConstraints "context" .) | nindent 8 }}
      {{- end }}
      {{- if .Values.priorityClassName }}
      priorityClassName: {{ .Values.priorityClassName | quote }}
      {{- end }}
      {{- if .Values.podSecurityContext.enabled }}
      securityContext: {{- include "common.compatibility.renderSecurityContext" (dict "secContext" .Values.podSecurityContext "context" $) | nindent 8 }}
      {{- end }}
      containers:
        - name: app
          image: {{ include "common.images.image" (dict "imageRoot" .Values.image "global" .Values.global) }}
          imagePullPolicy: {{ .Values.image.pullPolicy | quote }}
          {{- if .Values.containerSecurityContext.enabled }}
          securityContext: {{- include "common.compatibility.renderSecurityContext" (dict "secContext" .Values.containerSecurityContext "context" $) | nindent 12 }}
          {{- end }}
          {{- if .Values.diagnosticMode.enabled }}
          command: {{- include "common.tplvalues.render" (dict "value" .Values.diagnosticMode.command "context" $) | nindent 12 }}
          {{- else if .Values.command }}
          command: {{- include "common.tplvalues.render" (dict "value" .Values.command "context" $) | nindent 12 }}
          {{- end }}
          {{- if .Values.diagnosticMode.enabled }}
          args: {{- include "common.tplvalues.render" (dict "value" .Values.diagnosticMode.args "context" $) | nindent 12 }}
          {{- else if .Values.args }}
          args: {{- include "common.tplvalues.render" (dict "value" .Values.args "context" $) | nindent 12 }}
          {{- end }}
          {{- if .Values.lifecycleHooks }}
          lifecycle: {{- include "common.tplvalues.render" (dict "value" .Values.lifecycleHooks "context" $) | nindent 12 }}
          {{- end }}
          env:
            - name: POD_NAME
              valueFrom:
                fieldRef:
                  fieldPath: metadata.name
            {{- if .Values.extraEnvVars }}
            {{- include "common.tplvalues.render" (dict "value" .Values.extraEnvVars "context" $) | nindent 12 }}
            {{- end }}
          {{- if or .Values.extraEnvVarsCM .Values.extraEnvVarsSecret }}
          envFrom:
            {{- if .Values.extraEnvVarsCM }}
            - configMapRef:
                name: {{ include "common.tplvalues.render" (dict "value" .Values.extraEnvVarsCM "context" $) }}
            {{- end }}
            {{- if .Values.extraEnvVarsSecret }}
            - secretRef:
                name: {{ include "common.tplvalues.render" (dict "value" .Values.extraEnvVarsSecret "context" $) }}
            {{- end }}
          {{- end }}
          ports:
          {{- range .Values.containerPorts }}
            - name: {{ .name }}
              containerPort: {{ .containerPort }}
              protocol: {{ .protocol | default "TCP" }}
          {{- end }}
          {{- if not .Values.diagnosticMode.enabled }}
          {{- if .Values.customStartupProbe }}
          startupProbe: {{- include "common.tplvalues.render" (dict "value" .Values.customStartupProbe "context" $) | nindent 12 }}
          {{- end }}
          {{- if .Values.customLivenessProbe }}
          livenessProbe: {{- include "common.tplvalues.render" (dict "value" .Values.customLivenessProbe "context" $) | nindent 12 }}
          {{- end }}
          {{- if .Values.customReadinessProbe }}
          readinessProbe: {{- include "common.tplvalues.render" (dict "value" .Values.customReadinessProbe "context" $) | nindent 12 }}
          {{- end }}
          {{- end }}
          {{- if .Values.resources }}
          resources: {{- include "common.tplvalues.render" (dict "value" .Values.resources "context" $) | nindent 12 }}
          {{- else if ne .Values.resourcesPreset "none" }}
          resources: {{- include "common.resources.preset" (dict "type" .Values.resourcesPreset) | nindent 12 }}
          {{- end }}
          volumeMounts:
            - name: empty-dir
              mountPath: /tmp
              subPath: tmp-dir
            {{- if .Values.persistence.enabled }}
            - name: {{ include "common.names.fullname" . }}
              mountPath: {{ .Values.persistence.path }}
              {{- if .Values.persistence.subPath }}
              subPath: {{ .Values.persistence.subPath }}
              {{- else if .Values.persistence.subPathExpr }}
              subPathExpr: {{ .Values.persistence.subPathExpr }}
              {{- end }}
            {{- end }}
            {{- if .Values.extraVolumeMounts }}
            {{- include "common.tplvalues.render" (dict "value" .Values.extraVolumeMounts "context" $) | nindent 12 }}
            {{- end }}
      volumes:
        - name: empty-dir
          emptyDir: {}
        {{- if .Values.persistence.enabled }}
        - name: {{ include "common.names.fullname" . }}
          persistentVolumeClaim:
            claimName: {{ default (include "common.names.fullname" .) (tpl .Values.persistence.existingClaim $) }}
        {{- end }}
        {{- if .Values.extraVolumes }}
        {{- include "common.tplvalues.render" (dict "value" .Values.extraVolumes "context" $) | nindent 8 }}
        {{- end }}
```

#### svc.yaml

```yaml
apiVersion: v1
kind: Service
metadata:
  name: {{ template "common.names.fullname" . }}
  namespace: {{ include "common.names.namespace" . | quote }}
  labels: {{- include "common.labels.standard" ( dict "customLabels" .Values.commonLabels "context" $ ) | nindent 4 }}
  {{- if or .Values.service.annotations .Values.commonAnnotations }}
  {{- $annotations := include "common.tplvalues.merge" ( dict "values" ( list .Values.service.annotations .Values.commonAnnotations ) "context" . ) }}
  annotations: {{- include "common.tplvalues.render" ( dict "value" $annotations "context" $) | nindent 4 }}
  {{- end }}
spec:
  type: {{ .Values.service.type }}
  {{- if and .Values.service.clusterIP (eq .Values.service.type "ClusterIP") }}
  clusterIP: {{ .Values.service.clusterIP }}
  {{- end }}
  {{- if or (eq .Values.service.type "LoadBalancer") (eq .Values.service.type "NodePort") }}
  externalTrafficPolicy: {{ .Values.service.externalTrafficPolicy | quote }}
  {{- end }}
  {{- if and (eq .Values.service.type "LoadBalancer") .Values.service.loadBalancerSourceRanges }}
  loadBalancerSourceRanges: {{- toYaml .Values.service.loadBalancerSourceRanges | nindent 4 }}
  {{- end }}
  {{- if (and (eq .Values.service.type "LoadBalancer") (not (empty .Values.service.loadBalancerIP))) }}
  loadBalancerIP: {{ .Values.service.loadBalancerIP }}
  {{- end }}
  {{- if .Values.service.sessionAffinity }}
  sessionAffinity: {{ .Values.service.sessionAffinity }}
  {{- end }}
  {{- if .Values.service.sessionAffinityConfig }}
  sessionAffinityConfig: {{- include "common.tplvalues.render" (dict "value" .Values.service.sessionAffinityConfig "context" $) | nindent 4 }}
  {{- end }}
  ports:
  {{- range .Values.service.ports }}
    - name: {{ .name }}
      port: {{ .port }}
      targetPort: {{ .targetPort | default .port }}
      protocol: {{ .protocol | default "TCP" }}
      {{- if and (or (eq $.Values.service.type "NodePort") (eq $.Values.service.type "LoadBalancer")) .nodePort }}
      nodePort: {{ .nodePort }}
      {{- else if eq $.Values.service.type "ClusterIP" }}
      nodePort: null
      {{- end }}
  {{- end }}
    {{- if .Values.service.extraPorts }}
    {{- include "common.tplvalues.render" (dict "value" .Values.service.extraPorts "context" $) | nindent 4 }}
    {{- end }}
  {{- $podLabels := include "common.tplvalues.merge" ( dict "values" ( list .Values.podLabels .Values.commonLabels ) "context" . ) }}
  selector: {{- include "common.labels.matchLabels" ( dict "customLabels" $podLabels "context" $ ) | nindent 4 }}
    app.kubernetes.io/component: springboot-app
```

#### pvc.yaml

```yaml
{{- /*
Copyright Broadcom, Inc. All Rights Reserved.
SPDX-License-Identifier: APACHE-2.0
*/}}

{{- if and .Values.persistence.enabled (not .Values.persistence.existingClaim) }}
kind: PersistentVolumeClaim
apiVersion: v1
metadata:
  name: {{ include "common.names.fullname" . }}
  namespace: {{ include "common.names.namespace" . | quote }}
  labels: {{- include "common.labels.standard" ( dict "customLabels" .Values.commonLabels "context" $ ) | nindent 4 }}
  annotations:
    {{- if or .Values.persistence.annotations .Values.commonAnnotations }}
    {{- $annotations := include "common.tplvalues.merge" ( dict "values" ( list .Values.persistence.annotations .Values.commonAnnotations ) "context" . ) }}
    {{- include "common.tplvalues.render" ( dict "value" $annotations "context" $) | nindent 4 }}
    {{- end }}
spec:
  storageClassName: {{ ternary "" (trimPrefix "storageClassName: " (include "common.storage.class" (dict "persistence" .Values.persistence "global" .Values.global))) (empty (include "common.storage.class" (dict "persistence" .Values.persistence "global" .Values.global))) }}
  accessModes:
  {{- range .Values.persistence.accessModes }}
    - {{ . | quote }}
  {{- end }}
  resources:
    requests:
      storage: {{ .Values.persistence.size | quote }}
  {{- if .Values.persistence.selector }}
  selector: {{- include "common.tplvalues.render" (dict "value" .Values.persistence.selector "context" $) | nindent 4 }}
  {{- end }}
  {{- include "common.storage.class" (dict "persistence" .Values.persistence "global" .Values.global) | nindent 2 }}
{{- end }}
```

#### ingress.yaml

```yaml
{{- /*
Copyright Broadcom, Inc. All Rights Reserved.
SPDX-License-Identifier: APACHE-2.0
*/}}

{{- if .Values.ingress.enabled }}
apiVersion: {{ include "common.capabilities.ingress.apiVersion" . }}
kind: Ingress
metadata:
  name: {{ template "common.names.fullname" . }}
  namespace: {{ include "common.names.namespace" . | quote }}
  labels: {{- include "common.labels.standard" ( dict "customLabels" .Values.commonLabels "context" $ ) | nindent 4 }}
  {{- if or .Values.ingress.annotations .Values.commonAnnotations }}
  {{- $annotations := include "common.tplvalues.merge" ( dict "values" ( list .Values.ingress.annotations .Values.commonAnnotations ) "context" . ) }}
  annotations: {{- include "common.tplvalues.render" ( dict "value" $annotations "context" $) | nindent 4 }}
  {{- end }}
spec:
  {{- if and .Values.ingress.ingressClassName (eq "true" (include "common.ingress.supportsIngressClassname" .)) }}
  ingressClassName: {{ .Values.ingress.ingressClassName | quote }}
  {{- end }}
  rules:
    {{- if .Values.ingress.hostname }}
    - host: {{ .Values.ingress.hostname }}
      http:
        paths:
          {{- if .Values.ingress.extraPaths }}
          {{- toYaml .Values.ingress.extraPaths | nindent 10 }}
          {{- end }}
          - path: {{ .Values.ingress.path }}
            {{- if eq "true" (include "common.ingress.supportsPathType" .) }}
            pathType: {{ .Values.ingress.pathType }}
            {{- end }}
            backend: {{- include "common.ingress.backend" (dict "serviceName" (include "common.names.fullname" .) "servicePort" "http" "context" $)  | nindent 14 }}
    {{- end }}
    {{- range .Values.ingress.extraHosts }}
    - host: {{ .name | quote }}
      http:
        paths:
          - path: {{ default "/" .path }}
            {{- if eq "true" (include "common.ingress.supportsPathType" $) }}
            pathType: {{ default "ImplementationSpecific" .pathType }}
            {{- end }}
            backend: {{- include "common.ingress.backend" (dict "serviceName" (include "common.names.fullname" $) "servicePort" "http" "context" $) | nindent 14 }}
    {{- end }}
    {{- if .Values.ingress.extraRules }}
    {{- include "common.tplvalues.render" (dict "value" .Values.ingress.extraRules "context" $) | nindent 4 }}
    {{- end }}
  {{- if or .Values.ingress.tls .Values.ingress.extraTls }}
  tls:
    {{- if .Values.ingress.tls }}
    - hosts:
        - {{ .Values.ingress.hostname | quote }}
      secretName: {{ printf "%s-tls" .Values.ingress.hostname }}
    {{- end }}
    {{- if .Values.ingress.extraTls }}
    {{- include "common.tplvalues.render" (dict "value" .Values.ingress.extraTls "context" $) | nindent 4 }}
    {{- end }}
  {{- end }}
{{- end }}
```

#### serviceaccount.yaml

```yaml
{{- /*
Copyright Broadcom, Inc. All Rights Reserved.
SPDX-License-Identifier: APACHE-2.0
*/}}

{{- if .Values.serviceAccount.create }}
apiVersion: v1
kind: ServiceAccount
metadata:
  {{- if .Values.serviceAccount.create }}
  name: {{ default (include "common.names.fullname" .) .Values.serviceAccount.name }}
  {{- else }}
  name: {{ default "default" .Values.serviceAccount.name }}
  {{- end }}
  namespace: {{ include "common.names.namespace" . | quote }}
  labels: {{- include "common.labels.standard" ( dict "customLabels" .Values.commonLabels "context" $ ) | nindent 4 }}
  {{- if or .Values.serviceAccount.annotations .Values.commonAnnotations }}
  {{- $annotations := include "common.tplvalues.merge" ( dict "values" ( list .Values.serviceAccount.annotations .Values.commonAnnotations ) "context" . ) }}
  annotations: {{- include "common.tplvalues.render" ( dict "value" $annotations "context" $) | nindent 4 }}
  {{- end }}
automountServiceAccountToken: {{ .Values.serviceAccount.automountServiceAccountToken }}
{{- end }}
```

#### role.yaml

```yaml
{{- /*
Copyright Broadcom, Inc. All Rights Reserved.
SPDX-License-Identifier: APACHE-2.0
*/}}

{{- if and .Values.rbac.create }}
apiVersion: {{ include "common.capabilities.rbac.apiVersion" . }}
kind: Role
metadata:
  name: {{ include "common.names.fullname" . }}
  namespace: {{ include "common.names.namespace" . | quote }}
  labels: {{- include "common.labels.standard" ( dict "customLabels" .Values.commonLabels "context" $ ) | nindent 4 }}
  {{- if .Values.commonAnnotations }}
  annotations: {{- include "common.tplvalues.render" (dict "value" .Values.commonAnnotations "context" $) | nindent 4 }}
  {{- end }}
rules:
  {{- if .Values.rules }}
  {{- include "common.tplvalues.render" ( dict "value" .Values.rbac.rules "context" $ ) | nindent 2 }}
  {{- else }}
  - apiGroups:
      - "*"
    resources:
      - "*"
    verbs:
      - get
      - list
  {{- end }}
{{- end }}
```

#### rolebinding.yaml

```yaml
{{- /*
Copyright Broadcom, Inc. All Rights Reserved.
SPDX-License-Identifier: APACHE-2.0
*/}}

{{- if .Values.rbac.create }}
apiVersion: {{ include "common.capabilities.rbac.apiVersion" . }}
kind: RoleBinding
metadata:
  name: {{ include "common.names.fullname" . }}
  namespace: {{ include "common.names.namespace" . | quote }}
  labels: {{- include "common.labels.standard" ( dict "customLabels" .Values.commonLabels "context" $ ) | nindent 4 }}
  {{- if .Values.commonAnnotations }}
  annotations: {{- include "common.tplvalues.render" (dict "value" .Values.commonAnnotations "context" $) | nindent 4 }}
  {{- end }}
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: {{ include "common.names.fullname" . }}
subjects:
  - kind: ServiceAccount
    {{- if .Values.serviceAccount.create }}
    name: {{ default (include "common.names.fullname" .) .Values.serviceAccount.name }}
    {{- else }}
    name: {{ default "default" .Values.serviceAccount.name }}
    {{- end }}
    namespace: {{ include "common.names.namespace" . | quote }}
{{- end }}
```

#### hpa.yaml

```yaml
{{- /*
Copyright Broadcom, Inc. All Rights Reserved.
SPDX-License-Identifier: APACHE-2.0
*/}}

{{- if .Values.autoscaling.enabled }}
apiVersion: {{ include "common.capabilities.hpa.apiVersion" ( dict "context" $ ) }}
kind: HorizontalPodAutoscaler
metadata:
  name: {{ template "common.names.fullname" . }}
  namespace: {{ .Release.Namespace | quote }}
  labels: {{- include "common.labels.standard" ( dict "customLabels" .Values.commonLabels "context" $ ) | nindent 4 }}
  {{- if .Values.commonAnnotations }}
  annotations: {{- include "common.tplvalues.render" ( dict "value" .Values.commonAnnotations "context" $ ) | nindent 4 }}
  {{- end }}
spec:
  scaleTargetRef:
    apiVersion: {{ include "common.capabilities.deployment.apiVersion" . }}
    kind: Deployment
    name: {{ template "common.names.fullname" . }}
  minReplicas: {{ .Values.autoscaling.minReplicas }}
  maxReplicas: {{ .Values.autoscaling.maxReplicas }}
  metrics:
    {{- if .Values.autoscaling.targetMemory }}
    - type: Resource
      resource:
        name: memory
        {{- if semverCompare "<1.23-0" (include "common.capabilities.kubeVersion" .) }}
        targetAverageUtilization: {{ .Values.autoscaling.targetMemory }}
        {{- else }}
        target:
          type: Utilization
          averageUtilization: {{ .Values.autoscaling.targetMemory }}
        {{- end }}
    {{- end }}
    {{- if .Values.autoscaling.targetCPU }}
    - type: Resource
      resource:
        name: cpu
        {{- if semverCompare "<1.23-0" (include "common.capabilities.kubeVersion" .) }}
        targetAverageUtilization: {{ .Values.autoscaling.targetCPU }}
        {{- else }}
        target:
          type: Utilization
          averageUtilization: {{ .Values.autoscaling.targetCPU }}
        {{- end }}
    {{- end }}
{{- end }}
```

#### pdb.yaml

```yaml
{{- /*
Copyright Broadcom, Inc. All Rights Reserved.
SPDX-License-Identifier: APACHE-2.0
*/}}

{{- if .Values.pdb.create }}
apiVersion: {{ include "common.capabilities.policy.apiVersion" . }}
kind: PodDisruptionBudget
metadata:
  name: {{ include "common.names.fullname" . }}
  namespace: {{ include "common.names.namespace" . | quote }}
  labels: {{- include "common.labels.standard" ( dict "customLabels" .Values.commonLabels "context" $ ) | nindent 4 }}
  {{- if .Values.commonAnnotations }}
  annotations: {{- include "common.tplvalues.render" ( dict "value" .Values.commonAnnotations "context" $ ) | nindent 4 }}
  {{- end }}
spec:
  {{- if .Values.pdb.minAvailable }}
  minAvailable: {{ .Values.pdb.minAvailable }}
  {{- end  }}
  {{- if or .Values.pdb.maxUnavailable ( not .Values.pdb.minAvailable ) }}
  maxUnavailable: {{ .Values.pdb.maxUnavailable | default 1 }}
  {{- end  }}
  {{- $podLabels := include "common.tplvalues.merge" ( dict "values" ( list .Values.podLabels .Values.commonLabels ) "context" . ) }}
  selector:
    matchLabels: {{- include "common.labels.matchLabels" ( dict "customLabels" $podLabels "context" $ ) | nindent 6 }}
{{- end }}
```

#### networkpolicy.yaml

```yaml
{{- /*
Copyright Broadcom, Inc. All Rights Reserved.
SPDX-License-Identifier: APACHE-2.0
*/}}

{{- if .Values.networkPolicy.enabled }}
kind: NetworkPolicy
apiVersion: {{ include "common.capabilities.networkPolicy.apiVersion" . }}
metadata:
  name: {{ template "common.names.fullname" . }}
  namespace: {{ include "common.names.namespace" . | quote }}
  labels: {{- include "common.labels.standard" ( dict "customLabels" .Values.commonLabels "context" $ ) | nindent 4 }}
  {{- if .Values.commonAnnotations }}
  annotations: {{- include "common.tplvalues.render" ( dict "value" .Values.commonAnnotations "context" $ ) | nindent 4 }}
  {{- end }}
spec:
  {{- $podLabels := include "common.tplvalues.merge" ( dict "values" ( list .Values.podLabels .Values.commonLabels ) "context" . ) }}
  podSelector:
    matchLabels: {{- include "common.labels.matchLabels" ( dict "customLabels" $podLabels "context" $ ) | nindent 6 }}
  policyTypes:
    - Ingress
    - Egress
  {{- if .Values.networkPolicy.allowExternalEgress }}
  egress:
    - {}
  {{- else }}
  egress: 
    - ports:
        # Allow dns resolution
        - port: 53
          protocol: UDP
        - port: 53
          protocol: TCP
        # Allow http and https for plugin download
        - port: 80
        - port: 443
        {{- range $port := .Values.networkPolicy.kubeAPIServerPorts }}
        - port: {{ $port }}
        {{- end }}
    {{- if .Values.networkPolicy.extraEgress }}
    {{- include "common.tplvalues.render" ( dict "value" .Values.networkPolicy.extraEgress "context" $ ) | nindent 4 }}
    {{- end }}
  {{- end }}
  ingress:
    - ports:
        {{- range .Values.containerPorts }}
        - port: {{ .containerPort }}
          protocol: {{ .protocol | default "TCP" }}
        {{- end }}
      {{- if not .Values.networkPolicy.allowExternal }}
      from:
        - podSelector:
            matchLabels: {{- include "common.labels.matchLabels" ( dict "customLabels" .Values.commonLabels "context" $ ) | nindent 14 }}
        - podSelector:
            matchLabels:
              {{ template "common.names.fullname" . }}-client: "true"
        {{- if .Values.networkPolicy.ingressNSMatchLabels }}
        - namespaceSelector:
            matchLabels:
              {{- range $key, $value := .Values.networkPolicy.ingressNSMatchLabels }}
              {{ $key | quote }}: {{ $value | quote }}
              {{- end }}
          {{- if .Values.networkPolicy.ingressNSPodMatchLabels }}
          podSelector:
            matchLabels:
              {{- range $key, $value := .Values.networkPolicy.ingressNSPodMatchLabels }}
              {{ $key | quote }}: {{ $value | quote }}
              {{- end }}
          {{- end }}
        {{- end }}
      {{- end }}
    {{- if .Values.networkPolicy.extraIngress }}
    {{- include "common.tplvalues.render" ( dict "value" .Values.networkPolicy.extraIngress "context" $ ) | nindent 4 }}
    {{- end }}
{{- end }}
```

#### extra-list.yaml

```yaml
{{- /*
Copyright Broadcom, Inc. All Rights Reserved.
SPDX-License-Identifier: APACHE-2.0
*/}}

{{- range .Values.extraDeploy }}
---
{{ include "common.tplvalues.render" (dict "value" . "context" $) }}
{{- end }}
```

### 打包Chart

**更新**

```
helm dependency build springboot-app/
```

**打包**

```
helm package springboot-app/
```

### 使用Chart

#### 使用默认设置

**部署应用**

```
helm install springboot-app springboot-app/
```

**查看应用**

```
helm ls
kubectl get pod,svc
```

**删除应用**

```
helm uninstall springboot-app
```

#### 自定义设置

**编辑values文件**

编辑 `values-custom.yaml` 文件，写入以下内容

```yaml
global:
  defaultStorageClass: ""
fullnameOverride: "springboot-app"
replicaCount: 1
## 镜像设置
image:
  registry: swr.cn-north-1.myhuaweicloud.com
  repository: kongyu/java-app-integrated-cmd
  tag: debian12_temurin_openjdk-jdk-21-jre
  pullPolicy: IfNotPresent
command: []
args: []
extraEnvVars:
  - name: SPRING_PROFILES_ACTIVE
    value: "prod"
  - name: JAVA_OPTS
    value: "-Xms512m -Xmx1024m"
resources:
  requests:
    cpu: 2
    memory: 512Mi
  limits:
    cpu: 3
    memory: 1024Mi
containerPorts:
  - name: http
    containerPort: 8080
    protocol: TCP
customLivenessProbe:
  httpGet:
    path: /actuator/health
    port: http
  initialDelaySeconds: 10
  periodSeconds: 10
  timeoutSeconds: 2
  failureThreshold: 3
customReadinessProbe:
  httpGet:
    path: /actuator/health
    port: http
  initialDelaySeconds: 5
  periodSeconds: 5
  timeoutSeconds: 1
  failureThreshold: 3
service:
  type: NodePort
  ports:
    - name: http
      port: 80
      targetPort: 8080
      protocol: TCP
      nodePort: 38083
```

**试运行**

```
helm install -f values-custom.yaml -n kongyu springboot-app springboot-app/ --dry-run --debug
```

**部署应用**

```
helm install -f values-custom.yaml -n kongyu springboot-app springboot-app/
```

**查看应用**

```
helm ls -n kongyu
kubectl -n kongyu get pod,svc
```

**删除应用**

```
helm uninstall -n kongyu springboot-app
```

#### 自定义设置（完整）

**编辑values文件**

编辑 `values-custom-all.yaml` 文件，写入以下内容

```yaml
global:
  defaultStorageClass: ""
fullnameOverride: "springboot-app"
replicaCount: 1
commonLabels:
  team: devops
  environment: production
  owner: alice
commonAnnotations:
  prometheus.io/scrape: "true"
  prometheus.io/port: "8080"
  example.com/owner: "alice"
extraDeploy:
  - |
    apiVersion: v1
    kind: ConfigMap
    metadata:
      name: my-custom-config
    data:
      MY_ENV: "production"
  - |
    apiVersion: batch/v1
    kind: CronJob
    metadata:
      name: my-cron
    spec:
      schedule: "*/5 * * * *"
      jobTemplate:
        spec:
          template:
            spec:
              containers:
                - name: job
                  image: busybox
                  command: ["echo", "hello from cron"]
              restartPolicy: OnFailure
## 镜像设置
image:
  registry: swr.cn-north-1.myhuaweicloud.com
  repository: kongyu/java-app-integrated-cmd
  tag: debian12_temurin_openjdk-jdk-21-jre
  pullPolicy: IfNotPresent
command: []
args: []
extraEnvVars:
  - name: SPRING_PROFILES_ACTIVE
    value: "prod"
  - name: JAVA_OPTS
    value: "-Xms512m -Xmx1024m"
updateStrategy:
 type: RollingUpdate
 rollingUpdate:
   maxSurge: 25%
   maxUnavailable: 25%
hostAliases:
  - ip: "127.0.0.1"
    hostnames:
    - "foo.local"
    - "bar.local"
  - ip: "10.1.2.3"
    hostnames:
    - "foo.remote"
    - "bar.remote"
extraVolumes:
  - name: extra-volume
    emptyDir: {}
extraVolumeMounts:
  - name: extra-volume
    mountPath: /extra
    subPath: data-dir
pdb:
  create: true
  minAvailable: "1"
  maxUnavailable: ""
autoscaling:
  enabled: true
  minReplicas: 1
  maxReplicas: 11
  targetCPU: 50
  targetMemory: 50
lifecycleHooks:
  postStart:
    exec:
      command:
        - "/bin/sh"
        - "-c"
        - "echo Container started at $(date)"
  preStop:
    exec:
      command:
        - "/bin/sh"
        - "-c"
        - "echo Container stopping at $(date) && sleep 5"
podLabels:
  app.kubernetes.io/name: my-app
  app.kubernetes.io/instance: my-app
  app.kubernetes.io/component: backend
podAnnotations:
  prometheus.io/scrape: "true"
  prometheus.io/port: "8080"
  example.com/owner: "alice"
podAffinityPreset: "soft"  ## 调度到同一节点
podAntiAffinityPreset: "soft"  ## 调度到不同节点
nodeAffinityPreset:  ## 调度到包含指定标签的节点，例如创建节点标签：kubectl label node server02.lingo.local kubernetes.service/springboot-app="true"
  type: "soft"
  key: "kubernetes.service/springboot-app"
  values:
    - "true"
    - "yes"
tolerations:
  - key: "node.kubernetes.io/not-ready"
    operator: "Exists"
    effect: "NoExecute"
    tolerationSeconds: 300
  - key: "node-role.kubernetes.io/infra"
    operator: "Equal"
    value: "true"
    effect: "NoSchedule"
resources:
  requests:
    cpu: 2
    memory: 512Mi
  limits:
    cpu: 3
    memory: 1024Mi
containerPorts:
  - name: http
    containerPort: 8080
    protocol: TCP
podSecurityContext:
  enabled: true
  fsGroupChangePolicy: Always
  sysctls: []
  supplementalGroups: []
  fsGroup: 1001
containerSecurityContext:
  enabled: true
  seLinuxOptions: {}
  runAsUser: 1001
  runAsGroup: 1001
  runAsNonRoot: true
  privileged: false
  readOnlyRootFilesystem: true
  allowPrivilegeEscalation: false
  capabilities:
    drop: ["ALL"]
  seccompProfile:
    type: "RuntimeDefault"
customStartupProbe:
  httpGet:
    path: /actuator/health
    port: http
  initialDelaySeconds: 5
  periodSeconds: 10
  failureThreshold: 30
customLivenessProbe:
  httpGet:
    path: /actuator/health
    port: http
  initialDelaySeconds: 10
  periodSeconds: 10
  timeoutSeconds: 2
  failureThreshold: 3
customReadinessProbe:
  httpGet:
    path: /actuator/health
    port: http
  initialDelaySeconds: 5
  periodSeconds: 5
  timeoutSeconds: 1
  failureThreshold: 3
service:
  type: NodePort
  ports:
    - name: http
      port: 80
      targetPort: 8080
      protocol: TCP
      nodePort: 38083
networkPolicy:
  enabled: true
  allowExternal: true
  allowExternalEgress: true
  kubeAPIServerPorts: [443, 6443, 8443]
  extraIngress: []
  extraEgress: []
  ingressNSMatchLabels: {}
  ingressNSPodMatchLabels: {}
  
ingress:
  enabled: true
  pathType: ImplementationSpecific
  apiVersion: ""
  hostname: ateng.local
  path: /
  tls: false
  selfSigned: false
  extraHosts: []
  extraPaths: []
  extraTls: []
  secrets: []
  ingressClassName: ""
  extraRules: []
persistence:
  enabled: true
  path: /data
  subPath: ""
  subPathExpr: ""
  storageClass: ""
  accessModes:
    - ReadWriteOnce
  size: 8Gi
  annotations: {}
  labels: {}
  selector: {}
  existingClaim: ""
rbac:
  create: true
  rules:
    - apiGroups:
        - "*"
      resources:
        - "*"
      verbs:
        - "*"
serviceAccount:
  create: true
  name: ""
  annotations: {}
  automountServiceAccountToken: true
```

**试运行**

```
helm install -f values-custom-all.yaml -n kongyu springboot-app springboot-app/ --dry-run --debug
```

**部署应用**

```
helm install -f values-custom-all.yaml -n kongyu springboot-app springboot-app/
```

**查看应用**

```
helm ls -n kongyu
kubectl -n kongyu get pod,svc,pvc
```

**删除应用**

```
helm uninstall -n kongyu springboot-app
```

#### 