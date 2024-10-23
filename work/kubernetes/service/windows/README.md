# 容器中安装Windows

https://github.com/dockur/windows

## 在线安装

参考官网文档，直接修改**VERSION**的值就会去下载对应的镜像然后安装。



## 离线安装

将你的镜像放在HTTP服务器上，然后修改**VERSION**的值为这个镜像的URL，然后会自动识别这个镜像的版本并安装。



**建议使用win10-tiny**

```yaml
# cat win10-tiny/win10-tiny.yaml
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: win10-tiny
spec:
  serviceName: "win10-tiny"
  replicas: 1
  selector:
    matchLabels:
      app: win10-tiny
  template:
    metadata:
      labels:
        app: win10-tiny
    spec:
      nodeSelector:
        kubernetes.io/hostname: "server02.lingo.local"
      terminationGracePeriodSeconds: 120 # the Kubernetes default is 30 seconds and it may be not enough
      containers:
      - name: win10-tiny
        image: dockurr/windows
        ports:
        - containerPort: 8006
          protocol: TCP
        - containerPort: 3389
          protocol: TCP
        - containerPort: 3389
          protocol: UDP
        env:
        - name: VERSION
          value: "http://192.168.1.12:9000/public-bucket/images/tiny10_x64_23h2.iso"
        - name: LANGUAGE
          value: "Chinese"
        - name: REGION
          value: "zh_CN"
        - name: KEYBOARD
          value: "zh_CN"
        - name: USERNAME
          value: "admin"
        - name: PASSWORD
          value: "Admin@123"
        - name: RAM_SIZE
          value: "4G"
        - name: CPU_CORES
          value: "2"
        - name: DISK_SIZE
          value: "100G"
        volumeMounts:
        - mountPath: /storage
          name: storage
        - mountPath: /dev/kvm
          name: dev-kvm
        securityContext:
          privileged: true
      volumes:
        - name: dev-kvm
          hostPath:
            path: /dev/kvm
  volumeClaimTemplates:
  - metadata:
      name: storage
    spec:
      accessModes: ["ReadWriteOnce"]
      storageClassName: openebs-hostpath
      resources:
        requests:
          storage: 100Gi
---
apiVersion: v1
kind: Service
metadata:
  name: win10-tiny
spec:
  selector:
    app: win10-tiny
  ports:
    - name: tcp-8006
      protocol: TCP
      port: 8006
      targetPort: 8006
    - name: tcp-3389
      protocol: TCP
      port: 3389
      targetPort: 3389
    - name: udp-3389
      protocol: UDP
      port: 3389
      targetPort: 3389
  type: NodePort
```

