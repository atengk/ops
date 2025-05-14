# 编译Redis

使用容器编译Redis



## OpenEuler

**创建容器**

```
docker run --rm -it \
    -v $(pwd)/build:/usr/local/software \
    openeuler/openeuler:24.03 bash
```

**安装编译工具**

```
dnf install -y --nobest --skip-broken pkg-config xz wget which gcc-toolset-13-gcc gcc-toolset-13-gcc-c++ git make openssl openssl-devel python3 python3-pip python3-devel unzip rsync clang curl libtool automake autoconf jq systemd-devel cmake
```

**设置代理（可选）**

编译时会涉及到下载墙外的其他软件包，就需要使用代理完成科学上网

```
export https_proxy=http://192.168.100.2:7890
```

**下载并解压软件包**

```
wget -O redis-8.0.1.tar.gz https://github.com/redis/redis/archive/refs/tags/8.0.1.tar.gz
tar -zxvf redis-8.0.1.tar.gz
```

**编译软件包**

```
cd redis-8.0.1
export BUILD_TLS=yes BUILD_WITH_MODULES=yes INSTALL_RUST_TOOLCHAIN=yes DISABLE_WERRORS=yes
make -j "$(nproc)" all
```

**安装软件包**

```
make PREFIX=/usr/local/software/redis-8.0.1-openeuler install
cp *.conf /usr/local/software/redis-8.0.1-openeuler
```



## Rocky Linux

**创建容器**

```
docker run --rm -it \
    -v $(pwd)/build:/usr/local/software \
    rockylinux/rockylinux:9.5 bash
```

**安装编译工具**

```
dnf install -y --nobest --skip-broken pkg-config xz wget which gcc-toolset-13-gcc gcc-toolset-13-gcc-c++ git make openssl openssl-devel python3 python3-pip python3-devel unzip rsync clang curl libtool automake autoconf jq systemd-devel cmake
```

**设置代理（可选）**

编译时会涉及到下载墙外的其他软件包，就需要使用代理完成科学上网

```
export https_proxy=http://192.168.100.2:7890
```

**下载并解压软件包**

```
wget -O redis-8.0.1.tar.gz https://github.com/redis/redis/archive/refs/tags/8.0.1.tar.gz
tar -zxvf redis-8.0.1.tar.gz
```

**编译软件包**

```
cd redis-8.0.1
export BUILD_TLS=yes BUILD_WITH_MODULES=yes INSTALL_RUST_TOOLCHAIN=yes DISABLE_WERRORS=yes
make -j "$(nproc)" all
```

**安装软件包**

```
make PREFIX=/usr/local/software/redis-8.0.1-rockylinux install
cp *.conf /usr/local/software/redis-8.0.1-rockylinux
```



## AlmaLinux

**创建容器**

```
docker run --rm -it \
    -v $(pwd)/build:/usr/local/software \
    almalinux:9.5 bash
```

**配置国内镜像源**

```
sed -i 's|^mirrorlist=|#mirrorlist=|g' /etc/yum.repos.d/*.repo
sed -i 's|^# baseurl=http.*/almalinux/|baseurl=https://mirrors.aliyun.com/almalinux/|g' /etc/yum.repos.d/*.repo
```

**安装编译工具**

```
dnf install -y --nobest --skip-broken pkg-config xz wget which gcc-toolset-13-gcc gcc-toolset-13-gcc-c++ git make openssl openssl-devel python3 python3-pip python3-devel unzip rsync clang curl libtool automake autoconf jq systemd-devel cmake
```

**设置代理（可选）**

编译时会涉及到下载墙外的其他软件包，就需要使用代理完成科学上网

```
export https_proxy=http://192.168.100.2:7890
```

**下载并解压软件包**

```
wget -O redis-8.0.1.tar.gz https://github.com/redis/redis/archive/refs/tags/8.0.1.tar.gz
tar -zxvf redis-8.0.1.tar.gz
```

**编译软件包**

```
cd redis-8.0.1
export BUILD_TLS=yes BUILD_WITH_MODULES=yes INSTALL_RUST_TOOLCHAIN=yes DISABLE_WERRORS=yes
make -j "$(nproc)" all
```

**安装软件包**

```
make PREFIX=/usr/local/software/redis-8.0.1-almalinux install
cp *.conf /usr/local/software/redis-8.0.1-almalinux
```



## Debian

**创建容器**

```
docker run --rm -it \
    -v $(pwd)/build:/usr/local/software \
    debian:12.10 bash
```

**配置国内镜像源**

```
sed -i 's|http://deb.debian.org|http://mirrors.aliyun.com|g' /etc/apt/sources.list.d/debian.sources
apt-get update
```

**安装编译工具**

```
export DEBIAN_FRONTEND=noninteractive
apt-get install -y --no-install-recommends ca-certificates wget dpkg-dev gcc g++ libc6-dev libssl-dev make git cmake python3 python3-pip python3-venv python3-dev unzip rsync clang automake autoconf libtool cmake pkg-config
```

**设置代理（可选）**

编译时会涉及到下载墙外的其他软件包，就需要使用代理完成科学上网

```
export https_proxy=http://192.168.100.2:7890
```

**下载并解压软件包**

```
wget -O redis-8.0.1.tar.gz https://github.com/redis/redis/archive/refs/tags/8.0.1.tar.gz
tar -zxvf redis-8.0.1.tar.gz
```

**编译软件包**

```
cd redis-8.0.1
export BUILD_TLS=yes BUILD_WITH_MODULES=yes INSTALL_RUST_TOOLCHAIN=yes DISABLE_WERRORS=yes
make -j "$(nproc)" all
```

**安装软件包**

```
make PREFIX=/usr/local/software/redis-8.0.1-debian install
cp *.conf /usr/local/software/redis-8.0.1-debian
```



## Ubuntu

**创建容器**

```
docker run --rm -it \
    -v $(pwd)/build:/usr/local/software \
    ubuntu:24.04 bash
```

**配置国内镜像源**

```
sed -i 's|http://.*ubuntu.com|http://mirrors.aliyun.com|g' /etc/apt/sources.list.d/ubuntu.sources
apt-get update
```

**安装编译工具**

```
export DEBIAN_FRONTEND=noninteractive
apt-get install -y --no-install-recommends ca-certificates wget dpkg-dev gcc g++ libc6-dev libssl-dev make git cmake python3 python3-pip python3-venv python3-dev unzip rsync clang automake autoconf libtool cmake pkg-config
```

**设置代理（可选）**

编译时会涉及到下载墙外的其他软件包，就需要使用代理完成科学上网

```
export https_proxy=http://192.168.100.2:7890
```

**下载并解压软件包**

```
wget -O redis-8.0.1.tar.gz https://github.com/redis/redis/archive/refs/tags/8.0.1.tar.gz
tar -zxvf redis-8.0.1.tar.gz
```

**编译软件包**

```
cd redis-8.0.1
export BUILD_TLS=yes BUILD_WITH_MODULES=yes INSTALL_RUST_TOOLCHAIN=yes DISABLE_WERRORS=yes
make -j "$(nproc)" all
```

**安装软件包**

```
make PREFIX=/usr/local/software/redis-8.0.1-ubuntu install
cp *.conf /usr/local/software/redis-8.0.1-ubuntu
```

