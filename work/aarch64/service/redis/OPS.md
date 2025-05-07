# Redis CLI 使用文档

`redis-cli` 是 Redis 提供的命令行客户端，用于连接和操作 Redis 数据库。它支持执行常用的 Redis 命令、集群管理、调试和脚本执行等功能。

### 1. **基本连接和配置**

#### 1.1 **连接 Redis 服务器**

1. **连接服务器**

   - 如果 Redis 设置了密码，需要使用 `-a` 参数提供密码。
   ```bash
   redis-cli -h 192.168.1.100 -p 6379 -a your_password
   ```

   - 使用环境变量设置密码

   ```bash
   export REDISCLI_AUTH=Admin@123
   redis-cli -h 192.168.1.100 -p 6379
   ```

2. **选择数据库**

   - Redis 默认有 16 个数据库（编号 0 到 15），可以用 `-n` 参数指定连接到特定数据库。
   ```bash
   redis-cli -n 2
   ```
   - 进入 CLI 后使用 `SELECT` 命令切换数据库：
   ```bash
   SELECT 2
   ```

#### 1.2 **连接 Redis 集群**

1. **基本集群连接**

    - 要连接到 Redis 集群中的某个节点，只需指定该节点的 IP 和端口。

    ```bash
    redis-cli -c -h <节点IP> -p <节点端口>
    ```

    - 连接到任一节点后，`redis-cli` 可以自动处理分片和重定向请求，无需手动指定其他节点。

2. **查看集群信息**

    - 可以使用 `CLUSTER INFO` 命令查看集群的状态。

    ```bash
    redis-cli -c -h <节点IP> -p <节点端口> CLUSTER INFO
    ```

    - 例如，查看集群状态：

    ```bash
    CLUSTER INFO
    ```

3. **列出集群节点**

    - 使用 `CLUSTER NODES` 可以列出当前 Redis 集群中的所有节点及其状态信息。

    ```bash
    redis-cli -c -h <节点IP> -p <节点端口> CLUSTER NODES
    ```

4. **管理集群槽位**

    - Redis 集群使用槽（slot）来分配和管理数据，所有的键根据哈希值被映射到 0 到 16383 号槽上。可以通过 `--cluster` 模式管理槽位分布。

    - 示例：查看指定节点的槽位分配：

        ```bash
        redis-cli -c -h <节点IP> -p <节点端口> CLUSTER SLOTS
        ```

5. **简化的集群命令操作**

    - `redis-cli` 支持直接在集群上执行键操作命令，如 `SET`、`GET` 等。集群会自动将请求重定向到正确的分片节点。

    - 示例：向集群中的键 `mykey` 设置值。

        ```bash
        redis-cli -c -h <任一节点IP> -p <节点端口> SET mykey "value"
        ```

6. **集群故障转移**

    - 使用 `CLUSTER FAILOVER` 可以手动触发主从切换，在主节点不可用时让从节点接管。
    - 先查看从节点的节点，然后连接到从节点将其提升为主节点

    ```bash
    $ redis-cli -c -h 192.168.1.112 -p 6001 CLUSTER NODES
    2681160c6fd212335e507329d93ed93f19a0c3a2 192.168.1.114:6001@16001 master - 0 1730942843109 5 connected 10923-16383
    f8f2bef05c3ed2b53aca4be75f2b93a98e6179dc 192.168.1.112:6001@16001 myself,master - 0 0 1 connected 0-5460
    0cb71a3f459b563c65d5d3798c4bfe71563697b7 192.168.1.113:6002@16002 slave f8f2bef05c3ed2b53aca4be75f2b93a98e6179dc 0 1730942844115 1 connected
    662f4a9307375b92e25442d02817bcf99db5b9dc 192.168.1.114:6002@16002 slave 43a80f583f1ec63dc2cb46d6915e371fb29e7ab0 0 1730942841095 3 connected
    c8a13d3df5fc89444c1813fff37d378b2d60e62b 192.168.1.112:6002@16002 slave 2681160c6fd212335e507329d93ed93f19a0c3a2 0 1730942842102 5 connected
    43a80f583f1ec63dc2cb46d6915e371fb29e7ab0 192.168.1.113:6001@16001 master - 0 1730942841000 3 connected 5461-10922
    $ redis-cli -c -h 192.168.1.113 -p 6002 CLUSTER FAILOVER
    OK
    ```

### 2. **键操作命令**

Redis 中的键（Key）操作涉及对键的创建、删除、重命名、过期控制等操作。

#### 2.1 **设置键值：SET**
   - 将键 `key` 设置为指定的值 `value`。
   ```bash
   SET key value
   ```
   - 示例：
   ```bash
   SET mykey "Hello Redis"
   ```

#### 2.2 **获取键值：GET**
   - 获取指定键的值。
   ```bash
   GET key
   ```
   - 示例：
   ```bash
   GET mykey
   ```

#### 2.3 **删除键：DEL**
   - 删除一个或多个键。
   ```bash
   DEL key1 key2
   ```
   - 示例：
   ```bash
   DEL mykey
   ```

#### 2.4 **检查键是否存在：EXISTS**
   - 检查键是否存在，返回 1 表示存在，0 表示不存在。
   ```bash
   EXISTS key
   ```
   - 示例：
   ```bash
   EXISTS mykey
   ```

#### 2.5 **设置键过期时间：EXPIRE**
   - 设置键的过期时间（以秒为单位）。
   ```bash
   EXPIRE key seconds
   ```
   - 示例：设置 `mykey` 在 10 秒后过期。
   ```bash
   EXPIRE mykey 10
   ```

#### 2.6 **查看键的剩余生存时间：TTL**
   - 返回键的剩余生存时间（单位为秒），-1 表示没有设置过期时间，-2 表示键不存在。
   ```bash
   TTL key
   ```
   - 示例：
   ```bash
   TTL mykey
   ```

#### 2.7 **重命名键：RENAME**
   - 将键 `oldkey` 重命名为 `newkey`，若 `newkey` 已存在则覆盖。
   ```bash
   RENAME oldkey newkey
   ```
   - 示例：
   ```bash
   RENAME mykey newkey
   ```

#### 2.8 **获取键列表：KEYS**
   - 返回与指定模式匹配的所有键。模式支持通配符：
     - `*` 匹配任意字符
     - `?` 匹配一个字符
     - `[abc]` 匹配字符 a、b 或 c
   ```bash
   KEYS pattern
   ```
   - 示例：获取所有以 `user:` 开头的键。
   ```bash
   KEYS user:*
   ```

#### 2.9 **随机获取一个键：RANDOMKEY**
   - 随机返回一个键。
   ```bash
   RANDOMKEY
   ```

#### 2.10 **移动键到指定数据库：MOVE**
   - 将键 `key` 移动到目标数据库 `db`，成功返回 1，失败返回 0。
   ```bash
   MOVE key db
   ```
   - 示例：将 `mykey` 移动到数据库 1。
   ```bash
   MOVE mykey 1
   ```

#### 2.11 **获取键的类型：TYPE**
   - 返回键的数据类型，例如 `string`、`list`、`set`、`zset`、`hash`。
   ```bash
   TYPE key
   ```
   - 示例：
   ```bash
   TYPE mykey
   ```

#### 2.12 **清空所有键：FLUSHDB 和 FLUSHALL**
   - `FLUSHDB`：清空当前数据库的所有键。
   ```bash
   FLUSHDB
   ```
   - `FLUSHALL`：清空 Redis 实例中所有数据库的键。
   ```bash
   FLUSHALL
   ```

### 3. **字符串操作**

Redis 的字符串类型是最基本的数据类型。每个键最多可以存储 512MB 的字符串数据。

#### 3.1 **基本字符串命令**

- **`SET`**：设置键的值。
  ```bash
  SET key value
  ```
  示例：
  ```bash
  SET name "Alice"
  ```

- **`GET`**：获取键的值。
  ```bash
  GET key
  ```
  示例：
  ```bash
  GET name
  ```

- **`APPEND`**：在现有字符串值的末尾追加值。
  ```bash
  APPEND key value
  ```
  示例：
  ```bash
  APPEND name " Johnson"  # 结果为 "Alice Johnson"
  ```

- **`STRLEN`**：获取字符串值的长度。
  ```bash
  STRLEN key
  ```
  示例：
  ```bash
  STRLEN name  # 返回值为 "Alice Johnson" 的字符长度
  ```

#### 3.2 **数值增减**

- **`INCR`**：将键的值加 1。
  ```bash
  INCR key
  ```
  示例：
  ```bash
  SET counter 100
  INCR counter  # counter 值变为 101
  ```

- **`INCRBY`**：将键的值增加指定的整数。
  ```bash
  INCRBY key increment
  ```
  示例：
  ```bash
  INCRBY counter 10  # counter 值变为 111
  ```

- **`DECR`**：将键的值减 1。
  ```bash
  DECR key
  ```

- **`DECRBY`**：将键的值减少指定的整数。
  ```bash
  DECRBY key decrement
  ```

#### 3.3 **获取和设置位值**

- **`SETBIT`**：将键对应值的某一位设置为 0 或 1。
  ```bash
  SETBIT key offset value
  ```
  - 示例：
    ```bash
    SETBIT mykey 7 1
    ```

- **`GETBIT`**：获取键对应值的某一位的值。
  ```bash
  GETBIT key offset
  ```

---

### 4. **哈希操作**

Redis 哈希类型（Hash）是一种键值对集合，适合存储对象的属性。

#### 4.1 **基本哈希命令**

- **`HSET`**：设置哈希表中的字段值。
  ```bash
  HSET key field value
  ```
  示例：
  ```bash
  HSET user:1000 name "Alice"
  ```

- **`HGET`**：获取哈希表中的字段值。
  ```bash
  HGET key field
  ```
  示例：
  ```bash
  HGET user:1000 name
  ```

- **`HDEL`**：删除哈希表中的一个或多个字段。
  ```bash
  HDEL key field [field ...]
  ```

#### 4.2 **批量操作**

- **`HMSET`**：同时设置多个字段值。
  ```bash
  HMSET key field1 value1 field2 value2
  ```
  示例：
  ```bash
  HMSET user:1000 name "Alice" age 30
  ```

- **`HMGET`**：获取多个字段的值。
  ```bash
  HMGET key field1 field2
  ```
  示例：
  ```bash
  HMGET user:1000 name age
  ```

- **`HGETALL`**：获取哈希表中所有字段和值。
  ```bash
  HGETALL key
  ```

#### 4.3 **其他哈希操作**

- **`HEXISTS`**：检查字段是否存在。
  ```bash
  HEXISTS key field
  ```

- **`HLEN`**：获取哈希表中的字段数量。
  ```bash
  HLEN key
  ```

- **`HINCRBY`**：将哈希表中的字段值加上指定整数。
  ```bash
  HINCRBY key field increment
  ```

---

### 5. **列表操作**

Redis 列表（List）是字符串的链表，可以左右两端操作。

#### 5.1 **列表基本操作**

- **`LPUSH`**：在列表头部添加一个或多个元素。
  ```bash
  LPUSH key value [value ...]
  ```
  示例：
  ```bash
  LPUSH tasks "task1" "task2"
  ```

- **`RPUSH`**：在列表尾部添加一个或多个元素。
  ```bash
  RPUSH key value [value ...]
  ```

- **`LPOP`**：移除并返回列表头部的元素。
  ```bash
  LPOP key
  ```

- **`RPOP`**：移除并返回列表尾部的元素。
  ```bash
  RPOP key
  ```

#### 5.2 **获取和查询列表**

- **`LRANGE`**：获取列表指定范围的元素。
  ```bash
  LRANGE key start stop
  ```
  示例：
  ```bash
  LRANGE tasks 0 -1  # 获取整个列表
  ```

- **`LLEN`**：获取列表的长度。
  ```bash
  LLEN key
  ```

---

### 6. **集合操作**

Redis 集合（Set）是无序字符串集合，不允许重复值。

#### 6.1 **基本集合操作**

- **`SADD`**：向集合添加一个或多个成员。
  ```bash
  SADD key member [member ...]
  ```
  示例：
  ```bash
  SADD myset "value1" "value2"
  ```

- **`SREM`**：移除集合中的一个或多个成员。
  ```bash
  SREM key member [member ...]
  ```

- **`SMEMBERS`**：获取集合中的所有成员。
  ```bash
  SMEMBERS key
  ```

- **`SISMEMBER`**：判断指定成员是否在集合中。
  ```bash
  SISMEMBER key member
  ```

#### 6.2 **集合运算**

- **`SINTER`**：求多个集合的交集。
  ```bash
  SINTER key1 key2
  ```

- **`SUNION`**：求多个集合的并集。
  ```bash
  SUNION key1 key2
  ```

- **`SDIFF`**：求多个集合的差集。
  ```bash
  SDIFF key1 key2
  ```

---

### 7. **有序集合操作**

Redis 有序集合（Sorted Set）是带有分数的集合，支持根据分数排序。

#### 7.1 **添加和移除成员**

- **`ZADD`**：向有序集合添加一个或多个成员及其分数。
  ```bash
  ZADD key score member [score member ...]
  ```
  示例：
  ```bash
  ZADD leaderboard 100 "player1" 200 "player2"
  ```

- **`ZREM`**：移除一个或多个成员。
  ```bash
  ZREM key member [member ...]
  ```

#### 7.2 **获取成员和分数**

- **`ZRANGE`**：根据索引范围获取成员（从低到高）。
  ```bash
  ZRANGE key start stop [WITHSCORES]
  ```
  示例：
  ```bash
  ZRANGE leaderboard 0 -1 WITHSCORES  # 获取全部成员和分数
  ```

- **`ZREVRANGE`**：根据索引范围获取成员（从高到低）。
  ```bash
  ZREVRANGE key start stop [WITHSCORES]
  ```

- **`ZSCORE`**：获取指定成员的分数。
  ```bash
  ZSCORE key member
  ```

#### 7.3 **排名和计数**

- **`ZRANK`**：获取成员的排名（从低到高）。
  ```bash
  ZRANK key member
  ```

- **`ZREVRANK`**：获取成员的排名（从高到低）。
  ```bash
  ZREVRANK key member
  ```

- **`ZCOUNT`**：统计指定分数范围内的成员数量。
  ```bash
  ZCOUNT key min max
  ```

### 8. **数据备份与恢复**

#### 8.1 **RDB 快照备份与恢复**

RDB（Redis Database Backup）文件是 Redis 在某个时间点的全量数据快照。Redis 会在指定的条件下自动生成 RDB 文件，也可以手动生成。RDB 文件默认保存在 Redis 数据目录下，文件名通常为 `dump.rdb`。

##### 8.1.1 **RDB 快照备份**

1. **手动生成快照**
   - 使用 `SAVE` 命令手动触发快照操作，会阻塞 Redis 服务，直到快照完成。
     ```bash
     SAVE
     ```
   
   - 使用 `BGSAVE` 命令在后台异步生成快照，不会阻塞客户端请求。
     ```bash
     BGSAVE
     ```

2. **自动生成快照**
   - 可以在 Redis 配置文件中设置自动生成快照的条件。
   - 配置项 `save` 表示在指定的秒数内有一定数量的写操作时生成快照。例如：
     ```conf
     save 900 1      # 15 分钟内有 1 次写操作
     save 300 10     # 5 分钟内有 10 次写操作
     save 60 10000   # 1 分钟内有 10000 次写操作
     ```
   - 配置完成后，Redis 会在满足条件时自动生成 `dump.rdb` 文件。

3. **备份 RDB 文件**
   - 只需将 `dump.rdb` 文件复制到安全的位置，即完成备份。

##### 8.1.2 **RDB 快照恢复**

1. **关闭 Redis 服务**
   - 在恢复数据之前，先停止 Redis 服务。
     ```bash
     sudo systemctl stop redis
     ```

2. **替换 RDB 文件**
   - 将备份的 `dump.rdb` 文件复制到 Redis 数据目录（通常为 `/var/lib/redis/`），替换原有的 `dump.rdb` 文件。

3. **重启 Redis 服务**
   - 启动 Redis 服务，Redis 会自动加载 `dump.rdb` 文件中的数据。
     ```bash
     sudo systemctl start redis
     ```

---

#### 8.2 **AOF 日志备份与恢复**

AOF（Append-Only File）是 Redis 的持久化日志文件，它记录每个写操作。AOF 可以实现更高的数据持久性，但文件较大且写入频繁。AOF 文件默认保存在 Redis 数据目录下，文件名通常为 `appendonly.aof`。

##### 8.2.1 **启用 AOF 持久化**

1. **修改配置文件**
   - 打开 Redis 配置文件 `redis.conf`，找到 `appendonly` 配置项，将其设置为 `yes` 启用 AOF。
     ```conf
     appendonly yes
     ```
   
2. **设置写入策略**
   - 配置 `appendfsync` 选项来控制 AOF 的写入策略：
     - `always`：每个写操作都立即写入 AOF（最安全，但性能较低）。
     - `everysec`：每秒写入一次（默认设置，适中）。
     - `no`：完全由操作系统决定何时写入（性能高，但有丢失数据风险）。
     ```conf
     appendfsync everysec
     ```

3. **重启 Redis**
   - 修改配置后，重启 Redis 以应用设置。
     ```bash
     sudo systemctl restart redis
     ```

##### 8.2.2 **AOF 日志恢复**

1. **关闭 Redis 服务**
   - 在恢复数据之前，停止 Redis 服务。
     ```bash
     sudo systemctl stop redis
     ```

2. **替换 AOF 文件**
   - 将备份的 `appendonly.aof` 文件复制到 Redis 数据目录，替换原有的 AOF 文件。

3. **重启 Redis 服务**
   - Redis 会自动加载 AOF 文件中的数据，恢复到日志中记录的最新状态。
     ```bash
     sudo systemctl start redis
     ```

##### 8.2.3 **AOF 文件重写**

AOF 文件在长时间运行后会变得非常大，可以通过 AOF 重写（rewrite）来压缩文件。

- **手动触发重写**
  ```bash
  BGREWRITEAOF
  ```
  Redis 会在后台生成新的 AOF 文件，其中只包含当前数据状态的写操作，从而缩小文件大小。

---

#### 8.3 **选择 RDB 和 AOF 的备份策略**

- **只使用 RDB**：适合数据安全性要求较低的场景，RDB 对内存要求小，备份速度快。
- **只使用 AOF**：适合需要较高持久性的场景，但文件较大，可能影响性能。
- **同时启用 RDB 和 AOF**：既可以获得 RDB 的快速恢复，也能保证较高的数据持久性，是较为稳妥的方案。

配置示例：
```conf
save 900 1
save 300 10
appendonly yes
appendfsync everysec
```

### 9. **安全与访问控制**

Redis 的安全控制主要通过密码认证和访问权限设置实现。

#### 9.1 **设置密码认证**

1. **配置文件设置密码**  
   编辑 Redis 配置文件（通常为 `redis.conf`），找到 `requirepass` 项，将其设置为所需的密码：
   ```conf
   requirepass your_password
   ```
   重启 Redis 服务使其生效。配置密码后，客户端需在连接时进行认证。

2. **通过命令行设置密码**
   - 如果不修改配置文件，可以直接在 Redis CLI 中设置密码（但重启后失效）：
     ```bash
     CONFIG SET requirepass "your_password"
     ```

3. **客户端认证**
   - 连接后使用 `AUTH` 命令进行认证：
     ```bash
     AUTH your_password
     ```

#### 9.2 **设置用户和权限（Redis 6 及以上版本）**

Redis 6 引入了 ACL（访问控制列表）功能，可以为不同用户设置不同的访问权限。

1. **创建用户**
   ```bash
   ACL SETUSER new_user on >password ~* +@all
   ```
   - `on`：启用用户。
   - `>password`：设置用户密码为password。
   - `~*`：允许访问所有键。
   - `+@all`：赋予所有命令权限。

2. **指定命令权限**
   - 可以限制用户使用的命令集。例如，仅允许读取数据：
     ```bash
     ACL SETUSER readonly_user on >password ~* +@read -@write
     ```

3. **查看用户权限**
   ```bash
   ACL LIST
   ```

---

### 10. **事务与流水线**

#### 10.1 **事务**

Redis 事务（Transaction）通过 `MULTI` 和 `EXEC` 命令实现，将一组命令打包在一起顺序执行。

1. **开始事务**
   ```bash
   MULTI
   ```

2. **添加命令**
   - 在 `MULTI` 后可以添加多个命令。
     ```bash
     SET key1 value1
     INCR counter
     ```

3. **提交事务**
   ```bash
   EXEC
   ```
   - 事务中所有命令将按顺序执行。
   - 如果需要取消事务，可以使用 `DISCARD`。

#### 10.2 **流水线**

Redis 支持批量发送命令，即**流水线**（Pipeline）。流水线可以减少客户端和服务器之间的网络往返时间，提高执行效率。

1. **使用 Redis CLI 管道**
   - 将多条命令按行写入管道，以节省网络往返。例如：
     ```bash
     (echo "SET key1 value1"; echo "INCR counter"; echo "GET key1") | redis-cli --pipe
     ```

2. **批量执行命令**
   - 常用的 Redis 客户端库通常支持流水线，将多个命令一起发送到服务器以减少延迟。

---

### 11. **脚本和 Lua 支持**

Redis 支持使用 Lua 脚本来执行复杂的操作，避免多次网络往返。

#### 11.1 **编写和执行 Lua 脚本**

1. **使用 `EVAL` 命令**
   - `EVAL` 命令可以在 Redis 中直接运行 Lua 脚本：
     ```bash
     EVAL "return redis.call('SET', KEYS[1], ARGV[1])" 1 mykey myvalue
     ```
   - `1` 表示一个键，`mykey` 是键名，`myvalue` 是键的值。

2. **脚本参数**
   - `KEYS` 数组用于传递键名，`ARGV` 数组用于传递参数值。例如：
     ```bash
     EVAL "return redis.call('SET', KEYS[1], ARGV[1])" 1 key_name "hello"
     ```

#### 11.2 **预存脚本**

1. **通过脚本哈希值执行脚本**
   - 使用 `SCRIPT LOAD` 将脚本存储到 Redis，并获取唯一的哈希值。
     ```bash
     SCRIPT LOAD "return redis.call('SET', KEYS[1], ARGV[1])"
     ```
   - 然后使用 `EVALSHA` 和该哈希值执行脚本，减少传输数据量：
     ```bash
     EVALSHA <hash_value> 1 key_name "value"
     ```

2. **常用 Lua 操作**
   - `redis.call`：执行 Redis 命令并返回结果。
   - `redis.pcall`：执行命令并捕获错误。

---

### 12. **发布与订阅**

发布与订阅（Pub/Sub）是一种消息传递模式，用于在 Redis 中的客户端之间分发消息。

#### 12.1 **发布消息**

- `PUBLISH` 命令用于向指定频道发布消息：
  ```bash
  PUBLISH channel_name "message_content"
  ```

#### 12.2 **订阅频道**

- `SUBSCRIBE` 命令用于订阅指定频道，客户端会收到该频道的所有消息：
  ```bash
  SUBSCRIBE channel_name
  ```

#### 12.3 **模式匹配订阅**

- `PSUBSCRIBE` 命令支持按模式订阅频道。例如，订阅所有以 `news.` 开头的频道：
  ```bash
  PSUBSCRIBE news.*
  ```

#### 12.4 **取消订阅**

- `UNSUBSCRIBE` 和 `PUNSUBSCRIBE` 命令可以用于取消订阅。

---

### 13. **监控与调试命令**

Redis 提供了丰富的命令来监控和调试服务的状态。

#### 13.1 **常用监控命令**

1. **`INFO`**：查看 Redis 服务器状态信息。
   ```bash
   INFO
   ```
   - 可以带参数来获取某个模块的状态，例如 `INFO memory`。

2. **`MONITOR`**：实时监控所有客户端请求（调试用）。
   ```bash
   MONITOR
   ```

3. **`CLIENT LIST`**：查看当前连接的客户端信息。
   ```bash
   CLIENT LIST
   ```

4. **`SLOWLOG`**：查看慢日志，分析执行缓慢的命令。
   - 查看最近 10 条慢查询：
     ```bash
     SLOWLOG GET 10
     ```
   - 清除慢查询日志：
     ```bash
     SLOWLOG RESET
     ```

#### 13.2 **性能调优**

1. **`CONFIG GET` / `CONFIG SET`**：动态查看和修改 Redis 配置参数。
   ```bash
   CONFIG GET maxmemory
   CONFIG SET maxmemory 512mb
   ```

2. **`DEBUG OBJECT`**：查看某个键的底层信息，包括其内部编码。
   ```bash
   DEBUG OBJECT key
   ```

3. **`MEMORY USAGE`**：查看指定键的内存使用情况。
   ```bash
   MEMORY USAGE key
   ```

#### 13.3 **键空间通知**

Redis 支持键空间通知，可以监控键的变动。要启用通知：

1. **配置键空间通知**
   - 在 `redis.conf` 中启用通知：
     ```conf
     notify-keyspace-events Ex
     ```

2. **订阅通知频道**
   - 使用 `PSUBSCRIBE` 订阅键空间通知频道：
     ```bash
     PSUBSCRIBE __keyevent@0__:expired
     ```

好的，下面是 **RediSearch** 和 **RedisJSON** 模块的使用方法，不包括安装步骤，只包含如何在 Redis 中使用这些模块的功能。

---

### 14. **RediSearch 使用方法**

#### 14.1 **创建索引**

使用 `FT.CREATE` 命令创建一个索引，定义字段和字段类型：

```bash
FT.CREATE myindex ON HASH PREFIX 1 doc: SCHEMA name TEXT WEIGHT 5.0 age NUMERIC
```

- `myindex`：索引名称。
- `doc:`：索引的目标是以 `doc:` 为前缀的哈希类型键。
- `name`：文本字段，使用 `TEXT` 类型。
- `age`：数值字段，使用 `NUMERIC` 类型。
- `WEIGHT 5.0`：指定字段的权重，用于全文搜索的排序。

#### 14.2 **添加文档**

使用 `HSET` 命令添加文档数据到索引：

```bash
HSET doc:1 name "Alice" age 30
HSET doc:2 name "Bob" age 25
```

#### 14.3 **执行搜索**

使用 `FT.SEARCH` 命令搜索文档：

```bash
FT.SEARCH myindex "@name:Alice"
```

该命令会在 `myindex` 索引中查找 `name` 字段值为 "Alice" 的所有文档。

#### 14.4 **排序和分页**

使用 `SORTBY` 对搜索结果进行排序，使用 `LIMIT` 进行分页：

```bash
FT.SEARCH myindex "*" SORTBY age ASC LIMIT 0 10
```

- `SORTBY age ASC`：按 `age` 字段升序排序。
- `LIMIT 0 10`：返回前 10 条记录。

#### 14.5 **聚合**

使用 `FT.AGGREGATE` 执行聚合操作，例如按 `age` 字段聚合并计算平均值：

```bash
FT.AGGREGATE myindex * GROUPBY 1 @age REDUCE AVG @age AS avg_age
```

该命令会按 `age` 字段进行分组并计算平均值。

#### 14.6 **删除索引**

使用 `FT.DROPINDEX` 删除索引：

```bash
FT.DROPINDEX myindex
```

---

### 15. **RedisJSON 使用方法**

#### 15.1 **存储 JSON 数据**

使用 `JSON.SET` 命令将 JSON 数据存储到 Redis 中：

```bash
JSON.SET user:1 $ '{"name": "Alice", "age": 30, "address": {"city": "New York", "zip": "10001"}}'
```

该命令将 JSON 数据存储在 `user:1` 键下，数据包含 `name`、`age` 和 `address` 字段。

#### 15.2 **读取 JSON 数据**

使用 `JSON.GET` 命令读取 JSON 数据：

```bash
JSON.GET user:1 $
```

该命令返回存储在 `user:1` 键下的完整 JSON 数据。

#### 15.3 **获取 JSON 数据的特定字段**

可以通过路径选择器来获取 JSON 对象中的某个字段：

```bash
JSON.GET user:1 $.name
```

该命令返回 `user:1` 键下 JSON 对象的 `name` 字段。

#### 15.4 **更新 JSON 数据**

使用 `JSON.SET` 来更新 JSON 对象的字段。例如，更新 `age` 字段：

```bash
JSON.SET user:1 $ '{"age": 31}'
```

该命令将 `user:1` 键下 JSON 对象的 `age` 字段更新为 `31`。

#### 15.5 **添加数组元素**

使用 `JSON.ARRAPPEND` 向 JSON 数组中添加元素：

```bash
JSON.SET user:1 $ '{"friends": []}'
JSON.ARRAPPEND user:1 $.friends '"Bob"' '"Charlie"'
```

该命令将 `"Bob"` 和 `"Charlie"` 添加到 `user:1` 键下的 `friends` 数组中。

#### 15.6 **删除 JSON 字段**

使用 `JSON.DEL` 删除 JSON 数据中的某个字段：

```bash
JSON.DEL user:1 $.address.zip
```

该命令删除 `user:1` 键下 JSON 对象中的 `address.zip` 字段。

#### 15.7 **查询 JSON 数据**

结合 **RediSearch**，可以对 JSON 数据执行复杂的查询。首先，创建一个索引：

```bash
FT.CREATE jsonindex ON JSON PREFIX 1 user: SCHEMA $.name TEXT $.age NUMERIC
```

然后使用 `FT.SEARCH` 对 JSON 数据进行搜索：

```bash
FT.SEARCH jsonindex "@name:Alice"
```

#### 15.8 **数组操作**

RedisJSON 提供对数组的支持。使用 `JSON.ARRINDEX` 查找数组元素的索引：

```bash
JSON.ARRINDEX user:1 $.friends '"Bob"'
```

#### 15.9 **整数和浮动数值操作**

RedisJSON 支持对整数和浮动数值字段进行操作。可以使用 `JSON.NUMINCRBY` 来增加数值字段：

```bash
JSON.NUMINCRBY user:1 $.age 1
```

该命令将 `user:1` 键下 `age` 字段的值增加 1。

