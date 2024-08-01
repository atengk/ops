#!/bin/bash
set -x
yum install openstack-cinder -y 
source /etc/cloudconfig/openrc.sh
source /etc/keystone/admin-openrc.sh
mysql -uroot -p$DB_PASS -e "create database IF NOT EXISTS cinder ;"
mysql -uroot -p$DB_PASS -e "GRANT ALL PRIVILEGES ON cinder.* TO 'cinder'@'localhost' IDENTIFIED BY '$CINDER_DBPASS' ;"
mysql -uroot -p$DB_PASS -e "GRANT ALL PRIVILEGES ON cinder.* TO 'cinder'@'%' IDENTIFIED BY '$CINDER_DBPASS' ;"
openstack user create --domain $DOMAIN_NAME --password $CINDER_PASS cinder
openstack role add --project service --user cinder admin
openstack service create --name cinderv2  --description "OpenStack Block Store" volumev2
openstack service create --name cinderv3  --description "OpenStack Block Store" volumev3
openstack endpoint create --region RegionOne volumev2 public http://$HOST_NAME:8776/v2/%\(tenant_id\)s
openstack endpoint create --region RegionOne volumev2 internal http://$HOST_NAME:8776/v2/%\(tenant_id\)s
openstack endpoint create --region RegionOne volumev2 admin http://$HOST_NAME:8776/v2/%\(tenant_id\)s
openstack endpoint create --region RegionOne volumev3 public http://$HOST_NAME:8776/v3/%\(tenant_id\)s
openstack endpoint create --region RegionOne volumev3 internal http://$HOST_NAME:8776/v3/%\(tenant_id\)s
openstack endpoint create --region RegionOne volumev3 admin http://$HOST_NAME:8776/v3/%\(tenant_id\)s

crudini --set /etc/cinder/cinder.conf database connection mysql+pymysql://cinder:$CINDER_DBPASS@$HOST_NAME/cinder

crudini --set /etc/cinder/cinder.conf DEFAULT auth_strategy keystone
crudini --set /etc/cinder/cinder.conf keystone_authtoken auth_uri  http://$HOST_NAME:5000
crudini --set /etc/cinder/cinder.conf keystone_authtoken auth_url  http://$HOST_NAME:5000
crudini --set /etc/cinder/cinder.conf keystone_authtoken memcached_servers  $HOST_NAME:11211
crudini --set /etc/cinder/cinder.conf keystone_authtoken auth_type  password
crudini --set /etc/cinder/cinder.conf keystone_authtoken project_domain_name  $DOMAIN_NAME
crudini --set /etc/cinder/cinder.conf keystone_authtoken user_domain_name $DOMAIN_NAME
crudini --set /etc/cinder/cinder.conf keystone_authtoken project_name  service
crudini --set /etc/cinder/cinder.conf keystone_authtoken username  cinder
crudini --set /etc/cinder/cinder.conf keystone_authtoken password  $CINDER_PASS

crudini --set /etc/cinder/cinder.conf DEFAULT my_ip $HOST_IP
crudini --set /etc/cinder/cinder.conf oslo_concurrency lock_path /var/lib/cinder/tmp

su -s /bin/sh -c "cinder-manage db sync" cinder

crudini --set /etc/nova/nova.conf cinder os_region_name  RegionOne

systemctl restart openstack-nova-api.service
systemctl enable openstack-cinder-api.service openstack-cinder-scheduler.service
systemctl restart openstack-cinder-api.service openstack-cinder-scheduler.service