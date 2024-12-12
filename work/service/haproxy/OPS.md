# Haproxy使用文档

## 1. **HTTP 基本负载均衡**

这是最常见的配置，HAProxy 将 HTTP 请求均匀分发到多个 Web 服务器。

```text
frontend http_front
  bind *:80
  default_backend http_back

backend http_back
  balance roundrobin   # 负载均衡算法，轮询方式
  server web1 192.168.1.10:80 check
  server web2 192.168.1.11:80 check
```

## 2. **HTTPS 终端代理（SSL Offloading）**

如果需要将 HTTPS 流量加密解密的工作交给 HAProxy 来做，可以配置 SSL 终端代理。这可以减轻后端 Web 服务器的负担。

```text
frontend https_front
  bind *:443 ssl crt /etc/ssl/certs/example.com.pem
  default_backend https_back

backend https_back
  balance roundrobin
  server web1 192.168.1.10:80 check
  server web2 192.168.1.11:80 check
```

## 3. **HTTP 和 HTTPS 混合负载均衡**

处理 HTTP 和 HTTPS 请求，并将它们分别转发到相应的后端。

```text
frontend http_front
  bind *:80
  default_backend http_back

frontend https_front
  bind *:443 ssl crt /etc/ssl/certs/example.com.pem
  default_backend https_back

backend http_back
  balance roundrobin
  server web1 192.168.1.10:80 check
  server web2 192.168.1.11:80 check

backend https_back
  balance roundrobin
  server web1 192.168.1.10:443 ssl verify none check
  server web2 192.168.1.11:443 ssl verify none check
```

## 4. **基于内容的路由**

根据请求的 URL 路径或主机头，HAProxy 将请求路由到不同的后端。

```text
frontend http_front
  bind *:80
  acl is_api path_beg /api
  acl is_admin hdr(host) -i admin.example.com
  use_backend api_back if is_api
  use_backend admin_back if is_admin
  default_backend default_back

backend api_back
  balance roundrobin
  server api_server1 192.168.1.10:8080 check
  server api_server2 192.168.1.11:8080 check

backend admin_back
  balance roundrobin
  server admin_server1 192.168.1.10:8081 check
  server admin_server2 192.168.1.11:8081 check

backend default_back
  balance roundrobin
  server default_server 192.168.1.10:8082 check
```

## 5. **基于客户端 IP 的负载均衡（会话保持）**

根据客户端的 IP 地址进行负载均衡，确保同一客户端的请求始终被转发到同一台服务器。

```text
frontend http_front
  bind *:80
  default_backend http_back

backend http_back
  balance source  # 根据客户端 IP 地址进行负载均衡（会话保持）
  server web1 192.168.1.10:80 check
  server web2 192.168.1.11:80 check
```

## 6. **限制请求速率**

通过设置请求速率限制，避免系统过载。

```text
frontend http_front
  bind *:80
  stick-table type ip size 1m expire 10s store gpc0
  acl rate_limit_exceeded sc_http_req_rate(0) gt 100
  http-request deny if rate_limit_exceeded
  default_backend http_back

backend http_back
  balance roundrobin
  server web1 192.168.1.10:80 check
  server web2 192.168.1.11:80 check
```

在这个示例中，如果来自某个 IP 的请求速率超过 100 请求/秒，则会被拒绝。

## 7. **健康检查与故障转移**

HAProxy 可以对后端服务器进行健康检查，如果某个服务器不可用，自动将请求转发到其他可用的服务器。

```text
frontend http_front
  bind *:80
  default_backend http_back

backend http_back
  balance roundrobin
  server web1 192.168.1.10:80 check
  server web2 192.168.1.11:80 check backup  # 备用服务器
```

`backup` 标志表示如果 `web1` 不可用，HAProxy 会自动转发请求到 `web2`。

## 8. **HTTP 重定向**

HAProxy 可以实现简单的 HTTP 到 HTTPS 的重定向。

```text
frontend http_front
  bind *:80
  redirect scheme https code 301 if { hdr(Host) -i example.com }

frontend https_front
  bind *:443 ssl crt /etc/ssl/certs/example.com.pem
  default_backend https_back

backend https_back
  balance roundrobin
  server web1 192.168.1.10:443 ssl check
  server web2 192.168.1.11:443 ssl check
```

## 9. **WebSocket 支持**

HAProxy 也支持 WebSocket，如果你有 WebSocket 服务，可以通过以下方式进行负载均衡。

```text
frontend http_front
  bind *:80
  option httplog
  option http-server-close
  timeout client  50000ms
  timeout server  50000ms
  default_backend websocket_back

backend websocket_back
  balance roundrobin
  option http-server-close
  server ws1 192.168.1.10:8080 check
  server ws2 192.168.1.11:8080 check
```

## 10. **高级负载均衡策略（加权轮询）**

使用加权轮询策略，根据服务器的负载能力来分配请求。

```text
frontend http_front
  bind *:80
  default_backend weighted_back

backend weighted_back
  balance roundrobin
  server web1 192.168.1.10:80 weight 2 check
  server web2 192.168.1.11:80 weight 1 check
```

在此示例中，`web1` 的权重为 2，比 `web2` 更频繁地接收请求。

------

