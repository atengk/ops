# 编译和安装GCC

**安装一些编译GCC所需的依赖项**

```
sudo yum -y install gcc gcc-c++ gmp-devel mpfr-devel libmpc-devel
```

**查看版本**

```
gcc --version
```

**下载GCC源代码**

官网：https://ftp.gnu.org/gnu/gcc/gcc-12.3.0/gcc-12.3.0.tar.xz

阿里云镜像：https://mirrors.aliyun.com/gnu/gcc/gcc-12.3.0/gcc-12.3.0.tar.xz

```
wget https://mirrors.aliyun.com/gnu/gcc/gcc-12.3.0/gcc-12.3.0.tar.xz
tar -xf gcc-12.3.0.tar.xz
cd gcc-12.3.0
```

**配置GCC**

创建一个单独的目录来构建GCC，并运行`configure`脚本。

```
mkdir build
cd build
../configure \
  --disable-multilib \
  --enable-languages=c,c++ \
  --prefix=/usr/local/software/gcc-12.3.0
```

**编译GCC**

开始编译GCC，这个过程可能需要一些时间。

```
make -j$(nproc)
```

**安装GCC**

```
make install
```

**查找并删除调试文件**

```
find /usr/local/software/gcc-12.3.0/ -name "*-gdb.py" -exec rm -f {} \;
```

**更新库缓存**

```
echo "/usr/local/software/gcc-12.3.0/lib64" | sudo tee /etc/ld.so.conf.d/gcc-12.3.0.conf
sudo ldconfig
```

**删除旧版本**

```
sudo yum -y remove gcc gcc-c++
```

**配置环境变量**

```
cat >> ~/.bash_profile <<"EOF"
## GCC_HOME
export GCC_HOME=/usr/local/software/gcc-12.3.0
export PATH=$PATH:$GCC_HOME/bin
EOF
source ~/.bash_profile
```

**验证安装**

安装完成后，验证GCC是否安装成功。

```
gcc --version
```

执行以上命令应该会显示GCC的版本信息，例如`gcc (GCC) 12.3.0`。



# 编译和安装CMake

**下载cmake**

```
wget https://github.com/Kitware/CMake/releases/download/v3.27.9/cmake-3.27.9.tar.gz
tar -zxf cmake-3.27.9.tar.gz
cd cmake-3.27.9
```

**安装依赖**

```
sudo yum -y install openssl-devel
```

**编译和安装CMake**

```
./bootstrap --prefix=/usr/local/software/cmake-3.27.9
make -j$(nproc)
make install
```

**配置环境变量**

```
cat >> ~/.bash_profile <<"EOF"
## CMAKE_HOME
export CMAKE_HOME=/usr/local/software/cmake-3.27.9
export PATH=$PATH:$CMAKE_HOME/bin
EOF
source ~/.bash_profile
```

**验证安装**

```
cmake --version
```



# 编译和安装MySQL

**安装依赖工具和库**

```
sudo yum -y install ncurses-devel boost-devel libtirpc-devel bison rpcgen
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
cmake .. \
  -DCMAKE_INSTALL_PREFIX=/usr/local/software/mysql-server-mysql-8.4.1 \
  -DCMAKE_C_COMPILER=/usr/local/software/gcc-12.3.0/bin/gcc \
  -DCMAKE_CXX_COMPILER=/usr/local/software/gcc-12.3.0/bin/g++
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

