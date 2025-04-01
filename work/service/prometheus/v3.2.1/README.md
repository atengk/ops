# Prometheus

Prometheus 是一个开源的监控和报警系统，主要用于监控分布式系统和云原生环境。它通过拉取（Pull）方式从目标服务中采集时序数据，并存储在其时序数据库中。Prometheus 提供强大的查询语言 PromQL，可用于实时分析和可视化数据。它支持多维数据模型，使用标签（Labels）标识数据。此外，Prometheus 还具备灵活的报警功能，可根据设定的规则发送通知。凭借其可靠性和易于集成的特性，Prometheus 已成为现代监控解决方案的首选。

- [官网地址](https://prometheus.io/)

- [软件下载](https://prometheus.io/download/)

- [告警策略配置参考](https://github.com/sretalk/prometheus-rules)



## 基础配置

**下载软件包**

```
wget https://github.com/prometheus/prometheus/releases/download/v3.2.1/prometheus-3.2.1.linux-amd64.tar.gz
```

**解压软件包**

```
tar -zxvf prometheus-3.2.1.linux-amd64.tar.gz
```

**安装软件包**

```
cp -rvf prometheus-3.2.1.linux-amd64/{prometheus,promtool} /usr/local/bin/
```

**清理目录**

```
rm -rf prometheus-3.2.1.linux-amd64/
```



## 编辑配置

**创建数据目录**

```
mkdir -p /data/service/prometheus/{config,data}
```

**编辑配置文件**

```
cat > /data/service/prometheus/config/prometheus.yml <<EOF
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: "prometheus"
    static_configs:
      - targets: ["localhost:9090"]
EOF
```

**启动测试**

```
/usr/local/bin/prometheus --config.file=/data/service/prometheus/config/prometheus.yml --storage.tsdb.path=/data/service/prometheus/data --web.listen-address=:9090
```



## 启动服务

**编辑配置文件**

```
sudo tee /etc/systemd/system/prometheus.service <<"EOF"
[Unit]
Description=Prometheus
Documentation=https://prometheus.io/
After=network.target
[Service]
Type=simple
WorkingDirectory=/data/service/prometheus
ExecStart=/usr/local/bin/prometheus --config.file=/data/service/prometheus/config/prometheus.yml --storage.tsdb.path=/data/service/prometheus/data --web.listen-address=:9090 --web.enable-lifecycle
ExecStop=/bin/kill -SIGTERM $MAINPID
Restart=on-failure
RestartSec=30
TimeoutStartSec=120
TimeoutStopSec=180
StartLimitIntervalSec=600
StartLimitBurst=3
KillMode=control-group
KillSignal=SIGTERM
User=admin
Group=ateng
[Install]
WantedBy=multi-user.target
EOF
```

关键配置解释

- `--storage.tsdb.path`: 数据存储路径
- `--web.listen-address`: 监听的Web端口
- `--web.enable-lifecycle`: 启用 Lifecycle API，开启生命周期 API（`/-/reload`）

**启动服务**

```
sudo systemctl daemon-reload
sudo systemctl enable prometheus.service
sudo systemctl start prometheus.service
```

**查看状态和日志**

```
sudo systemctl status prometheus.service
sudo journalctl -f -u prometheus.service
```



## 使用服务

**访问Targets**

```
http://192.168.1.12:9090/targets
```

**访问Metrics**

```
http://192.168.1.12:9090/metrics
```

**新增target**

编辑配置文件

```
$ vi /data/service/prometheus/config/prometheus.yml
# ...
scrape_configs:
  - job_name: "otel"
    static_configs:
      - targets: ["192.168.1.12:8889"]
```

热加载配置

```
curl -X POST http://localhost:9090/-/reload
```

