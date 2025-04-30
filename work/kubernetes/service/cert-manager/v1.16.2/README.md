# cert-manager

**cert-manager** 是一个开源的 Kubernetes 插件，用于自动化管理 TLS 证书的申请、颁发和续订。它支持多种证书颁发机构（如 Let’s Encrypt、HashiCorp Vault、自定义 CA 等），通过 Kubernetes 原生资源配置轻松集成 HTTPS 服务。cert-manager 提供高效的证书生命周期管理，适用于生产环境。

- [官网链接](https://cert-manager.io/)

## 安装cert-manager

**查看版本**

```
helm search repo bitnami/cert-manager -l
```

**下载chart**

```
helm pull bitnami/cert-manager --version 1.3.22
```

**修改配置**

values.yaml是修改后的配置，可以根据环境做出适当修改

- 存储类：defaultStorageClass（不填为默认）
- 镜像地址：image.registry
- 副本数量：replicaCount *.replicaCount
- 其他配置：...

```
cat values.yaml
```

**创建服务**

```
helm install cert-manager --create-namespace -n cert-manager -f values.yaml cert-manager-1.3.22.tgz
```

**查看服务**

```
kubectl get -n cert-manager pod,svc
kubectl get Issuers,ClusterIssuers,Certificates,CertificateRequests,Orders,Challenges -A
```

**删除服务**

```
helm uninstall -n cert-manager cert-manager
```



## 颁发证书

### 创建CA的secret

将根CA的key及证书文件存入secret中。如果没有CA证书，可以参考[链接](https://atengk.github.io/work/#/work/service/tls/tls-cfssl/v1.6.5/)手动创建。

```
kubectl create secret tls ca-clusterissuer-keypair \
   --cert=tls-cfssl-ca.pem \
   --key=tls-cfssl-ca-key.pem \
   --namespace=cert-manager
kubectl create secret tls ca-issuer-keypair \
   --cert=tls-cfssl-ca.pem \
   --key=tls-cfssl-ca-key.pem \
   --namespace=default
```

### 创建Issuer

> Issuer只能在本命名空间使用，ClusterIssuer可以在所有命名空间使用

编辑配置文件

```
cat > ca-issuer-manual.yaml <<EOF
apiVersion: cert-manager.io/v1
kind: Issuer
metadata:
  name: ca-issuer
  namespace: default
spec:
  ca:
    secretName: ca-issuer-keypair
---
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: ca-clusterissuer
spec:
  ca:
    secretName: ca-clusterissuer-keypair
EOF
```

创建服务

```
kubectl apply -f ca-issuer-manual.yaml
kubectl get -n default Issuer -o wide
kubectl get ClusterIssuer -o wide
```

### 颁发证书

> 颁发证书给域名

编辑配置文件

```
cat > certificate-web-manual.yaml <<EOF
# 参考：https://cert-manager.io/docs/usage/certificate/
# api参考：https://cert-manager.io/docs/reference/api-docs/#cert-manager.io/v1alpha3.Certificate
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: ca-certificate-web-manual
  namespace: default ### 站点所在名字空间
spec:
  # Secret names are always required.
  secretName: ca-certificate-web-keypair-manual ### 生成Secret的名字
  duration: 2160h # 90d
  renewBefore: 360h # 15d
  subject:
    organizations: # Organizations to be used on the Certificate.
      - "阿腾集团"
    organizationalUnits: # Organizational Units to be used on the Certificate.
      - "研发中心"
    countries: # Countries to be used on the Certificate.
      - "CN"
    provinces: # State/Provinces to be used on the Certificate.
      - "重庆市"
    localities: # Cities to be used on the Certificate.
      - "重庆市"
    streetAddresses: # Street addresses to be used on the Certificate.
      - "重庆市巴南区丽都锦城"
    postalCodes: # Postal codes to be used on the Certificate.
      - "401320"
    serialNumber: "17623062936" # Serial number to be used on the Certificate.

  # The use of the common name field has been deprecated since 2000 and is
  # discouraged from being used.
  commonName: "kongyu.local"
  isCA: false
  privateKey:
    algorithm: RSA
    encoding: PKCS1
    size: 2048
  dnsNames:
    - nginx.kongyu.local
    - minio.kongyu.local
  issuerRef:
    name: ca-issuer ### 使用Issuer
    # We can reference ClusterIssuers by changing the kind here.
    # The default value is Issuer (i.e. a locally namespaced Issuer)
    kind: Issuer ### CA Issuer是Issuer
    # This is optional since cert-manager will default to this value however
    # if you are using an external issuer, change this to that issuer group.
    group: cert-manager.io
---
# 参考：https://cert-manager.io/docs/usage/certificate/
# api参考：https://cert-manager.io/docs/reference/api-docs/#cert-manager.io/v1alpha3.Certificate
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: ca-cluster-certificate-web-manual
  namespace: default ### 站点所在名字空间
spec:
  # Secret names are always required.
  secretName: ca-cluster-certificate-web-keypair-manual ### 生成Secret的名字
  duration: 2160h # 90d
  renewBefore: 360h # 15d
  subject:
    organizations: # Organizations to be used on the Certificate.
      - "阿腾集团"
    organizationalUnits: # Organizational Units to be used on the Certificate.
      - "研发中心"
    countries: # Countries to be used on the Certificate.
      - "CN"
    provinces: # State/Provinces to be used on the Certificate.
      - "重庆市"
    localities: # Cities to be used on the Certificate.
      - "重庆市"
    streetAddresses: # Street addresses to be used on the Certificate.
      - "重庆市巴南区丽都锦城"
    postalCodes: # Postal codes to be used on the Certificate.
      - "401320"
    serialNumber: "17623062936" # Serial number to be used on the Certificate.

  # The use of the common name field has been deprecated since 2000 and is
  # discouraged from being used.
  commonName: "kongyu.local"
  isCA: false
  privateKey:
    algorithm: RSA
    encoding: PKCS1
    size: 2048
  dnsNames:
    - nginx.kongyu.local
    - minio.kongyu.local
  issuerRef:
    name: ca-clusterissuer ### 使用Issuer
    # We can reference ClusterIssuers by changing the kind here.
    # The default value is Issuer (i.e. a locally namespaced Issuer)
    kind: ClusterIssuer ### CA Issuer是Issuer
    # This is optional since cert-manager will default to this value however
    # if you are using an external issuer, change this to that issuer group.
    group: cert-manager.io
EOF
```

创建Certificate

```
kubectl apply -f certificate-web-manual.yaml
kubectl get -n default Certificate ca-certificate-web-manual -o wide
kubectl get -n default Secrets ca-certificate-web-keypair-manual
kubectl describe -n default Certificate ca-certificate-web-manual
```

### 使用证书

编辑配置文件

```
cat > service-web-manual.yaml <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: registry.lingo.local/kubernetes/nginx:1.23.4
        ports:
        - containerPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: nginx-service
spec:
  selector:
    app: nginx
  ports:
    - protocol: TCP
      port: 80
      targetPort: 80
  type: ClusterIP
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: nginx-ingress
spec:
  ingressClassName: nginx
  rules:
    - host: nginx.kongyu.local
      http:
        paths:
          - path: /
            pathType: ImplementationSpecific
            backend:
              service:
                name: nginx-service
                port:
                  number: 80
  tls:
    - hosts:
        - nginx.kongyu.local
      secretName: ca-certificate-web-keypair-manual
---
EOF
```

创建服务

```
kubectl apply -f service-web-manual.yaml
kubectl get ingress -n default nginx-ingress
```

访问服务

> 注意Nginx Ingress Controller必须使用**LoadBalancer**模式，这样证书访问才有效。

```
curl -v \
    --cacert tls-cfssl-ca.pem \
    https://nginx.kongyu.local
```

