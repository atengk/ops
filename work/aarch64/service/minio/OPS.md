# MinIO使用文档

## 添加服务器

**添加服务器配置**

mcli config host add <主机名> <服务器地址> <用户名> <密码> --api s3v4

```
mcli config host add minio http://192.168.1.201:9000 admin Admin@123 --api s3v4
```

**配置别名**

也可以通过添加服别名的方式配置服务器

mcli alias set <主机名> <服务器地址> <用户名> <密码>

```
mcli alias set myminio http://minio-server:9000 YOUR-ACCESS-KEY YOUR-SECRET-KEY
```

**查看服务器信息**

mcli admin info <ALIAS>

```
mcli admin info minio
```

## 桶操作

**创建**

```
mcli mb myminio/mybucket
```

**列出**

```
mcli ls myminio
```

**设置权限**

公共读权限

```
mcli anonymous set download myminio/mybucket
```

公共读写权限

```
mcli anonymous set public myminio/mybucket
```

**查看权限**

```
mcli anonymous list myminio/mybucket
```

**删除**

删除一个空桶

```
mcli rb myminio/mybucket
```

递归删除（非空桶）

```
mcli rb --force myminio/mybucket
```

## 对象操作

### 上传

**上传本地目录**

```
mcli cp -r /path/to/localfile myminio/mybucket
```

- --limit-upload 512KiB 限制上传速率为 512 KiB/s
- --limit-download 1MiB 限制下载速率为 1 MiB/s

### **列出**

**列出桶的对象**

```
mcli ls myminio/mybucket
```

**计算对象大小**

```
mcli du myminio/mybucket/kongyu
```

### **下载**

```
mcli cp -r myminio/mybucket/remoteobject /path/to/localdir
```

### **镜像**

```
mcli mirror /path/to/local/directory myminio/mybucket/
```

**从桶到本地目录的镜像**

```
mcli mirror myminio/mybucket/ /path/to/local/directory
```

**桶与桶之间的镜像**

```
mcli mirror myminio/sourcebucket/ myminio/destinationbucket/
```

 **使用 `--remove` 选项**

同步并删除目标中多余的文件

```
mcli mirror myminio/sourcebucket/ myminio/destinationbucket/ --remove
```

**使用 `--force` 选项**

强制覆盖目标中的文件

```
mcli mirror myminio/sourcebucket/ myminio/destinationbucket/ --force
```

**持续监视源目录**

监视源目录并自动同步更改

```
mcli mirror /path/to/local/directory myminio/mybucket/ --watch
```

### **过滤**

使用 `--include` 选项可以指定要包含的文件：

```
mcli cp --recursive --include "*.jpg" myminio/mybucket/ /path/to/local/
```

使用 `--exclude` 选项可以指定要排除的文件：

```
mcli cp --recursive --exclude "*.tmp" myminio/mybucket/ /path/to/local/
```

### **删除**

```
mc rm -r --force myminio/mybucket/somedir
```

## 对象生命周期

**添加规则**

指定对象在存储 30 天后过期（即删除）

```
mcli ilm add --expiry-days 30 myminio/test/mysql
```

**列出当前规则**

```
mcli ilm ls myminio/test
```

**删除规则**

删除特定的生命周期规则

```
mcli ilm rm --id csj4hpqgsphvvf0jjugg myminio/test
```

删除所有生命周期规则

```
mcli ilm rm --all --force myminio/test
```

