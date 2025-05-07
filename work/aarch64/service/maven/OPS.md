# 使用Maven



## 项目构建相关命令

### 清理项目

删除 `target/` 目录，清除编译生成的文件。

```
mvn clean
```

### 编译项目

编译 `src/main/java` 目录下的 Java 源文件。

```
mvn compile
```

### 打包项目

```
mvn clean package -DskipTests
```



## 多模块项目命令

### 编译所有子模块

适用于父 POM 管理的多模块项目，会递归编译所有子模块。

```
mvn compile
```

### 指定模块执行

只编译指定模块，并编译其依赖模块。

```
mvn clean install -pl spring-cloud-dubbo-provider -am
```

子模块的子模块使用以下命令

```
mvn clean install -pl distributed/spring-cloud-dubbo-provider -am
```



## 依赖下载

### 指定临时仓库

该场景可以将依赖下载到地址路径，然后复制到其他离线环境下就可以直接使用

```
mvn clean package -DskipTests -Dmaven.repo.local=./repo
```



### 下载Jar

该命令会将所有依赖下载到 `lib/` 目录。

```
mvn dependency:copy-dependencies -DoutputDirectory=lib
```

如果你想包含 **运行时（runtime）** 依赖，可以使用：

```
mvn dependency:copy-dependencies -DoutputDirectory=lib -DincludeScope=runtime
```

如果你想包含 **provided** 依赖，可以使用：

```
mvn dependency:copy-dependencies -DoutputDirectory=lib -DincludeScope=provided
```

