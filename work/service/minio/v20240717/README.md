# 安装MinIO集群

下载软件包

```
wget https://dl.min.io/server/minio/release/linux-amd64/archive/minio.RELEASE.2024-07-16T23-46-41Z
wget https://dl.min.io/client/mc/release/linux-amd64/archive/mc.RELEASE.2024-07-15T17-46-06Z
```

1. 安装软件包

```
cp minio.RELEASE.2024-07-16T23-46-41Z /usr/local/bin/minio
cp mc.RELEASE.2024-07-15T17-46-06Z /usr/local/bin/mcli
chmod +x /usr/local/bin/{minio,mcli}
```

2. 创建数据目录

```
mkdir -p /data/service/minio/data{01..02}
```

3. 创建配置文件

> 注意修改MINIO_VOLUMES的值，节点必须在两个及以上
>
> 注意MinIO集群的存储目录不能和操作系统在同一块硬盘上

```
cat > /etc/default/minio <<EOF
MINIO_VOLUMES="http://192.168.1.101:9000/data/service/minio/data{01...02} http://192.168.1.102:9000/data/service/minio/data{01...02} http://192.168.1.103:9000/data/service/minio/data{01...02}"
MINIO_OPTS="--address :9000 --console-address :9001"
MINIO_ROOT_USER=admin
MINIO_ROOT_PASSWORD=Admin@123
EOF
```

4. 使用systemd管理服务

```
cat > /etc/systemd/system/minio.service<<"EOF"
[Unit]
Description=MinIO
Documentation=https://docs.min.io
After=network-online.target
[Service]
User=root
Type=simple
Restart=on-failure
RestartSec=5
StandardOutput=syslog
StandardError=syslog
CPUWeight=1000
CPUQuota=50%
CPUSoftLimit=true
MemoryLimit=16G
EnvironmentFile=-/etc/default/minio
ExecStart=/usr/local/bin/minio server $MINIO_OPTS $MINIO_VOLUMES
ExecStop=/bin/kill -SIGTERM $MAINPID
KillSignal=SIGTERM
TimeoutStopSec=30
[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl start minio
systemctl enable minio
```

5. 访问MinIO

```
URL: http://192.168.1.101:9001/
Username: admin
Password: Admin@123
```

6. 添加minio服务器

```
mcli config host add minio http://192.168.1.101:9000 admin Admin@123 --api s3v4
```

7. 查看信息

```
mcli admin info minio
```

