# Gitlab CE

GitLab Community Edition (GitLab-CE) 是一个开源的 DevOps 平台，提供代码版本控制、项目管理和持续集成/持续交付 (CI/CD) 等功能。它基于 Git 版本控制系统，允许团队在一个平台上进行代码托管、协作开发和自动化构建部署。

- [官网链接](https://about.gitlab.com/install/)



**下载镜像**

```
docker pull gitlab/gitlab-ce:17.10.4-ce.0
```

**推送到仓库**

```
docker tag gitlab/gitlab-ce:17.10.4-ce.0 registry.lingo.local/service/gitlab-ce:17.10.4-ce.0
docker push registry.lingo.local/service/gitlab-ce:17.10.4-ce.0
```

**保存镜像**

```
docker save registry.lingo.local/service/gitlab-ce:17.10.4-ce.0 | gzip -c > image-gitlab-ce_17.10.4-ce.0.tar.gz
```

**创建目录**

```
sudo mkdir -p /data/container/gitlab-ce/{data,config,log}
```

**创建配置文件**

external_url、gitlab_rails['gitlab_ssh_host']、gitlab_rails['gitlab_shell_ssh_port']: HTTP和SSH地址，这三个配置修改为最终实际访问的地址

设置地址环境变量

```
export HTTP_ADDRESS="http://192.168.1.12:20013"
export SSH_IP="192.168.1.12"
export SSH_PORT="20014"
```

创建配置文件

```
sudo tee /data/container/gitlab-ce/config/gitlab.rb <<EOF
# 基本访问配置
external_url '${HTTP_ADDRESS}'
nginx['listen_port'] = 80

# SSH 配置
gitlab_rails['gitlab_ssh_host'] = '${SSH_IP}'
gitlab_rails['gitlab_shell_ssh_port'] = ${SSH_PORT}
gitlab_rails['gitlab_ssh_user'] = 'git'

# 系统基础设置
gitlab_rails['time_zone'] = 'Asia/Shanghai'
gitlab_rails['backup_keep_time'] = 18144000
gitlab_rails['web_session_timeout'] = 0

# 性能优化（降低资源占用）
puma['worker_processes'] = 2
postgresql['shared_buffers'] = "128MB"
postgresql['max_worker_processes'] = 4
sidekiq['max_concurrency'] = 2
sidekiq['min_concurrency'] = 1

# 禁用不必要的监控组件
prometheus['enable'] = false
redis_exporter['enable'] = false
gitlab_exporter['enable'] = false
node_exporter['enable'] = false
postgres_exporter['enable'] = false

# 禁用不必要的服务
mattermost['enable'] = false
registry['enable'] = false
pages_external_url = nil
gitlab_pages['enable'] = false

# 关闭邮件/CI/注册相关功能
gitlab_rails['smtp_enable'] = false
gitlab_rails['gitlab_email_enabled'] = false
gitlab_rails['gitlab_ci_enabled'] = false
gitlab_rails['gitlab_signup_enabled'] = false
EOF
```

配置说明：

- `external_url`: 设置 GitLab 的 HTTP 访问地址
- `nginx['listen_port']`: 设置 Nginx 的监听端口，与 external_url 保持一致
- `gitlab_rails['gitlab_ssh_host']`: 设置 SSH 访问主机 IP
- `gitlab_rails['gitlab_shell_ssh_port']`: 设置 SSH 端口
- `gitlab_rails['gitlab_ssh_user']`: 设置 SSH 使用的用户
- `gitlab_rails['time_zone']`: 设置时区为上海
- `gitlab_rails['backup_keep_time']`: 设置备份保留时间（单位：秒，30 天）
- `gitlab_rails['web_session_timeout']`: 设置 Web 登录会话永不超时（0 表示不超时）
- `puma['worker_processes']`: 设置 Puma worker 数量，控制并发
- `postgresql['shared_buffers']`: 设置数据库缓存大小，降低内存占用
- `postgresql['max_worker_processes']`: 限制 PostgreSQL 的并发 worker 数量
- `sidekiq['max_concurrency']`: Sidekiq 最大并发
- `sidekiq['min_concurrency']`: Sidekiq 最小并发
- `prometheus['enable']` 等 exporter 相关配置：关闭 Prometheus 和相关监控服务
- `mattermost['enable']`: 关闭内置聊天服务
- `registry['enable']`: 关闭容器镜像仓库服务
- `gitlab_pages['enable']`: 关闭 GitLab Pages 静态网站托管
- `pages_external_url`: 设置为空表示不启用 GitLab Pages
- `gitlab_workhorse['enable']`: 关闭上传加速服务（可选，若上传变慢建议开启）
- `gitlab_rails['smtp_enable']`: 关闭 SMTP 邮件发送
- `gitlab_rails['gitlab_email_enabled']`: 完全禁用邮件相关功能
- `gitlab_rails['gitlab_ci_enabled']`: 关闭 CI/CD 功能
- `gitlab_rails['gitlab_signup_enabled']`: 禁用用户注册

**运行服务**

注意gitlab的root密码需要满足一定的复杂度：GITLAB_ROOT_PASSWORD

```
docker run -d --name ateng-gitlab-ce \
  -p 20013:80 -p 20014:22 --restart=always \
  -v /data/container/gitlab-ce/data:/var/opt/gitlab \
  -v /data/container/gitlab-ce/log:/var/log/gitlab \
  -v /data/container/gitlab-ce/config:/etc/gitlab \
  -v /data/container/gitlab-ce/config/gitlab.rb:/etc/gitlab/gitlab.rb:ro \
  -e GITLAB_ROOT_PASSWORD=Ateng@2025 \
  -e TZ=Asia/Shanghai \
  registry.lingo.local/service/gitlab-ce:17.10.4-ce.0
```

**查看日志**

```
docker logs -f ateng-gitlab-ce
```

**使用服务**

```
URL:            http://192.168.1.12:20013
HTTP Clone URL: http://192.168.1.12:20013/some-group/some-project.git
SSH Clone URL:  ssh://git@192.168.1.12:20014/some-group/some-project.git
Username:       root
Password:       Ateng@2024
```

**删除服务**

停止服务

```
docker stop ateng-gitlab-ce
```

删除服务

```
docker rm ateng-gitlab-ce
```

删除目录

```
sudo rm -rf /data/container/gitlab-ce
```

