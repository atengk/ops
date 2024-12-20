# 编译安装MySQL

**安装前先参考[前置条件](/work/service/00-basic/)**

编译安装MySQL，需要注意以下事项

- 需要 GCC 版本 >= 10
- 需要 CMake 版本 >= 3



## 编译和安装GCC

**安装依赖包**

```
sudo yum -y install gcc gcc-c++ gmp-devel mpfr-devel libmpc-devel
```

**查看版本**

编译MySQL时需要gcc版本>=10，如果是那么该章节就可以跳过了，否则就需要编译安装高版本的GCC

```
gcc --version
```

**下载GCC源代码**

官网：https://ftp.gnu.org/gnu/gcc/gcc-14.2.0/gcc-14.2.0.tar.xz

阿里云镜像：https://mirrors.aliyun.com/gnu/gcc/gcc-14.2.0/gcc-14.2.0.tar.xz

```
wget https://mirrors.aliyun.com/gnu/gcc/gcc-14.2.0/gcc-14.2.0.tar.xz
tar -xf gcc-14.2.0.tar.xz
cd gcc-14.2.0
```

**配置GCC**

创建一个单独的目录来构建GCC，并运行`configure`脚本

```
mkdir build
cd build
../configure \
  --disable-multilib \
  --enable-languages=c,c++ \
  --prefix=/usr/local/software/gcc-14.2.0
```

**编译GCC**

开始编译GCC，这个过程可能需要一些时间

```
make -j$(nproc)
```

**安装GCC**

```
make install
```

**查找并删除调试文件**

```
find /usr/local/software/gcc-14.2.0/ -name "*-gdb.py" -exec rm -f {} \;
```

**更新库缓存**

```
echo "/usr/local/software/gcc-14.2.0/lib64" | sudo tee /etc/ld.so.conf.d/gcc-14.2.0.conf
sudo ldconfig
```

**验证安装**

安装完成后，验证GCC是否安装成功。

```
$ /usr/local/software/gcc-14.2.0/bin/gcc --version
gcc (GCC) 14.2.0
```



## 编译和安装CMake

**查看版本**

使用软件源查看cmake版本。如果cmake版本小于3就不行，只能手动编译安装。如果大于等于3就可以直接安装该软件，就不需要编译安装了。

以 centos7.9 为例，这个cmake版本小于3，就需要手动编译安装

```
[admin@localhost ~]$ yum list cmake
已加载插件：fastestmirror
Loading mirror speeds from cached hostfile
 * base: mirrors.aliyun.com
 * extras: mirrors.aliyun.com
 * updates: mirrors.aliyun.com
可安装的软件包
cmake.x86_64                                                                    2.8.12.2-2.el7                                                                    base
```

以 OpenEuler24 为了，这个cmake版本大于等于3，就可以直接安装，安装后可以跳过编译的步骤了

```
[admin@localhost ~]$ yum list cmake
Last metadata expiration check: 0:00:37 ago on 2024年12月10日 星期二 18时35分35秒.
Available Packages
cmake.src                                                                   3.27.9-3.oe2403                                                                 source
cmake.x86_64                                                                3.27.9-3.oe2403                                                                 OS
cmake.x86_64                                                                3.27.9-3.oe2403                                                                 everything
[admin@localhost ~]$ sudo yum -y install cmake
```

**下载软件包**

```
wget https://github.com/Kitware/CMake/releases/download/v3.31.2/cmake-3.31.2.tar.gz
tar -zxf cmake-3.31.2.tar.gz
cd cmake-3.31.2
```

**安装依赖**

```
sudo yum -y install openssl-devel
```

**编译和安装**

```
./bootstrap --prefix=/usr/local/software/cmake-3.31.2
make -j$(nproc)
make install
```

**配置环境变量**

```
cat >> ~/.bash_profile <<"EOF"
## CMAKE_HOME
export CMAKE_HOME=/usr/local/software/cmake-3.31.2
export PATH=$PATH:$CMAKE_HOME/bin
EOF
source ~/.bash_profile
```

**验证安装**

```
$ cmake --version
cmake version 3.31.2
```



## 编译和安装MySQL

**安装依赖工具和库**

安装以下依赖包

```
sudo yum -y install ncurses-devel boost-devel libtirpc-devel bison-devel openssl-devel
```

在OpenEuler中，还需要安装以下软件包

> rpcgen: RPC通信的工具

```
sudo yum -y install rpcgen m4
```

**下载 MySQL 8 源码**

下载boost软件包并解压，MySQL指明需要这个版本，它依赖于该版本的特性和 API

```
wget https://archives.boost.io/release/1.77.0/source/boost_1_77_0.tar.bz2
tar -xjf boost_1_77_0.tar.bz2 -C /usr/local/software
```

在github下载MySQL源码：https://github.com/mysql/mysql-server/tags

```
wget https://github.com/mysql/mysql-server/archive/refs/tags/mysql-8.0.40.tar.gz
tar -zxf mysql-server-mysql-8.0.40.tar.gz
cd mysql-server-mysql-8.0.40/
```

**创建构建目录**

在源码目录中创建一个单独的构建目录：

```
mkdir build
cd build
```

**运行 `cmake` 配置构建环境**

在构建目录中运行以下命令来配置构建环境：

如果是编译安装的高版本GCC，需要指定GCC的路径，使用以下命令

```
cmake .. \
  -DCMAKE_INSTALL_PREFIX=/usr/local/software/mysql-8.0.40 \
  -DCMAKE_C_COMPILER=/usr/local/software/gcc-14.2.0/bin/gcc \
  -DCMAKE_CXX_COMPILER=/usr/local/software/gcc-14.2.0/bin/g++ \
  -DWITH_BOOST=/usr/local/software/boost_1_77_0
```

如果是软件源安装的GCC，且版本大于等于10，则不需要指定GCC的路径，使用以下命令

```
cmake .. \
  -DCMAKE_INSTALL_PREFIX=/usr/local/software/mysql-8.0.40 \
  -DWITH_BOOST=/usr/local/software/boost_1_77_0
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
ll /usr/local/software/mysql-8.0.40
```

**查看版本**

```
$ /usr/local/software/mysql-8.0.40/bin/mysql --version
/usr/local/software/mysql-8.0.40/bin/mysql  Ver 8.0.40 for Linux on x86_64 (Source distribution)
```

