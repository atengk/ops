### 步骤 0：准备安装源文件
1. 下载Windows 10的ISO镜像文件并挂载（右键点击ISO文件，然后选择“装载”）。
2. 找到镜像文件中的`sources\sxs`目录，并将其复制到本地计算机的D盘根目录下（路径为`D:\sxs`）。

### 步骤 1：安装 .NET Framework 3.5
1. 以管理员身份打开命令提示符：
   - 在“开始”菜单中搜索`cmd`，右键点击“命令提示符”，选择“以管理员身份运行”。
   
2. 运行以下命令以启用 .NET Framework 3.5功能：
   ```
   Dism /online /enable-feature /featurename:NetFx3 /All /Source:D:\sxs /LimitAccess
   ```
   - **说明：**
     - `Dism`（部署映像服务和管理工具）用于管理Windows的功能和组件。
     - `/online`表示操作系统正在运行的当前系统。
     - `/enable-feature /featurename:NetFx3`用于启用.NET Framework 3.5功能。
     - `/All`表示安装.NET Framework 3.5的所有子功能。
     - `/Source:D:\sxs`指定安装源路径，指向之前从ISO镜像复制的`sxs`目录。
     - `/LimitAccess`表示仅从指定的源路径获取文件，而不连接到Windows Update获取更新。

### 步骤 2：验证安装
1. 打开“控制面板” → “程序和功能” → “启用或关闭Windows功能”，查看是否已经勾选 .NET Framework 3.5。
2. 如果已经勾选，则说明安装成功。

### 注意事项
- 安装过程中请确保计算机未被其他程序占用较多的系统资源，否则可能会导致安装速度变慢。
- 如果步骤失败，请确保挂载的Windows 10 ISO镜像与当前系统版本兼容。

