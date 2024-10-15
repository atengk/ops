# Gitlab CE

GitLab Community Edition (GitLab-CE) 是一个开源的 DevOps 平台，提供代码版本控制、项目管理和持续集成/持续交付 (CI/CD) 等功能。它基于 Git 版本控制系统，允许团队在一个平台上进行代码托管、协作开发和自动化构建部署。

**自定义配置**

密码配置：StatefulSet环境变量的GITLAB_ROOT_PASSWORD值，密码需要一定的复杂度才行

端口映射：

- HTTP：external_url需要修改为集群的IP和对应的nodePort
- SSH：gitlab_ssh_host和gitlab_shell_ssh_port需要修改为集群的IP和对应的nodePort

存储类：修改storageClassName名称

其他：其他配置按照具体环境修改

**创建服务**

```
kubectl apply -n kongyu -f deploy.yaml
```

**查看服务**

```
kubectl get -n kongyu pod,pvc,svc -l app=gitlab-ce
kubectl logs -n kongyu -f --tail=100 gitlab-ce-0
```

**访问服务**

```
[HTTP]
Address: http://192.168.1.10:20001
Username: root
Password: Ateng@2000
[SSH]
Address: ssh://git@192.168.1.10:20002
```

**删除服务**

```
kubectl delete -n kongyu -f deploy.yaml
kubectl delete -n kongyu pvc -l app=gitlab-ce
```





