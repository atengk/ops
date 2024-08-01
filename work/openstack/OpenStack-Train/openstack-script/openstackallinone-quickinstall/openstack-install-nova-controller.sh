#!/bin/bash
set -x
source /etc/cloudconfig/openrc.sh
source /etc/keystone/admin-openrc.sh

#mysql nova mysql
mysql -uroot -p$DB_PASS -e "create database IF NOT EXISTS nova ;"
mysql -uroot -p$DB_PASS -e "create database IF NOT EXISTS nova_api ;"
mysql -uroot -p$DB_PASS -e "create database IF NOT EXISTS nova_cell0 ;"
mysql -uroot -p$DB_PASS -e "create database IF NOT EXISTS placement ;"
mysql -uroot -p$DB_PASS -e "GRANT ALL PRIVILEGES ON nova.* TO 'nova'@'localhost' IDENTIFIED BY '$NOVA_DBPASS' ;"
mysql -uroot -p$DB_PASS -e "GRANT ALL PRIVILEGES ON nova.* TO 'nova'@'%' IDENTIFIED BY '$NOVA_DBPASS' ;"
mysql -uroot -p$DB_PASS -e "GRANT ALL PRIVILEGES ON nova_api.* TO 'nova'@'localhost' IDENTIFIED BY '$NOVA_DBPASS' ;"
mysql -uroot -p$DB_PASS -e "GRANT ALL PRIVILEGES ON nova_api.* TO 'nova'@'%' IDENTIFIED BY '$NOVA_DBPASS' ;"
mysql -uroot -p$DB_PASS -e "GRANT ALL PRIVILEGES ON nova_cell0.* TO 'nova'@'localhost' IDENTIFIED BY '$NOVA_DBPASS' ;"
mysql -uroot -p$DB_PASS -e "GRANT ALL PRIVILEGES ON nova_cell0.* TO 'nova'@'%' IDENTIFIED BY '$NOVA_DBPASS' ;"
mysql -uroot -p$DB_PASS -e "GRANT ALL PRIVILEGES ON placement.* TO 'placement'@'localhost' IDENTIFIED BY '$NOVA_DBPASS' ;"
mysql -uroot -p$DB_PASS -e "GRANT ALL PRIVILEGES ON placement.* TO 'placement'@'%' IDENTIFIED BY '$NOVA_DBPASS' ;"

#nova user role service endpoint
openstack user create --domain $DOMAIN_NAME --password $NOVA_PASS nova
openstack role add --project service --user nova admin
openstack service create --name nova --description "OpenStack Compute" compute
openstack endpoint create --region RegionOne compute public http://$HOST_NAME:8774/v2.1
openstack endpoint create --region RegionOne compute internal http://$HOST_NAME:8774/v2.1
openstack endpoint create --region RegionOne compute admin http://$HOST_NAME:8774/v2.1
openstack user create --domain $DOMAIN_NAME --password $NOVA_PASS placement
openstack role add --project service --user placement admin
openstack service create --name placement --description "Placement API" placement
openstack endpoint create --region RegionOne placement public http://$HOST_NAME:8778
openstack endpoint create --region RegionOne placement internal http://$HOST_NAME:8778
openstack endpoint create --region RegionOne placement admin http://$HOST_NAME:8778

#nova install
yum install openstack-nova-api openstack-nova-conductor openstack-nova-console openstack-nova-novncproxy openstack-nova-scheduler openstack-placement-api -y

#/etc/nova/nova.conf
crudini --set /etc/nova/nova.conf DEFAULT enabled_apis  osapi_compute,metadata
crudini --set /etc/nova/nova.conf DEFAULT transport_url rabbit://openstack:$NOVA_DBPASS@$HOST_NAME
crudini --set /etc/nova/nova.conf DEFAULT my_ip $HOST_IP
crudini --set /etc/nova/nova.conf DEFAULT use_neutron  True
crudini --set /etc/nova/nova.conf DEFAULT firewall_driver nova.virt.firewall.NoopFirewallDriver

crudini --set /etc/nova/nova.conf api auth_strategy keystone

crudini --set /etc/nova/nova.conf api_database connection  mysql+pymysql://nova:$NOVA_DBPASS@$HOST_NAME/nova_api

crudini --set /etc/nova/nova.conf database connection  mysql+pymysql://nova:$NOVA_DBPASS@$HOST_NAME/nova

crudini --set /etc/nova/nova.conf keystone_authtoken auth_url  http://$HOST_NAME:5000/v3
crudini --set /etc/nova/nova.conf keystone_authtoken memcached_servers $HOST_NAME:11211
crudini --set /etc/nova/nova.conf keystone_authtoken auth_type password
crudini --set /etc/nova/nova.conf keystone_authtoken project_domain_name $DOMAIN_NAME
crudini --set /etc/nova/nova.conf keystone_authtoken user_domain_name $DOMAIN_NAME
crudini --set /etc/nova/nova.conf keystone_authtoken project_name service
crudini --set /etc/nova/nova.conf keystone_authtoken username nova
crudini --set /etc/nova/nova.conf keystone_authtoken password $NOVA_PASS

crudini --set /etc/nova/nova.conf vnc enabled true
crudini --set /etc/nova/nova.conf vnc server_listen $HOST_IP
crudini --set /etc/nova/nova.conf vnc server_proxyclient_address $HOST_IP

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

#/etc/placement/placement.conf
crudini --set /etc/placement/placement.conf placement_database connection mysql+pymysql://placement:$NOVA_DBPASS@$HOST_NAME/placement
crudini --set /etc/placement/placement.conf auth_strategy keystone
crudini --set /etc/placement/placement.conf keystone_authtoken auth_url  http://$HOST_NAME:5000/v3
crudini --set /etc/placement/placement.conf keystone_authtoken memcached_servers $HOST_NAME:11211
crudini --set /etc/placement/placement.conf keystone_authtoken auth_type password
crudini --set /etc/placement/placement.conf keystone_authtoken project_domain_name $DOMAIN_NAME
crudini --set /etc/placement/placement.conf keystone_authtoken user_domain_name $DOMAIN_NAME
crudini --set /etc/placement/placement.conf keystone_authtoken project_name service
crudini --set /etc/placement/placement.conf keystone_authtoken username placement
crudini --set /etc/placement/placement.conf keystone_authtoken password $NOVA_PASS

## 自动发现计算节点
crudini --set /etc/nova/nova.conf scheduler discover_hosts_in_cells_interval 300

## 调优参数
#crudini --set /etc/nova/nova.conf DEFAULT allow_resize_to_same_host true
#crudini --set /etc/nova/nova.conf DEFAULT resume_guests_state_on_host_boot true
#crudini --set /etc/nova/nova.conf DEFAULT cpu_allocation_ratio 8
#crudini --set /etc/nova/nova.conf DEFAULT ram_allocation_ratio 1.0
#crudini --set /etc/nova/nova.conf DEFAULT disk_allocation_ratio 1.0
#crudini --set /etc/nova/nova.conf DEFAULT reserved_host_disk_mb 20480
#crudini --set /etc/nova/nova.conf DEFAULT reserved_host_memory_mb 4096
#crudini --set /etc/nova/nova.conf DEFAULT max_concurrent_builds 20


#/etc/httpd/conf.d/00-nova-placement-api.conf
echo " " >> /etc/httpd/conf.d/00-nova-placement-api.conf
echo "<Directory /usr/bin>" >> /etc/httpd/conf.d/00-nova-placement-api.conf
echo "	<IfVersion >= 2.4>" >> /etc/httpd/conf.d/00-nova-placement-api.conf
echo "		Require all granted" >> /etc/httpd/conf.d/00-nova-placement-api.conf
echo "	</IfVersion>" >> /etc/httpd/conf.d/00-nova-placement-api.conf
echo "	<IfVersion < 2.4>" >> /etc/httpd/conf.d/00-nova-placement-api.conf
echo "		Order allow,deny" >> /etc/httpd/conf.d/00-nova-placement-api.conf
echo "		Allow from all" >> /etc/httpd/conf.d/00-nova-placement-api.conf
echo "	</IfVersion>" >> /etc/httpd/conf.d/00-nova-placement-api.conf
echo "</Directory>" >> /etc/httpd/conf.d/00-nova-placement-api.conf

#httpd restart
systemctl restart httpd

#su nova mysql
su -s /bin/sh -c "nova-manage api_db sync" nova
su -s /bin/sh -c "nova-manage cell_v2 map_cell0" nova
su -s /bin/sh -c "nova-manage cell_v2 discover_hosts --verbose" nova
su -s /bin/sh -c "nova-manage cell_v2 create_cell --name=cell1 --verbose" nova
su -s /bin/sh -c "nova-manage db sync" nova
su -s /bin/sh -c "placement-manage db sync" placement
nova-manage cell_v2 list_cells

systemctl restart httpd
placement-status upgrade check
#nova start service 
systemctl enable openstack-nova-api.service  openstack-nova-scheduler.service openstack-nova-conductor.service openstack-nova-novncproxy.service
systemctl start openstack-nova-api.service openstack-nova-scheduler.service openstack-nova-conductor.service openstack-nova-novncproxy.service
