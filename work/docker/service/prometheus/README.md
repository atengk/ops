# Prometheus

**Prometheus** 是一个开源的监控系统和时序数据库，广泛用于服务器、容器和应用的性能监控。它采用 **Pull 模式** 采集数据，支持 **PromQL 查询语言** 进行实时分析，并可与 **Grafana** 集成实现可视化。Prometheus 具备 **多维度数据模型**、**告警系统（Alertmanager）**，并对 **Kubernetes** 友好，是云原生监控的首选方案。

- [官网链接](https://prometheus.io/)



**下载镜像**

```
docker pull bitnami/prometheus:2.55.1
```

**推送到仓库**

```
docker tag bitnami/prometheus:2.55.1 registry.lingo.local/bitnami/prometheus:2.55.1
docker push registry.lingo.local/bitnami/prometheus:2.55.1
```

**保存镜像**

```
docker save registry.lingo.local/bitnami/prometheus:2.55.1 | gzip -c > image-prometheus_2.55.1.tar.gz
```

**创建目录**

```
sudo mkdir -p /data/container/prometheus/{data,config}
sudo chown -R 1001 /data/container/prometheus
```

**创建配置文件**

```
cat > /data/container/prometheus/config/prometheus.yml <<"EOF"
global:
  scrape_interval: 15s # Set the scrape interval to every 15 seconds. Default is every 1 minute.
  evaluation_interval: 15s # Evaluate rules every 15 seconds. The default is every 1 minute.
  # scrape_timeout is set to the global default (10s).

# Alertmanager configuration
alerting:
  alertmanagers:
    - static_configs:
        - targets:
          # - alertmanager:9093

# Load rules once and periodically evaluate them according to the global 'evaluation_interval'.
rule_files:
  # - "first_rules.yml"
  # - "second_rules.yml"

# A scrape configuration containing exactly one endpoint to scrape:
# Here it's Prometheus itself.
scrape_configs:
  # The job name is added as a label `job=<job_name>` to any timeseries scraped from this config.
  - job_name: "prometheus"

    # metrics_path defaults to '/metrics'
    # scheme defaults to 'http'.

    static_configs:
      - targets: ["localhost:9090"]
EOF
```

**运行服务**

```
docker run -d --name ateng-prometheus \
  -p 20025:9090 --restart=always \
  -v /data/container/prometheus/config/prometheus.yml:/opt/bitnami/prometheus/conf/prometheus.yml:ro \
  -v /data/container/prometheus/data:/opt/bitnami/prometheus/data \
  -e TZ=Asia/Shanghai \
  registry.lingo.local/bitnami/prometheus:2.55.1
```

**查看日志**

```
docker logs -f ateng-prometheus
```

**使用服务**

访问Web

```
URL: http://192.168.1.12:20025
```

**删除服务**

停止服务

```
docker stop ateng-prometheus
```

删除服务

```
docker rm ateng-prometheus
```

删除目录

```
sudo rm -rf /data/container/prometheus
```

