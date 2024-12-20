# 编译和安装MySQL

适用于**OpenEuler24.03**操作系统

**安装依赖工具和库**

```
sudo yum -y install gcc gcc-c++ cmake ncurses-devel boost-devel libtirpc-devel rpcgen
```

**下载 MySQL 8 源码**

在github下载MySQL源码：https://github.com/mysql/mysql-server/tags

```
wget https://github.com/mysql/mysql-server/archive/refs/tags/mysql-cluster-8.0.38.tar.gz
tar -zxf mysql-server-mysql-8.4.1.tar.gz
cd mysql-server-mysql-8.4.1/
```

**创建构建目录**

在源码目录中创建一个单独的构建目录：

```
mkdir build
cd build
```

**运行 `cmake` 配置构建环境**

在构建目录中运行以下命令来配置构建环境：

```
cmake .. -DCMAKE_INSTALL_PREFIX=/usr/local/software/mysql-server-mysql-8.4.1
```

**编译 MySQL**

配置完成后，运行 `make` 开始编译：

```
make -j$(nproc)
```

这个过程可能需要一些时间，取决于你的系统性能。

**安装 MySQL**

编译完成后，运行以下命令将 MySQL 安装到系统中：

```
make install
```

**查看目录**

```
ll /usr/local/software/mysql-server-mysql-8.4.1
```

