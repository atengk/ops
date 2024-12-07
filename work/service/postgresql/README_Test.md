# 编译和安装GCC

涉及的依赖性太多了，暂时不搞了...



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

以超级用户权限安装GCC。

```
sudo make install
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
yum -y remove gcc gcc-c++
```

**配置环境变量**

```
cat >> /etc/profile.d/00-gcc-12.3.0.sh <<"EOF"
## GCC_HOME
export GCC_HOME=/usr/local/software/gcc-12.3.0
export PATH=$PATH:$GCC_HOME/bin
EOF
source /etc/profile.d/00-gcc-12.3.0.sh
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
sudo make install
```

**配置环境变量**

```
cat >> /etc/profile.d/00-cmake-3.27.9.sh <<"EOF"
## CMAKE_HOME
export CMAKE_HOME=/usr/local/software/cmake-3.27.9
export PATH=$PATH:$CMAKE_HOME/bin
EOF
source /etc/profile.d/00-cmake-3.27.9.sh
```

**验证安装**

```
cmake --version
```



# 编译和安装PostgreSQL

**安装依赖工具和库**

```
sudo yum -y install libicu-devel readline-devel zlib-devel
```

**下载 PostgreSQL 源码**

下载PostgreSQL源码：https://www.postgresql.org/ftp/source/

```
wget https://ftp.postgresql.org/pub/source/v16.3/postgresql-16.3.tar.gz
tar -xzf postgresql-16.3.tar.gz
cd postgresql-16.3
```

**配置**

运行 `./configure` 脚本来检测系统环境并生成相应的Makefile。你可以指定安装目录以及其他选项。例如：

```
./configure --prefix=/usr/local/software/postgresql-16.3
```

**编译和安装**

使用 `make` 命令编译源码：

```
make -j$(nproc)
```

编译完成后，使用以下命令进行安装：

```
make install
```

**编译和安装插件**

```
cd contrib
make -j$(nproc)
make install
```

**查看目录**

```
ll /usr/local/software/postgresql-16.3
ll /usr/local/software/postgresql-16.3/share/extension
/usr/local/software/postgresql-16.3/bin/pg_ctl --version
```

**更新库缓存**

```
echo "/usr/local/software/postgresql-16.3/lib" | sudo tee /etc/ld.so.conf.d/postgresql-16.3.conf
sudo ldconfig
```



# 配置PostgreSQL

## 基础配置

**创建软链接**

```
ln -s /usr/local/software/postgresql-16.3 /usr/local/software/postgresql
```

**配置环境变量**

```
cat >> ~/.bash_profile <<"EOF"
## POSTGRESQL_HOME
export POSTGRESQL_HOME=/usr/local/software/postgresql
export PATH=$PATH:$POSTGRESQL_HOME/bin
EOF
source ~/.bash_profile
```

**查看版本**

```
pg_ctl --version
```

## 初始化

**初始化数据目录**

```sh
initdb -D /data/service/postgresql
```

## **修改配置文件**

**配置include目录**

```
$ vi +810 /data/service/postgresql/postgresql.conf
include_dir = 'conf.d'
$ mkdir /data/service/postgresql/conf.d
```

**创建配置文件**

```
cat > /data/service/postgresql/conf.d/override.conf <<EOF
port = 5432
listen_addresses = '0.0.0.0'
max_connections = 1024
shared_buffers = 4GB
work_mem = 64MB
max_parallel_workers_per_gather = 4
max_parallel_maintenance_workers = 2
max_parallel_workers = 8
wal_level = logical
log_timezone = Asia/Shanghai
timezone = Asia/Shanghai
EOF
```

**配置客户端认证**

编辑 `pg_hba.conf` 文件以允许远程连接。添加一行以允许所有IP地址的所有用户使用密码认证（你可以根据需要限制访问）：

```
cat >> /data/service/postgresql/pg_hba.conf <<EOF
host    all             all             0.0.0.0/0               md5
EOF
```

如果你只想允许特定IP地址范围，你可以更改 `0.0.0.0/0` 为一个更具体的CIDR地址范围，例如 `192.168.1.0/24`。

## 启动服务

**配置系统服务**：

创建一个systemd服务文件以便管理PostgreSQL服务：

```
sudo tee /etc/systemd/system/postgresql.service <<"EOF"
[Unit]
Description=PostgreSQL database server
After=network-online.target

[Service]
Type=forking
Restart=always
RestartSec=10
User=admin
Group=ateng
ExecStart=/usr/local/software/postgresql/bin/pg_ctl -D /data/service/postgresql --log /data/service/postgresql/postgresql.log start
ExecStop=/usr/local/software/postgresql/bin/pg_ctl stop -D /data/service/postgresql -s -m fast
ExecReload=/usr/local/software/postgresql/bin/pg_ctl reload -D /data/service/postgresql -s

[Install]
WantedBy=multi-user.target
EOF
```

**重新加载systemd并启动PostgreSQL服务**

```
sudo systemctl daemon-reload
sudo systemctl start postgresql
sudo systemctl enable postgresql
```

## 创建用户

**登录PostgreSQL**

```
psql -d postgres
```

**创建超级用户**

```
CREATE USER root WITH PASSWORD 'Admin@123' SUPERUSER;
\du
```

创建数据库

```
CREATE DATABASE kongyu OWNER root;
```

使用超级用户远程访问

```
$ PGPASSWORD='Admin@123' psql -h 192.168.1.109 -p 5432 -U root kongyu
kongyu=# \l
```



# 编译和安装PostGIS

## 编译和安装SQLite3 

```
wget https://sqlite.org/2024/sqlite-autoconf-3460000.tar.gz
tar -zxf sqlite-autoconf-3460000.tar.gz
cd sqlite-autoconf-3460000
./configure --prefix=/usr/local/software/sqlite-3.46.0
make -j$(nproc)
make install
cat >> ~/.bash_profile <<"EOF"
## SQLITE3_HOME
export SQLITE3_HOME=/usr/local/software/sqlite-3.46.0
export PATH=$SQLITE3_HOME/bin:$PATH
EOF
source ~/.bash_profile
sqlite3 --version
echo "/usr/local/software/sqlite-3.46.0/lib" | sudo tee /etc/ld.so.conf.d/sqlite-3.46.0.conf
sudo ldconfig
```

## 编译和安装proj

```
sudo yum -y install libtiff-devel libcurl-devel
wget https://download.osgeo.org/proj/proj-9.4.1.tar.gz
tar -zxf proj-9.4.1.tar.gz
cd proj-9.4.1
mkdir build
cd build
cmake .. \
  -DCMAKE_INSTALL_PREFIX=/usr/local/software/proj-9.4.1 \
  -DSQLITE3_INCLUDE_DIR=/usr/local/software/sqlite-3.46.0/include \
  -DSQLITE3_LIBRARY=/usr/local/software/sqlite-3.46.0/lib/libsqlite3.so \
  -DBUILD_TESTING=""

make -j$(nproc)
make install
/usr/local/software/proj-9.4.1/bin/proj
echo "/usr/local/software/proj-9.4.1/lib64" | sudo tee /etc/ld.so.conf.d/proj-9.4.1.conf
sudo ldconfig
```

## 编译和安装geos

```
wget https://download.osgeo.org/geos/geos-3.12.2.tar.bz2
sudo yum -y install bzip2
tar -xf geos-3.12.2.tar.bz2
cd geos-3.12.2
./configure --prefix=/usr/local/software/geos-3.12.2
make -j$(nproc)
make install
/usr/local/software/geos-3.12.2/bin/geosop
echo "/usr/local/software/geos-3.12.2/lib64" | sudo tee /etc/ld.so.conf.d/geos-3.12.2.conf
sudo ldconfig
```

## 编译和安装python

```
wget https://www.python.org/ftp/python/3.8.19/Python-3.8.19.tar.xz
tar -xf Python-3.8.19.tar.xz
cd Python-3.8.19
./configure --prefix=/usr/local/software/python-3.8.19
make -j$(nproc)
make install
/usr/local/software/python-3.8.19/bin/python3 --version
echo "/usr/local/software/python-3.8.19/lib" | sudo tee /etc/ld.so.conf.d/python-3.8.19.conf
sudo ldconfig
```



## 编译和安装GDAL

GDAL（Geospatial Data Abstraction Library）是一个开源的地理空间数据抽象库，它提供了处理和转换地理空间数据的工具和库集合。

**下载和解压 GDAL**

下载 GDAL 3.9.1 的源代码并解压到当前目录：

```bash
wget https://download.osgeo.org/gdal/3.9.1/gdal-3.9.1.tar.gz
tar -zxf gdal-3.9.1.tar.gz
cd gdal-3.9.1/
```

**配置和构建**

创建一个 build 目录，并在其中配置和构建 GDAL：

```bash
mkdir build
cd build
cmake .. \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_PREFIX=/usr/local/software/gdal-3.9.1 \
  -DPROJ_DIR=/usr/local/software/proj-9.4.1 \
  -DPROJ_LIBRARY=/usr/local/software/proj-9.4.1/lib64/libproj.so \
  -DPROJ_INCLUDE_DIR=/usr/local/software/proj-9.4.1/include \
  -DPython_EXECUTABLE=/usr/local/software/python-3.8.19/bin/python3
make -j$(nproc)
```

- `-DCMAKE_BUILD_TYPE=Release`：指定构建类型为 Release，用于优化性能。
- `-DCMAKE_INSTALL_PREFIX=/usr/local/software/gdal-3.9.1`：指定安装路径为 `/usr/local/software/gdal-3.9.1`。

**安装 GDAL**

使用以下命令安装 GDAL 到系统中：

```bash
make install
```

**配置库路径**

添加 GDAL 库的路径到系统动态链接器配置中：

```bash
echo "/usr/local/software/gdal-3.9.1/lib64" | sudo tee /etc/ld.so.conf.d/gdal-3.9.1.conf
sudo ldconfig
```

- `sudo ldconfig`：刷新动态链接器运行时绑定。



## 编译和安装CGAL

CGAL（Computational Geometry Algorithms Library）是一个用于计算几何的开源库。

**下载和解压 CGAL**

下载 CGAL 5.6.1 的源代码并解压到当前目录：

```bash
wget https://github.com/CGAL/cgal/releases/download/v5.6.1/CGAL-5.6.1.tar.xz
tar xf CGAL-5.6.1.tar.xz
cd CGAL-5.6.1
```

**配置和构建**

创建一个 `build` 目录，并在其中配置和构建 CGAL：

```bash
mkdir build
cd build
cmake .. \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_PREFIX=/usr/local/software/CGAL-5.6.1
make
```

- `-DCMAKE_BUILD_TYPE=Release`：指定构建类型为 Release，用于优化性能。
- `-DCMAKE_INSTALL_PREFIX=/usr/local/software/CGAL-5.6.1`：指定安装路径为 `/usr/local/software/CGAL-5.6.1`。

**安装 CGAL**

使用以下命令安装 CGAL 到系统中：

```bash
make install
```



## 编译和安装SFCGAL

SFCGAL 是一个用于增强 PostGIS 的三维几何库。

**安装依赖项**

首先安装 SFCGAL 所需的依赖项：

```bash
sudo yum -y install gmp-devel mpfr-devel boost-devel
```

**下载和解压 SFCGAL**

下载 SFCGAL 1.5.1 的源代码并解压到当前目录：

```bash
wget https://gitlab.com/sfcgal/SFCGAL/-/archive/v1.5.1/SFCGAL-v1.5.1.tar.gz
tar -zxf SFCGAL-v1.5.1.tar.gz
cd SFCGAL-v1.5.1
```

**配置和构建**

创建一个 `build` 目录，并在其中配置和构建 SFCGAL：

```bash
mkdir build
cd build
cmake .. \
  -DCMAKE_BUILD_TYPE=Release \
  -DCGAL_DIR=/usr/local/software/CGAL-5.6.1 \
  -DCMAKE_INSTALL_PREFIX=/usr/local/software/SFCGAL-v1.5.1
make -j$(nproc)
```

- `-DCMAKE_BUILD_TYPE=Release`：指定构建类型为 Release，用于优化性能。
- `-DCGAL_DIR=/usr/local/software/CGAL-5.6.1`：指定 CGAL 的安装路径。
- `-DCMAKE_INSTALL_PREFIX=/usr/local/software/SFCGAL-v1.5.1`：指定安装路径为 `/usr/local/software/SFCGAL-v1.5.1`。

**安装 SFCGAL**

使用以下命令安装 SFCGAL 到系统中：

```bash
make install
```

**配置库路径**

添加 SFCGAL库的路径到系统动态链接器配置中：

```bash
echo "/usr/local/software/SFCGAL-v1.5.1/lib64" | sudo tee /etc/ld.so.conf.d/SFCGAL-v1.5.1.conf
sudo ldconfig
```

- `sudo ldconfig`：刷新动态链接器运行时绑定。



## 编译和安装PostGIS

PostGIS 是一个用于 PostgreSQL 的空间和地理信息系统扩展。

**安装依赖项**

首先安装 PostGIS 所需的依赖项：

```bash
sudo yum -y install libxml2-devel geos-devel protobuf-c-devel pcre-devel json-c-devel
```

如果需要文档生成得功能就安装以下工具（可选）

```
sudo yum -y install libxslt dblatex docbook-style-xsl ImageMagick
```

**下载和解压 PostGIS**

下载 PostGIS 3.4.2 的源代码并解压到当前目录：

```bash
wget https://download.osgeo.org/postgis/source/postgis-3.4.2.tar.gz
tar -zxf postgis-3.4.2.tar.gz
cd postgis-3.4.2
```

**配置和构建**

使用 `configure` 脚本配置并构建 PostGIS，指定相关路径和选项：

```bash
./configure \
  --prefix=/usr/local/software/postgis-3.4.2 \
  --with-pgconfig=/usr/local/software/postgresql-16.3/bin/pg_config \
  --with-gdalconfig=/usr/local/software/gdal-3.9.1/bin/gdal-config \
  --with-sfcgal=/usr/local/software/SFCGAL-v1.5.1/bin/sfcgal-config
make -j$(nproc)
```

- `--prefix=/usr/local/software/postgis-3.4.2`：指定安装路径为 `/usr/local/software/postgis-3.4.2`。
- `--with-pgconfig` 和 `--with-gdalconfig`：指定 PostgreSQL 和 GDAL 的配置文件路径。

**安装 PostGIS**

使用以下命令安装 PostGIS 到系统中：

```bash
make install
```

**重启PostgreSQL**

```
sudo systemctl restart postgresql
```

**验证安装**

连接到 PostgreSQL 数据库：

```
psql -d postgres
```

创建 PostGIS 扩展

```
CREATE EXTENSION postgis;
```

查看所有可用的扩展：

```
SELECT * FROM pg_available_extensions;
```

查看当前数据库中已安装的扩展：

```
SELECT * FROM pg_extension;
```

## 使用PostGIS

要在 PostgreSQL 中使用 PostGIS 插件，首先需要确保已经成功创建并启用了 PostGIS 扩展。接下来，可以使用 PostGIS 提供的 SQL 函数和类型来操作空间数据。

### 创建包含空间数据的表

假设你已经连接到 PostgreSQL 数据库，并且成功创建了 PostGIS 扩展，以下是一个示例来创建一个包含空间数据的表：

```sql
CREATE TABLE spatial_table (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100),
    geom GEOMETRY(Point, 4326)  -- 4326 is the SRID (Spatial Reference System Identifier) for WGS 84
);
```

这个示例创建了一个名为 `spatial_table` 的表，包含 `id`（自增主键）、`name`（名称）和 `geom`（几何）列。`GEOMETRY(Point, 4326)` 指定了 `geom` 列存储的几何类型为点（Point），并使用 WGS 84 坐标系（EPSG 4326）。

### 插入空间数据

向刚创建的表中插入空间数据的示例：

```sql
INSERT INTO spatial_table (name, geom)
VALUES
    ('Point A', ST_SetSRID(ST_MakePoint(-73.9857, 40.7484), 4326)),
    ('Point B', ST_SetSRID(ST_MakePoint(-73.9772, 40.7870), 4326));
```

这个示例插入了两个点数据，分别表示纽约市的两个地点，使用了 PostGIS 提供的空间函数 `ST_MakePoint` 和 `ST_SetSRID` 来创建和设置点的坐标及其坐标系。

### 查询空间数据

使用 PostGIS 提供的空间查询函数来查询和分析空间数据：

```sql
-- 查询所有数据
SELECT * FROM spatial_table;

-- 查询距离某个点最近的点
SELECT name, ST_Distance(geom, ST_SetSRID(ST_MakePoint(-73.9866, 40.7485), 4326)) AS distance
FROM spatial_table
ORDER BY distance;

-- 查询包含在指定区域内的点
SELECT name
FROM spatial_table
WHERE ST_Within(geom, ST_MakeEnvelope(-74.0, 40.75, -73.95, 40.8, 4326));
```

这些示例展示了如何使用 PostGIS 扩展中的函数来进行空间数据的插入、查询和分析操作。根据你的具体需求，可以使用更多丰富的空间函数来处理不同类型的空间数据。

