# Hive on Tez 配置指南

本文档提供了将 Hive 配置为使用 Tez 作为执行引擎的详细步骤。按照以下步骤下载、配置和验证你的 Hive on Tez 设置。

## 前提条件

确保你已经具备以下条件：

- 已安装并配置好的 Hive。
- 已安装并配置好的 Hadoop。
- 修改 Hive 配置文件和重启服务的足够权限。

## 步骤 1: 下载并解压 Tez

1. 下载 Tez 二进制包：

    ```bash
    wget https://dlcdn.apache.org/tez/0.10.2/apache-tez-0.10.2-bin.tar.gz
    ```

2. 解压 Tez 二进制包：

    ```bash
    tar -zxf apache-tez-0.10.2-bin.tar.gz -C /usr/local/software/
    ln -s /usr/local/software/apache-tez-0.10.2-bin /usr/local/software/tez
    ```
    
3. 将 Tez JAR 文件复制到 Hive 的库目录：

    ```bash
    cp /usr/local/software/tez/tez-*.jar $HIVE_HOME/lib
    ```

4. 将 Tez 包上传到 HDFS：

    ```bash
    hadoop fs -put /usr/local/software/tez/share/tez.tar.gz /hive
    ```

## 步骤 2: 配置 Tez

1. 在 Hive 配置目录中创建或更新 `tez-site.xml` 配置文件：

    ```bash
    cat > $HIVE_HOME/conf/tez-site.xml <<"EOF"
    <?xml version="1.0" encoding="UTF-8"?>
    <configuration>
        <!-- HDFS 上 Tez 包的路径 -->
        <property>
            <name>tez.lib.uris</name>
            <value>${fs.defaultFS}/hive/tez.tar.gz</value>
        </property>
        <!-- 使用集群的 Hadoop 库 -->
        <property>
            <name>tez.use.cluster.hadoop-libs</name>
            <value>true</value>
        </property>
    </configuration>
    EOF
    ```

## 步骤 3: 配置 Hive 使用 Tez

1. 在 Hive 配置目录中添加或更新 `hive-site.xml` 配置文件中的以下属性：

    ```bash
    $ vi $HIVE_HOME/conf/hive-site.xml
    <configuration>
       ...
        <!-- 执行引擎使用Tez -->
        <property>
            <name>hive.execution.engine</name>
            <value>tez</value>
        </property>
    </configuration>
    ```

## 步骤 4: 重启 Hive 服务

1. 重启 Hive 服务以应用新配置：

    ```bash
    sudo systemctl restart hive-*
    ```

## 步骤 5: 验证配置

1. 使用 Beeline 连接到 Hive：

    ```bash
    beeline -u jdbc:hive2://bigdata01:10000 -n admin
    ```

2. 执行一个示例查询以确保 Tez 被用作执行引擎：

    ```sql
    SELECT count(*) FROM my_table;
    ```

按照这些步骤，你应该已经成功配置了 Hive 以使用 Tez 作为其执行引擎。
