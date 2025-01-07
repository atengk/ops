# Hadoop使用文档

## HDFS 使用命令

### 文件操作

```bash
# 上传文件到 HDFS
hdfs dfs -put <本地路径> <HDFS路径>
# 示例:
hdfs dfs -put file.txt /user/admin/

# 从 HDFS 下载文件
hdfs dfs -get <HDFS路径> <本地路径>
# 示例:
hdfs dfs -get /user/admin/file.txt ./

# 追加内容到 HDFS 文件
hdfs dfs -appendToFile <本地文件> <HDFS文件>
# 示例:
hdfs dfs -appendToFile log.txt /user/admin/logs.txt

# 查看文件内容
hdfs dfs -cat <HDFS路径>
# 示例:
hdfs dfs -cat /user/admin/file.txt

# 删除文件或目录
hdfs dfs -rm [-r] <路径>
# 示例:
hdfs dfs -rm -r /user/admin/dir/
```

### 目录操作

```bash
# 创建目录
hdfs dfs -mkdir [-p] <路径>
# 示例:
hdfs dfs -mkdir -p /user/admin/input/

# 列出目录和文件
hdfs dfs -ls [-R] <路径>
# 示例:
hdfs dfs -ls /user/admin/

# 移动文件或目录
hdfs dfs -mv <源路径> <目标路径>
# 示例:
hdfs dfs -mv /user/admin/old /user/admin/new
```

### 文件统计信息

```bash
# 查看文件大小统计
hdfs dfs -du [-s] [-h] <路径>
# 示例:
hdfs dfs -du -h /user/admin/

# 校验文件的校验和
hdfs dfs -checksum <路径>
# 示例:
hdfs dfs -checksum /user/admin/file.txt
```

### 集群和健康检查

```bash
# 查看文件系统报告
hdfs dfsadmin -report

# 查看 HDFS 安全模式状态
hdfs dfsadmin -safemode get

# 进入安全模式
hdfs dfsadmin -safemode enter

# 退出安全模式
hdfs dfsadmin -safemode leave
```

------

## YARN 使用命令

### 应用管理

```bash
# 提交应用程序
yarn jar <JAR文件> <主类> [参数...]
# 示例:
yarn jar my-app.jar com.example.Main input output

# 列出正在运行的应用程序
yarn application -list

# 查看应用程序状态
yarn application -status <ApplicationID>
# 示例:
yarn application -status application_1671234567890_0001

# 杀死应用程序
yarn application -kill <ApplicationID>
# 示例:
yarn application -kill application_1671234567890_0001
```

### 节点管理

```bash
# 列出节点状态
yarn node -list
# 示例:
yarn node -list -all

# 查看节点详细信息
yarn node -status <NodeID>
# 示例:
yarn node -status node123:8041
```

### 队列管理

```bash
# 列出调度器队列
yarn queue -list

# 查看特定队列状态
yarn queue -status <队列名称>
# 示例:
yarn queue -status default
```

### 日志查看

```bash
# 查看应用程序日志
yarn logs -applicationId <ApplicationID>
# 示例:
yarn logs -applicationId application_1671234567890_0001

# 查看特定容器日志
yarn logs -applicationId <ApplicationID> -containerId <ContainerID>
# 示例:
yarn logs -applicationId application_1671234567890_0001 -containerId container_1671234567890_0001_01_000001
```

### 集群管理

```bash
# 重启 ResourceManager
yarn resourcemanager

# 重启 NodeManager
yarn nodemanager

# 查看集群状态
# ResourceManager WebUI 默认地址:
# http://<ResourceManager主机>:8088
```

