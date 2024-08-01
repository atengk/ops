#!/bin/bash

source /etc/cloudconfig/openrc-ha-info.sh
source /etc/cloudconfig/openrc-ha.sh


sshpass -p $openstack_cluster_root_password ssh -Tqo StrictHostKeychecking=no root@$controller_name1 << eeooff
mysql -uroot -p$openstack_service_password -e "create database IF NOT EXISTS cinder ;"
mysql -uroot -p$openstack_service_password -e "GRANT ALL PRIVILEGES ON cinder.* TO 'cinder'@'localhost' IDENTIFIED BY '$openstack_service_password' ;"
mysql -uroot -p$openstack_service_password -e "GRANT ALL PRIVILEGES ON cinder.* TO 'cinder'@'%' IDENTIFIED BY '$openstack_service_password' ;"
openstack user create --domain demo --password $openstack_service_password cinder
openstack role add --project service --user cinder admin
openstack service create --name cinderv2  --description "OpenStack Block Store" volumev2
openstack service create --name cinderv3  --description "OpenStack Block Store" volumev3
openstack endpoint create --region RegionOne volumev2 public http://openstack:8776/v2/%\(tenant_id\)s
openstack endpoint create --region RegionOne volumev2 internal http://openstack:8776/v2/%\(tenant_id\)s
openstack endpoint create --region RegionOne volumev2 admin http://openstack:8776/v2/%\(tenant_id\)s
openstack endpoint create --region RegionOne volumev3 public http://openstack:8776/v3/%\(tenant_id\)s
openstack endpoint create --region RegionOne volumev3 internal http://openstack:8776/v3/%\(tenant_id\)s
openstack endpoint create --region RegionOne volumev3 admin http://openstack:8776/v3/%\(tenant_id\)s

eeooff


for host in $openstack_controller_cluster_host_name
do
sshpass -p $openstack_cluster_root_password ssh -Tqo StrictHostKeychecking=no root@$host << eeooff
net1=\$(ip address | grep mtu | grep "state UP" | awk -F ':' 'NR==1{print \$2}')
ipaddress1=\$(ip a | grep \$net1 | grep -w inet | awk '{print \$2}' | awk -F '/' '{print \$1}' | head -n 1)
yum install openstack-cinder -y 
crudini --set /etc/cinder/cinder.conf DEFAULT my_ip \$ipaddress1
crudini --set /etc/cinder/cinder.conf DEFAULT rpc_backend rabbit
crudini --set /etc/cinder/cinder.conf DEFAULT osapi_volume_listen \$ipaddress1
crudini --set /etc/cinder/cinder.conf DEFAULT osapi_volume_listen_port 8776
crudini --set /etc/cinder/cinder.conf DEFAULT auth_strategy keystone
crudini --set /etc/cinder/cinder.conf DEFAULT log_dir /var/log/cinder
crudini --set /etc/cinder/cinder.conf DEFAULT state_path /var/lib/cinder
crudini --set /etc/cinder/cinder.conf DEFAULT transport_url $openstack_controller_cluster_transport_url

crudini --set /etc/cinder/cinder.conf database connection mysql+pymysql://cinder:$openstack_service_password@openstack/cinder
crudini --set /etc/cinder/cinder.conf keystone_authtoken www_authenticate_uri http://openstack:5000
crudini --set /etc/cinder/cinder.conf keystone_authtoken auth_url  http://openstack:35357
crudini --set /etc/cinder/cinder.conf keystone_authtoken memcached_servers  $openstack_controller_cluster_memcache_servers
crudini --set /etc/cinder/cinder.conf keystone_authtoken auth_type  password
crudini --set /etc/cinder/cinder.conf keystone_authtoken project_domain_name  demo
crudini --set /etc/cinder/cinder.conf keystone_authtoken user_domain_name demo
crudini --set /etc/cinder/cinder.conf keystone_authtoken project_name  service
crudini --set /etc/cinder/cinder.conf keystone_authtoken username  cinder
crudini --set /etc/cinder/cinder.conf keystone_authtoken password  $openstack_service_password

crudini --set /etc/cinder/cinder.conf oslo_concurrency lock_path /var/lib/cinder/tmp
crudini --set /etc/nova/nova.conf cinder os_region_name  RegionOne
eeooff
done


sshpass -p $openstack_cluster_root_password ssh -Tqo StrictHostKeychecking=no root@$controller_ip1 << eeooff
su -s /bin/sh -c "cinder-manage db sync" cinder
eeooff


for host in $openstack_controller_cluster_host_name
do
sshpass -p $openstack_cluster_root_password ssh -Tqo StrictHostKeychecking=no root@$host << eeooff
systemctl restart openstack-nova-api
systemctl enable openstack-cinder-api openstack-cinder-scheduler
systemctl restart openstack-cinder-api openstack-cinder-scheduler
eeooff
done

for host in $openstack_compute_cluster_host_name
do
sshpass -p $openstack_cluster_root_password ssh -Tqo StrictHostKeychecking=no root@$host << eeooff
net1=\$(ip address | grep mtu | grep "state UP" | awk -F ':' 'NR==1{print \$2}')
ipaddress1=\$(ip a | grep \$net1 | grep -w inet | awk '{print \$2}' | awk -F '/' '{print \$1}' | head -n 1)
yum install lvm2 device-mapper-persistent-data \
    openstack-cinder targetcli python-keystone -y
crudini --set /etc/cinder/cinder.conf DEFAULT my_ip \$ipaddress1
crudini --set /etc/cinder/cinder.conf DEFAULT transport_url $openstack_controller_cluster_transport_url
crudini --set /etc/cinder/cinder.conf DEFAULT auth_strategy keystone
crudini --set /etc/cinder/cinder.conf DEFAULT glance_api_servers  http://openstack:9292
crudini --set /etc/cinder/cinder.conf DEFAULT enabled_backends  ceph
crudini --set /etc/cinder/cinder.conf database connection mysql+pymysql://cinder:$openstack_service_password@openstack/cinder
crudini --set /etc/cinder/cinder.conf keystone_authtoken www_authenticate_uri http://openstack:5000
crudini --set /etc/cinder/cinder.conf keystone_authtoken auth_url  http://openstack:35357
crudini --set /etc/cinder/cinder.conf keystone_authtoken memcached_servers  $openstack_controller_cluster_memcache_servers
crudini --set /etc/cinder/cinder.conf keystone_authtoken auth_type  password
crudini --set /etc/cinder/cinder.conf keystone_authtoken project_domain_name  demo
crudini --set /etc/cinder/cinder.conf keystone_authtoken user_domain_name demo
crudini --set /etc/cinder/cinder.conf keystone_authtoken project_name  service
crudini --set /etc/cinder/cinder.conf keystone_authtoken username  cinder
crudini --set /etc/cinder/cinder.conf keystone_authtoken password  $openstack_service_password
crudini --set /etc/cinder/cinder.conf oslo_concurrency lock_path /var/lib/cinder/tmp
systemctl enable openstack-cinder-volume target
systemctl restart openstack-cinder-volume target
eeooff
done


sshpass -p $openstack_cluster_root_password ssh -Tqo StrictHostKeychecking=no root@$controller_ip1 << eeooff
sleep 10
echo "# openstack volume service list"
openstack volume service list --service cinder-scheduler
eeooff
