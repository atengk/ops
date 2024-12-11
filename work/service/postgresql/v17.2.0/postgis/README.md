# 编译安装PostGIS

PostGIS 是一个为 PostgreSQL 提供地理信息系统（GIS）功能的扩展，使其能够处理空间数据。它支持多种空间数据类型，如点、线、面，并提供丰富的空间查询、分析和操作函数。PostGIS 使 PostgreSQL 成为一个强大的空间数据库，广泛应用于地图、地理数据分析、位置服务等领域。它支持标准的空间查询语言，如 SQL 和 OGC（Open Geospatial Consortium）规范。

## 编译和安装GDAL

GDAL（Geospatial Data Abstraction Library）是一个开源的地理空间数据抽象库，它提供了处理和转换地理空间数据的工具和库集合。

**安装依赖项**

在开始安装之前，需要先安装一些必要的依赖项：proj-devel 和 cmake。

```bash
sudo yum -y install proj-devel cmake
```

**下载和解压 GDAL**

下载 GDAL 3.9.3 的源代码并解压到当前目录：

```bash
wget https://download.osgeo.org/gdal/3.9.3/gdal-3.9.3.tar.gz
tar -zxf gdal-3.9.3.tar.gz
cd gdal-3.9.3/
```

**配置和构建**

创建一个 build 目录，并在其中配置和构建 GDAL：

```bash
mkdir build
cd build
cmake .. \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_PREFIX=/usr/local/software/gdal-3.9.3
make -j$(nproc)
```

- `-DCMAKE_BUILD_TYPE=Release`：指定构建类型为 Release，用于优化性能。
- `-DCMAKE_INSTALL_PREFIX=/usr/local/software/gdal-3.9.3`：指定安装路径为 `/usr/local/software/gdal-3.9.3`。

**安装 GDAL**

使用以下命令安装 GDAL 到系统中：

```bash
make install
```

**配置库路径**

添加 GDAL 库的路径到系统动态链接器配置中：

```bash
echo "/usr/local/software/gdal-3.9.3/lib64" | sudo tee /etc/ld.so.conf.d/gdal-3.9.3.conf
sudo ldconfig
```

- `sudo ldconfig`：刷新动态链接器运行时绑定。



## 编译和安装CGAL

CGAL（Computational Geometry Algorithms Library）是一个用于计算几何的开源库。

**下载和解压 CGAL**

下载 CGAL 5.6.2 的源代码并解压到当前目录：

```bash
wget https://github.com/CGAL/cgal/releases/download/v5.6.2/CGAL-5.6.2.tar.xz
tar xf CGAL-5.6.2.tar.xz
cd CGAL-5.6.2
```

**配置和构建**

创建一个 `build` 目录，并在其中配置和构建 CGAL：

```bash
mkdir build
cd build
cmake .. \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_PREFIX=/usr/local/software/CGAL-5.6.2
make
```

- `-DCMAKE_BUILD_TYPE=Release`：指定构建类型为 Release，用于优化性能。
- `-DCMAKE_INSTALL_PREFIX=/usr/local/software/CGAL-5.6.2`：指定安装路径为 `/usr/local/software/CGAL-5.6.2`。

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

下载 SFCGAL 1.5.2 的源代码并解压到当前目录：

```bash
wget https://gitlab.com/sfcgal/SFCGAL/-/archive/v1.5.2/SFCGAL-v1.5.2.tar.gz
tar -zxf SFCGAL-v1.5.2.tar.gz
cd SFCGAL-v1.5.2
```

**配置和构建**

创建一个 `build` 目录，并在其中配置和构建 SFCGAL：

```bash
mkdir build
cd build
cmake .. \
  -DCMAKE_BUILD_TYPE=Release \
  -DCGAL_DIR=/usr/local/software/CGAL-5.6.2 \
  -DCMAKE_INSTALL_PREFIX=/usr/local/software/SFCGAL-v1.5.2
make -j$(nproc)
```

- `-DCMAKE_BUILD_TYPE=Release`：指定构建类型为 Release，用于优化性能。
- `-DCGAL_DIR=/usr/local/software/CGAL-5.6.2`：指定 CGAL 的安装路径。
- `-DCMAKE_INSTALL_PREFIX=/usr/local/software/SFCGAL-v1.5.2`：指定安装路径为 `/usr/local/software/SFCGAL-v1.5.2`。

**安装 SFCGAL**

使用以下命令安装 SFCGAL 到系统中：

```bash
make install
```

**配置库路径**

添加 SFCGAL库的路径到系统动态链接器配置中：

```bash
echo "/usr/local/software/SFCGAL-v1.5.2/lib64" | sudo tee /etc/ld.so.conf.d/SFCGAL-v1.5.2.conf
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

下载 PostGIS 3.5.0 的源代码并解压到当前目录：

```bash
wget https://download.osgeo.org/postgis/source/postgis-3.5.0.tar.gz
tar -zxf postgis-3.5.0.tar.gz
cd postgis-3.5.0
```

**配置和构建**

使用 `configure` 脚本配置并构建 PostGIS，指定相关路径和选项：

```bash
./configure \
  --prefix=/usr/local/software/postgis-3.5.0 \
  --with-pgconfig=/usr/local/software/postgresql-17.2/bin/pg_config \
  --with-gdalconfig=/usr/local/software/gdal-3.9.3/bin/gdal-config \
  --with-sfcgal=/usr/local/software/SFCGAL-v1.5.2/bin/sfcgal-config
make -j$(nproc)
```

- `--prefix=/usr/local/software/postgis-3.5.0`：指定安装路径为 `/usr/local/software/postgis-3.5.0`。
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