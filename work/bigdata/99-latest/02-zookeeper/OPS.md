# Zookeeper使用文档



**进入客户端**

```
zkCli.sh -server bigdata01:2181
```

**创建节点**

```bash
create /path data
```

**查看节点数据**

```bash
get /path
```

**列出子节点**

```bash
ls /path
```

**更新节点数据**

```bash
set /path data
```

**删除节点**

```bash
delete /path
```

**检查节点是否存在**

```bash
stat /path
```

**递归删除节点**

```bash
deleteall /path
```

**监听节点数据变化**

```bash
get /path -w
```

**监听子节点变化**

```bash
ls /path -w
```

**退出客户端**

```bash
quit
```