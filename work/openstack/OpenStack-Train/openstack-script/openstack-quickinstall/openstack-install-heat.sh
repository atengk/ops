#!/bin/bash
set -x
source /etc/cloudconfig/openrc.sh
source /etc/keystone/admin-openrc.sh
mysql -uroot -p$DB_PASS -e "create database IF NOT EXISTS heat ;"
mysql -uroot -p$DB_PASS -e "GRANT ALL PRIVILEGES ON heat.* TO 'heat'@'localhost' IDENTIFIED BY '$HEAT_DBPASS' ;"
mysql -uroot -p$DB_PASS -e "GRANT ALL PRIVILEGES ON heat.* TO 'heat'@'%' IDENTIFIED BY '$HEAT_DBPASS' ;"
yum install openstack-heat-api openstack-heat-api-cfn openstack-heat-engine openstack-heat-ui -y
openstack user create --domain $DOMAIN_NAME --password $HEAT_PASS heat
openstack role add --project service --user heat admin
openstack service create --name heat --description "Orchestration" orchestration
openstack service create --name heat-cfn --description "Orchestration"  cloudformation 
openstack endpoint create --region RegionOne orchestration public http://$HOST_NAME:8004/v1/%\(tenant_id\)s
openstack endpoint create --region RegionOne orchestration internal http://$HOST_NAME:8004/v1/%\(tenant_id\)s
openstack endpoint create --region RegionOne orchestration admin http://$HOST_NAME:8004/v1/%\(tenant_id\)s
openstack endpoint create --region RegionOne cloudformation public http://$HOST_NAME:8000/v1
openstack endpoint create --region RegionOne cloudformation internal http://$HOST_NAME:8000/v1
openstack endpoint create --region RegionOne cloudformation admin http://$HOST_NAME:8000/v1
openstack domain create --description "Stack projects and users" heat
openstack user create --domain heat  --password $HEAT_PASS heat_domain_admin
openstack role add --domain heat --user-domain heat --user heat_domain_admin admin
openstack role create heat_stack_owner
openstack role add --project demo --user demo heat_stack_owner
openstack role create heat_stack_user

crudini --set /etc/heat/heat.conf database connection mysql+pymysql://heat:$HEAT_DBPASS@$HOST_NAME/heat

crudini --set /etc/heat/heat.conf DEFAULT transport_url rabbit://$RABBIT_USER:$RABBIT_PASS@$HOST_NAME

crudini --set /etc/heat/heat.conf keystone_authtoken auth_uri  http://$HOST_NAME:5000
crudini --set /etc/heat/heat.conf keystone_authtoken auth_url  http://$HOST_NAME:5000
crudini --set /etc/heat/heat.conf keystone_authtoken memcached_servers  $HOST_NAME:11211
crudini --set /etc/heat/heat.conf keystone_authtoken auth_type  password
crudini --set /etc/heat/heat.conf keystone_authtoken project_domain_name  $DOMAIN_NAME
crudini --set /etc/heat/heat.conf keystone_authtoken user_domain_name $DOMAIN_NAME
crudini --set /etc/heat/heat.conf keystone_authtoken project_name  service
crudini --set /etc/heat/heat.conf keystone_authtoken username  heat
crudini --set /etc/heat/heat.conf keystone_authtoken password  $HEAT_PASS

crudini --set /etc/heat/heat.conf trustee auth_plugin password
crudini --set /etc/heat/heat.conf trustee auth_url http://$HOST_NAME:5000
crudini --set /etc/heat/heat.conf trustee username heat
crudini --set /etc/heat/heat.conf trustee password $HEAT_PASS
crudini --set /etc/heat/heat.conf trustee user_domain_name $DOMAIN_NAME
crudini --set /etc/heat/heat.conf clients_keystone auth_uri http://$HOST_NAME:5000

crudini --set /etc/heat/heat.conf DEFAULT heat_metadata_server_url http://$HOST_NAME:8000
crudini --set /etc/heat/heat.conf DEFAULT heat_waitcondition_server_url http://$HOST_NAME:8000/v1/waitcondition

crudini --set /etc/heat/heat.conf DEFAULT stack_domain_admin heat_domain_admin
crudini --set /etc/heat/heat.conf DEFAULT stack_domain_admin_password $HEAT_PASS
crudini --set /etc/heat/heat.conf DEFAULT stack_user_domain_name heat

su -s /bin/sh -c "heat-manage db_sync" heat

systemctl enable openstack-heat-api.service openstack-heat-api-cfn.service openstack-heat-engine.service
systemctl restart openstack-heat-api.service openstack-heat-api-cfn.service openstack-heat-engine.service
systemctl restart httpd memcached