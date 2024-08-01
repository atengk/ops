# 安装MySQL客户端

## 安装软件包

解压软件包

```
tar -zxvf mysql-community-v8.0.34.tar.gz
cd mysql-community-v8.0.34/
```

安装依赖包

```
yum -y install perl net-tools
```

安装客户端依赖

```
rpm -Uvh mysql-community-client-plugins-8.0.34-1.el7.x86_64.rpm mysql-community-libs-8.0.34-1.el7.x86_64.rpm mysql-community-common-8.0.34-1.el7.x86_64.rpm mysql-community-libs-compat-8.0.34-1.el7.x86_64.rpm
```

安装客户端

```
rpm -ivh mysql-community-client-8.0.34-1.el7.x86_64.rpm
```

查看版本

```
mysql --version
```

