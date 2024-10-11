# WinSW

## 什么是 WinSW？

WinSW（Windows Service Wrapper） 是一个开源工具，允许将任何可执行文件（如 `.exe`、脚本等）包装为Windows服务运行。WinSW 提供服务控制（启动、停止、重启）、日志管理、自动重启等功能，适用于需要在后台持续运行的应用程序。

GitHub 项目地址：[https://github.com/winsw/winsw](https://github.com/winsw/winsw)

---

## 使用 WinSW 的步骤

### 1. **下载 WinSW**
- 访问 [WinSW Releases](https://github.com/winsw/winsw/releases)，选择适合你操作系统架构的版本（例如 `WinSW-x64.exe`）。
- 将下载的文件重命名为你服务的名称。例如，如果你的服务名是 `MyService`，重命名为 `MyService.exe`。

### 2. **创建 XML 配置文件**
- 在与 `MyService.exe` 同一目录下，创建 `MyService.xml` 文件，用于定义服务的配置。以下是一个示例配置：

```xml
<?xml version="1.0" encoding="utf-8"?>
<service>
  <id>MyService</id>
  <name>My Custom Service</name>
  <description>My application running as a Windows service.</description>
  
  <!-- 可执行文件的路径 -->
  <executable>C:\path\to\your\application.exe</executable>

  <!-- 可选：启动参数 -->
  <arguments>--some-arguments</arguments>

  <!-- 可选：日志配置 -->
  <logpath>C:\path\to\logs</logpath>
  <log mode="roll-by-size">
    <sizeThreshold>10240</sizeThreshold>
    <keepFiles>5</keepFiles>
  </log>

  <!-- 失败重启策略 -->
  <onfailure action="restart" delay="5000"/>
</service>
```

### 3. **安装服务**
- 打开命令提示符（以管理员身份运行），导航到 `MyService.exe` 所在目录，并执行以下命令安装服务：

```cmd
MyService.exe install
```

### 4. **启动服务**
- 安装完成后，启动服务：

```cmd
MyService.exe start
```

### 5. **管理服务**
- **停止服务**：
  ```cmd
  MyService.exe stop
  ```
- **重启服务**：
  ```cmd
  MyService.exe restart
  ```
- **卸载服务**：
  ```cmd
  MyService.exe uninstall
  ```

### 6. **检查服务状态**
- 查看服务运行状态：

```cmd
MyService.exe status
```

---

通过这些步骤，你可以轻松地将任意可执行程序作为Windows服务运行。如果需要更多高级配置或功能，请参考 [WinSW 的官方文档](https://github.com/winsw/winsw)。
