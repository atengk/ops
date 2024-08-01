#!/bin/bash

source /etc/cloudconfig/openrc-ha-info.sh
source /etc/cloudconfig/openrc-ha.sh


sshpass -p $openstack_cluster_root_password ssh -Tqo StrictHostKeychecking=no root@$controller_name1 << eeooff

mysql -uroot -p$openstack_service_password -e "create database IF NOT EXISTS glance ;"
mysql -uroot -p$openstack_service_password -e "GRANT ALL PRIVILEGES ON glance.* TO 'glance'@'localhost' IDENTIFIED BY '$openstack_service_password' ;"
mysql -uroot -p$openstack_service_password -e "GRANT ALL PRIVILEGES ON glance.* TO 'glance'@'%' IDENTIFIED BY '$openstack_service_password' ;"
eeooff


sshpass -p $openstack_cluster_root_password ssh -Tqo StrictHostKeychecking=no root@$controller_ip1 << eeooff
openstack user create --domain demo --password $openstack_service_password glance
openstack role add --project service --user glance admin
openstack service create --name glance --description "OpenStack Image" image
openstack endpoint create --region RegionOne image public http://openstack:9292
openstack endpoint create --region RegionOne image internal http://openstack:9292
openstack endpoint create --region RegionOne image admin http://openstack:9292
eeooff

for host in $openstack_controller_cluster_host_name
do
sshpass -p $openstack_cluster_root_password ssh -Tqo StrictHostKeychecking=no root@$host << eeooff
net1=\$(ip address | grep mtu | grep "state UP" | awk -F ':' 'NR==1{print \$2}')
ipaddress1=\$(ip a | grep \$net1 | grep -w inet | awk '{print \$2}' | awk -F '/' '{print \$1}' | head -n 1)
yum install -y openstack-glance
crudini --set /etc/glance/glance-api.conf DEFAULT bind_host \$ipaddress1
crudini --set /etc/glance/glance-api.conf DEFAULT enable_v1_api false
crudini --set /etc/glance/glance-api.conf database connection  mysql+pymysql://glance:$openstack_service_password@openstack/glance
crudini --set /etc/glance/glance-api.conf keystone_authtoken www_authenticate_uri http://openstack:5000
crudini --set /etc/glance/glance-api.conf keystone_authtoken auth_url http://openstack:35357
crudini --set /etc/glance/glance-api.conf keystone_authtoken memcached_servers $openstack_controller_cluster_memcache_servers
crudini --set /etc/glance/glance-api.conf keystone_authtoken auth_type password
crudini --set /etc/glance/glance-api.conf keystone_authtoken project_domain_name demo
crudini --set /etc/glance/glance-api.conf keystone_authtoken user_domain_name demo
crudini --set /etc/glance/glance-api.conf keystone_authtoken project_name service
crudini --set /etc/glance/glance-api.conf keystone_authtoken username glance
crudini --set /etc/glance/glance-api.conf keystone_authtoken password $openstack_service_password
crudini --set /etc/glance/glance-api.conf paste_deploy flavor keystone
crudini --set /etc/glance/glance-api.conf glance_store stores file,http
crudini --set /etc/glance/glance-api.conf glance_store default_store  file
crudini --set /etc/glance/glance-api.conf glance_store filesystem_store_datadir /var/lib/glance/images/

crudini --set /etc/glance/glance-registry.conf DEFAULT bind_host \$ipaddress1
crudini --set /etc/glance/glance-registry.conf database connection  mysql+pymysql://glance:$openstack_service_password@openstack/glance
crudini --set /etc/glance/glance-registry.conf keystone_authtoken www_authenticate_uri http://openstack:5000
crudini --set /etc/glance/glance-registry.conf keystone_authtoken auth_url http://openstack:35357
crudini --set /etc/glance/glance-registry.conf keystone_authtoken memcached_servers $openstack_controller_cluster_memcache_servers
crudini --set /etc/glance/glance-registry.conf keystone_authtoken auth_type password
crudini --set /etc/glance/glance-registry.conf keystone_authtoken project_domain_name demo
crudini --set /etc/glance/glance-registry.conf keystone_authtoken user_domain_name demo
crudini --set /etc/glance/glance-registry.conf keystone_authtoken project_name service
crudini --set /etc/glance/glance-registry.conf keystone_authtoken username glance
crudini --set /etc/glance/glance-registry.conf keystone_authtoken password $openstack_service_password
crudini --set /etc/glance/glance-registry.conf paste_deploy flavor keystone
eeooff
done

sshpass -p $openstack_cluster_root_password ssh -Tqo StrictHostKeychecking=no root@$controller_ip1 << eeooff
su -s /bin/sh -c "glance-manage db_sync" glance
eeooff

for host in $openstack_controller_cluster_host_name
do
sshpass -p $openstack_cluster_root_password ssh -Tqo StrictHostKeychecking=no root@$host << eeooff
systemctl enable openstack-glance-api openstack-glance-registry
systemctl restart openstack-glance-api openstack-glance-registry
eeooff
done

sshpass -p $openstack_cluster_root_password ssh -Tqo StrictHostKeychecking=no root@$controller_ip1 << eeooff
source /etc/profile
sleep 10
echo "# glance image-list"
glance image-list
eeooff


