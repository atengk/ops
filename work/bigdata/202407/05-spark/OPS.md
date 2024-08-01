# Spark运维



## Spark on YARN 动态资源配置

拷贝依赖包到所有yarn节点上

```
cp $SPARK_HOME/yarn/spark-3.5.0-yarn-shuffle.jar $HADOOP_HOME/share/hadoop/yarn/
```

yarn-site.xml修改配置

> 修改yarn.nodemanager.aux-services配置
>
> 新增yarn.nodemanager.aux-services.spark_shuffle.class配置

```
$ vi $HADOOP_HOME/etc/hadoop/yarn-site.xml
<configuration>
    ...
    <!-- Spark on YARN动态资源配置-->
    <property>
        <name>yarn.nodemanager.aux-services</name>
        <value>spark_shuffle,mapreduce_shuffle</value>
    </property>
    <property>
        <name>yarn.nodemanager.aux-services.spark_shuffle.class</name>
        <value>org.apache.spark.network.yarn.YarnShuffleService</value>
    </property>
</configuration>
```

重启集群所有NodeManager

```

```

配置spark-defaults.conf

```
$ vi $SPARK_HOME/conf/spark-defaults.conf
...
## 开启动态资源以及申请的Executors数最值
spark.shuffle.service.enabled           true
spark.shuffle.service.port              7337
spark.shuffle.service.removeShuffle     true
spark.dynamicAllocation.enabled         true
spark.dynamicAllocation.initExectors    2
spark.dynamicAllocation.minExecutors    2
spark.dynamicAllocation.maxExecutors    30
```

启动spark任务

```
spark-submit --master yarn \
    --class org.apache.spark.examples.SparkPi \
    --deploy-mode cluster \
    $SPARK_HOME/examples/jars/spark-examples_2.12-3.5.0.jar 10000
```

