# Grafana

Grafana 是一个开源的数据可视化和监控工具，支持多种数据源（如 Prometheus、MySQL、Elasticsearch 等）。它提供动态仪表盘、警报和数据分析功能，适用于 IT 监控、业务分析和物联网应用。Grafana 具有直观的界面，可通过 SQL 查询或 API 轻松创建可视化图表，并支持权限管理及插件扩展，广泛应用于 DevOps 和大数据领域。

- [官网地址](https://grafana.com/)

- [软件下载](https://grafana.com/grafana/download?pg=get&plcmt=selfmanaged-box1-cta1)

- [Dashboards](https://grafana.com/grafana/dashboards)



## 基础配置

**下载软件包**

```
wget https://dl.grafana.com/enterprise/release/grafana-enterprise-11.5.3.linux-amd64.tar.gz
```

**解压软件包**

```
tar -zxvf grafana-enterprise-11.5.3.linux-amd64.tar.gz -C /data/service/
```



## 编辑配置



## 启动服务

**编辑配置文件**

```
sudo tee /etc/systemd/system/grafana.service <<"EOF"
[Unit]
Description=Grafana
Documentation=https://grafana.com/
After=network.target
[Service]
Type=simple
WorkingDirectory=/data/service/grafana-v11.5.3
ExecStart=/data/service/grafana-v11.5.3/bin/grafana server
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

**启动服务**

```
sudo systemctl daemon-reload
sudo systemctl enable grafana.service
sudo systemctl start grafana.service
```

**查看状态和日志**

```
sudo systemctl status grafana.service
sudo journalctl -f -u grafana.service
```



## 使用服务

**访问Web**

```
URL: http://192.168.1.12:30000
Username: admin
Password: admin
```

