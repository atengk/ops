# PostgreSQL使用文档

## 连接数据库

**使用psql**

psql -h 主机名 -p 端口号 -U 用户名 -d 数据库名

```
psql -h localhost -p 5432 -U postgres -d kongyu
```

在输入命令后，系统会提示你输入密码。或者使用环境变量设置密码`export PGPASSWORD=Admin@123`

**简单查看信息**

查看所有数据库

```
\l
```

查看当前数据库中的所有表

```
\dt
```

切换数据库

```
\c 数据库名
```



## 数据库和表

### 数据库

**创建数据库**

```
CREATE DATABASE newdb;
```

**切换到数据库**

```
\c newdb
```

**删除数据库**

```
DROP DATABASE newdb;
```

### 表

**创建表**

```
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100),
    email VARCHAR(100) UNIQUE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

**插入数据**

```
INSERT INTO users (name, email) VALUES ('Alice', 'alice@example.com');
INSERT INTO users (name, email) VALUES ('Bob', 'bob@example.com');
```

**查询数据**

```
SELECT * FROM users;
```

**列出表**

```
\dt
```

**查看表结构**

```
\d mytable
```

**删除表**

```
DROP TABLE users;
```



## 导入导出

### pg_dump 命令参数说明

`pg_dump` 是 PostgreSQL 用于导出数据库的命令行工具，常用的参数包括：

- `-h <hostname>`：指定数据库服务器的主机名（如 `localhost`）。

- `-p <port>`：指定连接到数据库的端口号，默认是 `5432`。

- `-U <username>`：指定用于连接数据库的用户名。

- `-d <database_name>`：指定要导出的数据库名。

- `-F <format>`：指定导出的格式，常见的选项有：
    - `p`：纯 SQL 格式（文本格式），便于阅读和手动修改。
    - `c`：自定义格式，适合后续的恢复，支持压缩。
    - `t`：tar 格式，适合于备份多个对象（如多个表）。

- `-f <filename>`：指定导出的文件名及其路径。

- `-t <table_name>`：仅导出指定的表。

- `-s`：只导出数据库结构（不包括数据）。

- `--data-only`：仅导出数据（不包括表结构）。

- `--inserts`：使用 `INSERT` 语句导出数据。

- `--schema-only`：仅导出数据库的模式（结构，不包括数据）。

- `--no-owner`：不在备份中包含所有者信息，适用于不想恢复原有所有者的情况。

- `--no-privileges`：不在备份中包含权限信息。

### pg_restore 命令参数说明

`pg_restore` 是 PostgreSQL 用于从 `pg_dump` 备份文件中恢复数据库的命令行工具，常用于恢复 `.tar` 或自定义格式的备份文件。以下是 `pg_restore` 常用的参数：

- `-h <hostname>`：指定数据库服务器的主机名（例如 `localhost`）。
- `-p <port>`：指定数据库服务器的端口号，默认是 `5432`。
- `-U <username>`：指定用于连接数据库的用户名。
- `-d <database_name>`：指定要恢复的目标数据库名。

- `-F <format>`：指定备份文件的格式，主要有以下三种格式：
    - `c`：自定义格式（通常带 `.dump` 后缀），用于备份和压缩。
    - `d`：目录格式。
    - `t`：tar 格式（通常带 `.tar` 后缀），便于备份多个表或对象。

- `-f <filename>`：指定输入文件的路径。

- `-l`：列出备份文件中包含的所有对象，而不执行恢复，用于查看备份文件的内容。

- `-j <number_of_jobs>`：指定并行执行的任务数，适用于自定义格式和目录格式的备份文件，能加快恢复速度。

- `-n <schema>`：只恢复指定的模式（schema），用于部分恢复。

- `-t <table_name>`：只恢复指定的表（table），用于部分恢复。

- `-s`：只恢复数据库结构（不包括数据）。

- `-a`：只恢复数据（不包括表结构）。

- `--create`：在恢复时创建数据库，适用于需要创建目标数据库的情况。

- `--clean`：在恢复之前先删除目标数据库中的相应对象，以防止冲突。

- `--no-owner`：恢复时不恢复对象的所有者（通常用于跨用户恢复）。

- `--no-privileges`：不恢复权限信息。

- `-v`：启用详细模式，以查看恢复过程中输出的详细信息。

### COPY 命令参数说明

`COPY` 命令用于在 PostgreSQL 中导入或导出数据。常用的参数包括：

- `TO` 或 `FROM`：指定是将数据导出到文件还是从文件导入数据。

- `'/path/to/file'`：指定文件的路径（对于 `TO`，是导出路径；对于 `FROM`，是导入路径）。

- `WITH (FORMAT <format>)`：指定导出或导入的数据格式，常见的选项有：
    - `TEXT`：文本格式，默认值。
    - `CSV`：逗号分隔值格式。
    - `BINARY`：二进制格式。

- `HEADER`：在导出为 CSV 时，包含表头（列名）。

- `DELIMITER '<delimiter>'`：指定字段分隔符，默认是逗号（`,`），适用于 CSV 格式。

- `NULL '<null string>'`：指定在导出或导入时表示 NULL 的字符串。

- `QUOTE '<quote char>'`：指定用于包围字段的字符，默认是双引号（`"`）。

- `ESCAPE '<escape char>'`：指定用于转义字符的字符，默认是反斜杠（`\`）。

### 导出

**导出所有数据库**

导出所有数据库到一个 SQL 文件：

```
pg_dumpall -h localhost -U postgres -f all_databases.sql
```

**导出整个数据库**

pg_dump -h 主机名 -U 用户名 -F 格式 -f 文件名 数据库名

```
pg_dump -h localhost -p 5432 -U postgres -F c -f kongyu.dump kongyu
```

- `-F c` 指定导出格式为自定义格式，适合后续的恢复。

- `-f mydb.dump` 指定输出文件名。

**导出特定表**

pg_dump -h 主机名 -U 用户名 -F 格式 -t 表名 -f 文件名 数据库名

```
pg_dump -h localhost -U postgres -F c -t users -f users.dump kongyu
```

导出压缩包

```
pg_dump -h localhost -U postgres -F t -t users -f users.tar kongyu
```

导出数据为 COPY 语句

```
pg_dump -h localhost -U postgres -F p --data-only -t users -f users_data.sql kongyu
```

导出数据为 INSERT 语句

```
pg_dump -h localhost -U postgres -F p --data-only --inserts -t users -f users_data.sql kongyu
```

**导出数据为 CSV 文件**

可以使用 `COPY` 命令将查询结果导出为 CSV 文件。注意，这个操作需要在 PostgreSQL 命令行中执行。

```postgresql
COPY users TO '/tmp/users.csv' WITH (FORMAT CSV, HEADER);
```

- `/path/to/users.csv` 是输出文件的路径。

- `WITH (FORMAT CSV, HEADER)` 表示输出为 CSV 格式并包含表头。

如果只需要导出查询结果，可以使用 `COPY` 命令配合 SQL 查询：

```postgresql
COPY (SELECT * FROM users WHERE created_at > '2024-01-01') TO '/tmp/users_query.csv' WITH (FORMAT CSV, HEADER);
```

导出指定字段

```
COPY (SELECT name,email FROM users WHERE created_at > '2024-01-01') TO '/tmp/users.csv' WITH (FORMAT CSV, HEADER);
```

### 导入

**导入sql文件**

将sql文件在指定数据库中执行

```
psql -h localhost -U postgres -d newdb -f kongyu.sql
```

**恢复整个数据库**

```
pg_restore -h localhost -U myuser -d target_database -F c -v /path/to/backup_file.dump
```

**仅恢复数据（不包括表结构）**

```
pg_restore -h localhost -U myuser -d target_database -a -F c /path/to/backup_file.dump
```

**恢复指定表**

```
pg_restore -h localhost -U postgres -d newdb -t user -F c kongyu.dump
```

**并行恢复**

```
pg_restore -h localhost -U myuser -d target_database -j 4 -F c /path/to/backup_file.dump
```

**恢复指定模式**

```
pg_restore -h localhost -U myuser -d target_database -n schema_name -F c /path/to/backup_file.dump
```



## 查询

### 数据准备

**创建测试表**

```postgresql
CREATE TABLE users (
    id SERIAL PRIMARY KEY,                  -- 自增主键
    name VARCHAR(50) NOT NULL,              -- 用户姓名
    email VARCHAR(100) UNIQUE NOT NULL,     -- 用户邮箱
    password_hash TEXT NOT NULL,            -- 密码哈希
    age INT,                                -- 年龄
    is_active BOOLEAN DEFAULT TRUE,         -- 账户是否激活
    signup_date DATE DEFAULT CURRENT_DATE,  -- 注册日期
    last_login TIMESTAMP,                   -- 上次登录时间
    login_count INT DEFAULT 0,              -- 登录次数
    balance NUMERIC(10, 2) DEFAULT 0.00,    -- 账户余额
    preferences JSONB DEFAULT '{}'::JSONB,  -- 用户偏好（JSON 格式）
    country_code CHAR(2),                   -- 国家代码
    phone VARCHAR(15),                      -- 电话号码
    referral_code UUID DEFAULT gen_random_uuid(), -- 推荐码
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP -- 创建时间
);
```

**字段说明**

- `id`：自增主键，用于唯一标识用户。
- `name`：用户姓名，字符串类型。
- `email`：邮箱地址，使用 `UNIQUE` 约束，保证唯一性。
- `password_hash`：存储密码的哈希值，建议使用加密后的文本。
- `age`：用户年龄，整数类型。
- `is_active`：布尔值，表示用户是否激活。
- `signup_date`：用户注册日期，默认值为当前日期。
- `last_login`：上次登录时间，时间戳类型。
- `login_count`：用户登录次数，整数类型，默认值为 `0`。
- `balance`：账户余额，带有两位小数的数值类型。
- `preferences`：用户偏好设置，存储为 JSONB 格式。
- `country_code`：国家代码，使用 `CHAR(2)` 来存储国际标准国家代码。
- `phone`：电话号码，字符串类型。
- `referral_code`：推荐码，使用 `UUID` 类型确保唯一性。
- `created_at`：记录用户创建的时间，默认值为当前时间。

**插入测试数据**

```postgresql
INSERT INTO users (name, email, password_hash, age, is_active, signup_date, last_login, login_count, balance, preferences, country_code, phone)
SELECT 
    'User_' || generate_series(1, 10000) AS name,
    'user_' || generate_series(1, 10000) || '@example.com' AS email,
    md5(random()::text) AS password_hash,
    (random() * 50 + 18)::INT AS age,                -- 随机年龄在18-68岁之间
    (random() < 0.9) AS is_active,                   -- 90% 的用户为激活状态
    (CURRENT_DATE - (random() * 365)::INT) AS signup_date, -- 注册日期为过去一年内随机日期
    NOW() - (random() * (INTERVAL '365 days')) AS last_login, -- 最近一年内随机登录时间
    (random() * 100)::INT AS login_count,            -- 随机登录次数在 0 到 100 次之间
    (random() * 1000)::NUMERIC(10, 2) AS balance,    -- 随机账户余额
    jsonb_build_object('theme', 'dark', 'notifications', (random() < 0.5)) AS preferences, -- 随机偏好
    (ARRAY['US', 'CA', 'GB', 'AU', 'FR'])[floor(random() * 5 + 1)::INT] AS country_code, -- 随机国家代码
    '+1' || (1000000000 + floor(random() * 899999999)::INT)::TEXT AS phone; -- 随机生成手机号
```

**查看数据**

```
SELECT * FROM users LIMIT 10;
```



### 1. 基本统计查询

- **活跃用户数量**

    查询活跃的用户数（即 `is_active` 为 `TRUE` 的用户）：

    ```sql
    SELECT COUNT(*) FROM users WHERE is_active = TRUE;
    ```

- **总用户数**

    统计 `users` 表中的所有用户数量：

    ```sql
    SELECT COUNT(*) FROM users;
    ```

- **每个邮箱域名的用户数量**

    提取邮箱的域名部分，并按域名统计用户数，例如统计 `@example.com` 用户数量：

    ```sql
    SELECT SPLIT_PART(email, '@', 2) AS domain, COUNT(*) AS user_count
    FROM users
    GROUP BY domain
    ORDER BY user_count DESC;
    ```

---

### 2. 时间相关查询

- **最近登录的前 10 个用户**

    按 `last_login` 字段降序排列，获取最近登录的 10 个用户：

    ```sql
    SELECT * FROM users
    ORDER BY last_login DESC
    LIMIT 10;
    ```

- **过去 30 天注册的用户**

    查询过去 30 天内注册的用户，通过比较 `signup_date` 来筛选：

    ```sql
    SELECT * FROM users
    WHERE signup_date >= CURRENT_DATE - INTERVAL '30 days';
    ```

- **按月统计注册用户数量**

    统计每月注册的用户数量，使用 `DATE_TRUNC` 截取日期到月份：

    ```sql
    SELECT DATE_TRUNC('month', signup_date) AS month, COUNT(*) AS user_count
    FROM users
    GROUP BY month
    ORDER BY month;
    ```

#### 1. 获取当前时间和日期

- **当前日期**

  获取当前系统的日期（不含时间部分）：

  ```sql
  SELECT CURRENT_DATE AS today_date;
  ```

- **当前日期和时间（带时区）**

  获取系统的日期和时间，带时区信息：

  ```sql
  SELECT CURRENT_TIMESTAMP AS current_datetime;
  ```

- **当前 UTC 时间**

  获取当前的 UTC 时间，适合统一时间分析和跨时区场景：

  ```sql
  SELECT NOW() AT TIME ZONE 'UTC' AS utc_datetime;
  ```

#### 2. 时间和日期提取

- **提取年、月、日、小时等**

  使用 `EXTRACT` 从时间戳中提取指定的时间组件，如年、月、日、小时等：

  ```sql
  SELECT 
      EXTRACT(YEAR FROM signup_date) AS signup_year,
      EXTRACT(MONTH FROM signup_date) AS signup_month,
      EXTRACT(DAY FROM signup_date) AS signup_day,
      EXTRACT(HOUR FROM last_login) AS login_hour
  FROM users;
  ```

- **截断日期**

  使用 `DATE_TRUNC` 函数将时间戳截断到指定的精度，如年、季度、月、日等：

  ```sql
  SELECT 
      DATE_TRUNC('year', signup_date) AS signup_year,
      DATE_TRUNC('quarter', signup_date) AS signup_quarter,
      DATE_TRUNC('month', signup_date) AS signup_month,
      DATE_TRUNC('day', signup_date) AS signup_day
  FROM users;
  ```

#### 3. 日期和时间运算

- **日期加减**

  增加或减少天数、月数、年数，适用于到期日期的计算和预估时间等场景：

  ```sql
  -- 增加 30 天
  SELECT signup_date + INTERVAL '30 days' AS signup_plus_30_days
  FROM users;

  -- 减少 1 年
  SELECT signup_date - INTERVAL '1 year' AS signup_minus_1_year
  FROM users;
  ```

- **计算两个日期之间的差异**

  使用 `AGE` 函数或直接相减来计算时间差，例如计算注册至今的时间：

  ```sql
  -- 精确到年、月、日
  SELECT AGE(CURRENT_DATE, signup_date) AS time_since_signup
  FROM users;

  -- 计算天数差
  SELECT (CURRENT_DATE - signup_date) AS days_since_signup
  FROM users;
  ```

- **计算特定时间范围内的数据**

  查询某段时间内的记录，适用于业务报表或历史数据分析：

  ```sql
  -- 查询过去 7 天内的数据
  SELECT * 
  FROM users
  WHERE last_login >= CURRENT_DATE - INTERVAL '7 days';
  
  -- 查询本月的记录
  SELECT * 
  FROM users
  WHERE signup_date >= DATE_TRUNC('month', CURRENT_DATE);
  ```

#### 4. 时间格式化

- **将时间戳转换为特定格式**

  使用 `TO_CHAR` 函数自定义时间的显示格式，适合数据展示和报表需求：

  ```sql
  SELECT 
      TO_CHAR(signup_date, 'YYYY-MM-DD') AS signup_date_formatted,
      TO_CHAR(last_login, 'YYYY-MM-DD HH24:MI:SS') AS login_datetime_formatted
  FROM users;
  ```

- **按特定格式导出日期**

  设置日期格式为“周几，月 日, 年”的格式，例如显示为“Friday, Nov 3, 2024”：

  ```sql
  SELECT TO_CHAR(signup_date, 'Day, Mon DD, YYYY') AS pretty_date
  FROM users;
  ```

#### 5. 时区处理

- **将时间转换为指定时区**

  使用 `AT TIME ZONE` 函数将 UTC 时间转换为目标时区，便于跨时区数据的处理：

  ```sql
  SELECT last_login AT TIME ZONE 'America/New_York' AS login_in_ny
  FROM users;
  ```

- **存储时区敏感时间**

  如果数据需要时区敏感性，可以使用 `timestamp with time zone` 类型自动存储时区信息：

  ```sql
  CREATE TABLE events (
      event_id SERIAL PRIMARY KEY,
      event_name TEXT,
      event_time TIMESTAMPTZ DEFAULT NOW()
  );
  ```

#### 6. 日期比较和筛选

- **筛选特定时间段的记录**

  比较 `signup_date` 和 `last_login` 是否在同一年中：

  ```sql
  SELECT * 
  FROM users
  WHERE EXTRACT(YEAR FROM signup_date) = EXTRACT(YEAR FROM last_login);
  ```

- **在特定日期范围内查找记录**

  查询 2024 年 1 月到 2024 年 6 月期间的用户注册情况：

  ```sql
  SELECT * 
  FROM users
  WHERE signup_date BETWEEN '2024-01-01' AND '2024-06-30';
  ```

#### 7. 生成序列日期

- **生成一个日期序列（如按月、按日）**

  使用 `generate_series` 生成日期序列，便于按时间段统计数据或创建时间维度表：

  ```sql
  -- 生成2024年1月1日至12月31日的每日日期序列
  SELECT generate_series('2024-01-01'::DATE, '2024-12-31'::DATE, INTERVAL '1 day') AS daily_dates;
  
  -- 生成从2020年到2024年的每月日期序列
  SELECT generate_series('2020-01-01'::DATE, '2024-12-01'::DATE, INTERVAL '1 month') AS monthly_dates;
  ```

#### 8. 周和季度的特殊查询

- **计算每周的用户登录数**

  按周统计登录次数，便于分析每周活跃度：

  ```sql
  SELECT DATE_TRUNC('week', last_login) AS week_start, COUNT(*) AS login_count
  FROM users
  GROUP BY week_start
  ORDER BY week_start;
  ```

- **按季度统计新增用户数**

  按季度汇总注册用户，适用于季度性业务报告：

  ```sql
  SELECT DATE_TRUNC('quarter', signup_date) AS quarter, COUNT(*) AS user_count
  FROM users
  GROUP BY quarter
  ORDER BY quarter;
  ```

#### 9. 日期运算的高级用法

- **计算季度内的周数**

  查询指定季度中的周数，用于周数分布的分析：

  ```sql
  SELECT EXTRACT(WEEK FROM signup_date) AS week_in_quarter, COUNT(*)
  FROM users
  WHERE signup_date >= DATE_TRUNC('quarter', CURRENT_DATE)
  GROUP BY week_in_quarter
  ORDER BY week_in_quarter;
  ```

- **查找当前月份的最后一天**

  获取每月的最后一天，便于月底结算或数据统计：

  ```sql
  SELECT (DATE_TRUNC('month', CURRENT_DATE) + INTERVAL '1 month' - INTERVAL '1 day') AS last_day_of_month;
  ```

---

### 3. 条件查询

- **包含特定名称的用户**

    筛选 `name` 字段中包含 `User_1` 的用户：

    ```sql
    SELECT * FROM users
    WHERE name LIKE '%User_1%';
    ```

- **特定域名的用户数**

    查询邮箱域名为 `@example.com` 的用户数量：

    ```sql
    SELECT COUNT(*) FROM users
    WHERE email LIKE '%@example.com';
    ```

- **账户余额最高的 5 个用户**

    获取余额最高的前 5 个用户：

    ```sql
    SELECT name, email, balance FROM users
    ORDER BY balance DESC
    LIMIT 5;
    ```

---

### 4. 分组统计查询

- **按国家统计用户数量**

    统计每个国家的用户数量，按 `country_code` 字段分组：

    ```sql
    SELECT country_code, COUNT(*) AS user_count
    FROM users
    GROUP BY country_code
    ORDER BY user_count DESC;
    ```

- **按年龄段统计用户数量**

    使用 `CASE` 表达式将 `age` 分为不同年龄段，并按年龄段统计用户数量：

    ```sql
    SELECT 
        CASE 
            WHEN age BETWEEN 18 AND 25 THEN '18-25'
            WHEN age BETWEEN 26 AND 35 THEN '26-35'
            WHEN age BETWEEN 36 AND 45 THEN '36-45'
            ELSE '46+' 
        END AS age_range,
        COUNT(*) AS user_count
    FROM users
    GROUP BY age_range
    ORDER BY age_range;
    ```

- **按偏好统计主题为“dark”的用户数量**

    查询 `preferences` 字段（JSON 格式）中 `theme` 设置为 `dark` 的用户数量：

    ```sql
    SELECT COUNT(*) FROM users
    WHERE preferences->>'theme' = 'dark';
    ```

---

### 5. 聚合和计算查询

- **平均账户余额**

    计算并返回所有用户的平均账户余额：

    ```sql
    SELECT AVG(balance) AS average_balance FROM users;
    ```

- **账户余额的总和**

    计算所有用户的账户余额总和：

    ```sql
    SELECT SUM(balance) AS total_balance FROM users;
    ```

- **最早和最晚的注册日期**

    查询 `signup_date` 字段的最小和最大值，即最早和最晚的注册时间：

    ```sql
    SELECT MIN(signup_date) AS earliest_signup, MAX(signup_date) AS latest_signup FROM users;
    ```

### 6. 常用函数

以下是 PostgreSQL 常用的字符串、日期、数学和类型转换函数，适用于各种数据分析、清洗及格式化任务。

#### 字符串函数

- **提取邮箱的域名部分**

    将用户邮箱中的域名部分提取出来，便于进行分组分析或单独展示：

    ```sql
    SELECT email, SPLIT_PART(email, '@', 2) AS domain
    FROM users;
    ```

- **将用户名拼接成“姓,名”格式**

    假设 `name` 字段包含用户全名，将其分割为姓和名并重新格式化（这里假设空格分割）：

    ```sql
    SELECT name, 
           CONCAT(SPLIT_PART(name, ' ', 2), ', ', SPLIT_PART(name, ' ', 1)) AS formatted_name
    FROM users;
    ```

- **查找特定后缀邮箱的用户**

    使用 `RIGHT` 提取邮箱后缀并筛选出 Gmail 用户：

    ```sql
    SELECT * 
    FROM users
    WHERE RIGHT(email, 9) = '@gmail.com';
    ```

- **去除用户名中的空格**

    清理数据时，将用户名中的空格去除，保证数据一致性：

    ```sql
    SELECT name, TRIM(name) AS trimmed_name
    FROM users;
    ```

#### 日期和时间函数

- **计算用户注册后经过的年数**

    根据 `signup_date` 字段计算用户注册后的年数，适用于分析用户生命周期：

    ```sql
    SELECT name, signup_date, DATE_PART('year', AGE(CURRENT_DATE, signup_date)) AS years_since_signup
    FROM users;
    ```

- **获取当前时间的各个组成部分**

    将当前时间拆解为年、月、日、小时、分钟等组件，适用于时间维度分析：

    ```sql
    SELECT 
        EXTRACT(YEAR FROM CURRENT_TIMESTAMP) AS current_year,
        EXTRACT(MONTH FROM CURRENT_TIMESTAMP) AS current_month,
        EXTRACT(DAY FROM CURRENT_TIMESTAMP) AS current_day,
        EXTRACT(HOUR FROM CURRENT_TIMESTAMP) AS current_hour,
        EXTRACT(MINUTE FROM CURRENT_TIMESTAMP) AS current_minute;
    ```

- **按季度统计注册用户数**

    使用 `DATE_TRUNC` 获取注册时间的季度信息，以季度为单位统计用户注册数：

    ```sql
    SELECT DATE_TRUNC('quarter', signup_date) AS signup_quarter, COUNT(*) AS user_count
    FROM users
    GROUP BY signup_quarter
    ORDER BY signup_quarter;
    ```

#### 数学函数

- **模拟基于每次登录的增长率**

    假设我们定义增长率为用户的当前余额相对于 `login_count` 的增长（一个简单模拟）

    ```sql
    SELECT 
        id, 
        name, 
        balance,
        login_count,
        CASE 
            WHEN login_count = 0 THEN NULL
            ELSE ROUND(balance / NULLIF(login_count, 0) * 100, 2) 
        END AS simulated_growth_rate_per_login
    FROM 
        users;
    ```

- **生成随机的 8 位用户 ID**

    为每个用户生成一个随机的 8 位整数，适合模拟测试数据：

    ```sql
    SELECT name, (RANDOM() * 100000000)::INT AS random_user_id
    FROM users;
    ```

- **取账户余额的对数**

    计算 `balance` 的对数值（适合于数据变换或平滑处理）：

    ```sql
    SELECT name, balance, LN(balance) AS log_balance
    FROM users
    WHERE balance > 0;
    ```

#### 类型转换函数

- **将用户年龄转为文本格式**

    将 `age` 字段从整数类型转为文本类型，便于与字符串字段拼接：

    ```sql
    SELECT name, age::TEXT AS age_text
    FROM users;
    ```

- **将时间戳转为日期**

    从 `last_login` 字段中提取日期部分，忽略时间细节，适合日期范围查询：

    ```sql
    SELECT name, last_login::DATE AS login_date
    FROM users;
    ```

- **转换 JSON 字段的特定属性为整数**

    将 JSON 字段 `preferences` 中的某个数值属性提取并转为整数，用于数据计算：

    ```sql
    SELECT preferences->>'notifications' AS notifications_text,
           CASE 
               WHEN preferences->>'notifications' = 'true' THEN 1
               WHEN preferences->>'notifications' = 'false' THEN 0
               ELSE NULL  -- 处理其他情况，如果有其他值则返回 NULL
           END AS notifications_int
    FROM users;
    ```

#### 聚合函数

- **计算账户余额的标准差和方差**

    用于分析用户账户余额的离散情况，适合风险分析等场景：

    ```sql
    SELECT STDDEV(balance) AS balance_stddev, VARIANCE(balance) AS balance_variance
    FROM users;
    ```

- **计算账户余额的中位数**

    使用 `percentile_cont` 求中位数，适合分析用户分布情况：

    ```sql
    SELECT PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY balance) AS median_balance
    FROM users;
    ```

- **按国家统计用户的平均和最大登录次数**

    使用 `AVG` 和 `MAX` 聚合登录次数，分析不同国家用户的活跃度：

    ```sql
    SELECT country_code, AVG(login_count) AS avg_logins, MAX(login_count) AS max_logins
    FROM users
    GROUP BY country_code;
    ```

### 7. 窗口函数

窗口函数允许在查询中执行基于行集合的聚合运算，并保留行的详细信息。它们常用于数据排名、滚动计算、累积和统计分析。

#### 排名和排序

- **按账户余额排名**

    ```sql
    SELECT name, balance, RANK() OVER (ORDER BY balance DESC) AS balance_rank
    FROM users;
    ```

    使用 `RANK()` 对 `balance` 字段进行降序排名。适用于需要按特定字段排名的分析，如排名前十的高净值用户。

- **按登录次数为用户分组排名**

    ```sql
    SELECT name, login_count, DENSE_RANK() OVER (PARTITION BY country_code ORDER BY login_count DESC) AS login_rank
    FROM users;
    ```

    使用 `DENSE_RANK()`，按 `country_code` 为用户分组，计算每个国家用户的登录排名。

#### 滚动计算

- **计算过去 5 次登录的平均余额**

    ```sql
    SELECT name, balance, AVG(balance) OVER (ORDER BY last_login ROWS BETWEEN 4 PRECEDING AND CURRENT ROW) AS moving_avg_balance
    FROM users;
    ```

    使用滑动窗口 `ROWS BETWEEN` 实现滚动平均值计算。适用于连续事件的累积计算，如用户行为数据的移动平均分析。

- **计算每个用户的累计登录次数**

    ```sql
    SELECT name, login_count, SUM(login_count) OVER (ORDER BY last_login) AS cumulative_login_count
    FROM users;
    ```

    累计 `login_count` 数值，常用于展示用户行为的趋势分析，如活跃度累计曲线。

#### 分组内统计

- **计算每个国家用户的平均余额**

    ```sql
    SELECT country_code, name, balance, AVG(balance) OVER (PARTITION BY country_code) AS avg_balance_by_country
    FROM users;
    ```

    使用 `PARTITION BY` 按 `country_code` 分组，计算每个国家用户的平均余额。适合于分区域的数据分析，如区域用户的平均消费能力。

#### 百分比排名和累计百分比

- **计算账户余额的百分比排名**

    ```sql
    SELECT name, balance, PERCENT_RANK() OVER (ORDER BY balance DESC) AS balance_percent_rank
    FROM users;
    ```

    使用 `PERCENT_RANK()` 计算账户余额的百分比排名，用于展示用户资产在整体中的相对地位。

- **计算余额的累计百分比（帕累托分析）**

    ```sql
    SELECT name, balance, SUM(balance) OVER (ORDER BY balance DESC) / SUM(balance) OVER () AS cumulative_balance_ratio
    FROM users;
    ```

    累计 `balance` 并按总和比例计算累计百分比，适用于帕累托分析（80/20 原则），例如分析高净值用户在总资产中的占比。

## JSONB

在 PostgreSQL 中，`JSONB` 是一种用于存储和操作 JSON 数据的二进制格式。相较于普通的 `JSON` 类型，`JSONB` 提供更高效的存储和更强的操作能力。以下是关于 `JSONB` 的详细使用示例，包括创建表、插入数据、查询和更新。

### 1. 创建表

创建一个包含 `JSONB` 字段的表，示例表用于存储用户信息及其偏好设置。

```sql
CREATE TABLE users (
    id SERIAL PRIMARY KEY,                       -- 用户 ID
    username VARCHAR(50) NOT NULL,              -- 用户名
    email VARCHAR(100) UNIQUE NOT NULL,         -- 电子邮件
    preferences JSONB DEFAULT '{}'               -- 用户偏好设置，默认为空 JSON 对象
);
```

### 2. 插入数据

向表中插入数据，包括 `JSONB` 格式的偏好设置。

```sql
INSERT INTO users (username, email, preferences) VALUES 
('Alice', 'alice@example.com', '{"theme": "dark", "notifications": {"email": true, "sms": false}}'),
('Bob', 'bob@example.com', '{"theme": "light", "notifications": {"email": false, "sms": true}}'),
('Charlie', 'charlie@example.com', '{"theme": "dark", "language": "en"}');
```

### 3. 查询数据

使用 `JSONB` 提供的函数和操作符进行查询。

#### 查询所有用户及其偏好设置

```sql
SELECT * FROM users;
```

#### 查询特定字段

获取所有用户的主题偏好：

```sql
SELECT username, preferences->>'theme' AS theme
FROM users;
```

#### 查询具有特定条件的用户

查找偏好设置中启用了邮件通知的用户：

```sql
SELECT username 
FROM users 
WHERE preferences->'notifications'->>'email' = 'true';
```

### 4. 更新数据

可以使用 `JSONB` 的操作符更新字段。

#### 更新偏好设置

将用户的主题偏好更新为“light”，同时保留其他设置。

```sql
UPDATE users 
SET preferences = jsonb_set(preferences, '{theme}', '"light"')
WHERE username = 'Alice';
```

#### 添加新的偏好设置

为用户添加一个新的偏好设置字段，比如语言设置：

```sql
UPDATE users 
SET preferences = preferences || '{"language": "zh"}'
WHERE username = 'Bob';
```

### 5. 删除数据

删除 JSONB 中的特定字段。

#### 删除偏好设置中的 `notifications` 字段

```sql
UPDATE users 
SET preferences = preferences - 'notifications'
WHERE username = 'Charlie';
```

### 6. 使用 JSONB 的索引

为了提高查询效率，可以对 `JSONB` 字段创建索引。

#### 创建 GIN 索引

```sql
CREATE INDEX idx_preferences ON users USING GIN (preferences);
```

### 7. 高级查询

可以结合 `JSONB` 的功能进行复杂查询，比如查找主题为“dark”的用户：

```sql
SELECT username 
FROM users 
WHERE preferences @> '{"theme": "dark"}';
```

## 分区表

### 1. 基于范围（Range）分区

**场景**：创建一个销售记录表，根据销售日期进行分区，以便在查询特定年份的数据时更高效。

```sql
-- 创建主表，声明按销售日期进行范围分区
CREATE TABLE sales (
    id SERIAL,                       -- 销售记录 ID
    sale_date DATE NOT NULL,         -- 销售日期
    amount NUMERIC,
    PRIMARY KEY (id, sale_date)     -- 主键约束包含 sale_date
) PARTITION BY RANGE (sale_date);   -- 声明按 sale_date 列进行范围分区

-- 创建 2023 年的分区
CREATE TABLE sales_2023 PARTITION OF sales
    FOR VALUES FROM ('2023-01-01') TO ('2024-01-01');  -- 定义分区的值范围

-- 创建 2024 年的分区
CREATE TABLE sales_2024 PARTITION OF sales
    FOR VALUES FROM ('2024-01-01') TO ('2025-01-01');

-- 创建默认分区，用于存储不匹配其他分区条件的数据
CREATE TABLE sales_default PARTITION OF sales
    DEFAULT;
```

### 2. 基于列表（List）分区

**场景**：创建一个用户表，根据用户的地区进行分区，以便在特定地区的查询时提升性能。

```sql
-- 创建主表，声明按地区进行列表分区
CREATE TABLE users (
    id SERIAL,                     -- 用户 ID
    username TEXT NOT NULL,        -- 用户名
    region TEXT NOT NULL,          -- 用户所在地区
    PRIMARY KEY (id, region)       -- 主键约束包含 region 列
) PARTITION BY LIST (region);     -- 声明按 region 列进行列表分区

-- 创建北部地区的分区
CREATE TABLE users_north PARTITION OF users
    FOR VALUES IN ('North', 'Northeast');  -- 定义包含的地区

-- 创建南部地区的分区
CREATE TABLE users_south PARTITION OF users
    FOR VALUES IN ('South', 'Southeast');

-- 创建默认分区，用于存储不匹配其他分区条件的数据
CREATE TABLE users_default PARTITION OF users
    DEFAULT;
```

### 3. 基于哈希（Hash）分区

**场景**：创建一个订单表，根据用户 ID 进行哈希分区，以便均匀分配数据。

```sql
-- 创建订单表，按 user_id 进行哈希分区，并确保主键包含 user_id
CREATE TABLE orders (
    id SERIAL,                     -- 订单 ID
    user_id INT NOT NULL,          -- 用户 ID
    order_date DATE NOT NULL,      -- 订单日期
    amount NUMERIC,                -- 订单金额
    PRIMARY KEY (id, user_id)      -- 主键约束包含 user_id
) PARTITION BY HASH (user_id);    -- 声明按 user_id 列进行哈希分区

-- 创建哈希分区
CREATE TABLE orders_part1 PARTITION OF orders
    FOR VALUES WITH (MODULUS 4, REMAINDER 0);

CREATE TABLE orders_part2 PARTITION OF orders
    FOR VALUES WITH (MODULUS 4, REMAINDER 1);

CREATE TABLE orders_part3 PARTITION OF orders
    FOR VALUES WITH (MODULUS 4, REMAINDER 2);

CREATE TABLE orders_part4 PARTITION OF orders
    FOR VALUES WITH (MODULUS 4, REMAINDER 3);
```

### 4. 组合分区（Subpartitioning）

**场景**：创建一个日志表，首先按日期分区，再按日志级别进行子分区，便于更细粒度的管理和查询。

```sql
-- 创建日志表，声明按日志日期进行范围分区
CREATE TABLE logs (
    id SERIAL,                       -- 日志 ID
    log_date DATE NOT NULL,         -- 日志日期
    log_level TEXT NOT NULL,        -- 日志级别
    PRIMARY KEY (id, log_date)      -- 主键约束包含 log_date 列
) PARTITION BY RANGE (log_date);    -- 声明按 log_date 列进行范围分区

-- 创建 2023 年的分区，并声明其子分区为列表分区
CREATE TABLE logs_2023 PARTITION OF logs
    FOR VALUES FROM ('2023-01-01') TO ('2024-01-01') PARTITION BY LIST (log_level);

-- 创建日志级别为 INFO 的子分区
CREATE TABLE logs_2023_info PARTITION OF logs_2023
    FOR VALUES IN ('INFO');         -- 定义包含的日志级别

-- 创建日志级别为 ERROR 的子分区
CREATE TABLE logs_2023_error PARTITION OF logs_2023
    FOR VALUES IN ('ERROR');
```



## PostGIS

PostGIS 是 PostgreSQL 的一个扩展，为其添加了对地理信息系统（GIS）数据的支持。它允许用户在数据库中存储、查询和操作空间数据（例如点、线、多边形等），并且支持各种地理和空间计算功能。PostGIS 非常适合需要地理数据处理的应用场景，例如地图应用、导航系统、地理分析等。

### 基础准备

**安装 PostGIS 扩展**

```
CREATE EXTENSION IF NOT EXISTS postgis;
```

**创建包含地理空间数据的表**

```
-- 创建一个地点表，包含地点名称和地理空间位置
CREATE TABLE places (
    id SERIAL PRIMARY KEY,                     -- 地点 ID
    name TEXT NOT NULL,                        -- 地点名称
    location GEOMETRY(Point, 4326),           -- 地点位置，使用 GCJ-02 坐标系
    type TEXT NOT NULL                         -- 地点类型，例如“公园”、“商店”等
);
```

在上面的表结构中：

- `id` 是自增的主键，用于标识每个地点。
- `name` 用于存储地点的名称。
- `location` 使用 PostGIS 的 `GEOGRAPHY` 数据类型，表示地理位置，采用 WGS 84 坐标系（EPSG:4326），其中 `POINT` 类型用于存储经纬度信息。

**插入测试数据**

```postgresql
INSERT INTO places (name, location, type) VALUES 
('天安门', ST_SetSRID(ST_MakePoint(116.397128, 39.916527), 4326), '景点'),    -- 北京天安门
('故宫博物院', ST_SetSRID(ST_MakePoint(116.397128, 39.916527), 4326), '博物馆'),  -- 北京故宫
('颐和园', ST_SetSRID(ST_MakePoint(116.274428, 39.999445), 4326), '景点'),     -- 北京颐和园
('西湖', ST_SetSRID(ST_MakePoint(120.155070, 30.274085), 4326), '景点'),       -- 杭州西湖
('武汉大学', ST_SetSRID(ST_MakePoint(114.366270, 30.540416), 4326), '学校'),     -- 武汉大学
('南京大屠杀纪念馆', ST_SetSRID(ST_MakePoint(118.763232, 32.040215), 4326), '博物馆'), -- 南京大屠杀纪念馆
('长城', ST_SetSRID(ST_MakePoint(117.236194, 40.431908), 4326), '景点'),        -- 北京长城
('世博园', ST_SetSRID(ST_MakePoint(121.489206, 31.245334), 4326), '景点'),       -- 上海世博园
('南锣鼓巷', ST_SetSRID(ST_MakePoint(116.405285, 39.935573), 4326), '餐厅'),     -- 北京南锣鼓巷
('静安寺', ST_SetSRID(ST_MakePoint(121.446083, 31.224876), 4326), '景点'),       -- 上海静安寺
('小南国', ST_SetSRID(ST_MakePoint(121.478044, 31.223774), 4326), '餐厅'),      -- 上海小南国
('三亚湾', ST_SetSRID(ST_MakePoint(109.508193, 18.233013), 4326), '景点'),      -- 三亚湾
('青岛海洋科技馆', ST_SetSRID(ST_MakePoint(120.398904, 36.065564), 4326), '博物馆'), -- 青岛海洋科技馆
('黄山', ST_SetSRID(ST_MakePoint(118.168668, 29.718148), 4326), '景点');         -- 黄山
```

**导入坐标转换函数**

在[Github仓库](https://github.com/geocompass/pg-coordtransform)下载 `geoc-pg-coordtransform.sql` 文件并执行

```
curl -o geoc-pg-coordtransform.sql https://github.com/geocompass/pg-coordtransform/raw/refs/heads/master/geoc-pg-coordtransform.sql
geoc-pg-coordtransform.sql
```

执行SQL

```
psql -h localhost -U postgres -d newdb -f geoc-pg-coordtransform.sql
```

使用转换函数WGS84转GCJ02

```
select ST_AsText(geoc_wgs84togcj02(ST_SetSRID(ST_MakePoint(118.168668, 29.718148), 4326))) as wgs84;
```

**查看数据**

```
-- 分页查询地点信息，每页 10 条
SELECT 
    id, 
    name, 
    type, 
    ST_AsText(geoc_wgs84togcj02(location)) AS location_wgs84 
FROM 
    places
ORDER BY 
    id 
LIMIT 10 OFFSET 0;   -- OFFSET 用于分页，例如 OFFSET 10 则是第二页
```

### GeoJSON

**按属性条件查询并生成 GeoJSON**

假设您有一个 `places` 表，想要只查询某一类型的地点（如公园）并返回 GeoJSON 格式的结果。以下查询将实现条件过滤后再转换为 GeoJSON：

```
SELECT jsonb_agg(ST_AsGeoJSON(p)::jsonb) AS geojson_features
FROM places p
WHERE type = 'Park';
```

**获取指定半径内的地点并转换为 GeoJSON**

假如要查找 `places` 表中距离某个坐标（例如，120.398904, 36.065564 的位置）5 公里以内的地点，并返回 GeoJSON 格式，可以这样做：

```
SELECT jsonb_agg(ST_AsGeoJSON(p)::jsonb) AS geojson_features
FROM places p
WHERE ST_DWithin(location::geography, ST_SetSRID(ST_MakePoint(120.398904, 36.065564), 4326)::geography, 5000);
```

**聚合为 `FeatureCollection` 格式的 GeoJSON**

在 Web 应用中，有时需要以 `FeatureCollection` 的格式返回所有地点的集合，这样可以被直接解析并用于地图展示。

```
SELECT jsonb_build_object(
    'type', 'FeatureCollection',
    'features', jsonb_agg(ST_AsGeoJSON(p)::jsonb)
) AS geojson_collection
FROM places p;
```

**将地理数据与属性结合为自定义的 JSON**

有时我们不需要完整的 GeoJSON，可以创建自定义 JSON 结构，将几何数据与一些字段结合。以下是一个例子：

```
SELECT jsonb_agg(
    jsonb_build_object(
        'name', p.name,
        'type', p.type,
        'location', ST_AsGeoJSON(p.location)::jsonb
    )
) AS custom_geojson
FROM places p;
```

**按日期范围查询并返回 GeoJSON**

假设您要查询某个时间范围内创建的地点，并返回 GeoJSON 格式：

```
SELECT jsonb_agg(ST_AsGeoJSON(p)::jsonb) AS geojson_features
FROM places p
WHERE created_at BETWEEN '2024-01-01' AND '2024-12-31';
```

### 区域查询

**地点查询**

查询某个地区内的所有餐馆和公园

```
WITH area AS (
    SELECT ST_SetSRID(
        ST_MakePolygon(ST_GeomFromText('LINESTRING(
            116.40 39.90,
            116.45 39.90,
            116.45 39.95,
            116.40 39.95,
            116.40 39.90
        )')), 4326
    ) AS geom
)
SELECT name, type
FROM places
WHERE type IN ('Restaurant', 'Park')
AND ST_Within(location, (SELECT geom FROM area));
```

**计算距离**

计算一个地点到附近所有其他地点的距离

```
SELECT p1.name AS source_name, p2.name AS target_name,
       ST_Distance(p1.location, p2.location) AS distance
FROM places p1, places p2
WHERE p1.id != p2.id
AND ST_DWithin(p1.location, p2.location, 5000);  -- 5000 米内
```

**查找最近的地点**

查找离某个特定地点最近的公园

```
SELECT name, ST_Distance(location, ST_SetSRID(ST_MakePoint(116.404, 39.915), 4326)) AS distance
FROM places
WHERE type = 'Park'
ORDER BY distance
LIMIT 1;  -- 返回最近的公园
```

**复杂区域查询**

查找某个多边形区域内的所有地点，并返回 GeoJSON 格式的结果

```
WITH polygon AS (
    SELECT ST_SetSRID(
        ST_MakePolygon(ST_GeomFromText('LINESTRING(
            116.35 39.88,
            116.38 39.88,
            116.38 39.91,
            116.35 39.91,
            116.35 39.88
        )')), 4326
    ) AS geom
)
SELECT jsonb_agg(ST_AsGeoJSON(p)::jsonb) AS geojson_features
FROM places p
WHERE ST_Within(p.location, (SELECT geom FROM polygon));
```

**统计特定区域的地点数量**

统计特定区域内不同类型的地点数量

```
WITH area AS (
    SELECT ST_SetSRID(
        ST_MakePolygon(ST_GeomFromText('LINESTRING(
            116.30 39.80,
            116.50 39.80,
            116.50 39.90,
            116.30 39.90,
            116.30 39.80
        )')), 4326
    ) AS geom
)
SELECT type, COUNT(*) AS count
FROM places
WHERE ST_Within(location, (SELECT geom FROM area))
GROUP BY type;
```

