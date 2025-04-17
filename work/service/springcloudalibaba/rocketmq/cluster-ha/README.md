# RocketMQ5

**RocketMQ** 是 **Apache** 顶级开源的**分布式消息队列**，最初由 **阿里巴巴** 开发，具备**高吞吐、低延迟、高可用**等特性，广泛用于**异步解耦、分布式事务、流式计算**等场景。RocketMQ **5.x** 版本引入 **Controller、Proxy、云原生支持**，增强了**多协议兼容性（HTTP/gRPC/MQTT）、自动主从切换、存储优化**。其核心组件包括 **NameServer（注册中心）、Broker（存储转发）、Controller（高可用管理）、Proxy（协议适配）**，适合**云环境和高并发业务** 🚀。

- [官网链接](https://rocketmq.apache.org/zh/)



文档使用以下3台服务器，具体服务分配见描述的进程

| IP地址        | 主机名    | 描述                |
| ------------- | --------- | ------------------- |
| 192.168.1.131 | bigdata01 | NameServer + Broker |
| 192.168.1.132 | bigdata02 | NameServer + Broker |
| 192.168.1.133 | bigdata03 | NameServer + Broker |


