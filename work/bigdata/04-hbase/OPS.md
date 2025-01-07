# HBase使用文档

## 1. **连接 HBase Shell**

启动 HBase Shell 的命令：

```bash
hbase shell
```

## 2. **表管理命令**

### 2.1 创建表

使用 `create` 命令创建一个表。指定表名和列族，列族名可以根据需求设置多个。

```bash
create 'my_table', 'column_family1', 'column_family2'
```

- `my_table`：表名
- `column_family1`, `column_family2`：列族名，列族是HBase中对数据进行组织的基本单元。

### 2.2 查看表信息

使用 `describe` 命令查看指定表的结构。

```bash
describe 'my_table'
```

### 2.3 删除表

删除表前需要先禁用该表。

```bash
disable 'my_table'
drop 'my_table'
```

- `disable` 命令禁用表，之后才能删除表。
- `drop` 命令删除表。

### 2.4 查看所有表

查看当前 HBase 集群中的所有表。

```bash
list
```

### 2.5 查看表的详细信息

查看一个表的列族信息等详细信息。

```bash
describe 'my_table'
```

### 2.6 启用表

如果表被禁用，可以使用 `enable` 命令启用它。

```bash
enable 'my_table'
```

------

## 3. **数据操作命令**

### 3.1 插入数据

`put` 命令用于插入或更新单元格数据。

```bash
put 'my_table', 'row1', 'column_family1:column1', 'value1'
```

- `my_table`：表名
- `row1`：行键（Row Key）
- `column_family1:column1`：列族和列名
- `value1`：插入的值

可以为一个行键插入多个列数据：

```bash
put 'my_table', 'row1', 'column_family1:column1', 'value1'
put 'my_table', 'row1', 'column_family2:column2', 'value2'
```

### 3.2 查询数据

`get` 命令用于读取表中某一行的数据。

```bash
get 'my_table', 'row1'
```

可以指定列族和列来只查询部分数据：

```bash
get 'my_table', 'row1', 'column_family1:column1'
```

### 3.3 扫描数据

`scan` 命令用于扫描整个表，或者根据条件扫描指定范围的数据。

```bash
scan 'my_table'
```

你也可以使用 `LIMIT` 限制扫描结果的条目数：

```bash
scan 'my_table', {LIMIT => 5}
```

可以设置更多的筛选条件（如过滤器）：

```bash
scan 'my_table', {FILTER => "ValueFilter(=,'binary:some_value')"}
```

### 3.4 删除数据

使用 `delete` 命令删除指定行的数据。

```bash
delete 'my_table', 'row1', 'column_family1:column1'
```

删除整行数据（删除该行的所有列）：

```bash
deleteall 'my_table', 'row1'
```

### 3.5 更新数据

可以通过再次使用 `put` 命令来更新已有数据。HBase 会根据行键和列族/列名覆盖旧值。

```bash
put 'my_table', 'row1', 'column_family1:column1', 'new_value'
```

## 4. 导出数据

### 4.1 导出到 HDFS

可以使用 `hbase org.apache.hadoop.hbase.mapreduce.Export` 命令将 HBase 表的数据导出到 HDFS。

**命令**：

```bash
$ hbase org.apache.hadoop.hbase.mapreduce.Export 'default:ateng' '/data/hbase/ateng'
```

**检查导出结果**：

```bash
$ hadoop fs -ls /data/hbase/ateng
Found 2 items
-rw-r--r--   1 admin ateng          0 2024-12-24 11:30 /data/hbase/ateng/_SUCCESS
-rw-r--r--   1 admin ateng        174 2024-12-24 11:30 /data/hbase/ateng/part-m-00000
```

导出过程中会生成两个文件：

- **`_SUCCESS`**：表示导出任务成功。
- **`part-m-00000`**：实际导出的数据文件。

------

### 4.2 导出到本地文件系统

如果需要将数据导出到本地文件系统，可以使用 `file://` 前缀指定本地路径。

**命令**：

```bash
$ hbase org.apache.hadoop.hbase.mapreduce.Export 'default:ateng' 'file:///tmp/hbase/ateng'
```

**检查导出结果**：

```bash
$ ll /tmp/hbase/ateng
total 4
-rw-r--r-- 1 admin ateng 174 Dec 24 11:31 part-m-00000
-rw-r--r-- 1 admin ateng   0 Dec 24 11:31 _SUCCESS
```

导出到本地时，生成的文件与 HDFS 导出的文件类似，也包括 **`_SUCCESS`** 和 **`part-m-00000`** 文件。

------

## 5. 导入数据

### 5.1 从本地导入数据到 HBase

可以使用 HBase 的 `Import` 工具将本地文件的数据导入到 HBase 表中。

**步骤 1**：在 HBase shell 中创建目标表。

```bash
$ hbase shell
hbase:001:0> create 'ateng2', 'info'
```

**步骤 2**：使用 `Import` 命令将本地数据导入到 HBase 表中。

```bash
$ hbase org.apache.hadoop.hbase.mapreduce.Import 'default:ateng2' 'file:///tmp/hbase/ateng'
```

**步骤 3**：使用 `scan` 命令验证数据是否成功导入。

```bash
$ hbase shell
hbase:002:0> scan 'ateng2', {FORMATTER => 'toString'}
ROW                                         COLUMN+CELL
 row1                                       column=info:name, timestamp=2024-12-24T11:30:20.076, value=阿腾
1 row(s)
Took 0.0193 seconds
```

通过 `scan` 命令，可以验证数据是否已经成功导入到表 `ateng2` 中。

