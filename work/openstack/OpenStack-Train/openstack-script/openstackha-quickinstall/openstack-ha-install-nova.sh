#!/bin/bash

source /etc/cloudconfig/openrc-ha-info.sh
source /etc/cloudconfig/openrc-ha.sh


sshpass -p $openstack_cluster_root_password ssh -Tqo StrictHostKeychecking=no root@$controller_name1 << eeooff
rabbitmqctl set_policy ha-all "^" '{"ha-mode":"all"}'
rabbitmqctl cluster_status
rabbitmqctl add_user openstack $openstack_service_password
rabbitmqctl set_user_tags openstack administrator
rabbitmqctl set_permissions -p / openstack  ".*" ".*" ".*"
rabbitmqctl list_users
mysql -uroot -p$openstack_service_password -e "create database IF NOT EXISTS nova ;"
mysql -uroot -p$openstack_service_password  -e "create database IF NOT EXISTS nova_api ;"
mysql -uroot -p$openstack_service_password  -e "create database IF NOT EXISTS nova_cell0 ;"
mysql -uroot -p$openstack_service_password  -e "GRANT ALL PRIVILEGES ON nova.* TO 'nova'@'localhost' IDENTIFIED BY '$openstack_service_password' ;"
mysql -uroot -p$openstack_service_password -e "GRANT ALL PRIVILEGES ON nova.* TO 'nova'@'%' IDENTIFIED BY '$openstack_service_password' ;"
mysql -uroot -p$openstack_service_password -e "GRANT ALL PRIVILEGES ON nova_api.* TO 'nova'@'localhost' IDENTIFIED BY '$openstack_service_password' ;"
mysql -uroot -p$openstack_service_password -e "GRANT ALL PRIVILEGES ON nova_api.* TO 'nova'@'%' IDENTIFIED BY '$openstack_service_password' ;"
mysql -uroot -p$openstack_service_password -e "GRANT ALL PRIVILEGES ON nova_cell0.* TO 'nova'@'localhost' IDENTIFIED BY '$openstack_service_password' ;"
mysql -uroot -p$openstack_service_password -e "GRANT ALL PRIVILEGES ON nova_cell0.* TO 'nova'@'%' IDENTIFIED BY '$openstack_service_password' ;"
openstack user create --domain demo --password $openstack_service_password nova
openstack role add --project service --user nova admin
openstack service create --name nova --description "OpenStack Compute" compute
openstack endpoint create --region RegionOne compute public http://openstack:8774/v2.1
openstack endpoint create --region RegionOne compute internal http://openstack:8774/v2.1
openstack endpoint create --region RegionOne compute admin http://openstack:8774/v2.1
openstack user create --domain demo --password $openstack_service_password placement
openstack role add --project service --user placement admin
openstack service create --name placement --description "Placement API" placement
openstack endpoint create --region RegionOne placement public http://openstack:8778
openstack endpoint create --region RegionOne placement internal http://openstack:8778
openstack endpoint create --region RegionOne placement admin http://openstack:8778
eeooff


for host in $openstack_controller_cluster_host_name
do
sshpass -p $openstack_cluster_root_password ssh -Tqo StrictHostKeychecking=no root@$host << eeooff
net1=\$(ip address | grep mtu | grep "state UP" | awk -F ':' 'NR==1{print \$2}')
ipaddress1=\$(ip a | grep \$net1 | grep -w inet | awk '{print \$2}' | awk -F '/' '{print \$1}' | head -n 1)
yum install openstack-nova-api openstack-nova-conductor \
    openstack-nova-console openstack-nova-novncproxy \
    openstack-nova-scheduler openstack-placement-api -y
crudini --set /etc/nova/nova.conf DEFAULT my_ip \$ipaddress1
crudini --set /etc/nova/nova.conf DEFAULT osapi_compute_listen \$ipaddress1
crudini --set /etc/nova/nova.conf DEFAULT osapi_compute_listen_port 8774
crudini --set /etc/nova/nova.conf DEFAULT metadata_listen \$ipaddress1
crudini --set /etc/nova/nova.conf DEFAULT metadata_listen_port 8775
crudini --set /etc/nova/nova.conf DEFAULT enabled_apis osapi_compute,metadata
crudini --set /etc/nova/nova.conf DEFAULT transport_url $openstack_controller_cluster_transport_url
crudini --set /etc/nova/nova.conf DEFAULT use_neutron  True
crudini --set /etc/nova/nova.conf DEFAULT firewall_driver nova.virt.firewall.NoopFirewallDriver
crudini --set /etc/nova/nova.conf api auth_strategy keystone
crudini --set /etc/nova/nova.conf api_database connection  mysql+pymysql://nova:$openstack_service_password@openstack/nova_api
crudini --set /etc/nova/nova.conf database connection  mysql+pymysql://nova:$openstack_service_password@openstack/nova
crudini --set /etc/nova/nova.conf cache backend oslo_cache.memcache_pool
crudini --set /etc/nova/nova.conf cache enabled True
crudini --set /etc/nova/nova.conf cache memcache_servers $openstack_controller_cluster_memcache_servers

crudini --set /etc/nova/nova.conf keystone_authtoken auth_uri  http://openstack:5000/v3
crudini --set /etc/nova/nova.conf keystone_authtoken auth_url  http://openstack:35357/v3
crudini --set /etc/nova/nova.conf keystone_authtoken memcached_servers $openstack_controller_cluster_memcache_servers
crudini --set /etc/nova/nova.conf keystone_authtoken auth_type password
crudini --set /etc/nova/nova.conf keystone_authtoken project_domain_name demo
crudini --set /etc/nova/nova.conf keystone_authtoken user_domain_name demo
crudini --set /etc/nova/nova.conf keystone_authtoken project_name service
crudini --set /etc/nova/nova.conf keystone_authtoken username nova
crudini --set /etc/nova/nova.conf keystone_authtoken password $openstack_service_password
crudini --set /etc/nova/nova.conf vnc enabled true
crudini --set /etc/nova/nova.conf vnc server_listen \$ipaddress1
crudini --set /etc/nova/nova.conf vnc server_proxyclient_address \$ipaddress1
crudini --set /etc/nova/nova.conf vnc novncproxy_base_url http://$openstack_cluster_vip:6080/vnc_auto.html
crudini --set /etc/nova/nova.conf vnc novncproxy_host \$ipaddress1
crudini --set /etc/nova/nova.conf vnc novncproxy_port 6080

crudini --set /etc/nova/nova.conf glance api_servers http://openstack:9292
crudini --set /etc/nova/nova.conf oslo_concurrency lock_path /var/lib/nova/tmp
crudini --set /etc/nova/nova.conf placement region_name RegionOne
crudini --set /etc/nova/nova.conf placement project_domain_name dmeo
crudini --set /etc/nova/nova.conf placement project_name service
crudini --set /etc/nova/nova.conf placement auth_type password
crudini --set /etc/nova/nova.conf placement user_domain_name demo
crudini --set /etc/nova/nova.conf placement auth_url http://openstack:35357/v3
crudini --set /etc/nova/nova.conf placement username placement
crudini --set /etc/nova/nova.conf placement password $openstack_service_password

sed -i "s/Listen 8778/Listen \$ipaddress1:8778/g" /etc/httpd/conf.d/00-nova-placement-api.conf
sed -i "s/*:8778/\$ipaddress1:8778/g" /etc/httpd/conf.d/00-nova-placement-api.conf
cat >> /etc/httpd/conf.d/00-nova-placement-api.conf <<EOF

<Directory /usr/bin>
  <IfVersion >= 2.4>
    Require all granted
  </IfVersion>
  <IfVersion < 2.4>
    Order allow,deny
    Allow from all
  </IfVersion>
</Directory>
EOF
## 重启httpd服务，启动placement-api监听端口
systemctl restart httpd
eeooff
done

sshpass -p $openstack_cluster_root_password ssh -Tqo StrictHostKeychecking=no root@$controller_ip1 << eeooff
su -s /bin/sh -c "nova-manage api_db sync" nova
su -s /bin/sh -c "nova-manage cell_v2 map_cell0" nova
su -s /bin/sh -c "nova-manage cell_v2 discover_hosts --verbose" nova
su -s /bin/sh -c "nova-manage cell_v2 create_cell --name=cell1 --verbose" nova
su -s /bin/sh -c "nova-manage db sync" nova
mysql -uroot -p$openstack_service_password -e "use nova_api;select id,uuid,name,transport_url,database_connection from cell_mappings\G;"
sleep 10
eeooff

for host in $openstack_controller_cluster_host_name
do
sshpass -p $openstack_cluster_root_password ssh -Tqo StrictHostKeychecking=no root@$host << eeooff
systemctl enable openstack-nova-api openstack-nova-consoleauth openstack-nova-scheduler openstack-nova-conductor openstack-nova-novncproxy
systemctl restart openstack-nova-api openstack-nova-consoleauth openstack-nova-scheduler openstack-nova-conductor openstack-nova-novncproxy
eeooff
done


for host in $openstack_compute_cluster_host_name
do
sshpass -p $openstack_cluster_root_password ssh -Tqo StrictHostKeychecking=no root@$host << eeooff
net1=\$(ip address | grep mtu | grep "state UP" | awk -F ':' 'NR==1{print \$2}')
ipaddress1=\$(ip a | grep \$net1 | grep -w inet | awk '{print \$2}' | awk -F '/' '{print \$1}' | head -n 1)
yum install openstack-nova-compute -y
crudini --set /etc/nova/nova.conf DEFAULT my_ip \$ipaddress1
crudini --set /etc/nova/nova.conf DEFAULT enabled_apis osapi_compute,metadata
crudini --set /etc/nova/nova.conf DEFAULT transport_url $openstack_controller_cluster_transport_url
crudini --set /etc/nova/nova.conf DEFAULT use_neutron True
crudini --set /etc/nova/nova.conf DEFAULT firewall_driver nova.virt.firewall.NoopFirewallDriver
crudini --set /etc/nova/nova.conf api auth_strategy keystone
crudini --set /etc/nova/nova.conf keystone_authtoken auth_uri http://openstack:5000
crudini --set /etc/nova/nova.conf keystone_authtoken auth_url http://openstack:35357
crudini --set /etc/nova/nova.conf keystone_authtoken memcached_servers $openstack_controller_cluster_memcache_servers
crudini --set /etc/nova/nova.conf keystone_authtoken auth_type password
crudini --set /etc/nova/nova.conf keystone_authtoken project_domain_name demo
crudini --set /etc/nova/nova.conf keystone_authtoken user_domain_name demo
crudini --set /etc/nova/nova.conf keystone_authtoken project_name service
crudini --set /etc/nova/nova.conf keystone_authtoken username nova
crudini --set /etc/nova/nova.conf keystone_authtoken password $openstack_service_password
crudini --set /etc/nova/nova.conf vnc enabled True
crudini --set /etc/nova/nova.conf vnc server_listen \$ipaddress1
crudini --set /etc/nova/nova.conf vnc server_proxyclient_address \$ipaddress1
## 填虚拟ip地址
crudini --set /etc/nova/nova.conf vnc novncproxy_base_url http://$openstack_cluster_vip:6080/vnc_auto.html
crudini --set /etc/nova/nova.conf glance api_servers http://openstack:9292
crudini --set /etc/nova/nova.conf oslo_concurrency lock_path /var/lib/nova/tmp

crudini --set /etc/nova/nova.conf placement region_name RegionOne
crudini --set /etc/nova/nova.conf placement project_domain_name demo
crudini --set /etc/nova/nova.conf placement project_name service
crudini --set /etc/nova/nova.conf placement auth_type password
crudini --set /etc/nova/nova.conf placement user_domain_name demo
crudini --set /etc/nova/nova.conf placement auth_url http://openstack:5000/v3
crudini --set /etc/nova/nova.conf placement username placement
crudini --set /etc/nova/nova.conf placement password $openstack_service_password
virt_num=\$(egrep -c '(vmx|svm)' /proc/cpuinfo)
if [ \$virt_num = '0' ];then
	crudini --set /etc/nova/nova.conf libvirt virt_type  qemu
fi
systemctl enable libvirtd openstack-nova-compute
systemctl restart libvirtd openstack-nova-compute
eeooff
done


sshpass -p $openstack_cluster_root_password ssh -Tqo StrictHostKeychecking=no root@$controller_ip1 << eeooff
sleep 10
source /etc/keystone/admin-openrc.sh
nova-manage cell_v2 discover_hosts --verbose
nova flavor-create test 1 512 5 1
nova flavor-create c2_r2_d20 2 2048 20 2
nova flavor-create c4_r8_d100 3 8192 100 4
echo "# openstack compute service list"
openstack compute service list
eeooff
