# OpenJDK使用文档

OpenJDK（Open Java Development Kit）是Java平台的开源实现，包含了Java虚拟机（JVM）、核心类库、编译器（javac）以及其他开发工具。作为Java的参考实现，OpenJDK遵循GNU通用公共许可证（GPL），是完全开放的，允许任何人查看、修改和分发其源代码。它与Oracle JDK兼容，广泛用于开发和部署Java应用程序，支持跨平台运行。OpenJDK不仅提供了稳定的Java开发环境，还具有活跃的社区和持续的更新，保障了其安全性和性能优化。

OpenJDK是Java生态系统的重要组成部分，广泛应用于服务器、桌面、嵌入式系统等多种场景。

- [官方文档地址](https://openjdk.java.net/)



## 启动应用程序

### 常规启动

**直接启动**

```
java -jar springboot3-demo-v1.0.jar
```

**设置堆内存参数**

```
java -server -Xms1024m -Xmx1024m -jar springboot3-demo-v1.0.jar
```

- `-server`: 以服务器模式启动 JVM，优化长期运行性能，适合生产环境。
- `-Xms1024m`: 设置 JVM 初始堆内存为 1024MB（1GB），避免频繁扩容带来的性能损耗。
- `-Xmx1024m`: 设置 JVM 最大堆内存为 1024MB（1GB），限制内存上限，防止占用过多系统资源。

### 设置参数和配置文件

**设置运行参数**

通过 `-D` JVM 系统属性，放在 `java` 命令中，用于传递系统级配置或 Spring 变量

```
java -Dspring.profiles.active=prod -Dserver.port=8081 -jar springboot3-demo-v1.0.jar
```

通过命令行参数，直接在 `java -jar` 后面添加 `--key=value` 的形式

```
java -jar springboot3-demo-v1.0.jar --server.port=8081 --spring.profiles.active=prod
```

**设置运行配置文件**

指定配置文件的**位置**，可以是**目录**或**具体的配置文件**，如果是目录，其目录下的配置文件命名需要和Spring规范保持一致

- `--spring.config.location`: 用于指定配置文件的**位置**
- `--spring.config.additional-location`: 用于指定**额外的配置文件位置**

指定配置文件

```
java -jar springboot3-demo-v1.0.jar --spring.config.location=file:/opt/app/application.yml
```

指定目录

```
/opt/app/
├── application-prod.yml
└── application.yml

java -jar springboot3-demo-v1.0.jar --spring.config.location=file:/opt/app/
```

### 添加lib

**通过 `-classpath` 或 `-cp` 参数**

通过 `java` 命令的 `-classpath` 或 `-cp` 参数指定额外的 JAR 文件

```
java -cp "springboot3-demo-v1.0.jar:/opt/app/lib/*"  local.ateng.java.banner.SpringBoot3BannerApplication
```

- `-cp` 或 `-classpath`：用来指定类路径，`app.jar` 是你的 Spring Boot 应用包，`/path/to/extra/lib/*` 是你要添加的额外 JAR 库路径。

- `/*` 表示路径下所有的 JAR 文件。



## `jps` 常用命令

### 1. **基本命令**

```bash
jps
```

- **功能**：显示当前系统上所有的 Java 进程及其相关信息。
- **输出**：列出进程的 PID 和类名（或 JAR 文件）。

**示例输出**：

```bash
12345 org.springframework.boot.loader.JarLauncher
67890 org.apache.catalina.startup.Bootstrap
```

### 2. **显示更多信息**

```bash
jps -l
```

- **功能**：显示更详细的信息，通常会显示 Java 应用程序的类名或 JAR 文件路径。
- **输出**：除了 PID 和类名，还会显示完整的类路径或 JAR 文件的完整路径。

**示例输出**：

```bash
12345 /path/to/springboot3-demo-v1.0.jar
67890 /opt/tomcat/bin/bootstrap.jar
```

### 3. **显示进程的 JVM 参数**

```bash
jps -v
```

- **功能**：显示每个 Java 进程的 JVM 参数（如堆大小、GC 参数等）。
- **输出**：PID、类名（或 JAR 文件路径），以及与该进程相关的 JVM 启动参数。

**示例输出**：

```bash
12345 org.springframework.boot.loader.JarLauncher -Xms512m -Xmx1024m
67890 org.apache.catalina.startup.Bootstrap -Duser.timezone=UTC
```

### 4. **显示进程的线程信息**

```bash
jps -m
```

- **功能**：显示启动时传递给 `main` 方法的参数（即 `main(String[] args)` 中的参数）。
- **输出**：PID、类名，并显示传递给 `main` 方法的参数。

**示例输出**：

```bash
12345 org.springframework.boot.loader.JarLauncher --server.port=8080
67890 org.apache.catalina.startup.Bootstrap --config /etc/tomcat/server.xml
```

### 5. **显示所有信息（PID、类名、JVM 参数、启动参数）**

```bash
jps -lvm
```

- **功能**：组合 `-l`（显示类路径/文件路径）、`-v`（显示 JVM 参数）、`-m`（显示启动时传递给 main 方法的参数），展示最详细的信息。

**示例输出**：

```bash
12345 /path/to/springboot3-demo-v1.0.jar -Xms512m -Xmx1024m --server.port=8080
67890 /opt/tomcat/bin/bootstrap.jar -Duser.timezone=UTC --config /etc/tomcat/server.xml
```

### 6. **查找特定的 Java 进程**

```bash
jps -l | grep <process_name_or_keyword>
```

- **功能**：通过 `grep` 过滤，找到指定关键字或进程名的 Java 进程。

- **示例**：如果你想查找与 `springboot3-demo-v1.0.jar` 相关的进程：

    ```bash
    jps -l | grep springboot3-demo-v1.0.jar
    ```

------

### `jps` 输出解析：

1. **PID**（进程 ID）：每个正在运行的 Java 进程的唯一标识符。
2. **类名** 或 **JAR 文件路径**：Java 进程正在运行的类或 JAR 文件。
3. **JVM 参数**：如堆大小 (`-Xms`, `-Xmx`)、垃圾回收策略、系统属性等。
4. **`main` 方法的参数**：传递给 `main` 方法的启动参数。

