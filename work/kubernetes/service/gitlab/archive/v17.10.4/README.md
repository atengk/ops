# Gitlab CE

GitLab Community Edition (GitLab-CE) 是一个开源的 DevOps 平台，提供代码版本控制、项目管理和持续集成/持续交付 (CI/CD) 等功能。它基于 Git 版本控制系统，允许团队在一个平台上进行代码托管、协作开发和自动化构建部署。

**配置修改**

- 密码配置：spec.template.spec.containers[0].env[0]: GITLAB_ROOT_PASSWORD值，密码需要满足复杂度

- 存储类：spec.volumeClaimTemplates[*].spec.storageClassName

- 镜像地址：spec.template.spec.containers[0].image

- 端口映射：修改ConfigMap

    - HTTP：external_url需要修改为集群的IP和对应的nodePort

    - SSH：gitlab_ssh_host和gitlab_shell_ssh_port需要修改为集群的IP和对应的nodePort

- 其他：其他配置按照具体环境修改

**添加节点标签**

创建标签，运行在标签节点上

```
kubectl label nodes server03.lingo.local kubernetes.service/gitlab-ce="true"
```

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
URL:            http://192.168.1.10:20001
HTTP Clone URL: http://192.168.1.10:20001/some-group/some-project.git
SSH Clone URL:  ssh://git@192.168.1.10:20002/some-group/some-project.git
Username:       root
Password:       Ateng@2025
```

![image-20241203195956445](./assets/image-20241203195956445.png)

**删除服务**

```
kubectl delete -n kongyu -f deploy.yaml
kubectl delete -n kongyu pvc -l app=gitlab-ce
```



