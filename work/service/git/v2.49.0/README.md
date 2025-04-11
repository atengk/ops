# Git

Git 是一个分布式版本控制系统，用于跟踪代码变更，支持多人协作开发。它提供分支管理、代码合并、版本回溯等功能，确保代码的安全性和可追溯性。Git 通过本地仓库和远程仓库（如 GitHub、GitLab）进行代码管理，提高开发效率和团队协作能力。常用命令包括 `git clone`、`git commit`、`git push`、`git pull` 等。

- [官网链接](https://git-scm.com/)
- [下载地址](https://git-scm.com/downloads/linux)
- [下载详细地址](https://www.kernel.org/pub/software/scm/git/)



**下载软件包**

```
wget https://www.kernel.org/pub/software/scm/git/git-2.49.0.tar.gz
```

**解压软件包**

```
mkdir -p /usr/local/software/git-2.49.0/source
tar -zxvf git-2.49.0.tar.gz -C /usr/local/software/git-2.49.0/source
ln -s /usr/local/software/git-2.49.0 /usr/local/software/git
```

**安装编译软件包**

```
sudo yum install -y gcc make openssl-devel zlib-devel curl-devel gettext autoconf
```

**编译 Git**

```
cd /usr/local/software/git/source/git-*/
make configure
./configure --prefix=/usr/local/software/git
make -j$(nproc)
```

**安装 Git**

```
make install
```

**配置环境变量**

```
cat >> ~/.bash_profile <<"EOF"
## GIT_HOME
export GIT_HOME=/usr/local/software/git
export PATH=$PATH:$GIT_HOME/bin
EOF
source ~/.bash_profile
```

**配置全局使用**

```
sudo ln -s  /usr/local/software/git/bin/git /usr/bin/git
```

**查看版本**

```
git --version
```

**设置 Git 用户信息**

```
git config --global user.name "阿腾"
git config --global user.email "2385569970@qq.com"
```

