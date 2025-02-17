# OpenJDK使用文档

OpenJDK（Open Java Development Kit）是Java平台的开源实现，包含了Java虚拟机（JVM）、核心类库、编译器（javac）以及其他开发工具。作为Java的参考实现，OpenJDK遵循GNU通用公共许可证（GPL），是完全开放的，允许任何人查看、修改和分发其源代码。它与Oracle JDK兼容，广泛用于开发和部署Java应用程序，支持跨平台运行。OpenJDK不仅提供了稳定的Java开发环境，还具有活跃的社区和持续的更新，保障了其安全性和性能优化。

OpenJDK是Java生态系统的重要组成部分，广泛应用于服务器、桌面、嵌入式系统等多种场景。

- [官方文档地址](https://openjdk.java.net/)

## 常用参数

这些参数是最常见的，几乎每次运行Java程序时都会用到，或者至少需要了解。

`-version` 用于显示当前Java版本，适用于检查当前环境的JDK版本。
 例如：

```bash
java -version
```

`-help` 用于显示帮助信息，列出所有`java`命令的可用选项。
 例如：

```bash
java -help
```

`-D<property>=<value>` 设置系统属性。例如，可以通过这个选项设置应用程序的配置项。
 例如：

```bash
java -Dfile.encoding=UTF-8 -jar myapp.jar
```

`-Xmx<size>` 设置JVM堆内存的最大值。例如，将最大堆内存设置为1GB。
 例如：

```bash
java -Xmx1024m MyClass
```

`-Xms<size>` 设置JVM堆内存的初始值。例如，设置初始堆内存为512MB。
 例如：

```bash
java -Xms512m MyClass
```

`-ea (或 -enableassertions)` 启用断言功能，在开发调试时非常有用。
 例如：

```bash
java -ea MyClass
```

`-da (或 -disableassertions)` 禁用断言功能，生产环境中通常会禁用。
 例如：

```bash
java -da MyClass
```

## JAR 文件运行

`-jar` 选项用于指定并运行一个JAR包。这个选项允许你直接通过`java`命令执行打包好的Java应用。

`-jar <jar-file>` 用于运行一个JAR文件。JAR文件需要包含一个`META-INF/MANIFEST.MF`文件，其中指定了入口主类（`Main-Class`）。
 例如：

```bash
java -jar myapp.jar
```

`-D<property>=<value>`（与JAR文件一起使用）设置系统属性。例如，你可以传递配置项或环境变量。
 例如：

```bash
java -Dconfig.file=application.properties -jar myapp.jar
```

## 引用依赖

如果你有一个JAR文件并且有一些依赖库在`./lib/`目录下，通常你会想通过`java`命令将这些依赖库包含到类路径中，以确保JVM能够正确地找到并加载这些库。

假设你有以下文件结构：

```
/path/to/yourapp/
  ├── myapp.jar           # 你的主应用程序JAR文件
  ├── lib/                # 存放依赖库的目录
      ├── lib1.jar        # 依赖库1
      ├── lib2.jar        # 依赖库2
      ├── lib3.jar        # 依赖库3
```

你可以使用以下命令来启动应用程序并引用`lib/`目录下的所有JAR依赖：

```bash
java -cp ./myapp.jar:./lib/* com.example.MainClass
```

在这个命令中：

- `./myapp.jar` 是你的主JAR文件，它包含了应用的入口点（`Main-Class`）。
- `./lib/*` 会将`lib/`目录下的所有JAR文件添加到类路径中。

请注意：

- 在Windows上，路径分隔符是分号（

    ```
    ;
    ```

    ），因此命令应该写成：

    ```bash
    java -cp .\myapp.jar;.\lib\* com.example.MainClass
    ```

这种方式将`lib/`目录下的所有JAR文件都加载进来，确保你的应用能够找到所有必要的依赖库。

1. 模块化运行（JDK 9 及以上）

从JDK 9开始，Java引入了模块系统。`java`命令提供了一些新选项来处理模块化应用。

`-p (或 --module-path) <path>` 用于指定模块路径。JDK 9引入了模块化系统，你可以用它来指定模块的路径。
 例如：

```bash
java -p /path/to/modules -m mymodule/com.example.Main
```

`-m <module>/<main-class>` 用于指定要执行的模块及其主类。这是模块化应用的标准启动方式。
 例如：

```bash
java -m mymodule/com.example.Main
```

1. JVM 性能调优

这些参数用于调优JVM的性能，优化垃圾回收器、内存使用、线程数等。

`-XX:+UseG1GC` 启用G1垃圾回收器，这是JDK 9及以后版本的默认垃圾回收器，适用于大内存应用。
 例如：

```bash
java -XX:+UseG1GC -jar myapp.jar
```

`-XX:+UseZGC` 启用Z垃圾回收器（适用于JDK 15及以上版本）。ZGC是低延迟的垃圾回收器，适用于需要低停顿时间的应用。
 例如：

```bash
java -XX:+UseZGC -jar myapp.jar
```

`-XX:+UseConcMarkSweepGC` 启用并发标记清除（CMS）垃圾回收器。在JDK 8中，它是默认的垃圾回收器，适用于低延迟应用。
 例如：

```bash
java -XX:+UseConcMarkSweepGC -jar myapp.jar
```

`-XX:MaxMetaspaceSize=<size>` 设置JVM元空间（Metaspace）的最大大小。JVM类的元数据存储在Metaspace中。
 例如：

```bash
java -XX:MaxMetaspaceSize=256m -jar myapp.jar
```

`-Xlog:gc*` 在JDK 9及以后版本，统一的日志系统用于输出垃圾回收的日志。通过此选项，你可以获取详细的GC信息。
 例如：

```bash
java -Xlog:gc* -jar myapp.jar
```

`-XX:ParallelGCThreads=<n>` 指定用于垃圾回收的并行线程数。这有助于在多核机器上优化垃圾回收性能。
 例如：

```bash
java -XX:ParallelGCThreads=4 -jar myapp.jar
```

## 调试与监控

调试选项用于在开发过程中进行程序调试，或用于性能监控。

`-agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=8000` 启用远程调试。此选项会启动一个调试服务，允许你通过IDE（如 IntelliJ IDEA、Eclipse）连接到JVM进行远程调试。
 例如：

```bash
java -agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=8000 -jar myapp.jar
```

`-XX:+PrintGCDetails` 输出详细的垃圾回收日志，帮助开发人员优化GC性能。
 例如：

```bash
java -XX:+PrintGCDetails -jar myapp.jar
```

`-XX:+PrintGCDateStamps` 在垃圾回收日志中输出时间戳，便于跟踪和分析GC发生的时间。
 例如：

```bash
java -XX:+PrintGCDateStamps -jar myapp.jar
```

`-XX:+PrintHeapAtGC` 每次垃圾回收时输出堆的详细信息。
 例如：

```bash
java -XX:+PrintHeapAtGC -jar myapp.jar
```

## 其他高级参数

这些是一些特定场景下使用的高级参数，可以根据需要调整JVM行为。

`-Xverify:none` 禁用字节码验证，通常在开发过程中用于加快启动速度，但会减少程序的安全性。
 例如：

```bash
java -Xverify:none -jar myapp.jar
```

`-XX:+UnlockDiagnosticVMOptions` 启用一些诊断功能，这些功能是默认禁用的，仅用于高级调试和分析。
 例如：

```bash
java -XX:+UnlockDiagnosticVMOptions -XX:+PrintFlagsFinal -version
```

`-XX:CICompilerCount=<n>` 设置JIT编译器的线程数，影响JVM的编译性能。
 例如：

```bash
java -XX:CICompilerCount=4 -jar myapp.jar
```

