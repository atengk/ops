

前提条件：将spark配置为spark on yarn模式

```
rm $HIVE_HOME/lib/spark-*
cp $SPARK_HOME/jars/spark-* $HIVE_HOME/lib/

$ vi $HIVE_HOME/conf/hive-site.xml
<property>
  <name>hive.execution.engine</name>
  <value>spark</value>
</property>
<property>
  <name>spark.master</name>
  <value>yarn</value>
</property>


hive
SELECT count(*) FROM my_table;
```

插入数据

```
INSERT INTO my_table VALUES
    (1, 'John'),
    (2, 'Jane'),
    (3, 'Bob'),
    (4, 'Alice');
```

