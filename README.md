# 运维技术栈 · 阿腾

## 🚀 初衷与愿景

历经打磨，运维知识库正式版温暖上线。这里记录的不只是技术，更是一次次深夜排障的背影、一条条命令背后的思考。
无论你是新手起步，还是资深老兵，我希望这个网站，能让你在翻阅中找到方向，在困境中看到答案。
时间在走，经验在累，知识也应被珍藏。愿你我携手，用知识点亮未来，用积淀成就自己。

------

## 🔥 精选专题 · 运维从这里起飞

实战驱动、经验沉淀，每一份文档都为高效运维而生，助你构建更稳定、更智能的系统基础设施。

------

### ☕ Java 开发网站

📚 系统级 Java 开发实践文档，涵盖微服务架构、大数据处理与异步任务调度等多个技术方向。

 🔗 [Java开发网站](https://kongyu666.github.io/dev/)

------

### 🐧 Linux 部署服务

⚙️ 从零搭建 Linux 服务环境，详细涵盖网络、安全、存储、用户管理等核心模块，适配多种系统发行版。

 📖 [部署文档](/work/service/README.md)

------

### 🐳 Docker 部署服务

🚀 基于容器的部署手册，支持主流服务一键构建和运行，加快开发交付与系统运维的效率。

 📖 [部署文档](/work/docker/service/catalog.md)

------

### ☸️ Kubernetes 部署服务

🌐 全栈 K8s 实战指南，提供微服务、数据库、中间件、CI/CD、监控等模块的自动化部署方案。

 📖 [部署文档](/work/kubernetes/service/catalog.md)

------

### 📊 大数据部署与使用

📈 集成 Zookeeper、Kafka、Spark、Flink 等组件，提供从部署到优化的全链路文档支持。

 📖 [使用文档](/work/bigdata/)

------

### ⚙️ CI/CD 自动化部署

🔄 Jenkins + ArgoCD 打造持续集成 / 持续交付流水线，实现容器镜像构建、回滚与环境隔离。

 📖 [Jenkins 文档](/work/service/jenkins/OPS.md)｜[ArgoCD 文档](/work/service/argo-cd/OPS.md)

------

### 🔍 可观测体系建设

📡 OpenTelemetry 构建统一的监控、日志与追踪体系，实现系统运行状态的全面可视化。

 📖 [使用文档](/work/service/opentelemetry/)

------

### 🚀 Snail Job 分布式调度平台

🧠 支持任务重试、分布式运行与自定义执行策略，适用于复杂业务流程的自动化调度。

 📖 [Kubernetes部署](/work/kubernetes/service/snail-job/v1.3.0/)｜[Java开发文档](https://kongyu666.github.io/dev/#/work/Ateng-Java/task/snail-job/)

---

## 📚 全站索引

- Linux Service
    - 服务器管理
        - [基础配置](/work/service/00-basic/)
        - [网络配置](/work/service/network/)
        - [系统性能监控](/work/linux/metrics/)
        - [时间同步服务](/work/service/chrony/)
    - 安全管理
        - 用户管理
            - [用户管理](/work/service/security/user/)
        - OpenSSH
            - [使用文档](/work/service/openssh/OPS.md)
            - [升级服务](/work/service/openssh/v10.0/)
        - TLS证书
            - [cfssl创建证书](/work/service/security/tls/tls-cfssl/v1.6.5/)
            - [openssl创建证书](/work/service/security/tls/tls-openssl/)
    - 存储服务
        - 网络文件共享 NFS
            - [安装使用文档](/work/service/nfs/)
        - 网络文件共享 Samba
            - [安装使用文档](/work/service/samba/)
        - 网络文件共享 VSFTP
            - [安装使用文档](/work/service/ftp/)
        - 对象存储服务 MinIO
            - [安装文档](/work/service/minio/v20241107/)
            - [使用文档](/work/service/minio/OPS.md)
        - 分布式存储 JuiceFS
            - [安装文档](/work/service/juicefs/v1.2.1/)
            - [使用文档](/work/service/juicefs/OPS.md)
        - 备份工具 Restic
            - [安装使用文档](/work/service/restic/)
    - 数据存储
        - MySQL
            - [安装文档](/work/service/mysql/v8.4.3/)
            - [编译安装文档](/work/service/mysql/v8.4.3/make/)
            - [使用文档](/work/service/mysql/OPS.md)
        - MariaDB Galera
            - [安装文档](/work/service/mariadb/v11.4.4/)
        - Redis
            - [安装文档](/work/service/redis/v7.4.1/)
            - [使用文档](/work/service/redis/OPS.md)
        - PostgreSQL
            - [编译安装文档](/work/service/postgresql/v17.2.0/)
            - [编译PostGIS](/work/service/postgresql/v17.2.0/postgis/)
            - [使用文档](/work/service/postgresql/OPS.md)
        - ETCD
            - [安装文档](/work/service/etcd/v3.5.17/)
            - [使用文档](/work/service/etcd/OPS.md)
        - FoundationDB
            - [安装文档](/work/service/foundationdb/v7.1.38/)
            - [使用文档](/work/service/foundationdb/OPS.md)
        - ElasticSearch
            - [安装单机模式](/work/service/elastic/elasticsearch/standalone/)
            - [安装集群模式](/work/service/elastic/elasticsearch/cluster/)
        - OpenSearch
            - [1.x安装文档](/work/service/opensearch/v1.3.19/)
            - [2.x安装文档](/work/service/opensearch/v2.18.0/)
            - [使用文档](/work/service/opensearch/OPS.md)
    - Web服务
        - Nginx
            - [安装文档](/work/service/nginx/v1.27.3/)
            - [使用文档](/work/service/nginx/OPS.md)
        - Haproxy
            - [安装文档](/work/service/haproxy/)
            - [使用文档](/work/service/haproxy/OPS.md)
    - CI/CD
        - DevOps - Jenkins
            - [安装文档](/work/service/jenkins/)
            - [使用文档](/work/service/jenkins/OPS.md)
            - [Agent镜像构建](/work/service/jenkins/images/)
        - GitOps - Argo CD
            - [安装文档](/work/service/argo-cd/)
            - [使用文档](/work/service/argo-cd/OPS.md)
    - 可观测
        - OTLP
            - [OpenTelemetry](/work/service/opentelemetry/)
            - [Jaeger](/work/service/jaeger/)
        - 监控
            - [Beszel](/work/service/beszel/)
            - [Prometheus](/work/service/prometheus/v3.2.1/)
            - [Grafana](/work/service/grafana/v11.5.3/)
            - [Alertmanager](/work/service/alertmanager/v0.28.1/)
    - 开发工具
        - OpenJDK
            - [OpenJDK8](/work/service/openjdk/openjdk8/)
            - [OpenJDK11](/work/service/openjdk/openjdk11/)
            - [OpenJDK17](/work/service/openjdk/openjdk17/)
            - [OpenJDK21](/work/service/openjdk/openjdk21/)
            - [使用文档](/work/service/openjdk/OPS.md)
        - Apache Maven
            - [安装文档](/work/service/maven/v3.9.9/)
            - [使用文档](/work/service/maven/OPS.md)
        - Git
            - [安装文档](/work/service/git/v2.49.0/)
            - [使用文档](/work/service/git/OPS.md)
        - Node.js
            - [安装文档](/work/service/nodejs/v22.14.0/)
            - [使用文档](/work/service/nodejs/OPS.md)
        - Node.js 和 NVM
            - [安装文档](/work/service/nvm/v0.40.2/)
            - [使用文档](/work/service/nvm/OPS.md)
        - Python
            - [安装文档](/work/service/python/v3.13.3/)
            - [使用文档](/work/service/python/OPS.md)
        - SpringCloud Alibaba
            - [Nacos](/work/service/springcloudalibaba/nacos)
            - [Sentinel](/work/service/springcloudalibaba/sentinel/)
            - [Seata](/work/service/springcloudalibaba/seata/)
            - [RocketMQ](/work/service/springcloudalibaba/rocketmq/standalone/)
    - 流媒体服务
        - [FFmpeg](/work/service/ffmpeg/)
        - ZLMediaKit
            - [安装文档](/work/service/zlmediakit/)
            - [使用文档](/work/service/zlmediakit/OPS.md)
        - SRS
            - [安装文档](/work/service/srs/)
            - [使用文档](/work/service/srs/OPS.md)
    - 其他服务
        - [内网穿透FRP](/work/service/frp/)
        - [CoreDNS](/work/service/coredns/)
- Shell
    - Spring
        - [应用管理](work/shell/java/)
    - 服务备份脚本
        - [mysql](work/shell/backups/mysql/)
        - [postgresql](work/shell/backups/postgresql/)
        - [etcd](work/shell/backups/etcd/)
        - [minio](work/shell/backups/minio/)
        - [mongodb](work/shell/backups/mongodb/)
- Docker
    - 使用文档
        - [安装文档](/work/docker/deploy/v27.3.1/)
        - [使用文档](/work/docker/OPS.md)
    - Dockerfile
        - [JDK和应用](/work/docker/dockerfile/java/)
        - [kkFileView](/work/docker/dockerfile/kkfileview/v4.4.0/)
    - 服务安装文档
        - [mysql](/work/docker/service/mysql/)
        - [postgresql](/work/docker/service/postgresql/)
        - [doris](/work/docker/service/doris/)
        - [redis](/work/docker/service/redis/)
        - [kafka](/work/docker/service/kafka/)
        - [kafka-ui](/work/docker/service/kafka-ui/)
        - [minio](/work/docker/service/minio/)
        - [mongodb](/work/docker/service/mongodb/)
        - [rabbitmq](/work/docker/service/rabbitmq/)
        - [gitea](/work/docker/service/gitea/)
        - [gitlab](/work/docker/service/gitlab/)
        - [zookeeper](/work/docker/service/zookeeper/)
        - [windows](/work/docker/service/windows/)
        - [elasticsearch](/work/docker/service/elasticsearch/)
        - [opensearch](/work/docker/service/opensearch/)
        - [elastic-view](/work/docker/service/elastic-view/)
        - [jenkins](/work/docker/service/jenkins/)
        - [jumpserver](/work/docker/service/jumpserver/)
        - [达梦数据库](/work/docker/service/dm8/v20241230/)
        - [Java应用](/work/docker/service/java/)
        - [nacos](/work/docker/service/nacos/)
        - [rocketmq](/work/docker/service/rocketmq/)
        - [kkfileview](/work/docker/service/kkfileview/v4.4.0/)
        - [禅道](/work/docker/service/zentao/)
        - [Snail-Job](/work/docker/service/snail-job/)
- Kubernetes
    - 使用文档
        - [K8S使用文档](/work/kubernetes/OPS.md)
        - [Helm使用文档](/work/kubernetes/deploy/helm/OPS.md)
    - 安装文档
        - [kubekey](/work/kubernetes/deploy/kubekey/v3.1.7/)
        - [kubesphere3](/work/kubernetes/deploy/kubesphere/v3.4.1/)
        - [kubesphere4](/work/kubernetes/deploy/kubesphere/v4.1.2/)
        - [kubeadm](/work/kubernetes/deploy/kubeadm/v1.23.12/)
        - [kubevirt](/work/kubernetes/deploy/kubevirt/deploy/v1.3.0/)
        - [helm](/work/kubernetes/deploy/helm/)
    - 镜像仓库
        - [Harbor](/work/kubernetes/deploy/harbor/v2.12.0/)
        - [Registry](/work/kubernetes/deploy/harbor/registry/)
    - 网络服务
        - [Calico](/work/kubernetes/deploy/network/calico/)
        - [Flannel](/work/kubernetes/deploy/network/flannel/)
        - [Cilium](/work/kubernetes/deploy/network/cilium/)
        - [插件](/work/kubernetes/deploy/network/plugins/)
        - [卸载网络](/work/kubernetes/deploy/network/uninstall.md)
    - 存储服务
        - openebs
            - [localpv](/work/kubernetes/deploy/storage/openebs/localpv-provisioner/v4.1.0/)
            - [nfs](/work/kubernetes/deploy/storage/openebs/nfs-provisioner/v0.11.0/)
        - nfs
            - [nfs-client](/work/kubernetes/deploy/storage/nfs/nfs-client/)
            - [nfs-server](/work/kubernetes/deploy/storage/nfs/nfs-server/)
        - juicefs-csi
            - [juicefs-csi](/work/kubernetes/deploy/storage/juicefs-csi/v0.24.4/)
        - rook
            - [ceph](/work/kubernetes/deploy/storage/rook/ceph/)
            - [nfs](/work/kubernetes/deploy/storage/rook/nfs/)
        - longhorn
            - [longhorn](/work/kubernetes/deploy/storage/longhorn/v1.4.0/)
        - kadalu
            - [kadalu](/work/kubernetes/deploy/storage/kadalu/v1.0.0/)
    - 中间件服务
        - 数据存储
            - Redis
                - [单机模式](/work/kubernetes/service/redis/v7.4.1/standalone/)
                - [主从模式](/work/kubernetes/service/redis/v7.4.1/replication/)
                - [哨兵模式](/work/kubernetes/service/redis/v7.4.1/sentinel/)
                - [集群模式](/work/kubernetes/service/redis/v7.4.1/cluster/)
            - Valkey
                - [单机模式](/work/kubernetes/service/redis/valkey/v8.0.2/)
            - Mariadb Galera
                - [Galera集群](/work/kubernetes/service/mariadb/v11.4.4/)
            - PostgreSQL
                - [单机模式](/work/kubernetes/service/postgresql/v17.2.0/standalone/)
                - [主从模式](/work/kubernetes/service/postgresql/v17.2.0/replication/)
                - [集群模式](/work/kubernetes/service/postgresql/v17.2.0/ha/)
            - MongoDB
                - [单机模式](/work/kubernetes/service/mongodb/v8.0.3/standalone/)
                - [副本集群模式](/work/kubernetes/service/mongodb/v8.0.3/replicaset/)
                - [分配集群模式](/work/kubernetes/service/mongodb/v8.0.3/sharded/)
            - MySQL
                - [单机模式](/work/kubernetes/service/mysql/v8.4.3/standalone/)
                - [主从模式](/work/kubernetes/service/mysql/v8.4.3/replication/)
                - [配置metrics](/work/kubernetes/service/mysql/v8.4.3/metrics/)
            - Doris
                - [集群模式2](/work/kubernetes/service/doris/v2.1.7/)
                - [集群模式3](/work/kubernetes/service/doris/v3.0.3/)
            - Clickhouse
                - [集群模式](/work/kubernetes/service/clickhouse/v25.1.3/)
            - ElasticSearch7
                - [单机模式](/work/kubernetes/service/elasticsearch/v7.17.26/all-in-one/)
                - [认证模式](/work/kubernetes/service/elasticsearch/v7.17.26/auth/)
                - [HTTPS模式](/work/kubernetes/service/elasticsearch/v7.17.26/https/)
                - [HTTPS模式(自定义证书)](/work/kubernetes/service/elasticsearch/v7.17.26/https-custom/)
                - [Kibana](/work/kubernetes/service/kibana/v7.17.26/)
                - [Elastic View可视化](/work/kubernetes/service/elasticsearch/elastic-view/)
            - ElasticSearch8
                - [单机模式](/work/kubernetes/service/elasticsearch/v8.16.1/all-in-one/)
                - [认证模式](/work/kubernetes/service/elasticsearch/v8.16.1/auth/)
                - [HTTPS模式](/work/kubernetes/service/elasticsearch/v8.16.1/https/)
                - [HTTPS模式(自定义证书)](/work/kubernetes/service/elasticsearch/v8.16.1/https-custom/)
                - [Kibana](/work/kubernetes/service/kibana/v7.17.26/)
                - [Elastic View可视化](/work/kubernetes/service/elasticsearch/elastic-view/)
            - OpenSearch1
                - [单机模式](/work/kubernetes/service/opensearch/v1.3.19/all-in-one/)
                - [HTTPS模式(自定义证书)](/work/kubernetes/service/opensearch/v1.3.19/https-custom/)
                - [Elastic View可视化](/work/kubernetes/service/opensearch/elastic-view/)
            - OpenSearch2
                - [单机模式](/work/kubernetes/service/opensearch/v2.18.0/all-in-one/)
                - [HTTPS模式](/work/kubernetes/service/opensearch/v2.18.0/https/)
                - [HTTPS模式(自定义证书)](/work/kubernetes/service/opensearch/v2.18.0/https-custom/)
                - [Elastic View可视化](/work/kubernetes/service/opensearch/elastic-view/)
            - ETCD
                - [集群模式](/work/kubernetes/service/etcd/v3.5.17/basic/)
                - [认证模式](/work/kubernetes/service/etcd/v3.5.17/http-auth/)
                - [HTTPS模式](/work/kubernetes/service/etcd/v3.5.17/https/)
            - FoundationDB
                - [安装文档](/work/kubernetes/service/foundationdb/v7.1.38/)
            - Cassandra
                - [安装文档](/work/kubernetes/service/cassandra/v5.0.3/)
            - 达梦数据库
                - [安装文档](/work/kubernetes/service/dm8/v20241230/)
            - Memcached
                - [单机模式](/work/kubernetes/service/memcached/v1.6.38/standalone/)
                - [集群模式](/work/kubernetes/service/memcached/v1.6.38/high-availability/)
        - 消息队列
            - RabbitMQ
                - [集群模式](/work/kubernetes/service/rabbitmq/v4.0.2/)
            - Kafka
                - [单机模式](/work/kubernetes/service/kafka/v3.8.1/standalone/)
                - [集群模式](/work/kubernetes/service/kafka/v3.8.1/cluster/)
                - [高可用集群模式](/work/kubernetes/service/kafka/v3.8.1/cluster-ha/)
                - [认证模式](/work/kubernetes/service/kafka/v3.8.1/auth/)
            - Kafka UI
                - [Kafka可视化](/work/kubernetes/service/kafka-ui/v0.7.2/)
        - 存储服务
            - MinIO
                - [单机模式](/work/kubernetes/service/minio/v2024.11.7/standalone/)
                - [集群模式](/work/kubernetes/service/minio/v2024.11.7/distributed/)
            - Harbor
                - [http模式](/work/kubernetes/service/harbor/v2.12.0/http/)
                - [ingress模式](/work/kubernetes/service/harbor/v2.12.0/ingress-http/)
                - [https模式](/work/kubernetes/service/harbor/v2.12.0/https/)
                - [https模式(自定义证书)](/work/kubernetes/service/harbor/v2.12.0/https-custom/)
        - CI/CD
            - [Gitlab](/work/kubernetes/service/gitlab/v17.6.1/)
            - [Gitea](/work/kubernetes/service/gitea/v1.23.7/)
            - [Jenkins](/work/kubernetes/service/jenkins/v2.492.3/)
            - [Argo CD](/work/kubernetes/service/argo-cd/v2.14.8/)
            - [Sonarqube](/work/kubernetes/service/sonarqube/v10.7.0/)
        - 可观测
            - [Prometheus](/work/kubernetes/service/prometheus/v2.55.1/)
            - [Grafana](/work/kubernetes/service/grafana/v11.5.3/)
            - [Grafana Loki](/work/kubernetes/service/grafana-loki/v3.4.2/)
            - [Grafana Mimir](/work/kubernetes/service/grafana-mimir/v2.15.1/)
            - [Grafana Tempo](/work/kubernetes/service/grafana-tempo/v2.7.2/)
            - [Fluentd](/work/kubernetes/service/fluentd/v.18.0/)
            - [Fluent Bit](/work/kubernetes/service/fluent-bit/v3.2.10/)
            - [Logstash](/work/kubernetes/service/logstash/v8.16.1/)
            - [SkyWalking](/work/kubernetes/service/skywalking/v10.1.0/)
            - [Zipkin](/work/kubernetes/service/zipkin/v3.5.0/)
            - [Jaeger](/work/kubernetes/service/jaeger/v2.4.0/)
        - 开发服务
            - [Java应用](/work/kubernetes/service/java-app/v1.1/)
            - [Snail-Job](/work/kubernetes/service/snail-job/v1.4.0/)
            - [PowerJob](/work/kubernetes/service/powerjob/v5.1.1/)
            - [Spring Boot Admin](/work/kubernetes/service/springboot-admin/v3.3.0/)
            - [Nacos](/work/kubernetes/service/nacos/v2.4.3/)
            - [Seata](/work/kubernetes/service/seata/)
            - [Sentinel](/work/kubernetes/service/sentinel/)
            - [禅道](/work/kubernetes/service/zentao/v21.6/)
            - [chat2db数据库管理工具](/work/kubernetes/service/chat2db/v0.3.7/)
            - [drawDB数据库编辑器](/work/kubernetes/service/drawdb/)
            - [kkFileView](/work/kubernetes/service/kkfileview/v4.4.0/)
        - 大数据
            - [Zookeeper](/work/kubernetes/service/zookeeper/v3.9.3/)
            - [Flink](/work/kubernetes/service/flink/v1.19.1/)
            - [Spark](/work/kubernetes/service/spark/v3.5.4/)
            - [DolphinScheduler](/work/kubernetes/service/dolphinscheduler/v3.2.2/)
            - [Doris2集群模式](/work/kubernetes/service/doris/v2.1.7/)
            - [Doris3集群模式](/work/kubernetes/service/doris/v3.0.3/)
        - 负载均衡和网络
            - [MetalLB](/work/kubernetes/service/metallb/v0.14.8/)
            - [External-DNS](/work/kubernetes/service/external-dns/v0.15.0/)
            - [HAProxy](/work/kubernetes/service/haproxy/v3.0.2/)
            - [Nginx](/work/kubernetes/service/nginx/v1.27.0/)
            - [Multus-CNI](/work/kubernetes/service/multus-cni/)
        - 其他
            - [Cert-Manager](/work/kubernetes/service/cert-manager/v1.16.2/)
            - [安装Windows系统](/work/kubernetes/service/windows/)
            - [Stirling-PDF](/work/kubernetes/service/Stirling-PDF/)
        - KubeBlocks
            - [安装](/work/kubernetes/service/kubeblocks/deploy/)
            - [mysql](/work/kubernetes/service/kubeblocks/service/mysql/)
            - [postgresql](/work/kubernetes/service/kubeblocks/service/postgresql/)
            - [redis](/work/kubernetes/service/kubeblocks/service/redis/)
            - [kafka](/work/kubernetes/service/kubeblocks/service/kafka/)
            - [备份](/work/kubernetes/service/kubeblocks/backup/)
        - 堡垒机
            - [JumpServer](/work/kubernetes/service/jumpserver/v4.3.1/)
            - [Nexterm](/work/kubernetes/service/nexterm/v1.0.2/)
        - 共享文件
            - [kodbox](/work/kubernetes/service/kodbox/v1.52/)
    - 备份服务
        - velero
            - [安装备份和恢复Velero](/work/kubernetes/deploy/backups/velero/v1.11.0/)
        - etcd
            - [备份到本地](/work/kubernetes/deploy/backups/etcd/local/)
            - [备份到MinIO](/work/kubernetes/deploy/backups/etcd/minio/)
        - mysql
            - [备份到本地](/work/kubernetes/deploy/backups/mysql/local/)
            - [备份到MinIO](/work/kubernetes/deploy/backups/mysql/minio/)
        - postgresql
            - [备份到本地](/work/kubernetes/deploy/backups/postgresql/local/)
            - [备份到MinIO](/work/kubernetes/deploy/backups/postgresql/minio/)
    - 服务测试
        - [存储测试](/work/kubernetes/deploy/test/storage/)
        - [网络测试](/work/kubernetes/deploy/test/network/)
- KVM
    - [使用文档](work/kvm/)
- 大数据
    - 基础服务
        - 基础配置
            - [基础配置](work/bigdata/00-basic/)
        - JDK
            - [安装OpenJDK8](/work/bigdata/01-jdk/)
        - Zookeeper
            - [单机](work/bigdata/02-zookeeper/standalone/)
            - [集群](work/bigdata/02-zookeeper/cluster/)
            - [使用文档](work/bigdata/02-zookeeper/OPS.md)
        - Hadoop
            - [单机](work/bigdata/03-hadoop/standalone/)
            - [集群](work/bigdata/03-hadoop/cluster/)
            - [高可用集群](work/bigdata/03-hadoop/cluster-ha/)
            - [使用文档](work/bigdata/03-hadoop/OPS.md)
        - Kafka
            - [单机](work/bigdata/03-kafka/standalone/)
            - [集群](work/bigdata/03-kafka/cluster/)
            - [高可用集群](work/bigdata/03-kafka/cluster-ha/)
            - [使用文档](work/bigdata/03-kafka/OPS.md)
    - 数据存储
        - HBase
            - [单机](work/bigdata/04-hbase/standalone/)
            - [集群](work/bigdata/04-hbase/cluster/)
            - [高可用集群](work/bigdata/04-hbase/cluster-ha/)
            - [使用文档](work/bigdata/04-hbase/OPS.md)
        - Hive
            - [单机](work/bigdata/04-hive/standalone/)
            - [集群](work/bigdata/04-hive/cluster/)
            - [高可用集群](work/bigdata/04-hive/cluster-ha/)
            - [集成TEZ](work/bigdata/04-hive/tez/)
            - [使用文档](work/bigdata/04-hive/OPS.md)
        - Doris
            - Doris v2.1.7
                - [单机](work/bigdata/05-doris/v2.1.7/standalone/)
                - [集群](work/bigdata/05-doris/v2.1.7/cluster/)
                - [高可用集群](work/bigdata/05-doris/v2.1.7/cluster-ha/)
            - Doris v3.0.3
                - [单机](work/bigdata/05-doris/v3.0.3/standalone/)
                - [集群](work/bigdata/05-doris/v3.0.3/cluster/)
                - [高可用集群](work/bigdata/05-doris/v3.0.3/cluster-ha/)
            - [使用文档](work/bigdata/05-doris/OPS.md)
        - Iceberg
            - [使用文档](work/bigdata/06-iceberg/)
    - 数据计算
        - Spark
            - [单机](work/bigdata/05-spark/standalone/)
            - [集群](work/bigdata/05-spark/cluster/)
            - [高可用集群](work/bigdata/05-spark/cluster-ha/)
            - [YARN](work/bigdata/05-spark/yarn/)
            - [Kubernetes Operator](work/bigdata/05-spark/kubernetes-operator/)
            - [Operator使用文档](work/bigdata/05-spark/kubernetes-operator/examples/)
            - [集成Hive](work/bigdata/05-spark/hive/)
            - [使用文档](work/bigdata/05-spark/OPS.md)
        - Flink
            - [单机](work/bigdata/05-flink/standalone/)
            - [集群](work/bigdata/05-flink/cluster/)
            - [高可用集群](work/bigdata/05-flink/cluster-ha/)
            - [YARN](work/bigdata/05-flink/yarn/)
            - [Kubernetes Operator](work/bigdata/05-flink/kubernetes-operator/)
            - [Operator使用文档](work/bigdata/05-flink/kubernetes-operator/examples/)
            - [Flink CDC](work/bigdata/05-flink/cdc/)
            - [使用文档](work/bigdata/05-flink/OPS.md)
    - 调度平台
        - Dolphinscheduler
            - [单机](work/bigdata/06-dolphinscheduler/standalone/)
            - [集群](work/bigdata/06-dolphinscheduler/cluster/)
- 系统和软件
    - 操作系统
        - [Windows](/work/syssoft/os/windows/)
        - [OpenEuler](/work/syssoft/os/openeuler/)
        - [CentOS](/work/syssoft/os/centos/)
    - 开发软件
        - [JDK](/work/syssoft/dev/jdk/)
        - [Maven](/work/syssoft/dev/maven/)
        - [Git](/work/syssoft/dev/git/)
        - [IntelliJ IDEA ](/work/syssoft/dev/idea/)
        - [DataGrip](/work/syssoft/dev/datagrip/)
    - 系统软件
        - [常用软件](/work/syssoft/software/primary/)
        - [其他软件](/work/syssoft/software/others/)
    - 相关文档
        - [技术文档](/work/syssoft/doc/nb/)
        - [其他文档](/work/syssoft/doc/others/)
