#!/bin/bash

source /etc/cloudconfig/openrc-ha-info.sh
source /etc/cloudconfig/openrc-ha.sh


sshpass -p $openstack_cluster_root_password ssh -Tqo StrictHostKeychecking=no root@$controller_name1 << eeooff
mysql -uroot -p$openstack_service_password -e "create database IF NOT EXISTS neutron ;"
mysql -uroot -p$openstack_service_password -e "GRANT ALL PRIVILEGES ON neutron.* TO 'neutron'@'localhost' IDENTIFIED BY '$openstack_service_password' ;"
mysql -uroot -p$openstack_service_password -e "GRANT ALL PRIVILEGES ON neutron.* TO 'neutron'@'%' IDENTIFIED BY '$openstack_service_password' ;"
openstack user create --domain demo --password $openstack_service_password neutron
openstack role add --project service --user neutron admin
openstack service create --name neutron --description "OpenStack Networking" network
openstack endpoint create --region RegionOne network public http://openstack:9696
openstack endpoint create --region RegionOne  network internal http://openstack:9696
openstack endpoint create --region RegionOne  network admin http://openstack:9696


eeooff


for host in $openstack_controller_cluster_host_name
do
sshpass -p $openstack_cluster_root_password ssh -Tqo StrictHostKeychecking=no root@$host << eeooff
net1=\$(ip address | grep mtu | grep "state UP" | awk -F ':' 'NR==1{print \$2}' | awk '{print \$1}')
net2=\$(ip address | grep mtu | grep "mtu 1500" | awk -F ':' 'NR==2{print \$2}' | awk '{print \$1}')
ipaddress1=\$(ip a | grep \$net1 | grep -w inet | awk '{print \$2}' | awk -F '/' '{print \$1}' | head -n 1)
yum install openstack-neutron openstack-neutron-ml2 openstack-neutron-linuxbridge ebtables -y
cp /etc/sysconfig/network-scripts/ifcfg-\$net2{,.bak} &> /dev/null
cat > /etc/sysconfig/network-scripts/ifcfg-\$net2 <<EOF
DEVICE=\$net2
TYPE=Ethernet
BOOTPROTO=none
ONBOOT=yes
EOF
systemctl restart network

crudini --set /etc/neutron/neutron.conf DEFAULT bind_host \$ipaddress1
crudini --set /etc/neutron/neutron.conf DEFAULT core_plugin ml2
crudini --set /etc/neutron/neutron.conf DEFAULT service_plugins router
crudini --set /etc/neutron/neutron.conf DEFAULT allow_overlapping_ips True
crudini --set /etc/neutron/neutron.conf DEFAULT transport_url $openstack_controller_cluster_transport_url
crudini --set /etc/neutron/neutron.conf DEFAULT auth_strategy keystone
crudini --set /etc/neutron/neutron.conf DEFAULT notify_nova_on_port_status_changes true
crudini --set /etc/neutron/neutron.conf DEFAULT notify_nova_on_port_data_changes true
crudini --set /etc/neutron/neutron.conf DEFAULT l3_ha true
crudini --set /etc/neutron/neutron.conf DEFAULT max_l3_agents_per_router 3
crudini --set /etc/neutron/neutron.conf DEFAULT min_l3_agents_per_router 2
crudini --set /etc/neutron/neutron.conf DEFAULT l3_ha_net_cidr 169.254.192.0/18
crudini --set /etc/neutron/neutron.conf DEFAULT dhcp_agents_per_network 3
crudini --set /etc/neutron/neutron.conf database connection mysql+pymysql://neutron:$openstack_service_password@openstack/neutron

crudini --set /etc/neutron/neutron.conf keystone_authtoken auth_uri  http://openstack:5000
crudini --set /etc/neutron/neutron.conf keystone_authtoken auth_url  http://openstack:35357
crudini --set /etc/neutron/neutron.conf keystone_authtoken memcached_servers $openstack_controller_cluster_memcache_servers
crudini --set /etc/neutron/neutron.conf keystone_authtoken auth_type  password
crudini --set /etc/neutron/neutron.conf keystone_authtoken project_domain_name  demo
crudini --set /etc/neutron/neutron.conf keystone_authtoken user_domain_name  demo
crudini --set /etc/neutron/neutron.conf keystone_authtoken project_name  service
crudini --set /etc/neutron/neutron.conf keystone_authtoken username  neutron
crudini --set /etc/neutron/neutron.conf keystone_authtoken password  $openstack_service_password

crudini --set /etc/neutron/neutron.conf nova auth_url  http://openstack:35357
crudini --set /etc/neutron/neutron.conf nova auth_type  password
crudini --set /etc/neutron/neutron.conf nova project_domain_name  demo
crudini --set /etc/neutron/neutron.conf nova user_domain_name  demo
crudini --set /etc/neutron/neutron.conf nova region_name  RegionOne
crudini --set /etc/neutron/neutron.conf nova project_name  service
crudini --set /etc/neutron/neutron.conf nova username  nova
crudini --set /etc/neutron/neutron.conf nova password  $openstack_service_password

crudini --set /etc/neutron/neutron.conf oslo_concurrency lock_path  /var/lib/neutron/tmp

crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini ml2 type_drivers  vlan,flat,vxlan
crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini ml2 tenant_network_types  vlan
crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini ml2 mechanism_drivers  linuxbridge,l2population
crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini ml2 extension_drivers  port_security

crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini ml2_type_flat flat_networks  provider

crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini ml2_type_vlan network_vlan_ranges provider:2:200

crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini ml2_type_vxlan vni_ranges  2:200

crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini securitygroup enable_ipset  true

crudini --set /etc/neutron/plugins/ml2/linuxbridge_agent.ini linux_bridge physical_interface_mappings  provider:\$net2

crudini --set /etc/neutron/plugins/ml2/linuxbridge_agent.ini vxlan enable_vxlan  true
crudini --set /etc/neutron/plugins/ml2/linuxbridge_agent.ini vxlan local_ip \$ipaddress1
crudini --set /etc/neutron/plugins/ml2/linuxbridge_agent.ini vxlan l2_population  true

crudini --set /etc/neutron/plugins/ml2/linuxbridge_agent.ini securitygroup enable_security_group  true
crudini --set /etc/neutron/plugins/ml2/linuxbridge_agent.ini securitygroup firewall_driver  neutron.agent.linux.iptables_firewall.IptablesFirewallDriver
crudini --set /etc/neutron/l3_agent.ini DEFAULT interface_driver  linuxbridge


crudini --set /etc/neutron/dhcp_agent.ini DEFAULT interface_driver  linuxbridge
crudini --set /etc/neutron/dhcp_agent.ini DEFAULT dhcp_driver  neutron.agent.linux.dhcp.Dnsmasq
crudini --set /etc/neutron/dhcp_agent.ini DEFAULT enable_isolated_metadata  true
crudini --set /etc/neutron/metadata_agent.ini DEFAULT nova_metadata_host openstack
crudini --set /etc/neutron/metadata_agent.ini DEFAULT metadata_proxy_shared_secret qq2385569970
## metadata_proxy_shared_secret：与/etc/nova/nova.conf文件中参数一致

crudini --set /etc/nova/nova.conf neutron url  http://openstack:9696
crudini --set /etc/nova/nova.conf neutron auth_url  http://openstack:35357
crudini --set /etc/nova/nova.conf neutron auth_type  password
crudini --set /etc/nova/nova.conf neutron project_domain_name  demo
crudini --set /etc/nova/nova.conf neutron user_domain_name  demo
crudini --set /etc/nova/nova.conf neutron region_name  RegionOne
crudini --set /etc/nova/nova.conf neutron project_name  service
crudini --set /etc/nova/nova.conf neutron username  neutron
crudini --set /etc/nova/nova.conf neutron password  $openstack_service_password
crudini --set /etc/nova/nova.conf neutron service_metadata_proxy  true
crudini --set /etc/nova/nova.conf neutron metadata_proxy_shared_secret  qq2385569970
ln -s /etc/neutron/plugins/ml2/ml2_conf.ini /etc/neutron/plugin.ini
cat >> /etc/sysctl.conf <<EOF
## bridge
net.bridge.bridge-nf-call-iptables = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF
## 加载内核模块
modprobe br_netfilter
sysctl -p
eeooff
done


sshpass -p $openstack_cluster_root_password ssh -Tqo StrictHostKeychecking=no root@$controller_ip1 << eeooff
su -s /bin/sh -c "neutron-db-manage --config-file /etc/neutron/neutron.conf \
    --config-file /etc/neutron/plugins/ml2/ml2_conf.ini upgrade head" neutron
sleep 10
eeooff


for host in $openstack_controller_cluster_host_name
do
sshpass -p $openstack_cluster_root_password ssh -Tqo StrictHostKeychecking=no root@$host << eeooff
systemctl restart openstack-nova-api
systemctl enable neutron-server neutron-linuxbridge-agent \
    neutron-dhcp-agent neutron-metadata-agent neutron-l3-agent
systemctl restart neutron-server neutron-linuxbridge-agent \
    neutron-dhcp-agent neutron-metadata-agent neutron-l3-agent
eeooff
done



for host in $openstack_compute_cluster_host_name
do
sshpass -p $openstack_cluster_root_password ssh -Tqo StrictHostKeychecking=no root@$host << eeooff
net1=\$(ip address | grep mtu | grep "state UP" | awk -F ':' 'NR==1{print \$2}' | awk '{print \$1}')
net2=\$(ip address | grep mtu | grep "mtu 1500" | awk -F ':' 'NR==2{print \$2}' | awk '{print \$1}')
ipaddress1=\$(ip a | grep \$net1 | grep -w inet | awk '{print \$2}' | awk -F '/' '{print \$1}' | head -n 1)
yum install openstack-neutron-linuxbridge ebtables ipset net-tools -y
cp /etc/sysconfig/network-scripts/ifcfg-\$net2{,.bak} &> /dev/null
cat > /etc/sysconfig/network-scripts/ifcfg-\$net2 <<EOF
DEVICE=\$net2
TYPE=Ethernet
BOOTPROTO=none
ONBOOT=yes
EOF
systemctl restart network


crudini --set /etc/neutron/neutron.conf DEFAULT bind_host \$ipaddress1
crudini --set /etc/neutron/neutron.conf DEFAULT transport_url  $openstack_controller_cluster_transport_url
crudini --set /etc/neutron/neutron.conf DEFAULT auth_strategy  keystone
crudini --set /etc/neutron/neutron.conf DEFAULT state_path /var/lib/neutron

crudini --set /etc/neutron/neutron.conf keystone_authtoken auth_uri  http://openstack:5000
crudini --set /etc/neutron/neutron.conf keystone_authtoken auth_url  http://openstack:35357
crudini --set /etc/neutron/neutron.conf keystone_authtoken memcached_servers  $openstack_controller_cluster_memcache_servers
crudini --set /etc/neutron/neutron.conf keystone_authtoken auth_type  password
crudini --set /etc/neutron/neutron.conf keystone_authtoken project_domain_name  demo
crudini --set /etc/neutron/neutron.conf keystone_authtoken user_domain_name  demo
crudini --set /etc/neutron/neutron.conf keystone_authtoken project_name  service
crudini --set /etc/neutron/neutron.conf keystone_authtoken username  neutron
crudini --set /etc/neutron/neutron.conf keystone_authtoken password  $openstack_service_password
crudini --set /etc/neutron/neutron.conf oslo_concurrency lock_path  /var/lib/neutron/tmp

crudini --set /etc/neutron/plugins/ml2/linuxbridge_agent.ini linux_bridge physical_interface_mappings  provider:\$net2
crudini --set /etc/neutron/plugins/ml2/linuxbridge_agent.ini vxlan enable_vxlan  true
crudini --set /etc/neutron/plugins/ml2/linuxbridge_agent.ini vxlan local_ip \$ipaddress1
crudini --set /etc/neutron/plugins/ml2/linuxbridge_agent.ini vxlan l2_population  true
crudini --set /etc/neutron/plugins/ml2/linuxbridge_agent.ini securitygroup enable_security_group  true
crudini --set /etc/neutron/plugins/ml2/linuxbridge_agent.ini securitygroup firewall_driver  neutron.agent.linux.iptables_firewall.IptablesFirewallDriver


cat >> /etc/sysctl.conf <<EOF
net.ipv4.ip_nonlocal_bind = 1
net.ipv4.ip_forward = 1
## bridge
net.bridge.bridge-nf-call-iptables = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF
## 加载内核模块
modprobe br_netfilter
sysctl -p

crudini --set /etc/nova/nova.conf neutron url  http://openstack:9696
crudini --set /etc/nova/nova.conf neutron auth_url  http://openstack:35357
crudini --set /etc/nova/nova.conf neutron auth_type  password
crudini --set /etc/nova/nova.conf neutron project_domain_name  demo
crudini --set /etc/nova/nova.conf neutron user_domain_name  demo
crudini --set /etc/nova/nova.conf neutron region_name  RegionOne
crudini --set /etc/nova/nova.conf neutron project_name  service
crudini --set /etc/nova/nova.conf neutron username  neutron
crudini --set /etc/nova/nova.conf neutron password  $openstack_service_password
systemctl restart openstack-nova-compute
systemctl restart neutron-linuxbridge-agent
systemctl enable neutron-linuxbridge-agent
eeooff
done


sshpass -p $openstack_cluster_root_password ssh -Tqo StrictHostKeychecking=no root@$controller_ip1 << eeooff
sleep 10
## 创建安全组规则
openstack security group rule create --ingress --ethertype IPv4 --protocol icmp default
openstack security group rule create --ingress --ethertype IPv4 --dst-port 1:65535 --protocol tcp default
openstack security group rule create --ingress --ethertype IPv4 --dst-port 1:65535 --protocol udp default
openstack security group rule create --egress --ethertype IPv4 --protocol icmp default
openstack security group rule create --egress --ethertype IPv4 --dst-port 1:65535 --protocol tcp default
openstack security group rule create --egress --ethertype IPv4 --dst-port 1:65535 --protocol udp default
## 创建网络
openstack network create int-net
openstack subnet create --subnet-range 10.0.0.0/24 --network int-net int-subnet
echo "# openstack network agent list"
openstack network agent list
eeooff

