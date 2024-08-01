#!/bin/bash
set -x
source /etc/cloudconfig/openrc.sh

#neutron install
yum install openstack-neutron-linuxbridge ebtables ipset net-tools conntrack-tools -y

if [[ `ip a |grep -w $INTERFACE_IP |grep -w $INTERFACE_NAME` = '' ]];then 
cat > /etc/sysconfig/network-scripts/ifcfg-$INTERFACE_NAME <<EOF
DEVICE=$INTERFACE_NAME
TYPE=Ethernet
BOOTPROTO=none
ONBOOT=yes
EOF
systemctl restart network
fi

#/etc/neutron/neutron.conf
crudini --set /etc/neutron/neutron.conf DEFAULT transport_url  rabbit://openstack:$NEUTRON_DBPASS@$HOST_NAME
crudini --set /etc/neutron/neutron.conf DEFAULT auth_strategy  keystone
crudini --set /etc/neutron/neutron.conf keystone_authtoken auth_uri  http://$HOST_NAME:5000
crudini --set /etc/neutron/neutron.conf keystone_authtoken auth_url  http://$HOST_NAME:5000
crudini --set /etc/neutron/neutron.conf keystone_authtoken memcached_servers  $HOST_NAME:11211
crudini --set /etc/neutron/neutron.conf keystone_authtoken auth_type  password
crudini --set /etc/neutron/neutron.conf keystone_authtoken project_domain_name  $DOMAIN_NAME
crudini --set /etc/neutron/neutron.conf keystone_authtoken user_domain_name  $DOMAIN_NAME
crudini --set /etc/neutron/neutron.conf keystone_authtoken project_name  service
crudini --set /etc/neutron/neutron.conf keystone_authtoken username  neutron
crudini --set /etc/neutron/neutron.conf keystone_authtoken password  $NEUTRON_PASS
crudini --set /etc/neutron/neutron.conf oslo_concurrency lock_path  /var/lib/neutron/tmp

#/etc/neutron/plugins/ml2/linuxbridge_agent.ini
crudini --set /etc/neutron/plugins/ml2/linuxbridge_agent.ini linux_bridge physical_interface_mappings  provider:$INTERFACE_NAME
crudini --set /etc/neutron/plugins/ml2/linuxbridge_agent.ini vxlan enable_vxlan  true
crudini --set /etc/neutron/plugins/ml2/linuxbridge_agent.ini vxlan local_ip $INTERFACE_IP
crudini --set /etc/neutron/plugins/ml2/linuxbridge_agent.ini vxlan l2_population  true
crudini --set /etc/neutron/plugins/ml2/linuxbridge_agent.ini securitygroup enable_security_group  true
crudini --set /etc/neutron/plugins/ml2/linuxbridge_agent.ini securitygroup firewall_driver  neutron.agent.linux.iptables_firewall.IptablesFirewallDriver

#/etc/nova/nova.conf
crudini --set /etc/nova/nova.conf neutron url  http://$HOST_NAME:9696
crudini --set /etc/nova/nova.conf neutron auth_url  http://$HOST_NAME:5000
crudini --set /etc/nova/nova.conf neutron auth_type  password
crudini --set /etc/nova/nova.conf neutron project_domain_name  $DOMAIN_NAME
crudini --set /etc/nova/nova.conf neutron user_domain_name  $DOMAIN_NAME
crudini --set /etc/nova/nova.conf neutron region_name  RegionOne
crudini --set /etc/nova/nova.conf neutron project_name  service
crudini --set /etc/nova/nova.conf neutron username  neutron
crudini --set /etc/nova/nova.conf neutron password  $NEUTRON_PASS

cat > /etc/sysctl.d/openstack-neutron.conf <<EOF
net.bridge.bridge-nf-call-iptables = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward = 1
EOF
modprobe br_netfilter
sysctl -p /etc/sysctl.d/openstack-neutron.conf

systemctl restart openstack-nova-compute.service
systemctl start neutron-linuxbridge-agent.service
systemctl enable neutron-linuxbridge-agent.service

systemctl restart libvirtd.service openstack-nova-compute.service
