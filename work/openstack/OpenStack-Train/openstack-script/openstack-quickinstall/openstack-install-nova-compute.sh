#!/bin/bash
set -x
source /etc/cloudconfig/openrc.sh

#nova-compute install
yum install openstack-nova-compute sshpass -y

#/etc/nova/nova.conf
crudini --set /etc/nova/nova.conf DEFAULT enabled_apis osapi_compute,metadata
crudini --set /etc/nova/nova.conf DEFAULT transport_url rabbit://openstack:$NOVA_DBPASS@$HOST_NAME
crudini --set /etc/nova/nova.conf DEFAULT my_ip $HOST_IP_NODE
crudini --set /etc/nova/nova.conf DEFAULT use_neutron True
crudini --set /etc/nova/nova.conf DEFAULT firewall_driver nova.virt.firewall.NoopFirewallDriver

crudini --set /etc/nova/nova.conf api auth_strategy keystone

crudini --set /etc/nova/nova.conf keystone_authtoken auth_url http://$HOST_NAME:5000/v3
crudini --set /etc/nova/nova.conf keystone_authtoken memcached_servers $HOST_NAME:11211
crudini --set /etc/nova/nova.conf keystone_authtoken auth_type password
crudini --set /etc/nova/nova.conf keystone_authtoken project_domain_name $DOMAIN_NAME
crudini --set /etc/nova/nova.conf keystone_authtoken user_domain_name $DOMAIN_NAME
crudini --set /etc/nova/nova.conf keystone_authtoken project_name service
crudini --set /etc/nova/nova.conf keystone_authtoken username nova
crudini --set /etc/nova/nova.conf keystone_authtoken password $NOVA_PASS

crudini --set /etc/nova/nova.conf vnc enabled True
crudini --set /etc/nova/nova.conf vnc server_listen 0.0.0.0
crudini --set /etc/nova/nova.conf vnc server_proxyclient_address $HOST_IP_NODE
crudini --set /etc/nova/nova.conf vnc novncproxy_base_url http://$HOST_IP:6080/vnc_auto.html

crudini --set /etc/nova/nova.conf glance api_servers http://$HOST_NAME:9292

crudini --set /etc/nova/nova.conf oslo_concurrency lock_path /var/lib/nova/tmp

crudini --set /etc/nova/nova.conf placement os_region_name RegionOne
crudini --set /etc/nova/nova.conf placement project_domain_name $DOMAIN_NAME
crudini --set /etc/nova/nova.conf placement project_name service
crudini --set /etc/nova/nova.conf placement auth_type password
crudini --set /etc/nova/nova.conf placement user_domain_name $DOMAIN_NAME
crudini --set /etc/nova/nova.conf placement auth_url http://$HOST_NAME:5000/v3
crudini --set /etc/nova/nova.conf placement username placement
crudini --set /etc/nova/nova.conf placement password $NOVA_PASS


## 调优参数
#crudini --set /etc/nova/nova.conf DEFAULT allow_resize_to_same_host true
#crudini --set /etc/nova/nova.conf DEFAULT resume_guests_state_on_host_boot true
#crudini --set /etc/nova/nova.conf DEFAULT cpu_allocation_ratio 8
#crudini --set /etc/nova/nova.conf DEFAULT ram_allocation_ratio 1.0
#crudini --set /etc/nova/nova.conf DEFAULT disk_allocation_ratio 1.0
#crudini --set /etc/nova/nova.conf DEFAULT reserved_host_disk_mb 20480
#crudini --set /etc/nova/nova.conf DEFAULT reserved_host_memory_mb 4096
#crudini --set /etc/nova/nova.conf DEFAULT max_concurrent_builds 20

## 设置qemu虚拟化模式
#crudini --set /etc/nova/nova.conf libvirt virt_type qemu


systemctl enable libvirtd.service openstack-nova-compute.service
systemctl restart libvirtd.service openstack-nova-compute.service

sshpass -p $HOST_PASS ssh -o StrictHostKeychecking=no -q $HOST_IP << EOF
source /etc/cloudconfig/openrc.sh
source /etc/keystone/admin-openrc.sh
openstack compute service list --service nova-compute
su -s /bin/sh -c "nova-manage cell_v2 discover_hosts --verbose" nova
exit
EOF