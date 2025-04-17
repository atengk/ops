# Gitlab CE

GitLab Community Edition (GitLab-CE) 是一个开源的 DevOps 平台，提供代码版本控制、项目管理和持续集成/持续交付 (CI/CD) 等功能。它基于 Git 版本控制系统，允许团队在一个平台上进行代码托管、协作开发和自动化构建部署。

**下载镜像**

```
docker pull gitlab/gitlab-ce:17.6.1-ce.0
```

**推送到仓库**

```
docker tag gitlab/gitlab-ce:17.6.1-ce.0 registry.lingo.local/service/gitlab-ce:17.6.1-ce.0
docker push registry.lingo.local/service/gitlab-ce:17.6.1-ce.0
```

**保存镜像**

```
docker save registry.lingo.local/service/gitlab-ce:17.6.1-ce.0 | gzip -c > image-gitlab-ce_17.6.1-ce.0.tar.gz
```

**创建目录**

```
sudo mkdir -p /data/container/gitlab-ce/{data,config,log}
```

**创建配置文件**

注意以下配置

- HTTP地址：external_url
- SSH地址：gitlab_rails['gitlab_ssh_host']、gitlab_rails['gitlab_shell_ssh_port']

```
sudo tee /data/container/gitlab-ce/config/gitlab.rb <<"EOF"
# 修改 http 访问地址
external_url 'http://192.168.1.10:20013'
# 修改了 http 端口同时也要修改 nginx 端口
nginx['listen_port'] = 80
# 修改 ssh 访问地址
gitlab_rails['gitlab_ssh_host'] = '192.168.1.10'
# 修改 ssh 端口为上面 docker run 设置的端口
gitlab_rails['gitlab_shell_ssh_port'] = 20014
# 修改 ssh 用户
gitlab_rails['gitlab_ssh_user'] = 'git'
# 修改时区
gitlab_rails['time_zone'] = 'Asia/Shanghai'
# 设置备份保留30天（7*3600*24*30=18144000），秒为单位
gitlab_rails['backup_keep_time'] = 18144000

# 优化减少服务的内存占用
puma['worker_processes'] = 2
postgresql['shared_buffers'] = "128MB"
postgresql['max_worker_processes'] = 4
sidekiq['max_concurrency'] = 2
sidekiq['min_concurrency'] = 1
 
# 关闭不需要的服务
prometheus['enable'] = false
redis_exporter['enable'] = false
gitlab_exporter['enable'] = false
node_exporter['enable'] = false
postgres_exporter['enable'] = false
EOF
```

**运行服务**

注意修改gitlab的root密码：GITLAB_ROOT_PASSWORD

```
docker run -d --name ateng-gitlab-ce \
  -p 20013:80 -p 20014:22 --restart=always \
  -v /data/container/gitlab-ce/data:/var/opt/gitlab \
  -v /data/container/gitlab-ce/log:/var/log/gitlab \
  -v /data/container/gitlab-ce/config:/etc/gitlab \
  -v /data/container/gitlab-ce/config/gitlab.rb:/etc/gitlab/gitlab.rb:ro \
  -e GITLAB_ROOT_PASSWORD=Ateng@2024 \
  -e TZ=Asia/Shanghai \
  registry.lingo.local/service/gitlab-ce:17.6.1-ce.0
```

**查看日志**

```
docker logs -f ateng-gitlab-ce
```

**使用服务**

```
HTTP Address: http://192.168.1.114:20013
SSH Address: ssh://git@192.168.1.114:20014
Username: root
Password: Ateng@2024
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

