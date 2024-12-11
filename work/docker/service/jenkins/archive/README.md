# Jenkins 2.387.3



## 环境准备

创建网络，将容器运行在该网络下，若已创建则忽略

```
docker network create --subnet 10.188.0.1/24 kongyu
```

准备目录

```
mkdir -p /data/service/jenkins/data
chown -R 1001 /data/service/jenkins
```



## 启动容器

- 使用docker run的方式


```
docker run -d --name kongyu-jenkins --network kongyu \
    -p 20001:8080 --restart=always \
    -v /data/service/jenkins/data:/bitnami/jenkins \
    -e JENKINS_USERNAME=admin \
    -e JENKINS_PASSWORD=Admin@123 \
    -e JENKINS_EMAIL=2385569970@qq.com \
    -e JAVA_OPTS="-server -Xms1g -Xmx2g" \
    -e TZ=Asia/Shanghai \
    registry.lingo.local/service/jenkins:2.387.3
docker logs -f kongyu-jenkins
```

- 使用docker-compose的方式


```
cat > /data/service/jenkins/docker-compose.yaml <<"EOF"
version: '3'

services:
  jenkins:
    image: registry.lingo.local/service/jenkins:2.387.3
    container_name: kongyu-jenkins
    networks:
      - kongyu
    ports:
      - "20001:8080"
    restart: always
    volumes:
      - /data/service/jenkins/data:/bitnami/jenkins
    environment:
      - JENKINS_USERNAME=admin
      - JENKINS_PASSWORD=Admin@123
      - JENKINS_EMAIL=2385569970@qq.com
      - JAVA_OPTS=-server -Xms1g -Xmx2g
      - TZ=Asia/Shanghai

networks:
  kongyu:
    external: true

EOF

docker-compose -f /data/service/jenkins/docker-compose.yaml up -d 
docker-compose -f /data/service/jenkins/docker-compose.yaml logs -f
```



## 访问服务

登录服务查看

```
URL: http://192.168.1.101:20001/
Username: admin
Password: Admin@123
```



## 删除服务

- 使用docker run的方式


```
docker rm -f kongyu-jenkins
```

- 使用docker-compose的方式


```
docker-compose -f /data/service/jenkins/docker-compose.yaml down
```

删除数据目录

```
rm -rf /data/service/jenkins
```

