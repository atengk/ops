# ETCD 使用文档

## 1. 基本键值操作

- **设置键值对**：用于在 ETCD 中存储键值对。
  ```bash
  etcdctl put <key> <value>
  ```
  **示例**：将键 `foo` 的值设置为 `"hello world"`。
  ```bash
  etcdctl put foo "hello world"
  ```

- **获取键值**：用于检索存储的键值。
  ```bash
  etcdctl get <key>
  ```
  **示例**：获取键 `foo` 的值。
  ```bash
  etcdctl get foo
  ```

- **获取所有键值（带前缀）**：用于列出所有键值，按前缀匹配。
  ```bash
  etcdctl get "" --prefix
  ```

- **删除键值**：用于删除指定键。
  ```bash
  etcdctl del <key>
  ```
  **示例**：删除键 `foo`。
  ```bash
  etcdctl del foo
  ```

- **删除具有特定前缀的键**：用于批量删除匹配指定前缀的键。
  ```bash
  etcdctl del <prefix> --prefix
  ```
  **示例**：删除所有以 `foo` 开头的键。
  ```bash
  etcdctl del foo --prefix
  ```

## 2. 键值管理与历史

- **获取键的历史版本**：可以获取指定键的历史版本数据。
  ```bash
  etcdctl get <key> --revision=<revision_number>
  ```

- **列表键值（仅显示键）**：列出存储中的所有键而不显示值。
  ```bash
  etcdctl get "" --prefix --keys-only
  ```

## 3. 监控键值变化

- **监听键的变化**：用于实时监控键的变化。
  ```bash
  etcdctl watch <key>
  ```
  **示例**：监听 `foo` 键的变化。
  ```bash
  etcdctl watch foo
  ```

## 4. 集群管理命令

- **查看集群健康状态**：用于检查 ETCD 集群的健康状态。
  
  ```bash
  etcdctl endpoint health
  ```
  
- **查看集群成员信息**：显示集群成员的详细信息。
  ```bash
  etcdctl member list
  ```

## 6. 快照和恢复

### （1）数据备份
备份只能从一个指定节点进行，这样导出的数据代表整个集群的快照。
1. 设置备份节点的环境变量：
   ```bash
   export ETCDCTL_ENDPOINTS=https://etcd01.ateng.local:2379
   ```
2. 创建带有时间戳的快照文件：
   ```bash
   time=$(date +%Y%m%d-%H%M%S)
   etcdctl snapshot save etcd-snapshot-${time}.db
   ```
3. 复制快照文件为固定名称以便后续操作：
   ```bash
   \cp etcd-snapshot-${time}.db etcd-snapshot.db
   ```

### （2）查看备份数据
使用 `etcdutl` 查看快照文件的状态：
```bash
etcdutl snapshot status etcd-snapshot.db -w table
```

### （3）所有节点停止 ETCD 并清空数据目录
在所有节点上停止 ETCD 服务并清空数据目录：
```bash
sudo systemctl stop etcd
rm -rf /data/service/etcd/*
```

### （4）将备份数据拷贝到所有节点
将备份文件复制到每个节点，以便恢复。
```bash
scp etcd-snapshot.db etcd02.ateng.local:~
scp etcd-snapshot.db etcd03.ateng.local:~
```

### （5）数据恢复，集群恢复
恢复时需要根据对应的配置文件 `/etc/etcd/etcd.conf` 修改相应的参数

- **恢复 `etcd01` 节点的数据**：
  ```bash
  etcdutl snapshot restore etcd-snapshot.db \
    --name etcd01 \
    --initial-advertise-peer-urls https://192.168.1.112:2380 \
    --initial-cluster etcd01=https://192.168.1.112:2380,etcd02=https://192.168.1.113:2380,etcd03=https://192.168.1.114:2380 \
    --initial-cluster-token 2385569970 \
    --data-dir /data/service/etcd/
  ```

- **恢复 `etcd02` 节点的数据**：
  ```bash
  etcdutl snapshot restore etcd-snapshot.db \
    --name etcd02 \
    --initial-advertise-peer-urls https://192.168.1.113:2380 \
    --initial-cluster etcd01=https://192.168.1.112:2380,etcd02=https://192.168.1.113:2380,etcd03=https://192.168.1.114:2380 \
    --initial-cluster-token 2385569970 \
    --data-dir /data/service/etcd/
  ```

- **恢复 `etcd03` 节点的数据**：
  ```bash
  etcdutl snapshot restore etcd-snapshot.db \
    --name etcd03 \
    --initial-advertise-peer-urls https://192.168.1.114:2380 \
    --initial-cluster etcd01=https://192.168.1.112:2380,etcd02=https://192.168.1.113:2380,etcd03=https://192.168.1.114:2380 \
    --initial-cluster-token 2385569970 \
    --data-dir /data/service/etcd/
  ```

### （6）启动集群
在每个节点依次启动 ETCD 服务：
```bash
sudo systemctl start etcd
```

### （7）查看集群信息
验证集群状态并检查恢复结果：
```bash
etcdctl endpoint status --write-out=table --cluster
etcdctl endpoint health --write-out=table --cluster
etcdctl member list --write-out=table
```

### （8）查看数据
确保数据恢复后正常显示：
```bash
etcdctl get "" --prefix --keys-only
```

## 6. 租约与自动过期

- **创建租约**：用于生成一个具有指定 TTL（生存时间）的租约。
  ```bash
  etcdctl lease grant <TTL>
  ```
  **示例**：创建一个 60 秒的租约。
  ```bash
  etcdctl lease grant 60
  ```

- **将键绑定到租约**：让键在租约到期时自动过期。
  ```bash
  etcdctl put <key> <value> --lease=<lease_id>
  ```

## 7. 分布式锁

- **获取锁**：用于获取一个分布式锁，便于在分布式环境下进行同步。
  ```bash
  etcdctl lock <lock_name>
  ```
  **示例**：获取锁 `mylock`。
  ```bash
  etcdctl lock mylock
  ```

