# Jaeger

Jaeger 是一个由 CNCF（Cloud Native Computing Foundation）托管的分布式追踪系统，用于监控和故障排查微服务架构。它提供了分布式上下文的可视化，使开发人员能够追踪请求在各个微服务之间的传播路径，从而更快地发现性能瓶颈和错误。

- [官网链接](https://www.jaegertracing.io/)



## 安装

**下载软件包**

```
wget https://github.com/jaegertracing/jaeger/releases/download/v1.67.0/jaeger-2.4.0-linux-amd64.tar.gz
```

**解压软件包**

```
tar -zxvf jaeger-2.4.0-linux-amd64.tar.gz
```

- **`jaeger`**：这是一个多功能的可执行文件，包含了 Jaeger 的所有组件。你可以通过参数指定它的运行模式（如 Agent、Collector、Query 等）。
- **`example-hotrod`**：这是一个示例应用程序，用于生成追踪数据，方便你测试 Jaeger 的功能。



## 启动服务

**编辑配置文件**

```yaml
service:
  extensions: [jaeger_storage, jaeger_query]
  pipelines:
    traces:
      receivers: [otlp]
      processors: [batch]
      exporters: [jaeger_storage_exporter]
  telemetry:
    resource:
      service.name: jaeger-query
    metrics:
      level: detailed
      readers:
        - pull:
            exporter:
              prometheus:
                host: 0.0.0.0
                port: 8888

extensions:
  jaeger_storage:
    backends:
      some_trace_storage:
        memory:
          max_traces: 100000
  jaeger_query:
    storage:
      traces: some_trace_storage
    base_path: /
    grpc:
      endpoint: 0.0.0.0:16685
    http:
      endpoint: 0.0.0.0:16686

receivers:
  otlp:
    protocols:
      grpc:
        endpoint: 0.0.0.0:4317
      http:
        endpoint: 0.0.0.0:4318

processors:
  batch:

exporters:
  jaeger_storage_exporter:
    trace_storage: some_trace_storage
```

**启动服务**

```
./jaeger --config ./config.yaml
```

**访问服务**

```
http://192.168.1.12:16686/
```

