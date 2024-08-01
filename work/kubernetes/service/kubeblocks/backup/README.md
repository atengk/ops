# KubeBlocks 备份恢复

https://cn.kubeblocks.io/docs/preview/user-docs/backup-and-restore/overview

### 1. 配置备份存储库 (BackupRepo)

KubeBlocks 允许通过 `kbcli` 命令配置备份存储库，以保存数据库集群的备份。以下示例演示了如何配置 MinIO 作为备份存储库：

```shell
kbcli backuprepo create my-repo \
  --provider minio \
  --endpoint http://192.168.1.12:9000 \
  --bucket k8s-s3-sc \
  --access-key-id admin \
  --secret-access-key Lingo@local_minio_9000 \
  --access-method Tool \
  --default
```

在上述命令中，`my-repo` 是创建的存储库名称，`Tool` 作为访问方法可以直接通过工具访问远程存储，而无需安装额外的 CSI 驱动。这个选项减少了依赖关系，但可能涉及在多租户环境中同步秘密资源的安全风险【6†source】。

### 2. 列出所有备份存储库

使用以下命令可以查看已配置的备份存储库：

```shell
kbcli backuprepo list
```

### 3. 启用集群备份

可以在特定集群上启用自动备份。以下命令示例展示了如何在 `pg-cluster` 集群中启用备份：

```shell
kbcli cluster update -n kongyu pg-cluster --backup-enabled=true \
--backup-method=pg-basebackup --backup-repo-name=my-repo \
--backup-retention-period=7d --backup-cron-expression="0 18 * * *"
```

此命令设置了每天 18:00 触发的定期备份，使用 `pg-basebackup` 方法，备份数据将保留 7 天【7†source】【8†source】。

### 4. 按需备份

KubeBlocks 支持按需备份，可以手动创建特定时间点的备份。例如，使用以下命令创建名为 `mybackup` 的备份：

```shell
kbcli cluster backup -n kongyu pg-cluster --name mybackup --method pg-basebackup
```

使用 `--method` 指定的备份方法可以是 `pg-basebackup` 或其他支持的工具【7†source】。

### 5. 查看备份列表

可以使用以下命令查看指定集群的所有备份：

```shell
kbcli cluster list-backups --name=mybackup -n kongyu
```

此命令将列出名为 `mybackup` 的备份的详细信息，包括备份状态、大小、持续时间和创建时间【7†source】。

### 6. Point-in-Time Recovery (PITR)

PITR 允许恢复数据库到指定时间点，提供细粒度的数据恢复能力。在启用 PITR 的情况下，集群将定期创建完整备份并记录所有事务日志。

执行以下命令以查看集群可以恢复的时间戳范围：

```shell
kbcli cluster describe pg-cluster
```

要恢复到特定时间点，可以使用以下命令：

```shell
kbcli cluster restore pg-cluster-pitr --restore-to-time 'May 07,2024 15:48:47 UTC+0800' --backup <continuousBackupName>
```

恢复后，可以使用 `kbcli cluster list` 命令检查恢复状态【9†source】。

---

这些步骤和命令为 KubeBlocks 用户提供了完整的备份和恢复解决方案，从存储库配置到按需和定期备份，再到高级的 PITR 功能。确保根据实际需求配置合适的备份方法和存储方案，以实现数据的安全和高效管理。