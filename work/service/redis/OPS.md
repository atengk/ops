# Redis CLI 使用指南

`redis-cli` 是 Redis 提供的命令行客户端，用于连接和操作 Redis 数据库。它支持执行常用的 Redis 命令、集群管理、调试和脚本执行等功能。

### 1. 基本用法

#### 连接到 Redis 实例

连接到 Redis 服务器时，可以指定 `-h`（主机）和 `-p`（端口）参数：

```bash
redis-cli -h <hostname> -p <port>
```

- 默认主机（hostname）为 `127.0.0.1`（本地）。
- 默认端口（port）为 `6379`。

例如，连接到本地的 Redis 服务器：

```bash
redis-cli -h 127.0.0.1 -p 6379
```

如果 Redis 配置了密码，还需要使用 `-a` 参数提供密码：

```bash
redis-cli -h 127.0.0.1 -p 6379 -a <password>
```

#### 进入交互式模式

运行 `redis-cli` 后，可以直接输入 Redis 命令进入交互式模式：

```bash
redis-cli
127.0.0.1:6379> GET mykey
```

输入 `quit` 可以退出交互式模式。

### 2. 执行单个命令

可以在命令行中执行单个 Redis 命令，而不进入交互式模式。例如：

```bash
redis-cli -h 127.0.0.1 -p 6379 GET mykey
```

这会直接输出 `mykey` 的值。

### 3. 常用参数

- `-h <hostname>`：指定 Redis 服务器的主机名或 IP 地址。
- `-p <port>`：指定 Redis 服务器的端口号。
- `-a <password>`：指定 Redis 服务器的密码（如果启用了密码验证）。
- `-c`：启用集群模式，允许客户端重定向到其他节点。适用于 Redis 集群模式。
- `-n <database>`：指定要连接的数据库编号（0-15），默认连接数据库 `0`。

### 4. 批量导入和导出数据

`redis-cli` 支持从文件中导入命令，也可以将 Redis 输出保存到文件中。

#### 从文件导入数据

可以使用 `redis-cli` 和重定向符号将文件中的 Redis 命令导入：

```bash
redis-cli < mydata.txt
```

文件 `mydata.txt` 中每一行是一个 Redis 命令，比如 `SET` 或 `GET`。

#### 将输出保存到文件

将 Redis 的输出重定向到文件：

```bash
redis-cli KEYS * > allkeys.txt
```

这会将 `KEYS *` 命令的结果保存到 `allkeys.txt` 文件中。

### 5. 使用管道模式提高性能

`redis-cli` 支持通过 `--pipe` 参数启用管道模式，可以用于批量插入数据，提高数据传输效率。例如：

```bash
(echo -en "PING\r\nPING\r\n"; sleep 1) | redis-cli --pipe
```

这个例子将两个 `PING` 命令通过管道发送到 Redis。

### 6. 管理 Redis 集群

`redis-cli` 提供了一些用于管理 Redis 集群的功能，包括创建集群、查看集群信息等。

#### 创建 Redis 集群

在设置好 Redis 节点后，可以使用以下命令创建集群：

```bash
redis-cli --cluster create <host1>:<port1> <host2>:<port2> <host3>:<port3> --cluster-replicas 1
```

- `<host>` 和 `<port>`：指定 Redis 节点的主机名或 IP 和端口。
- `--cluster-replicas <num>`：指定每个主节点的从节点数量。

#### 查看 Redis 集群信息

连接到 Redis 集群中的任一节点后，可以使用以下命令查看集群信息：

```bash
redis-cli -c -h <hostname> -p <port> CLUSTER INFO
```

查看集群中的所有节点：

```bash
redis-cli -c -h <hostname> -p <port> CLUSTER NODES
```

### 7. 调试和监控

#### MONITOR 命令

`MONITOR` 命令用于实时显示 Redis 服务器接收到的所有命令，可以用于调试：

```bash
redis-cli MONITOR
```

#### INFO 命令

`INFO` 命令可以查看 Redis 服务器的状态信息：

```bash
redis-cli INFO
```

这个命令会输出 Redis 的各种状态信息，包括内存使用、连接信息、键的统计数据等。

#### CONFIG 命令

可以使用 `CONFIG` 命令查看和修改 Redis 配置：

```bash
redis-cli CONFIG GET <parameter>
redis-cli CONFIG SET <parameter> <value>
```

例如，查看 `maxmemory` 配置：

```bash
redis-cli CONFIG GET maxmemory
```

### 8. 通过脚本执行

可以通过 `redis-cli` 执行 Lua 脚本：

```bash
redis-cli EVAL "return redis.call('SET', KEYS[1], ARGV[1])" 1 mykey myvalue
```

这个命令执行一个简单的 Lua 脚本，将 `myvalue` 设置为 `mykey` 的值。

### 9. 退出 Redis CLI

在 `redis-cli` 的交互模式中，可以使用 `quit` 命令或按 `Ctrl+C` 键退出。

