# Node.js

Node.js 是一个基于 V8 引擎的 JavaScript 运行时环境，用于在服务器端运行 JavaScript 代码。它采用事件驱动、非阻塞 I/O 模型，适用于高并发应用，如 Web 服务器、实时应用和微服务架构。

Node.js 生态系统庞大，拥有 npm（Node Package Manager）作为包管理工具，提供丰富的第三方模块支持。常见用途包括 REST API 开发、实时聊天、流式处理等。其核心模块如 `fs`、`http`、`path` 使其能够高效处理文件、网络请求等任务。

- [NodeJs下载页面](https://nodejs.org/zh-cn/download)



**下载软件包**

```
wget https://nodejs.org/dist/v22.14.0/node-v22.14.0-linux-x64.tar.xz
```

**解压软件包**

```
tar -xJf node-v22.14.0-linux-x64.tar.xz -C /usr/local/software/
ln -s /usr/local/software/node-v22.14.0-linux-x64 /usr/local/software/nodejs
```

**配置环境变量**

```
cat >> ~/.bash_profile <<"EOF"
## NODEJS_HOME
export NODEJS_HOME=/usr/local/software/nodejs
export PATH=$PATH:$NODEJS_HOME/bin
EOF
source ~/.bash_profile
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

