## author:	孔余
## QQ:		2385569970
## version:	1.1
## date:	2022-05-26


# 集群控制节点IP地址，使用逗号分隔
openstack_controller_cluster_ip=10.24.10.7,10.24.10.8,10.24.10.9

# 集群计算节点IP地址，使用逗号分隔
openstack_compute_cluster_ip=10.24.10.7,10.24.10.8,10.24.10.9

# 集群ceph节点IP地址，使用逗号分隔
openstack_ceph_cluster_ip=10.24.10.7,10.24.10.8,10.24.10.9

## 控制节点的虚拟IP地址(Keepalived服务)
openstack_cluster_vip=10.24.10.10

## 集群root密码，确保集群root密码一致；一键修改密码：echo 000000 | passwd --stdin root
openstack_cluster_root_password=000000

## 集群中其他服务组件密码
openstack_service_password=000000

## ceph集群磁盘
openstack_ceph_disk=vdb

