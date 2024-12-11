# Jenkins

Jenkins 是一个开源的自动化服务器，广泛用于实现持续集成（CI）和持续交付（CD）。它支持通过插件扩展，能够自动化构建、测试、部署等软件开发流程。Jenkins 提供了图形化的用户界面、分布式构建功能、丰富的插件生态以及强大的集成能力，帮助开发团队提高开发效率和交付速度。

- [官网链接](https://www.jenkins.io/)

**下载镜像**

```
docker pull bitnami/jenkins:2.479.1
```

**推送到仓库**

```
docker tag bitnami/jenkins:2.479.1 registry.lingo.local/bitnami/jenkins:2.479.1
docker push registry.lingo.local/bitnami/jenkins:2.479.1
```

**保存镜像**

```
docker save registry.lingo.local/bitnami/jenkins:2.479.1 | gzip -c > image-jenkins_2.479.1.tar.gz
```

**创建目录**

```
sudo mkdir -p /data/container/jenkins/data
sudo chown -R 1001 /data/container/jenkins
```

**运行服务**

```
docker run -d --name ateng-jenkins \
  -p 20022:8080 --restart=always \
  -v /data/container/jenkins:/bitnami/jenkins \
  -e JENKINS_USERNAME=admin \
  -e JENKINS_PASSWORD=Admin@123 \
  -e JENKINS_EMAIL=2385569970@qq.com \
  -e JAVA_OPTS="-server -Xms1g -Xmx2g" \
  -e TZ=Asia/Shanghai \
  registry.lingo.local/bitnami/jenkins:2.479.1
```

**查看日志**

```
docker logs -f ateng-jenkins
```

**使用服务**

```
URL: http://192.168.1.12:20022
Username: admin
Password: Admin@123
```

**删除服务**

停止服务

```
docker stop ateng-jenkins
```

删除服务

```
docker rm ateng-jenkins
```

删除目录

```
sudo rm -rf /data/container/jenkins
```

