# MySQL 8 使用文档

## 1. 基础概述

### 1.1 MySQL 8 新特性简介
MySQL 8 引入了许多新特性，提升了性能、管理便利性和安全性，主要包括以下几个方面：
   - **JSON 支持增强**：提供了对 JSON 数据类型和 JSON 函数的扩展支持。
   - **窗口函数（Window Functions）**：新增了 `ROW_NUMBER()`、`RANK()` 等窗口函数，支持复杂的数据分析。
   - **公用表表达式（Common Table Expressions, CTE）**：支持使用 `WITH` 语句，便于递归查询和简化 SQL 语句。
   - **隐式列（Invisible Columns）**：允许创建表时设置列为“隐形”，使其对 `SELECT *` 语句不可见，便于灵活设计。
   - **角色（Roles）管理**：增加了对用户权限的角色管理，方便授权和权限管理。
   - **查询性能优化**：包括更高效的索引算法、优化器改进、无锁表查询等。
   - **地理空间数据支持**：增强了对空间数据的支持，便于存储和查询地理数据。
   - **自动化管理**：支持复制集群（InnoDB Cluster）和组复制，提供更高可用性和自动化管理支持。

### 1.2 基本数据库概念
   - **数据库（Database）**：数据的集合，用来存储和组织信息。在 MySQL 中，一个数据库对应多个表。
   - **表（Table）**：存储数据的基本单位，由行和列组成。每个表都有特定的结构和数据类型。
   - **行（Row）和列（Column）**：行代表一条记录，列代表一个数据字段，行和列共同定义了数据表的结构。
   - **主键（Primary Key）**：唯一标识表中的每一行数据的列或多列。
   - **外键（Foreign Key）**：用于关联不同表之间的数据，通过外键来实现关系型数据的完整性。
   - **索引（Index）**：加速数据查询的结构，常用索引类型包括 B-Tree 索引和 Full-text 索引。
   - **视图（View）**：基于查询创建的虚拟表，不保存实际数据，通常用于简化复杂查询。

### 1.3 连接 MySQL 数据库
在 MySQL 8 中，可以使用命令行和图形化界面工具（如 MySQL Workbench）连接到数据库。

   - **命令行连接**：
     ```bash
     mysql -u 用户名 -p -h 主机地址 -P 端口号
     ```
     - `-u`：指定用户名
     - `-p`：提示输入密码
     - `-h`：服务器地址（默认本地：127.0.0.1）
     - `-P`：端口号（默认 3306）

   - **使用 MySQL Workbench 连接**：
     1. 打开 MySQL Workbench。
     2. 创建新的连接，输入主机名、用户名和密码等信息。
     3. 测试连接并保存即可。

---

## 2. 数据库和表的基本操作

### 2.1 创建和删除数据库

   - **创建数据库**：
     ```sql
     CREATE DATABASE 数据库名;
     ```
     可选项：
     ```sql
     CREATE DATABASE 数据库名 CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
     ```
     - `CHARACTER SET`：设置字符集，`utf8mb4` 支持更多字符。
     - `COLLATE`：指定排序规则。

   - **删除数据库**：
     ```sql
     DROP DATABASE 数据库名;
     ```
     *注意：删除数据库将清除其中所有表和数据。*

### 2.2 创建、修改和删除表

   - **创建表**：
     ```sql
     CREATE TABLE 表名 (
         列名 数据类型 [列约束],
         ...
     );
     ```
     示例：
     ```sql
     CREATE TABLE users (
         id INT AUTO_INCREMENT PRIMARY KEY,
         name VARCHAR(50) NOT NULL,
         age INT,
         email VARCHAR(100) UNIQUE
     );
     ```

   - **修改表**：
     - 添加新列：
       ```sql
       ALTER TABLE 表名 ADD 列名 数据类型 [列约束];
       ```
     - 修改列类型：
       ```sql
       ALTER TABLE 表名 MODIFY 列名 新数据类型;
       ```
     - 删除列：
       ```sql
       ALTER TABLE 表名 DROP COLUMN 列名;
       ```

   - **删除表**：
     ```sql
     DROP TABLE 表名;
     ```

### 2.3 表结构设计：数据类型及约束

   - **常用数据类型**：
     - 数字类型：`INT`、`BIGINT`、`DECIMAL`、`FLOAT` 等。
     - 字符串类型：`CHAR`、`VARCHAR`、`TEXT` 等。
     - 日期时间类型：`DATE`、`DATETIME`、`TIMESTAMP` 等。
     - JSON 类型：用于存储 JSON 格式数据。
     - 布尔类型：`BOOLEAN`（实际为 TINYINT）。
   
   - **约束**：
     - **PRIMARY KEY**：主键，唯一标识一行数据。
     - **UNIQUE**：唯一约束，保证列中的数据不重复。
     - **FOREIGN KEY**：外键，用于关联其他表的列。
     - **CHECK**：检查约束，限制列中数据满足条件。

### 2.4 索引的创建与管理

   - **创建索引**：
     ```sql
     CREATE INDEX 索引名 ON 表名(列名);
     ```
     - 索引可以显著提高查询速度，适用于经常查询的列。

   - **删除索引**：
     ```sql
     DROP INDEX 索引名 ON 表名;
     ```

   - **索引类型**：
     - **B-Tree 索引**：最常见的索引类型，用于范围查询和排序。
     - **Full-text 索引**：全文索引，支持全文搜索，适用于文本数据。
     - **Spatial 索引**：用于地理空间数据查询，如经纬度查询。

## 3. 数据操作

### 3.1 插入数据（INSERT）

MySQL 中的 `INSERT` 语句用于向表中插入一条或多条新记录。

#### 插入单条记录

```sql
INSERT INTO 表名 (列1, 列2, ...) VALUES (值1, 值2, ...);
```

示例：

```sql
INSERT INTO users (name, age, email) VALUES ('Alice', 30, 'alice@example.com');
```

#### 插入多条记录

```sql
INSERT INTO 表名 (列1, 列2, ...) VALUES (值1, 值2, ...), (值1, 值2, ...), ...;
```

示例：

```sql
INSERT INTO users (name, age, email) VALUES 
('Bob', 25, 'bob@example.com'), 
('Carol', 28, 'carol@example.com');
```

#### 插入部分列

在不需要为所有列提供值的情况下，可以只指定部分列，未指定的列将使用默认值（如有设置），或为 `NULL`。

```sql
INSERT INTO users (name, email) VALUES ('Dave', 'dave@example.com');
```

#### 插入时避免重复数据 - `INSERT IGNORE`

若希望在插入时忽略重复的数据（例如，已存在相同的唯一键值），可以使用 `INSERT IGNORE`。

```sql
INSERT IGNORE INTO users (id, name, age, email) VALUES (1, 'Eve', 22, 'eve@example.com');
```

#### 更新或插入 - `INSERT ... ON DUPLICATE KEY UPDATE`

该语法用于在插入记录时，如果存在主键或唯一索引冲突时执行更新操作。

```sql
INSERT INTO users (id, name, age, email) VALUES (1, 'Eve', 22, 'eve@example.com')
ON DUPLICATE KEY UPDATE age = 23;
```

---

### 3.2 查询数据（SELECT）

MySQL 中的 `SELECT` 语句用于从表中检索数据，并支持多种查询条件和功能。

#### 基础查询

```sql
SELECT 列1, 列2, ... FROM 表名;
```

示例：

```sql
SELECT name, age FROM users;
```

#### 查询所有列

使用 `*` 查询所有列。

```sql
SELECT * FROM users;
```

#### 添加条件 - `WHERE`

可以使用 `WHERE` 子句来限制查询结果。

```sql
SELECT * FROM users WHERE age > 25;
```

#### 排序结果 - `ORDER BY`

使用 `ORDER BY` 按指定列排序，`ASC` 为升序，`DESC` 为降序。

```sql
SELECT * FROM users ORDER BY age DESC;
```

#### 限制查询结果 - `LIMIT`

`LIMIT` 用于限制返回结果的数量，通常与分页查询结合使用。

```sql
SELECT * FROM users ORDER BY age DESC LIMIT 5;
```

#### 多表查询（JOIN）

MySQL 支持多种表连接方式，常见连接方式包括内连接、左连接、右连接。

##### 内连接（INNER JOIN）

```sql
SELECT u.name, o.order_date 
FROM users u
INNER JOIN orders o ON u.id = o.user_id;
```

##### 左连接（LEFT JOIN）

```sql
SELECT u.name, o.order_date 
FROM users u
LEFT JOIN orders o ON u.id = o.user_id;
```

#### 聚合查询（GROUP BY, HAVING）

MySQL 支持多种聚合函数，包括 `COUNT`、`SUM`、`AVG`、`MAX` 和 `MIN`。

##### 使用 `GROUP BY`

```sql
SELECT age, COUNT(*) AS count 
FROM users 
GROUP BY age;
```

##### 使用 `HAVING`

`HAVING` 用于过滤分组结果。

```sql
SELECT age, COUNT(*) AS count 
FROM users 
GROUP BY age 
HAVING count > 1;
```

#### 子查询

子查询是在另一个查询中嵌套的查询，通常用于复杂查询。

##### 在 `WHERE` 子句中使用子查询

```sql
SELECT * FROM users 
WHERE age = (SELECT MAX(age) FROM users);
```

##### 在 `FROM` 子句中使用子查询

```sql
SELECT AVG(age) AS avg_age 
FROM (SELECT age FROM users WHERE age > 20) AS subquery;
```

---

### 3.3 更新数据（UPDATE）

`UPDATE` 语句用于修改表中已存在的数据。

#### 基本用法

```sql
UPDATE 表名 SET 列1 = 新值1, 列2 = 新值2, ... WHERE 条件;
```

示例：

```sql
UPDATE users 
SET age = 31 
WHERE name = 'Alice';
```

#### 更新多列

可以同时更新多个列。

```sql
UPDATE users 
SET age = 32, email = 'alice_new@example.com' 
WHERE name = 'Alice';
```

#### 使用条件更新

**注意**：如果没有 `WHERE` 子句，`UPDATE` 会更新表中的所有行。

```sql
UPDATE users 
SET age = age + 1 
WHERE age > 30;
```

#### 防止多行更新错误

可以使用 `LIMIT` 限制更新的行数。

```sql
UPDATE users 
SET age = age + 1 
WHERE age > 25 
LIMIT 5;
```

---

### 3.4 删除数据（DELETE）

`DELETE` 语句用于删除表中的记录。

#### 基本用法

```sql
DELETE FROM 表名 WHERE 条件;
```

示例：

```sql
DELETE FROM users WHERE age < 20;
```

#### 删除所有记录

使用 `DELETE` 删除所有记录时，如果不加 `WHERE` 条件，则会删除表中的所有数据。

```sql
DELETE FROM users;
```

#### 使用 `LIMIT` 限制删除记录数

可以在删除操作中使用 `LIMIT` 限制删除的行数。

```sql
DELETE FROM users 
WHERE age > 30 
LIMIT 5;
```

#### `DELETE` 和 `TRUNCATE` 的区别

- **DELETE**：逐行删除记录，通常会记录到事务日志中，可以回滚。
- **TRUNCATE**：直接清空整个表数据，不能逐行控制且不能回滚。

使用 `TRUNCATE`：

```sql
TRUNCATE TABLE users;
```

## 4. 函数的用法

MySQL 提供了丰富的内置函数，可以帮助用户在查询和数据操作时处理各种数据。常见的函数类型包括 **字符串函数**、**数值函数**、**日期和时间函数**、**聚合函数** 和 **控制流函数**。

---

### 4.1 字符串函数

字符串函数用于处理和操作字符串数据。

#### 4.1.1 `CONCAT` - 拼接字符串

将多个字符串连接为一个字符串。

```sql
SELECT CONCAT('Hello, ', 'World!') AS greeting;
-- 输出: "Hello, World!"
```

#### 4.1.2 `SUBSTRING` - 提取子字符串

从指定位置开始提取子字符串。

```sql
SELECT SUBSTRING('Hello, World!', 8, 5) AS substring;
-- 输出: "World"
```

#### 4.1.3 `LOWER` 和 `UPPER` - 字符串大小写转换

将字符串转换为小写或大写。

```sql
SELECT LOWER('HELLO') AS lowercase, UPPER('hello') AS uppercase;
-- 输出: lowercase: "hello", uppercase: "HELLO"
```

#### 4.1.4 `TRIM` - 去除空格

去除字符串开头或结尾的空格。

```sql
SELECT TRIM('   MySQL   ') AS trimmed;
-- 输出: "MySQL"
```

#### 4.1.5 `REPLACE` - 字符串替换

替换字符串中的指定子字符串。

```sql
SELECT REPLACE('Hello, World!', 'World', 'MySQL') AS replaced;
-- 输出: "Hello, MySQL!"
```

---

### 4.2 数值函数

数值函数用于处理和操作数字数据。

#### 4.2.1 `ABS` - 绝对值

返回数值的绝对值。

```sql
SELECT ABS(-10) AS absolute_value;
-- 输出: 10
```

#### 4.2.2 `CEILING` 和 `FLOOR` - 向上或向下取整

- `CEILING` 向上取整
- `FLOOR` 向下取整

```sql
SELECT CEILING(4.3) AS ceiling_value, FLOOR(4.7) AS floor_value;
-- 输出: ceiling_value: 5, floor_value: 4
```

#### 4.2.3 `ROUND` - 四舍五入

对数值进行四舍五入。

```sql
SELECT ROUND(4.567, 2) AS rounded_value;
-- 输出: 4.57
```

#### 4.2.4 `RAND` - 生成随机数

生成 0 到 1 之间的随机数。

```sql
SELECT RAND() AS random_value;
-- 输出: 随机数，如 0.7325
```

---

### 4.3 日期和时间函数

日期和时间函数用于处理和操作日期和时间数据。

#### 4.3.1 `NOW` 和 `CURDATE` - 获取当前时间和日期

- `NOW()` 返回当前日期和时间。
- `CURDATE()` 返回当前日期，不包含时间。

```sql
SELECT NOW() AS current_datetime, CURDATE() AS current_date;
-- 输出: 当前日期和时间，如 "2024-11-07 10:15:45" 和 "2024-11-07"
```

#### 4.3.2 `DATE_ADD` 和 `DATE_SUB` - 日期加减

用于在日期上加或减去指定的时间间隔。

```sql
SELECT DATE_ADD('2024-11-07', INTERVAL 10 DAY) AS new_date;
-- 输出: "2024-11-17"
```

#### 4.3.3 `DATEDIFF` - 计算日期差

计算两个日期之间的天数差。

```sql
SELECT DATEDIFF('2024-12-25', '2024-11-07') AS date_difference;
-- 输出: 48
```

#### 4.3.4 `EXTRACT` - 提取日期部分

提取日期或时间的指定部分，例如年份、月份、天等。

```sql
SELECT EXTRACT(YEAR FROM '2024-11-07') AS year_part;
-- 输出: 2024
```

---

### 4.4 聚合函数

聚合函数用于对一组数据进行计算和聚合，常用于分组和统计数据。

#### 4.4.1 `COUNT` - 计数

计算指定列中非空值的数量。

```sql
SELECT COUNT(*) AS total_users FROM users;
-- 输出: 例如，"total_users": 5
```

#### 4.4.2 `SUM` - 求和

计算指定列中所有数值的和。

```sql
SELECT SUM(salary) AS total_salary FROM employees;
-- 输出: 总工资，如 50000
```

#### 4.4.3 `AVG` - 平均值

计算指定列中所有数值的平均值。

```sql
SELECT AVG(age) AS average_age FROM users;
-- 输出: 平均年龄，如 30
```

#### 4.4.4 `MAX` 和 `MIN` - 最大值和最小值

- `MAX` 返回列中的最大值
- `MIN` 返回列中的最小值

```sql
SELECT MAX(salary) AS max_salary, MIN(salary) AS min_salary FROM employees;
-- 输出: 最大工资和最小工资，如 max_salary: 10000, min_salary: 2000
```

---

### 4.5 控制流函数

控制流函数允许在查询中加入条件逻辑，例如判断某个条件是否成立并返回相应的结果。

#### 4.5.1 `IF` - 条件判断

根据条件判断返回不同的值。

```sql
SELECT name, IF(age > 18, 'Adult', 'Minor') AS age_group FROM users;
-- 输出: 对于 age > 18 的用户返回 "Adult"，否则返回 "Minor"
```

#### 4.5.2 `IFNULL` - 空值处理

当值为 `NULL` 时返回指定的替代值。

```sql
SELECT name, IFNULL(email, 'No Email') AS email_info FROM users;
-- 输出: 如果 email 为空，返回 "No Email"，否则返回实际 email
```

#### 4.5.3 `CASE` - 多条件判断

`CASE` 可以用于多条件判断，类似于多重 `IF`。

```sql
SELECT name,
    CASE 
        WHEN age < 18 THEN 'Minor'
        WHEN age BETWEEN 18 AND 60 THEN 'Adult'
        ELSE 'Senior'
    END AS age_category
FROM users;
-- 输出: 根据 age 的范围返回不同的年龄组，如 "Minor"、"Adult" 或 "Senior"
```

---

### 4.6 JSON 函数

MySQL 8 增强了对 JSON 数据类型的支持，提供了许多用于操作 JSON 的函数。

#### 4.6.1 `JSON_OBJECT` - 创建 JSON 对象

创建一个 JSON 对象。

```sql
SELECT JSON_OBJECT('name', 'Alice', 'age', 25) AS user_json;
-- 输出: {"name": "Alice", "age": 25}
```

#### 4.6.2 `JSON_EXTRACT` - 提取 JSON 值

从 JSON 对象中提取指定的值。

```sql
SELECT JSON_EXTRACT('{"name": "Alice", "age": 25}', '$.name') AS extracted_name;
-- 输出: "Alice"
```

#### 4.6.3 `JSON_ARRAY` - 创建 JSON 数组

将多个值组合成一个 JSON 数组。

```sql
SELECT JSON_ARRAY('apple', 'banana', 'cherry') AS fruit_array;
-- 输出: ["apple", "banana", "cherry"]
```

#### 4.6.4 `JSON_MERGE_PATCH` - 合并 JSON 对象

合并两个 JSON 对象，若键冲突则覆盖前者。

```sql
SELECT JSON_MERGE_PATCH('{"name": "Alice"}', '{"age": 25}') AS merged_json;
-- 输出: {"name": "Alice", "age": 25}
```

## 5. 窗口函数

窗口函数用于在特定“窗口”范围内计算聚合值（如累计和、排名、百分比等），而不影响整个查询结果的每一行。窗口函数的结果会基于每一行，并可设置排序和窗口范围，适合数据分析的复杂计算。

### 5.1 窗口函数的基本语法

在 MySQL 中，窗口函数的通用语法为：

```sql
函数() OVER ([PARTITION BY 分区列] [ORDER BY 排序列] [窗口框架])
```

- `PARTITION BY`：按指定列对数据进行分区，类似于 `GROUP BY`，但窗口函数不会合并行。
- `ORDER BY`：指定在窗口内的排序方式。
- 窗口框架（如 `ROWS` 或 `RANGE`）：定义窗口的范围，可选择性地用于累计、滑动窗口等操作。

### 5.2 常见的窗口函数

#### 5.2.1 `ROW_NUMBER` - 行号

`ROW_NUMBER` 为每一行分配唯一的行号。行号从 1 开始，并在每个分区内递增。

```sql
SELECT name, department, salary,
       ROW_NUMBER() OVER (PARTITION BY department ORDER BY salary DESC) AS row_num
FROM employees;
-- 输出: 每个部门中按工资降序排序的行号
```

#### 5.2.2 `RANK` 和 `DENSE_RANK` - 排名

- **`RANK`**：分配排名，但当遇到相同值时会跳过排名。
- **`DENSE_RANK`**：类似 `RANK`，但不会跳过排名。

```sql
SELECT name, department, salary,
       RANK() OVER (PARTITION BY department ORDER BY salary DESC) AS rank,
       DENSE_RANK() OVER (PARTITION BY department ORDER BY salary DESC) AS dense_rank
FROM employees;
-- 输出: 每个部门按工资降序排名，RANK 有跳跃，DENSE_RANK 连续
```

#### 5.2.3 `NTILE` - 分组

`NTILE` 将结果划分为指定数量的相等组，并为每一行分配一个组号。适合用来生成分布式分析，如四分位数、百分位等。

```sql
SELECT name, department, salary,
       NTILE(4) OVER (ORDER BY salary DESC) AS quartile
FROM employees;
-- 输出: 将员工按工资降序分为四个组（四分位数）
```

### 5.3 聚合函数的窗口版

许多标准聚合函数（如 `SUM`、`AVG`、`MIN`、`MAX` 等）可以作为窗口函数使用，适用于分区或滑动窗口计算。

#### 5.3.1 `SUM` - 窗口内累计和

计算每一行的累计和。

```sql
SELECT name, department, salary,
       SUM(salary) OVER (PARTITION BY department ORDER BY name) AS cumulative_salary
FROM employees;
-- 输出: 每个部门内员工工资的累计和
```

#### 5.3.2 `AVG` - 窗口内平均值

```sql
SELECT name, department, salary,
       AVG(salary) OVER (PARTITION BY department ORDER BY salary) AS average_salary
FROM employees;
-- 输出: 每个部门内员工工资的平均值
```

#### 5.3.3 `MIN` 和 `MAX` - 窗口内最小值和最大值

返回窗口内的最小值或最大值。

```sql
SELECT name, department, salary,
       MIN(salary) OVER (PARTITION BY department) AS min_salary,
       MAX(salary) OVER (PARTITION BY department) AS max_salary
FROM employees;
-- 输出: 每个部门内的最小和最大工资
```

### 5.4 窗口框架

窗口框架进一步指定窗口函数的计算范围，使用 `ROWS` 或 `RANGE` 子句来定义。可以实现滑动窗口和累计窗口等效果。

#### 5.4.1 `ROWS` - 基于行的窗口框架

`ROWS` 指定基于当前行的相对位置。

- `ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW`：表示从窗口的第一行到当前行。
- `ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING`：表示从前一行到后一行。

示例：计算每行当前行及之前两行的累计和。

```sql
SELECT name, department, salary,
       SUM(salary) OVER (ORDER BY salary 
                         ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS sliding_sum
FROM employees;
-- 输出: 当前行及前两行的工资和
```

#### 5.4.2 `RANGE` - 基于值的窗口框架

`RANGE` 用于基于值范围的窗口定义，适合按金额、日期等值范围计算累计等。

- `RANGE BETWEEN INTERVAL 1 DAY PRECEDING AND INTERVAL 1 DAY FOLLOWING`：表示从前一天到后一天的值。

示例：计算当前行及前一天的销售总额。

```sql
SELECT sale_date, amount,
       SUM(amount) OVER (ORDER BY sale_date 
                         RANGE BETWEEN INTERVAL 1 DAY PRECEDING AND CURRENT ROW) AS sales_sum
FROM sales;
-- 输出: 当前日期及前一天的销售累计
```

### 5.5 实用示例

#### 5.5.1 计算累计销售额

统计每一天的累计销售额。

```sql
SELECT sale_date, amount,
       SUM(amount) OVER (ORDER BY sale_date) AS cumulative_sales
FROM sales;
-- 输出: 每一天及之前的累计销售额
```

#### 5.5.2 按部门统计每个员工的工资排名

计算每个员工在各自部门内的工资排名。

```sql
SELECT name, department, salary,
       RANK() OVER (PARTITION BY department ORDER BY salary DESC) AS department_rank
FROM employees;
-- 输出: 每个部门按工资排名的员工
```

#### 5.5.3 分析员工工资的百分位数

将员工按工资分为 10 个组，统计其工资的百分位数。

```sql
SELECT name, department, salary,
       NTILE(10) OVER (ORDER BY salary DESC) AS percentile
FROM employees;
-- 输出: 每个员工对应的工资百分位数
```

#### 5.5.4 计算过去 7 天的滑动平均销售额

通过滑动窗口计算过去 7 天的平均销售额。

```sql
SELECT sale_date, amount,
       AVG(amount) OVER (ORDER BY sale_date 
                         ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) AS moving_avg_7_days
FROM sales;
-- 输出: 每天及过去6天的平均销售额
```

## 6. 高级查询和数据处理

高级查询和数据处理包括子查询、联合查询、视图、存储过程和触发器等内容，用于实现复杂数据操作和优化查询效率。

### 6.1 子查询

子查询是嵌套在其他查询语句中的查询，可用于返回值或数据集，以支持主查询的执行。

#### 6.1.1 单行子查询

返回单个值的子查询，常用于比较。

```sql
SELECT name, salary
FROM employees
WHERE salary > (SELECT AVG(salary) FROM employees);
-- 输出: 所有工资高于平均工资的员工
```

#### 6.1.2 多行子查询

返回多个值的子查询，常与 `IN`、`ANY` 或 `ALL` 一起使用。

```sql
SELECT name
FROM employees
WHERE department_id IN (SELECT department_id FROM departments WHERE location = 'New York');
-- 输出: 所有在纽约的部门员工
```

#### 6.1.3 相关子查询

相关子查询依赖于主查询的值，会针对每一行执行。

```sql
SELECT e1.name, e1.salary
FROM employees e1
WHERE e1.salary > (SELECT AVG(e2.salary) FROM employees e2 WHERE e2.department_id = e1.department_id);
-- 输出: 每个部门内高于部门平均工资的员工
```

### 6.2 联合查询（UNION）

`UNION` 操作符用于合并多个 `SELECT` 查询的结果，去除重复行（使用 `UNION ALL` 保留重复行）。

```sql
SELECT name, 'Department' AS source
FROM departments
UNION
SELECT name, 'Employee' AS source
FROM employees;
-- 输出: 部门和员工的所有名称，带来源标识
```

### 6.3 视图（VIEW）

视图是基于查询结果的虚拟表，便于复用复杂查询。

#### 6.3.1 创建视图

```sql
CREATE VIEW high_salary_employees AS
SELECT name, salary, department
FROM employees
WHERE salary > 10000;
-- 创建视图：筛选工资高于10000的员工
```

#### 6.3.2 使用视图

```sql
SELECT * FROM high_salary_employees;
-- 输出: 视图中高工资员工的信息
```

#### 6.3.3 更新视图

可以更新某些视图的数据，但受视图定义限制。

```sql
UPDATE high_salary_employees SET salary = salary + 500 WHERE name = 'Alice';
-- 增加指定员工的工资
```

### 6.4 存储过程（Stored Procedure）

存储过程是存储在数据库中的一组 SQL 语句，可以简化重复任务。

#### 6.4.1 创建存储过程

```sql
DELIMITER //
CREATE PROCEDURE increase_salary(IN emp_id INT, IN amount DECIMAL(10, 2))
BEGIN
    UPDATE employees SET salary = salary + amount WHERE id = emp_id;
END //
DELIMITER ;
-- 创建一个增加指定员工工资的存储过程
```

#### 6.4.2 调用存储过程

```sql
CALL increase_salary(1, 500);
-- 增加员工 ID 为 1 的员工工资 500
```

### 6.5 触发器（Trigger）

触发器是在指定事件发生时自动执行的 SQL 语句集合，通常用于数据完整性验证或日志记录。

#### 6.5.1 创建触发器

```sql
CREATE TRIGGER before_employee_insert
BEFORE INSERT ON employees
FOR EACH ROW
BEGIN
    IF NEW.salary < 0 THEN
        SET NEW.salary = 0;
    END IF;
END;
-- 创建触发器：在插入员工记录时检查工资，不允许负值
```

---

## 7. 用户与权限管理

MySQL 提供了完善的用户权限管理机制，以确保数据库的安全性和访问控制。可以通过创建用户和分配权限来控制用户访问的范围和操作权限。

### 7.1 创建和管理用户

创建用户时指定用户名和主机，用户可以在同一数据库上有不同的权限。

#### 7.1.1 创建用户

```sql
CREATE USER 'username'@'localhost' IDENTIFIED BY 'password';
-- 创建名为 'username' 的用户，仅允许从本地主机访问
```

#### 7.1.2 删除用户

```sql
DROP USER 'username'@'localhost';
-- 删除用户 'username'
```

### 7.2 分配权限

权限可以基于数据库、表、列、甚至特定操作进行分配。以下是常见权限类型：

- **ALL PRIVILEGES**：所有权限。
- **SELECT**：查询数据的权限。
- **INSERT**：插入数据的权限。
- **UPDATE**：更新数据的权限。
- **DELETE**：删除数据的权限。
- **CREATE**、**DROP**：创建和删除数据库对象的权限。
- **EXECUTE**：执行存储过程和函数的权限。

#### 7.2.1 授予权限

```sql
GRANT SELECT, INSERT ON database_name.* TO 'username'@'localhost';
-- 赋予用户在指定数据库上查询和插入的权限
```

#### 7.2.2 撤销权限

```sql
REVOKE INSERT ON database_name.* FROM 'username'@'localhost';
-- 撤销用户在指定数据库上插入数据的权限
```

#### 7.2.3 查看权限

使用 `SHOW GRANTS` 查看用户的权限。

```sql
SHOW GRANTS FOR 'username'@'localhost';
-- 输出: 用户在各数据库上的权限
```

### 7.3 角色管理

MySQL 8 中引入了角色，可以将权限集赋给角色，再将角色赋给用户，便于管理。

#### 7.3.1 创建角色

```sql
CREATE ROLE 'manager';
-- 创建一个角色 'manager'
```

#### 7.3.2 分配权限给角色

```sql
GRANT SELECT, INSERT, UPDATE ON database_name.* TO 'manager';
-- 将权限授予角色 'manager'
```

#### 7.3.3 将角色分配给用户

```sql
GRANT 'manager' TO 'username'@'localhost';
-- 将 'manager' 角色分配给 'username'
```

#### 7.3.4 启用角色

用户登录后，需启用角色以获得角色权限。

```sql
SET ROLE 'manager';
-- 启用 'manager' 角色的权限
```

## 8. 备份与恢复

数据库的备份和恢复是数据管理中至关重要的一环。备份用于在数据丢失或损坏时能够恢复数据。MySQL 支持多种备份方式，包括逻辑备份和物理备份。以下是常用的备份与恢复方法。

### 8.1 逻辑备份

逻辑备份是通过 SQL 语句（如 `mysqldump` 工具）将数据库中的数据和表结构导出到一个文本文件中。这种备份适合小型数据库和需要跨平台迁移的场景。

#### 8.1.1 使用 `mysqldump` 工具进行备份

**`mysqldump`** 是 MySQL 提供的备份工具，可以将数据库或表导出为 SQL 文件。

- **备份单个数据库**：

```bash
mysqldump -u username -p database_name > backup.sql
-- 说明: 将 `database_name` 数据库导出到 backup.sql 文件
```

- **备份多个数据库**：

```bash
mysqldump -u username -p --databases database1 database2 > backup_multi.sql
-- 说明: 导出 `database1` 和 `database2` 到 backup_multi.sql
```

- **备份所有数据库**：

```bash
mysqldump -u username -p --all-databases > backup_all.sql
-- 说明: 导出所有数据库
```

- **备份特定表**：

```bash
mysqldump -u username -p database_name table1 table2 > backup_tables.sql
-- 说明: 导出 `database_name` 中的 `table1` 和 `table2`
```

- **备份结构而不包含数据**：

```bash
mysqldump -u username -p --no-data database_name > backup_structure.sql
-- 说明: 仅导出数据库结构，不包括数据
```

- **备份数据而不包含结构**：

```bash
mysqldump -u username -p --no-create-info database_name > backup_data.sql
-- 说明: 仅导出数据库数据，不包括结构
```

#### 8.1.2 `mysqldump` 的其他常用选项

- `--routines`：包含存储过程和函数。
- `--triggers`：包含触发器。
- `--single-transaction`：在 InnoDB 引擎上进行一致性备份。
  

示例：

```bash
mysqldump -u username -p --routines --triggers --single-transaction database_name > backup_full.sql
-- 说明: 完整备份，包括结构、数据、存储过程、触发器
```

#### 8.1.3 恢复逻辑备份

**恢复备份的 SQL 文件** 使用 `mysql` 命令。

```bash
mysql -u username -p database_name < backup.sql
-- 说明: 将 backup.sql 文件中的数据恢复到 `database_name` 数据库
```

**恢复多个数据库或所有数据库**：

```bash
mysql -u username -p < backup_multi.sql
-- 说明: 恢复多个数据库，适用于使用 --databases 或 --all-databases 导出的文件
```

### 8.2 物理备份

物理备份是直接复制数据库的文件，包括数据文件和日志文件，适合大规模数据库或需要快速恢复的场景。`InnoDB` 存储引擎的物理备份推荐使用 `MySQL Enterprise Backup` 工具或开源的 `Percona XtraBackup` 工具。

#### 8.2.1 使用 MySQL Enterprise Backup 工具

`MySQL Enterprise Backup` 是 MySQL 官方的物理备份工具，适用于 MySQL Enterprise Edition。以下是一些基本的操作示例：

- **完整备份**：

```bash
mysqlbackup --user=username --password --backup-dir=/path/to/backup/ --backup-image=backup.mbi backup-to-image
-- 说明: 创建一个完整备份并保存为 `backup.mbi`
```

- **增量备份**：

```bash
mysqlbackup --user=username --password --incremental --incremental-base=history:last_backup --backup-dir=/path/to/backup/incremental/ --backup-image=incremental_backup.mbi backup-to-image
-- 说明: 基于上次备份创建一个增量备份
```

- **恢复备份**：

```bash
mysqlbackup --user=username --password --backup-image=backup.mbi --backup-dir=/path/to/restore-dir copy-back-and-apply-log
-- 说明: 从备份镜像恢复数据
```

#### 8.2.2 使用 Percona XtraBackup 工具

`Percona XtraBackup` 是开源的物理备份工具，可用于 `InnoDB` 引擎的物理备份。

- **完整备份**：

```bash
xtrabackup --backup --target-dir=/path/to/backup/
-- 说明: 将完整备份保存到指定路径
```

- **增量备份**：

```bash
xtrabackup --backup --target-dir=/path/to/incremental_backup --incremental-basedir=/path/to/backup/
-- 说明: 基于指定的备份目录创建增量备份
```

- **应用日志并准备备份（准备恢复）**：

```bash
xtrabackup --prepare --target-dir=/path/to/backup/
-- 说明: 准备恢复备份
```

- **恢复备份**：

```bash
xtrabackup --copy-back --target-dir=/path/to/backup/
-- 说明: 将备份数据复制到 MySQL 数据库路径
```

### 8.3 二进制日志备份

二进制日志可以记录数据库的所有更改，适用于基于点时间的恢复、增量备份和数据同步。

#### 8.3.1 启用二进制日志

在 MySQL 配置文件（`my.cnf`）中添加以下设置以启用二进制日志：

```ini
[mysqld]
log-bin=mysql-bin
```

重启 MySQL 服务后，所有更改将记录在二进制日志中。

#### 8.3.2 使用 `mysqlbinlog` 备份和恢复

- **备份二进制日志**：

```bash
mysqlbinlog --read-from-remote-server --host=host --user=username --password --raw mysql-bin.000001 > binary_log_backup.sql
-- 说明: 将远程服务器的二进制日志导出到 SQL 文件
```

- **恢复二进制日志文件**：

```bash
mysqlbinlog mysql-bin.000001 | mysql -u username -p
-- 说明: 将二进制日志文件应用到数据库，恢复数据更改
```

- **基于时间点的恢复**：

```bash
mysqlbinlog --start-datetime="2023-01-01 10:00:00" --stop-datetime="2023-01-01 12:00:00" mysql-bin.000001 | mysql -u username -p
-- 说明: 仅应用指定时间段内的更改
```

- **基于事件位置的恢复**：

```bash
mysqlbinlog --start-position=120 --stop-position=400 mysql-bin.000001 | mysql -u username -p
-- 说明: 仅应用指定位置范围的更改
```

### 8.4 备份策略

设计备份策略需要考虑业务需求、数据量、备份时间和恢复时间等因素。通常推荐以下策略：

1. **完整备份**：每周进行一次。
2. **增量备份**：每日进行一次增量备份，保存较短时间的增量数据。
3. **二进制日志**：持续启用二进制日志以支持精细恢复。
4. **定期检查备份**：定期验证备份文件的完整性，以确保数据可用。

## 9. 性能优化

MySQL 性能优化涵盖多方面内容，包括数据库结构优化、索引使用、查询优化和系统配置调整等，以提升数据库的响应速度和处理效率。

### 9.1 表结构优化

表结构的设计会直接影响查询效率，因此选择合适的数据类型和索引至关重要。

#### 9.1.1 选择合适的数据类型

- 使用定长数据类型如 `CHAR` 代替 `VARCHAR`，对长度固定的数据（如国家代码）提升性能。
- 使用尽量小的数值类型，如 `TINYINT`、`SMALLINT` 等，以减少数据存储量。
- 尽量避免使用 `TEXT` 和 `BLOB`，可以将大数据放到文件系统中，存储文件路径。

#### 9.1.2 使用分区表

表分区将表划分为多个物理分区，提高查询速度。

```sql
CREATE TABLE sales (
    id INT,
    sale_date DATE,
    amount DECIMAL(10,2)
)
PARTITION BY RANGE (YEAR(sale_date)) (
    PARTITION p0 VALUES LESS THAN (2022),
    PARTITION p1 VALUES LESS THAN (2023),
    PARTITION p2 VALUES LESS THAN MAXVALUE
);
-- 根据年份分区，提升查询特定年份数据的效率
```

### 9.2 索引优化

索引是提升查询效率的重要方式。合理地使用索引可以极大地减少查询时间。

#### 9.2.1 创建合适的索引

- **单列索引**：适用于单列查询条件。

  ```sql
  CREATE INDEX idx_employee_name ON employees(name);
  ```

- **多列索引**：对组合查询条件有帮助。

  ```sql
  CREATE INDEX idx_employee_name_age ON employees(name, age);
  ```

#### 9.2.2 使用唯一索引

唯一索引能加速查询，且保证数据唯一性。

```sql
CREATE UNIQUE INDEX idx_employee_email ON employees(email);
```

#### 9.2.3 覆盖索引

覆盖索引指查询中所有字段都在索引中，不需要回表查询。

```sql
SELECT name FROM employees WHERE name = 'Alice';
-- 如果 'name' 有索引，不需要查询实际表
```

### 9.3 查询优化

#### 9.3.1 使用 `EXPLAIN` 分析查询

`EXPLAIN` 可帮助分析查询性能，确定是否使用了索引，是否存在全表扫描等。

```sql
EXPLAIN SELECT * FROM employees WHERE age > 30;
```

#### 9.3.2 避免使用 `SELECT *`

指定所需的列以减少数据读取量。

```sql
SELECT name, age FROM employees WHERE department_id = 1;
```

#### 9.3.3 避免函数操作字段

在字段上使用函数会导致全表扫描。

```sql
-- 不推荐
SELECT * FROM employees WHERE YEAR(birthdate) = 1990;
-- 推荐
SELECT * FROM employees WHERE birthdate BETWEEN '1990-01-01' AND '1990-12-31';
```

### 9.4 配置优化

#### 9.4.1 调整 `innodb_buffer_pool_size`

`innodb_buffer_pool_size` 决定了 InnoDB 存储引擎缓存的大小，通常设置为服务器内存的 50% 到 80%。

```ini
[mysqld]
innodb_buffer_pool_size = 4G
```

#### 9.4.2 调整 `query_cache_size`

对较小的数据集可以开启查询缓存，以减少重复查询。

```ini
[mysqld]
query_cache_size = 256M
```

#### 9.4.3 增大 `max_connections`

增大连接数限制以支持更多的并发用户连接。

```ini
[mysqld]
max_connections = 500
```

---

## 10. 安全性

MySQL 的安全性管理包括权限控制、网络访问控制、数据加密等措施，确保数据的机密性和完整性。

### 10.1 权限控制

权限控制是数据库安全的核心，用户权限配置应遵循最小权限原则。

```sql
GRANT SELECT, INSERT ON database_name.* TO 'username'@'localhost' IDENTIFIED BY 'password';
-- 仅授予基本权限，避免授予 ALL PRIVILEGES
```

### 10.2 网络安全

#### 10.2.1 限制网络访问

将 MySQL 绑定到指定的 IP 地址，限制非授权访问。

```ini
[mysqld]
bind-address = 127.0.0.1
```

#### 10.2.2 使用 SSL/TLS 加密通信

MySQL 支持通过 SSL/TLS 加密客户端和服务器之间的数据传输。

```sql
CREATE USER 'username'@'%' IDENTIFIED BY 'password' REQUIRE SSL;
-- 创建一个仅允许加密连接的用户
```

### 10.3 数据加密

MySQL 提供透明数据加密（TDE），可以加密 InnoDB 存储的数据文件。

#### 10.3.1 设置表加密

在加密支持启用的 MySQL 实例上，可以在创建表时指定加密。

```sql
CREATE TABLE employees (
    id INT,
    name VARCHAR(100)
) ENCRYPTION='Y';
-- 将表数据加密存储
```

### 10.4 审计日志

启用审计日志记录数据库的所有活动以便审计。

```ini
[mysqld]
plugin-load-add=audit_log.so
audit-log=ON
```

---

## 11. 常见问题及故障排查

MySQL 在实际运行中可能遇到各种问题，下面列出了一些常见问题及其解决方法。

### 11.1 MySQL 启动失败

#### 11.1.1 检查配置文件错误

在 `/etc/my.cnf` 或 `/etc/mysql/my.cnf` 中查找配置错误。

#### 11.1.2 查看错误日志

检查 MySQL 错误日志（通常位于 `/var/log/mysql/error.log`）以了解详细信息。

```bash
tail -f /var/log/mysql/error.log
```

### 11.2 数据库连接问题

#### 11.2.1 确保 MySQL 服务正在运行

```bash
systemctl status mysql
```

#### 11.2.2 检查用户权限

确保用户具有正确的主机访问权限和密码。

```sql
SHOW GRANTS FOR 'username'@'localhost';
```

### 11.3 性能问题

#### 11.3.1 慢查询日志

启用慢查询日志以识别低效查询。

```ini
[mysqld]
slow_query_log = 1
slow_query_log_file = /var/log/mysql/slow.log
long_query_time = 2
```

#### 11.3.2 使用 `EXPLAIN` 分析慢查询

使用 `EXPLAIN` 检查慢查询的执行计划，优化索引或重写查询。

### 11.4 锁等待超时

MySQL 中的锁机制可能导致超时问题，通常由并发冲突引起。

#### 11.4.1 使用 `SHOW PROCESSLIST`

查看当前进程列表，查找长时间等待的进程。

```sql
SHOW PROCESSLIST;
```

#### 11.4.2 强制终止长时间等待的事务

```sql
KILL process_id;
-- 终止指定的进程以释放锁
```

### 11.5 表损坏

表可能因崩溃或磁盘问题损坏，InnoDB 通常能自动恢复，但 MyISAM 表需要手动修复。

#### 11.5.1 修复 MyISAM 表

```sql
REPAIR TABLE table_name;
-- 修复损坏的 MyISAM 表
```

#### 11.5.2 检查 InnoDB 崩溃恢复

检查错误日志以确认是否需要重启数据库，InnoDB 会在重启时自动尝试恢复。

### 11.6 忘记 root 密码

重置 root 密码的步骤如下：

1. 启动 MySQL，禁用权限验证：

   ```bash
   mysqld_safe --skip-grant-tables &
   ```

2. 连接 MySQL，然后更新 root 密码：

   ```sql
   ALTER USER 'root'@'localhost' IDENTIFIED BY 'new_password';
   ```

3. 重启 MySQL，恢复正常安全模式。
