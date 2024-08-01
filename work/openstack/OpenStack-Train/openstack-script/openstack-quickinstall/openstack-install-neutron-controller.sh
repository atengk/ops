#!/bin/bash
set -x
source /etc/cloudconfig/openrc.sh
source /etc/keystone/admin-openrc.sh

#neutron mysql
mysql -uroot -p$DB_PASS -e "create database IF NOT EXISTS neutron ;"
mysql -uroot -p$DB_PASS -e "GRANT ALL PRIVILEGES ON neutron.* TO 'neutron'@'localhost' IDENTIFIED BY '$NEUTRON_DBPASS' ;"
mysql -uroot -p$DB_PASS -e "GRANT ALL PRIVILEGES ON neutron.* TO 'neutron'@'%' IDENTIFIED BY '$NEUTRON_DBPASS' ;"

#neutron  user role service endpoint 
openstack user create --domain $DOMAIN_NAME --password $NEUTRON_PASS neutron
openstack role add --project service --user neutron admin
openstack service create --name neutron --description "OpenStack Networking" network
openstack endpoint create --region RegionOne network public http://$HOST_NAME:9696
openstack endpoint create --region RegionOne  network internal http://$HOST_NAME:9696
openstack endpoint create --region RegionOne  network admin http://$HOST_NAME:9696

#neutron install
yum install openstack-neutron openstack-neutron-ml2 openstack-neutron-linuxbridge ebtables -y

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
crudini --set /etc/neutron/neutron.conf DEFAULT core_plugin  ml2
crudini --set /etc/neutron/neutron.conf DEFAULT service_plugins 
crudini --set /etc/neutron/neutron.conf DEFAULT transport_url  rabbit://openstack:$NEUTRON_DBPASS@$HOST_NAME
crudini --set /etc/neutron/neutron.conf DEFAULT auth_strategy  keystone
crudini --set /etc/neutron/neutron.conf DEFAULT notify_nova_on_port_status_changes  true
crudini --set /etc/neutron/neutron.conf DEFAULT notify_nova_on_port_data_changes  true

crudini --set /etc/neutron/neutron.conf database connection mysql+pymysql://neutron:$NEUTRON_DBPASS@$HOST_NAME/neutron

crudini --set /etc/neutron/neutron.conf keystone_authtoken auth_uri  http://$HOST_NAME:5000
crudini --set /etc/neutron/neutron.conf keystone_authtoken auth_url  http://$HOST_NAME:5000
crudini --set /etc/neutron/neutron.conf keystone_authtoken memcached_servers  $HOST_NAME:11211
crudini --set /etc/neutron/neutron.conf keystone_authtoken auth_type  password
crudini --set /etc/neutron/neutron.conf keystone_authtoken project_domain_name  $DOMAIN_NAME
crudini --set /etc/neutron/neutron.conf keystone_authtoken user_domain_name  $DOMAIN_NAME
crudini --set /etc/neutron/neutron.conf keystone_authtoken project_name  service
crudini --set /etc/neutron/neutron.conf keystone_authtoken username  neutron
crudini --set /etc/neutron/neutron.conf keystone_authtoken password  $NEUTRON_PASS

crudini --set /etc/neutron/neutron.conf nova auth_url  http://$HOST_NAME:5000
crudini --set /etc/neutron/neutron.conf nova auth_type  password
crudini --set /etc/neutron/neutron.conf nova project_domain_name  $DOMAIN_NAME
crudini --set /etc/neutron/neutron.conf nova user_domain_name  $DOMAIN_NAME
crudini --set /etc/neutron/neutron.conf nova region_name  RegionOne
crudini --set /etc/neutron/neutron.conf nova project_name  service
crudini --set /etc/neutron/neutron.conf nova username  nova
crudini --set /etc/neutron/neutron.conf nova password  $NOVA_PASS

crudini --set /etc/neutron/neutron.conf oslo_concurrency lock_path  /var/lib/neutron/tmp

#/etc/neutron/plugins/ml2/ml2_conf.ini
crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini ml2 type_drivers  flat,vlan,vxlan
crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini ml2 tenant_network_types  vxlan
crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini ml2 mechanism_drivers  linuxbridge,l2population
crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini ml2 extension_drivers  port_security

crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini ml2_type_flat flat_networks  $Physical_NAME

crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini ml2_type_vlan network_vlan_ranges $Physical_NAME:$minvlan:$maxvlan

crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini ml2_type_vxlan vni_ranges  $minvlan:$maxvlan

crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini securitygroup enable_ipset  true

#/etc/neutron/plugins/ml2/linuxbridge_agent.ini
crudini --set /etc/neutron/plugins/ml2/linuxbridge_agent.ini linux_bridge physical_interface_mappings  $Physical_NAME:$INTERFACE_NAME

crudini --set /etc/neutron/plugins/ml2/linuxbridge_agent.ini vxlan enable_vxlan  true
crudini --set /etc/neutron/plugins/ml2/linuxbridge_agent.ini vxlan local_ip  $INTERFACE_IP
crudini --set /etc/neutron/plugins/ml2/linuxbridge_agent.ini vxlan l2_population  true

crudini --set /etc/neutron/plugins/ml2/linuxbridge_agent.ini securitygroup enable_security_group  true
crudini --set /etc/neutron/plugins/ml2/linuxbridge_agent.ini securitygroup firewall_driver  neutron.agent.linux.iptables_firewall.IptablesFirewallDriver


#/etc/neutron/dhcp_agent.ini
crudini --set /etc/neutron/dhcp_agent.ini DEFAULT interface_driver  linuxbridge
crudini --set /etc/neutron/dhcp_agent.ini DEFAULT dhcp_driver  neutron.agent.linux.dhcp.Dnsmasq
crudini --set /etc/neutron/dhcp_agent.ini DEFAULT enable_isolated_metadata  true

#/etc/neutron/metadata_agent.ini
crudini --set /etc/neutron/metadata_agent.ini DEFAULT nova_metadata_host  $HOST_NAME
crudini --set /etc/neutron/metadata_agent.ini DEFAULT metadata_proxy_shared_secret  $METADATA_SECRET

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
crudini --set /etc/nova/nova.conf neutron service_metadata_proxy  true
crudini --set /etc/nova/nova.conf neutron metadata_proxy_shared_secret  $METADATA_SECRET

cat > /etc/sysctl.d/openstack-neutron.conf <<EOF
net.bridge.bridge-nf-call-iptables = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward = 1
EOF
modprobe br_netfilter
sysctl -p /etc/sysctl.d/openstack-neutron.conf

ln -s /etc/neutron/plugins/ml2/ml2_conf.ini /etc/neutron/plugin.ini
su -s /bin/sh -c "neutron-db-manage --config-file /etc/neutron/neutron.conf  --config-file /etc/neutron/plugins/ml2/ml2_conf.ini upgrade head" neutron
systemctl restart openstack-nova-api.service

systemctl enable neutron-server \
  neutron-linuxbridge-agent neutron-dhcp-agent \
  neutron-metadata-agent
systemctl start neutron-server \
  neutron-linuxbridge-agent neutron-dhcp-agent \
  neutron-metadata-agent