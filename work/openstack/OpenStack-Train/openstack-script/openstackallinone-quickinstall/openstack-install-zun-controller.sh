#!/bin/bash
set -x
source /etc/cloudconfig/openrc.sh
source /etc/keystone/admin-openrc.sh
yum install python-pip git openstack-zun openstack-zun-ui -y
mysql -uroot -p$DB_PASS -e "create database IF NOT EXISTS zun ;"
mysql -uroot -p$DB_PASS -e "GRANT ALL PRIVILEGES ON zun.* TO 'zun'@'localhost' IDENTIFIED BY '$ZUN_DBPASS' ;"
mysql -uroot -p$DB_PASS -e "GRANT ALL PRIVILEGES ON zun.* TO 'zun'@'%' IDENTIFIED BY '$ZUN_DBPASS' ;"

openstack user create --domain $DOMAIN_NAME --password $ZUN_PASS zun
openstack role add --project service --user zun admin
openstack user create --domain $DOMAIN_NAME --password $KURYR_PASS kuryr
openstack role add --project service --user kuryr admin
openstack service create --name zun --description "Container Service" container
openstack endpoint create --region RegionOne container public http://$HOST_NAME:9517/v1
openstack endpoint create --region RegionOne container internal http://$HOST_NAME:9517/v1
openstack endpoint create --region RegionOne container admin http://$HOST_NAME:9517/v1

crudini --set /etc/zun/zun.conf DEFAULT transport_url rabbit://$RABBIT_USER:$RABBIT_PASS@$HOST_NAME
crudini --set /etc/zun/zun.conf DEFAULT log_dir /var/log/zun
crudini --set /etc/zun/zun.conf api host_ip $HOST_IP
crudini --set /etc/zun/zun.conf api port 9517
crudini --set /etc/zun/zun.conf database connection mysql+pymysql://zun:$ZUN_DBPASS@$HOST_NAME/zun

crudini --set /etc/zun/zun.conf keystone_auth memcached_servers $HOST_NAME:11211
crudini --set /etc/zun/zun.conf keystone_auth auth_uri http://$HOST_NAME:5000
crudini --set /etc/zun/zun.conf keystone_auth project_domain_name $DOMAIN_NAME
crudini --set /etc/zun/zun.conf keystone_auth project_name service
crudini --set /etc/zun/zun.conf keystone_auth user_domain_name $DOMAIN_NAME
crudini --set /etc/zun/zun.conf keystone_auth password $ZUN_PASS
crudini --set /etc/zun/zun.conf keystone_auth username zun
crudini --set /etc/zun/zun.conf keystone_auth auth_url http://$HOST_NAME:5000
crudini --set /etc/zun/zun.conf keystone_auth auth_type password
crudini --set /etc/zun/zun.conf keystone_auth auth_version v3
crudini --set /etc/zun/zun.conf keystone_auth auth_protocol http
crudini --set /etc/zun/zun.conf keystone_auth service_token_roles_required True
crudini --set /etc/zun/zun.conf keystone_auth endpoint_type internalURL

crudini --set /etc/zun/zun.conf keystone_authtoken memcached_servers $HOST_NAME:11211
crudini --set /etc/zun/zun.conf keystone_authtoken auth_uri http://$HOST_NAME:5000
crudini --set /etc/zun/zun.conf keystone_authtoken project_domain_name $DOMAIN_NAME
crudini --set /etc/zun/zun.conf keystone_authtoken project_name service
crudini --set /etc/zun/zun.conf keystone_authtoken user_domain_name $DOMAIN_NAME
crudini --set /etc/zun/zun.conf keystone_authtoken password $ZUN_PASS
crudini --set /etc/zun/zun.conf keystone_authtoken username zun
crudini --set /etc/zun/zun.conf keystone_authtoken auth_url http://$HOST_NAME:5000
crudini --set /etc/zun/zun.conf keystone_authtoken auth_type password
crudini --set /etc/zun/zun.conf keystone_authtoken auth_version v3
crudini --set /etc/zun/zun.conf keystone_authtoken auth_protocol http
crudini --set /etc/zun/zun.conf keystone_authtoken service_token_roles_required True
crudini --set /etc/zun/zun.conf keystone_authtoken endpoint_type internalURL

crudini --set /etc/zun/zun.conf oslo_concurrency lock_path /var/lib/zun/tmp

crudini --set /etc/zun/zun.conf oslo_messaging_notifications driver messaging

crudini --set /etc/zun/zun.conf websocket_proxy wsproxy_host $HOST_IP
crudini --set /etc/zun/zun.conf websocket_proxy wsproxy_port 6784

su -s /bin/sh -c "zun-db-manage upgrade" zun

systemctl enable zun-api  zun-wsproxy
systemctl restart zun-api  zun-wsproxy

systemctl restart httpd memcached
