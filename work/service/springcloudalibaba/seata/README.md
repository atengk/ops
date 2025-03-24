# Seata

Seata（Simple Extensible Autonomous Transaction Architecture）是一款开源的分布式事务解决方案，旨在解决微服务架构下的数据一致性问题。它提供了AT、TCC、SAGA和XA等多种事务模式，支持自动回滚和补偿机制。Seata通过事务协调器（TC）管理全局事务，确保各服务间的事务一致性。它易于集成，广泛兼容Spring Cloud、Dubbo等框架，是微服务环境中可靠的分布式事务解决方案。

- [官方文档](https://seata.apache.org/zh-cn/docs/overview/what-is-seata)



文档使用以下1台服务器，具体服务分配见描述的进程

| IP地址       | 主机名   | 描述  |
| ------------ | -------- | ----- |
| 192.168.1.13 | server03 | Seata |



## 基础配置

**下载软件包**

```
wget https://dist.apache.org/repos/dist/release/incubator/seata/2.3.0/apache-seata-2.3.0-incubating-bin.tar.gz
```

**解压软件包**

```
tar -zxvf apache-seata-2.3.0-incubating-bin.tar.gz -C /usr/local/software/
ln -s /usr/local/software/apache-seata-2.3.0-incubating-bin /usr/local/software/apache-seata
```

**下载SQL**

将下载的SQL导入对应的数据库

- MySQL

URL: jdbc:mysql://192.168.1.10:35725/kongyu

```
curl -O https://raw.githubusercontent.com/apache/incubator-seata/refs/tags/v2.3.0/script/server/db/mysql.sql
```

- PostgreSQL

URL: jdbc:postgresql://192.168.1.10:32297/kongyu?currentSchema=public&stringtype=unspecified

```
curl -O https://raw.githubusercontent.com/apache/incubator-seata/refs/tags/v2.3.0/script/server/db/postgresql.sql
```

**下载数据库驱动**

- MySQL

```
wget https://repo1.maven.org/maven2/com/mysql/mysql-connector-j/8.0.33/mysql-connector-j-8.0.33.jar
cp mysql-connector-j-8.0.33.jar /usr/local/software/apache-seata/seata-server/lib/jdbc/
```

- PostgreSQL

```
wget https://repo1.maven.org/maven2/org/postgresql/postgresql/42.7.1/postgresql-42.7.1.jar
cp postgresql-42.7.1.jar /usr/local/software/apache-seata/seata-server/lib/jdbc/
```



## 配置文件

```yaml
cat > /usr/local/software/apache-seata/seata-server/conf/application.yml <<"EOF"
server:
  port: 7091
spring:
  application:
    name: seata-server
logging:
  config: classpath:logback-spring.xml
  file:
    path: ${log.home:${user.home}/logs/seata}
console:
  user:
    username: admin
    password: Admin@123
seata:
  config:
    type: nacos
    nacos:
      server-addr: 192.168.1.10:30648
      namespace: 3ac1b8fa-0fb1-4aa2-9858-374af73825f3
      group: SEATA_GROUP
      username: nacos
      password: Admin@123
      data-id: seataServer.properties
  registry:
    type: nacos
    nacos:
      cluster: atengSeata
      server-addr: ${seata.config.nacos.server-addr}
      namespace: ${seata.config.nacos.namespace}
      group: ${seata.config.nacos.group}
      username: ${seata.config.nacos.username}
      password: ${seata.config.nacos.password}
  server:
    service-port: 8091 #If not configured, the default is '${server.port} + 1000'
    max-commit-retry-timeout: -1
    max-rollback-retry-timeout: -1
    rollback-retry-timeout-unlock-enable: false
    enable-check-auth: true
    enable-parallel-request-handle: true
    enable-parallel-handle-branch: false
    retry-dead-threshold: 130000
    xaer-nota-retry-timeout: 60000
    enableParallelRequestHandle: true
    applicationDataLimitCheck: true
    applicationDataLimit: 64000
    recovery:
      committing-retry-period: 1000
      async-committing-retry-period: 1000
      rollbacking-retry-period: 1000
      timeout-retry-period: 1000
    undo:
      log-save-days: 7
      log-delete-period: 86400000
    session:
      branch-async-queue-size: 5000 #branch async remove queue size
      enable-branch-async-remove: false #enable to asynchronous remove branchSession
  store:
    mode: db
    session:
      mode: db
    lock:
      mode: db
    db:
      datasource: druid
      db-type: mysql
      driver-class-name: com.mysql.cj.jdbc.Driver
      url: jdbc:mysql://192.168.1.10:21489/ateng_seata?rewriteBatchedStatements=true
      user: root
      password: Admin@123
      min-conn: 10
      max-conn: 100
      global-table: global_table
      branch-table: branch_table
      lock-table: lock_table
      distributed-lock-table: distributed_lock
      vgroup-table: vgroup_table
      query-limit: 1000
      max-wait: 5000
  metrics:
    enabled: false
    registry-type: compact
    exporter-list: prometheus
    exporter-prometheus-port: 9898
  transport:
    rpc-tc-request-timeout: 15000
    enable-tc-server-batch-send-response: false
    shutdown:
      wait: 3
    thread-factory:
      boss-thread-prefix: NettyBoss
      worker-thread-prefix: NettyServerNIOWorker
      boss-thread-size: 1
  security:
    secretKey: SeataSecretKey0c382ef121d778043159209298fd40bf3850a017
    tokenValidityInMilliseconds: 1800000
    csrf-ignore-urls: /metadata/v1/**
    ignore:
      urls: /,/**/*.css,/**/*.js,/**/*.html,/**/*.map,/**/*.svg,/**/*.png,/**/*.jpeg,/**/*.ico,/api/v1/auth/login,/version.json,/health,/error,/vgroup/v1/**
EOF
```



## 设置服务自启

**编辑配置文件**

```
sudo tee /etc/systemd/system/seata.service <<"EOF"
[Unit]
Description=Apache Seata
Documentation=https://seata.apache.org/zh-cn
After=network.target
[Service]
Type=simple
WorkingDirectory=/usr/local/software/seata
ExecStart=/usr/local/software/jdk8/bin/java -jar -server -Xms512m -Xmx2048m -Dloader.path=/usr/local/software/apache-seata/seata-server/lib -Dspring.config.location=/usr/local/software/apache-seata/seata-server/conf/application.yml -jar /usr/local/software/apache-seata/seata-server/target/seata-server.jar
ExecStop=/bin/kill -SIGTERM $MAINPID
Restart=on-failure
RestartSec=30
TimeoutStartSec=120
TimeoutStopSec=180
StartLimitIntervalSec=600
StartLimitBurst=3
KillMode=control-group
KillSignal=SIGTERM
SuccessExitStatus=143
User=admin
Group=ateng
[Install]
WantedBy=multi-user.target
EOF
```

**启动服务**

```
sudo systemctl daemon-reload
sudo systemctl enable seata.service
sudo systemctl start seata.service
```

**查看状态**

```
systemctl status seata.service
journalctl -f -u seata.service
```

## 访问服务

```
URL: http://192.168.1.13:7091
Username: admin
Password: Admin@123
```

