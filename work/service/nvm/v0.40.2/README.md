# NVM

NVM（Node Version Manager）是一个用于管理 Node.js 版本的工具。它允许用户在同一台设备上安装和切换多个 Node.js 版本，适用于不同项目的需求。NVM 主要用于 Unix/Linux 和 macOS 终端（Windows 需要 WSL 或额外工具支持）。常见命令包括：

- `nvm install <version>`：安装指定版本的 Node.js
- `nvm use <version>`：切换到指定版本
- `nvm list`：列出已安装的 Node.js 版本
- `nvm alias default <version>`：设置默认版本

NVM 使开发者能够灵活管理 Node.js 环境，避免版本冲突，提高开发效率。

Node.js 是一个基于 V8 引擎的 JavaScript 运行时环境，用于在服务器端运行 JavaScript 代码。它采用事件驱动、非阻塞 I/O 模型，适用于高并发应用，如 Web 服务器、实时应用和微服务架构。

Node.js 生态系统庞大，拥有 npm（Node Package Manager）作为包管理工具，提供丰富的第三方模块支持。常见用途包括 REST API 开发、实时聊天、流式处理等。其核心模块如 `fs`、`http`、`path` 使其能够高效处理文件、网络请求等任务。

- [NVM Github](https://github.com/nvm-sh/nvm)
- [NodeJs下载页面](https://nodejs.org/zh-cn/download)



## 安装NVM

**下载软件包**

```
wget -O nvm-0.40.2.tar.gz https://github.com/nvm-sh/nvm/archive/refs/tags/v0.40.2.tar.gz
```

**解压软件包**

```
tar -zxvf nvm-0.40.2.tar.gz -C /usr/local/software/
ln -s /usr/local/software/nvm-0.40.2 /usr/local/software/nvm
```

**配置环境变量**

```
cat >> ~/.bash_profile <<"EOF"
## NVM_HOME
export NVM_HOME=/usr/local/software/nvm
[ -s "$NVM_HOME/nvm.sh" ] && \. "$NVM_HOME/nvm.sh"
export PATH=$PATH:$NVM_HOME/bin
EOF
source ~/.bash_profile
```

关键参数说明：

- [ -s "$NVM_HOME/nvm.sh" ] && \. "$NVM_HOME/nvm.sh"：重新启动shell，使命令 `nvm` 生效

**查看版本**

```
nvm --version
```



## 安装Node.js

**下载软件包**

下载多个版本由NVM管理

```
wget https://nodejs.org/dist/v22.14.0/node-v22.14.0-linux-x64.tar.xz
wget https://nodejs.org/dist/v20.19.0/node-v20.19.0-linux-x64.tar.xz
wget https://nodejs.org/dist/v18.20.8/node-v18.20.8-linux-x64.tar.xz
```

**创建目录**

```
mkdir -p $NVM_HOME/versions/node
```

**使用NVM管理**

解压 Node.js

```
tar -xJf node-v22.14.0-linux-x64.tar.xz
tar -xJf node-v20.19.0-linux-x64.tar.xz
tar -xJf node-v18.20.8-linux-x64.tar.xz
```

将 Node.js 移动到 `nvm` 目录

```
mv node-v22.14.0-linux-x64 $NVM_HOME/versions/node/v22.14.0
mv node-v20.19.0-linux-x64 $NVM_HOME/versions/node/v20.19.0
mv node-v18.20.8-linux-x64 $NVM_HOME/versions/node/v18.20.8
```

使用并设置默认的Node.js版本

```
nvm use 22.14.0
nvm alias default 22.14.0
```

查看 Node.js 的版本列表

```
$ nvm list
       v18.20.8
       v20.19.0
->     v22.14.0
```

**查看版本**

```
node -v
```

**配置国内镜像源**

```
export NPM_CONFIG_REGISTRY=https://registry.npmmirror.com
export NODEJS_ORG_MIRROR=https://npmmirror.com/mirrors/node
```

- NPM_CONFIG_REGISTRY：设置 npm（Node.js 包管理器）使用的包注册表（registry）地址
- NODEJS_ORG_MIRROR：设置 Node.js 二进制文件（安装包、源码、nvm 等工具下载 Node.js 版本时）的镜像地址

**查看配置**

```
npm config list
```

