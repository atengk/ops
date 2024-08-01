# 手动颁发证书

## 生成CA证书

1. 下载cfssl软件包
```
proxy="https://ghproxy.com/"
wget ${proxy}https://github.com/cloudflare/cfssl/releases/download/v1.6.1/cfssl_1.6.1_linux_amd64
wget ${proxy}https://github.com/cloudflare/cfssl/releases/download/v1.6.1/cfssljson_1.6.1_linux_amd64
wget ${proxy}https://github.com/cloudflare/cfssl/releases/download/v1.6.1/cfssl-certinfo_1.6.1_linux_amd64
```

2. 拷贝到/usr/local/bin/下
```
chmod +x cfssl*
mv cfssl_1.6.1_linux_amd64 /usr/local/bin/cfssl
mv cfssljson_1.6.1_linux_amd64 /usr/local/bin/cfssljson
mv cfssl-certinfo_1.6.1_linux_amd64 /usr/local/bin/cfssl-certinfo
```

3. 生成ca证书
```
cat > ca-csr.json <<EOF
{
    "CA":{"expiry":"876000h"},
    "CN": "www.kongyu.local",
    "key": {
        "algo": "rsa",
        "size": 2048
    },
    "names": [
        {
            "C": "CN",
            "L": "重庆市",
            "ST": "重庆市",
            "O": "阿腾集团",
            "OU": "软件开发部门"
        }
    ]
}
EOF
## 生成证书
cfssl gencert -initca ca-csr.json | cfssljson -bare ca -
cfssl certinfo -cert ca.pem | grep not
ls ca-key.pem ca.pem ca.csr
## ca-key.pem : CA的私有key
## ca.pem : CA证书
## ca.csr : CA的证书请求文件
```

4. 将根CA的key及证书文件存入secret中
```
kubectl create secret tls ca-clusterissuer-keypair \
   --cert=ca.pem \
   --key=ca-key.pem \
   --namespace=cert-manager
kubectl create secret tls ca-issuer-keypair \
   --cert=ca.pem \
   --key=ca-key.pem \
   --namespace=default
```

## 创建Issuer
1. Issuer只能在本命名空间使用，ClusterIssuer可以在所有命名空间使用
```
kubectl apply -f 01-ca-issuer.yaml
kubectl get -n default Issuer -o wide
kubectl get ClusterIssuer -o wide
```

## 颁发证书
1. 颁发证书给域名
```
kubectl apply -f 01-certificate-web.yaml
kubectl get -n default Certificate ca-certificate-web -o wide
kubectl get -n default Secrets ca-certificate-web-keypair
kubectl describe -n default Certificate ca-certificate-web
```

## 创建ingress

1. 创建https的ingress
```
kubectl apply -f 01-ingress-web.yaml
kubectl get ingress -n default nginx

```
2. 访问域名
```
https://nginx.kongyu.local/
```



# 自动颁发证书
## 创建Issuer
1. Issuer只能在本命名空间使用，ClusterIssuer可以在所有命名空间使用
```
kubectl apply -f 02-selfsigned-issuer.yaml
kubectl get -n default Issuer -o wide
kubectl get ClusterIssuer -o wide
```

## 颁发证书
1. 颁发证书给域名
```
kubectl apply -f 02-certificate-ca.yaml
kubectl get -n default Certificate selfsigned-certificate-ca -o wide
kubectl get -n default Secrets selfsigned-certificate-ca-keypair
kubectl describe -n default Certificate selfsigned-certificate-ca
```

## 创建ingress
1. 创建https的ingress
```
kubectl apply -f 02-ingress-web.yaml
kubectl get ingress -n default nginx
```

2. 访问域名
```
https://nginx.kongyu.local/
```
