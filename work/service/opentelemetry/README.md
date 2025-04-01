# OpenTelemetry

OpenTelemetry（简称 OTel）是一个用于 **可观测性（Observability）** 的开源框架，主要用于收集、处理和导出 **跟踪（Tracing）、指标（Metrics）和日志（Logs）** 数据。它是由 **CNCF（云原生计算基金会）** 托管的项目，旨在提供统一的 API 和 SDK，使开发者能够方便地监控和分析分布式系统的性能。

**OpenTelemetry 的主要组件**

1. **API**：提供标准化的接口，让开发者在代码中埋点，无需关心底层实现。
2. **SDK**：具体的实现，包含数据采集、处理和导出功能。
3. **Collector**：一个独立的服务，用于接收、处理和导出遥测数据，支持多种后端（如 Jaeger、Prometheus、Zipkin、Grafana 等）。
4. **Instrumentation（自动/手动）**：自动或手动在应用中插入代码，以收集遥测数据。

**支持的语言**

OpenTelemetry 支持多种编程语言，如 **Java、Python、Go、JavaScript、C++、Rust** 等，方便集成到不同的技术栈中。

**应用场景**

- **分布式跟踪**：帮助开发者分析跨服务调用的请求路径，优化性能。
- **性能监控**：结合指标和日志，分析应用的健康状况。
- **故障排查**：快速发现和定位问题，提高运维效率。

**与其他工具的关系**

OpenTelemetry 可以与 **Prometheus、Jaeger、Grafana、Zipkin、Elastic Stack** 等监控工具配合使用，提供完整的可观测性解决方案。

**总结**：OpenTelemetry 是现代微服务架构中的重要工具，帮助开发者实现端到端的监控，提升系统稳定性和可维护性。

- [官网链接](https://opentelemetry.io/zh/docs/what-is-opentelemetry/)



## OpenTelemetry Collector Contrib

**OpenTelemetry Collector**

OpenTelemetry Collector 是一个独立的可观测性数据处理组件，负责接收、处理和导出 **Tracing（跟踪）、Metrics（指标）和 Logs（日志）** 数据。它提供了一种无侵入的方式，将遥测数据从应用程序发送到后端，如 **Prometheus、Jaeger、Zipkin、Datadog 和 Elasticsearch**。

Collector 由 **接收器（Receiver）、处理器（Processor）和导出器（Exporter）** 组成，支持数据格式转换、批处理、采样和过滤等功能。相比直接在应用中嵌入 SDK，Collector 降低了数据传输的开销，提高了可扩展性和灵活性。

Collector 主要有两种部署模式：

1. **Agent 模式**（运行在应用服务器上，靠近数据源）。
2. **Gateway 模式**（集中式收集和处理数据）。

它是 OpenTelemetry 生态的核心组件，为分布式系统提供统一的可观测性数据管道。

------

**OpenTelemetry Collector Contrib**

OpenTelemetry Collector Contrib 是 OpenTelemetry Collector 的增强版本，包含了 **更多的接收器、处理器和导出器**，提供更丰富的功能。

除了核心版本支持的后端（如 Jaeger、Prometheus），Contrib 版本增加了对 **AWS CloudWatch、Google Cloud Monitoring、Splunk、Sentry、Loki** 等多种云服务和 APM 解决方案的支持。此外，它还包括 **额外的转换逻辑、数据过滤器、加密支持** 等高级特性，适用于更复杂的生产环境。

虽然 Contrib 版本功能更强大，但由于插件数量多，可能需要更精细的配置和管理。因此，在实际应用中，可以根据需求选择核心版或 Contrib 版。

- [官网安装文档](https://opentelemetry.io/docs/collector/installation/)

- [Github](https://github.com/open-telemetry/opentelemetry-collector-contrib)
- [Exports使用文档1](https://opentelemetry.io/docs/collector/configuration/#exporters)
- [Exports使用文档2](https://github.com/open-telemetry/opentelemetry-collector-contrib/tree/main/exporter)

### 安装软件

**下载软件包**

```
wget https://github.com/open-telemetry/opentelemetry-collector-releases/releases/download/v0.122.1/otelcol-contrib_0.122.1_linux_amd64.tar.gz
```

**解压软件包**

```
mkdir -p target && tar -xzvf otelcol-contrib_0.122.1_linux_amd64.tar.gz -C target
```

**安装软件包**

```
mv target/otelcol-contrib /usr/local/bin/
```

**清理目录**

```
rm -rf target/
```

### 配置文件

#### 创建配置文件

```
sudo mkdir /etc/otelcol
sudo tee /etc/otelcol/config.yaml <<EOF
receivers:
  otlp:
    protocols:
      grpc:
        endpoint: 0.0.0.0:4317
      http:
        endpoint: 0.0.0.0:4318

exporters:
  debug:
    verbosity: detailed

service:
  pipelines:
    traces:
      receivers: [otlp]
      processors: []
      exporters: [debug]
    metrics:
      receivers: [otlp]
      processors: []
      exporters: [debug]
    logs:
      receivers: [otlp]
      processors: []
      exporters: [debug]
EOF
```

#### **配置文件解释**

**receivers（数据接收）**

- **`receivers`**: 定义 OpenTelemetry Collector 如何接收数据。
- **`otlp`**: 这里使用了 **OTLP（OpenTelemetry Protocol）** 作为接收器，意味着 Collector 可以接收 OpenTelemetry 代理（SDK）或其他组件发送的遥测数据。
- **`protocols`**:
    - `grpc`: 监听 `0.0.0.0:4317` 端口，支持 gRPC 协议接收数据。
    - `http`: 监听 `0.0.0.0:4318` 端口，支持 HTTP 协议接收数据。

这两个端口是 OpenTelemetry 的 **默认端口**：

- `4317` → gRPC（推荐方式）
- `4318` → HTTP（兼容性支持）

**exporters（数据导出）**

**`exporters`**: 定义数据导出方式。

**`debug`**: 这里使用了 `debug` 导出器，它会在 **日志中输出** 采集的数据，而不是发送到外部系统（如 Jaeger、Prometheus）。

**`verbosity`**: basi表示仅输出基本信息；normal表示输出摘要信息；detailed表示输出详细日志，适用于调试场景；

**service（数据处理管道）**

- **`service`**: 定义 OpenTelemetry Collector 的核心处理逻辑。
- **`pipelines`**: 定义不同类型的遥测数据的处理方式。
- **`traces`（链路追踪）、`metrics`（指标）、`logs`（日志）**：
    - **`receivers: [otlp]`** → 这三种数据都通过 `otlp` 接收器接收。
    - **`processors: []`** → 这里没有配置处理器（默认不会进行数据过滤、转换等操作）。
    - **`exporters: [debug]`** → 数据直接输出到 `debug`（标准输出）。

### 启动服务

**编辑配置文件**

```
sudo tee /etc/systemd/system/otelcol.service <<"EOF"
[Unit]
Description=OpenTelemetry
Documentation=https://opentelemetry.io/
After=network.target
[Service]
Type=simple
ExecStart=/usr/local/bin/otelcol-contrib --config /etc/otelcol/config.yaml
ExecStop=/bin/kill -SIGTERM $MAINPID
Restart=on-failure
RestartSec=10
TimeoutStartSec=90
TimeoutStopSec=120
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
sudo systemctl enable otelcol.service
sudo systemctl start otelcol.service
```

**查看状态和日志**

```
sudo systemctl status otelcol.service
sudo journalctl -f -u otelcol.service
```



### traces: jaeger exporter

#### otlp/jaeger

**配置示例**

```yaml
exporters:
  # Data sources: traces
  otlp/jaeger:
    endpoint: jaeger-server:4317
    tls:
      insecure: true
```

**完整配置文件**

```yaml
receivers:
  otlp:
    protocols:
      grpc:
        endpoint: 0.0.0.0:4317
      http:
        endpoint: 0.0.0.0:4318

exporters:
  debug:
    verbosity: detailed
  otlp/jaeger:
    endpoint: 192.168.1.10:37216
    tls:
      insecure: true

processors:
  batch:

service:
  pipelines:
    traces:
      receivers: [otlp]
      processors: [batch]
      exporters: [debug, otlp/jaeger]
    metrics:
      receivers: [otlp]
      processors: [batch]
      exporters: [debug]
    logs:
      receivers: [otlp]
      processors: [batch]
      exporters: [debug]
```

**重启服务**

```
sudo systemctl restart otelcol.service
```

**查看日志**

```
sudo journalctl -f -u otelcol.service
```

#### otlphttp

**配置示例**

```yaml
exporters:
  # Data sources: traces, metrics
  otlphttp:
    endpoint: http://otlp.example.com:4318
    tls:
      insecure: true
```

**完整配置文件**

```yaml
receivers:
  otlp:
    protocols:
      grpc:
        endpoint: 0.0.0.0:4317
      http:
        endpoint: 0.0.0.0:4318

exporters:
  debug:
    verbosity: detailed
  otlphttp:
    endpoint: http://192.168.1.10:31353
    tls:
      insecure: true

processors:
  batch:

service:
  pipelines:
    traces:
      receivers: [otlp]
      processors: [batch]
      exporters: [debug, otlphttp]
    metrics:
      receivers: [otlp]
      processors: [batch]
      exporters: [debug]
    logs:
      receivers: [otlp]
      processors: [batch]
      exporters: [debug]
```

**重启服务**

```
sudo systemctl restart otelcol.service
```

**查看日志**

```
sudo journalctl -f -u otelcol.service
```



### traces: zipkin exporter

参考：[官方文档](https://github.com/open-telemetry/opentelemetry-collector-contrib/tree/main/exporter/zipkinexporter)

**配置示例**

```yaml
  # Data sources: traces
exporters:
  zipkin/nontls:
    endpoint: "http://some.url:9411/api/v2/spans"
    format: proto
    default_service_name: unknown-service

  zipkin/withtls:
    endpoint: "https://some.url:9411/api/v2/spans"

  zipkin/tlsnoverify:
    endpoint: "https://some.url:9411/api/v2/spans"
    tls:
      insecure_skip_verify: true
```

**完整配置文件**

```yaml
receivers:
  otlp:
    protocols:
      grpc:
        endpoint: 0.0.0.0:4317
      http:
        endpoint: 0.0.0.0:4318

exporters:
  debug:
    verbosity: detailed
  zipkin/tlsnoverify:
    endpoint: "http://192.168.1.10:49723/api/v2/spans"
    tls:
      insecure_skip_verify: true

processors:
  batch:

service:
  pipelines:
    traces:
      receivers: [otlp]
      processors: [batch]
      exporters: [debug, zipkin/tlsnoverify]
    metrics:
      receivers: [otlp]
      processors: [batch]
      exporters: [debug]
    logs:
      receivers: [otlp]
      processors: [batch]
      exporters: [debug]
```

**重启服务**

```
sudo systemctl restart otelcol.service
```

**查看日志**

```
sudo journalctl -f -u otelcol.service
```



### logs: kafka exporter

参考：[官方文档](https://github.com/open-telemetry/opentelemetry-collector-contrib/tree/main/exporter/kafkaexporter)

**配置示例**

```yaml
  # Data sources: traces, metrics, logs
exporters:
  kafka:
    brokers:
      - localhost:9092
    topic: ateng_otlp
    encoding: otlp_json
```

**完整配置文件**

```yaml
receivers:
  otlp:
    protocols:
      grpc:
        endpoint: 0.0.0.0:4317
      http:
        endpoint: 0.0.0.0:4318

exporters:
  debug:
    verbosity: detailed
  kafka:
    brokers:
      - 192.168.1.10:9094
    topic: ateng_otlp
    encoding: otlp_json

service:
  pipelines:
    traces:
      receivers: [otlp]
      processors: []
      exporters: [debug, kafka]
    metrics:
      receivers: [otlp]
      processors: []
      exporters: [debug, kafka]
    logs:
      receivers: [otlp]
      processors: []
      exporters: [debug, kafka]
```

**重启服务**

```
sudo systemctl restart otelcol.service
```

**查看日志**

```
sudo journalctl -f -u otelcol.service
```



### logs: elasticsearch exporter

建议Elasticsearch>=8.16

参考：[官方文档](https://github.com/open-telemetry/opentelemetry-collector-contrib/tree/main/exporter/elasticsearchexporter)

**配置示例**

```yaml
  # Data sources: traces, logs
exporters:
  elasticsearch:
    endpoint: https://elastic.example.com:9200
    auth:
      authenticator: basicauth

extensions:
  basicauth:
    client_auth:
      username: elastic
      password: changeme
```

**完整配置文件**

```yaml
receivers:
  otlp:
    protocols:
      grpc:
        endpoint: 0.0.0.0:4317
      http:
        endpoint: 0.0.0.0:4318

exporters:
  debug:
    verbosity: detailed
  elasticsearch:
    endpoint: http://192.168.1.10:43335
    auth:
      authenticator: basicauth
    mapping:
      mode: otel
    logs_index: otlp_logs 

extensions:
  basicauth:
    client_auth:
      username: elastic
      password: Admin@123

processors:
  batch:

service:
  extensions: [basicauth]
  pipelines:
    traces:
      receivers: [otlp]
      processors: [batch]
      exporters: [debug]
    metrics:
      receivers: [otlp]
      processors: [batch]
      exporters: [debug]
    logs:
      receivers: [otlp]
      processors: [batch]
      exporters: [debug, elasticsearch]
```

**创建数据流**

在ElasticSearch中先创建索引模版，然后创建数据流

创建索引模版

```
curl -u elastic:Admin@123 -X PUT "http://localhost:9200/_index_template/otlp_template" -H "Content-Type: application/json" -d '
{
  "index_patterns": ["otlp_logs*"],
  "data_stream": {},
  "template": {
    "settings": {
      "index.lifecycle.name": "data-stream-policy"
    },
    "mappings": {
      "properties": {
        "@timestamp": { "type": "date" }
      }
    }
  }
}'
```

创建数据流

```
curl -u elastic:Admin@123 -X PUT "http://localhost:9200/_data_stream/otlp_logs"
```

**重启服务**

```
sudo systemctl restart otelcol.service
```

**查看日志**

```
sudo journalctl -f -u otelcol.service
```

**查看ES的数据**

查看索引列表

```
curl -u elastic:Admin@123 http://localhost:9200/_cat/indices?v
```

查看数据

```
curl -u elastic:Admin@123 -X GET "http://localhost:9200/.ds-otlp_logs-2025.03.28-000001/_search?pretty" -H 'Content-Type: application/json' -d'
{
  "query": {
    "match_all": {}
  },
  "size": 2
}'
```



### logs: opensearch exporter

参考：[官方文档](https://github.com/open-telemetry/opentelemetry-collector-contrib/tree/main/exporter/opensearchexporter)

**配置示例**

```yaml
  # Data sources: traces, logs
exporters:
  elasticsearch:
    endpoint: https://opensearch.example.com:9200
    auth:
      authenticator: basicauth

extensions:
  basicauth:
    client_auth:
      username: admin
      password: changeme
```

**完整配置文件**

```yaml
receivers:
  otlp:
    protocols:
      grpc:
        endpoint: 0.0.0.0:4317
      http:
        endpoint: 0.0.0.0:4318

exporters:
  debug:
    verbosity: detailed
  opensearch:
    http:
      endpoint: http://192.168.1.10:29860
      auth:
        authenticator: basicauth
    logs_index: otlp_logs 

extensions:
  basicauth:
    client_auth:
      username: admin
      password: Admin@123

processors:
  batch:

service:
  extensions: [basicauth]
  pipelines:
    traces:
      receivers: [otlp]
      processors: [batch]
      exporters: [debug]
    metrics:
      receivers: [otlp]
      processors: [batch]
      exporters: [debug]
    logs:
      receivers: [otlp]
      processors: [batch]
      exporters: [debug, opensearch]
```

**重启服务**

```
sudo systemctl restart otelcol.service
```

**查看日志**

```
sudo journalctl -f -u otelcol.service
```

**查看ES的数据**

查看索引列表

```
curl http://localhost:9200/_cat/indices?v
```

查看数据

```
curl -X GET "http://localhost:9200/otlp_logs/_search?pretty" -H 'Content-Type: application/json' -d'
{
  "query": {
    "match_all": {}
  },
  "size": 2
}'
```



### logs: doris exporter

参考：[官方文档](https://github.com/open-telemetry/opentelemetry-collector-contrib/tree/main/exporter/dorisexporter)

**配置示例**

```yaml
  # Data sources: traces, metrics, logs
exporters:
  doris:
    endpoint: http://localhost:8030
    database: otel
    username: admin
    password: admin
    table:
      logs: otel_logs
      traces: otel_traces
      metrics: otel_metrics
    create_schema: true
    mysql_endpoint: localhost:9030
    history_days: 0
    create_history_days: 0
    replication_num: 1
    timezone: Asia/Shanghai
    timeout: 5s
    sending_queue:
      enabled: true
      num_consumers: 10
      queue_size: 1000
    retry_on_failure:
      enabled: true
      initial_interval: 5s
      max_interval: 30s
      max_elapsed_time: 300s
```

**完整配置文件**

```yaml
receivers:
  otlp:
    protocols:
      grpc:
        endpoint: 0.0.0.0:4317
      http:
        endpoint: 0.0.0.0:4318

exporters:
  debug:
    verbosity: detailed
  doris:
    endpoint: http://192.168.1.12:9040
    database: ateng_otel
    username: admin
    password: Admin@123
    table:
      logs: otel_logs
      traces: otel_traces
      metrics: otel_metrics
    create_schema: true
    mysql_endpoint: 192.168.1.12:9030
    history_days: 100
    create_history_days: 3
    replication_num: 1
    timezone: Asia/Shanghai
    timeout: 5s
    sending_queue:
      enabled: true
      num_consumers: 10
      queue_size: 1000
    retry_on_failure:
      enabled: true
      initial_interval: 5s
      max_interval: 30s
      max_elapsed_time: 300s

processors:
  batch:

service:
  pipelines:
    traces:
      receivers: [otlp]
      processors: [batch]
      exporters: [debug]
    metrics:
      receivers: [otlp]
      processors: [batch]
      exporters: [debug]
    logs:
      receivers: [otlp]
      processors: [batch]
      exporters: [debug, doris]
```

**重启服务**

```
sudo systemctl restart otelcol.service
```

**查看日志**

```
sudo journalctl -f -u otelcol.service
```



### logs: cassandra exporter

参考：[官方文档](https://github.com/open-telemetry/opentelemetry-collector-contrib/tree/main/exporter/cassandraexporter)

**配置示例**

```yaml
  # Data sources: traces, logs
exporters:
  cassandra:
    dsn: 127.0.0.1
    port: 9042
    timeout: 10s
    keyspace: "otel"
    trace_table: "otel_spans"
    replication:
      class: "SimpleStrategy"
      replication_factor: 1
    compression:
      algorithm: "ZstdCompressor"
    auth:
      username: "your-username"
      password: "your-password"
```

**完整配置文件**

```yaml
receivers:
  otlp:
    protocols:
      grpc:
        endpoint: 0.0.0.0:4317
      http:
        endpoint: 0.0.0.0:4318

exporters:
  debug:
    verbosity: detailed
  cassandra:
    dsn: 192.168.1.10
    port: 47023
    timeout: 10s
    keyspace: "ateng_otel"
    trace_table: "otel_spans"
    replication:
      class: "SimpleStrategy"
      replication_factor: 1
    compression:
      algorithm: "ZstdCompressor"
    auth:
      username: "cassandra"
      password: "Admin@123"

processors:
  batch:

service:
  pipelines:
    traces:
      receivers: [otlp]
      processors: [batch]
      exporters: [debug]
    metrics:
      receivers: [otlp]
      processors: [batch]
      exporters: [debug]
    logs:
      receivers: [otlp]
      processors: [batch]
      exporters: [debug, cassandra]
```

**重启服务**

```
sudo systemctl restart otelcol.service
```

**查看日志**

```
sudo journalctl -f -u otelcol.service
```



### logs: minio exporter

参考：[官方文档](https://github.com/open-telemetry/opentelemetry-collector-contrib/tree/main/exporter/awss3exporter)

**完整配置文件**

```yaml
receivers:
  otlp:
    protocols:
      grpc:
        endpoint: 0.0.0.0:4317
      http:
        endpoint: 0.0.0.0:4318

exporters:
  debug:
    verbosity: detailed
  awss3:
    s3uploader:
      endpoint: http://192.168.1.12:9000
      region: 'eu-central-1'
      s3_bucket: 'data'
      s3_prefix: 'otel'
      s3_force_path_style: true

processors:
  batch:

service:
  pipelines:
    traces:
      receivers: [otlp]
      processors: [batch]
      exporters: [debug]
    metrics:
      receivers: [otlp]
      processors: [batch]
      exporters: [debug]
    logs:
      receivers: [otlp]
      processors: [batch]
      exporters: [debug, awss3]
```

**重启服务**

注意需要将S3认证的环境变量配置上：AWS_ACCESS_KEY_ID、AWS_SECRET_ACCESS_KEY

```
sudo systemctl restart otelcol.service
```

**查看日志**

```
sudo journalctl -f -u otelcol.service
```



### metrics: prometheus exporter

参考：[官方文档](https://github.com/open-telemetry/opentelemetry-collector-contrib/tree/main/exporter/prometheusexporter)

**配置示例**

```yaml
exporters:
  prometheus:
    endpoint: "1.2.3.4:1234"
    tls:
      ca_file: "/path/to/ca.pem"
      cert_file: "/path/to/cert.pem"
      key_file: "/path/to/key.pem"
    namespace: test-space
    const_labels:
      label1: value1
      "another label": spaced value
    send_timestamps: true
    metric_expiration: 180m
    enable_open_metrics: true
    add_metric_suffixes: false
    resource_to_telemetry_conversion:
      enabled: true
```

**完整配置文件**

```yaml
receivers:
  otlp:
    protocols:
      grpc:
        endpoint: 0.0.0.0:4317
      http:
        endpoint: 0.0.0.0:4318

exporters:
  debug:
    verbosity: detailed
  prometheus:
    endpoint: 0.0.0.0:8889

processors:
  batch:

service:
  pipelines:
    traces:
      receivers: [otlp]
      processors: [batch]
      exporters: [debug]
    metrics:
      receivers: [otlp]
      processors: [batch]
      exporters: [debug, prometheus]
    logs:
      receivers: [otlp]
      processors: [batch]
      exporters: [debug]
```

**重启服务**

```
sudo systemctl restart otelcol.service
```

**查看日志**

```
sudo journalctl -f -u otelcol.service
```

