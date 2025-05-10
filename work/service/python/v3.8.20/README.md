# Python

Python 是一种广泛使用的高级编程语言，以简洁、易读著称。它支持多种编程范式，如面向对象、函数式和过程式编程，适用于数据分析、人工智能、Web开发、自动化等众多领域。拥有丰富的第三方库和活跃的开发社区，是初学者和专业人士的首选语言。

- [官网地址](https://www.python.org/)

- [源码下载地址](https://www.python.org/downloads/source/)
- [Windows下载地址](https://www.python.org/downloads/windows/)



**下载软件包**

```
wget https://www.python.org/ftp/python/3.8.20/Python-3.8.20.tgz
```

**解压软件包**

```
tar -xzf Python-3.8.20.tgz
cd Python-3.8.20
```

**安装编译依赖**

```
sudo yum install -y \
    gcc \
    gcc-c++ \
    make \
    zlib-devel \
    bzip2-devel \
    openssl-devel \
    ncurses-devel \
    sqlite-devel \
    readline-devel \
    tk-devel \
    libffi-devel \
    xz-devel \
    libuuid-devel \
    gdbm-devel \
    uuid-devel
```

**配置编译选项**

```
./configure --prefix=/usr/local/software/python3.8.20 --enable-optimizations
```

**编译并安装**

使用 `make altinstall` 而非 `make install`，可以避免覆盖系统默认的 Python 版本。

```
make -j$(nproc)
make altinstall
```

**配置软链接**

```
ln -s /usr/local/software/python3.8.20 /usr/local/software/python3
```

**配置环境变量**

```
cat >> ~/.bash_profile <<"EOF"
## PYTHON_HOME
export PYTHON_HOME=/usr/local/software/python3
export PATH=$PYTHON_HOME/bin:$PATH
EOF
source ~/.bash_profile
```

**配置全局仓库**

编辑配置文件

```
mkdir -p ~/.pip
cat > ~/.pip/pip.conf <<EOF
[global]
index-url = https://pypi.tuna.tsinghua.edu.cn/simple
target=/data/download/python

[install]
trusted-host = pypi.tuna.tsinghua.edu.cn
EOF
```

创建目录

```
sudo mkdir -p /data/download/python
sudo chown -R admin:ateng  /data/download/python
```

**验证安装**

```
$ python3.13 --version
Python 3.8.20
$ pip3.13 config list
global.index-url='https://pypi.tuna.tsinghua.edu.cn/simple'
global.target='/data/download/python'
install.trusted-host='pypi.tuna.tsinghua.edu.cn'
```

**设置软链接**

```
ln -s /usr/local/software/python3.8.20/bin/python3.13 /usr/local/software/python3/bin/python
ln -s /usr/local/software/python3.8.20/bin/python3.13 /usr/local/software/python3/bin/python3
ln -s /usr/local/software/python3.8.20/bin/pip3.13 /usr/local/software/python3/bin/pip3
ln -s /usr/local/software/python3.8.20/bin/pip3.13 /usr/local/software/python3/bin/pip
```

**下载测试**

```
pip install requests
ls -l /data/download/python
```

