#!/bin/bash
set -x
source /etc/cloudconfig/openrc.sh

yum install openstack-ceilometer-compute -y

crudini --set /etc/ceilometer/ceilometer.conf DEFAULT transport_url rabbit://$RABBIT_USER:$RABBIT_PASS@$HOST_NAME
crudini --set /etc/ceilometer/ceilometer.conf service_credentials auth_url http://$HOST_NAME:5000
crudini --set /etc/ceilometer/ceilometer.conf service_credentials memcached_servers = $HOST_NAME:11211
crudini --set /etc/ceilometer/ceilometer.conf service_credentials project_domain_name $DOMAIN_NAME
crudini --set /etc/ceilometer/ceilometer.conf service_credentials user_domain_name $DOMAIN_NAME
crudini --set /etc/ceilometer/ceilometer.conf service_credentials project_name service
crudini --set /etc/ceilometer/ceilometer.conf service_credentials auth_type password
crudini --set /etc/ceilometer/ceilometer.conf service_credentials username ceilometer
crudini --set /etc/ceilometer/ceilometer.conf service_credentials password $CEILOMETER_PASS

crudini --set /etc/nova/nova.conf DEFAULT instance_usage_audit True
crudini --set /etc/nova/nova.conf DEFAULT instance_usage_audit_period hour
crudini --set /etc/nova/nova.conf DEFAULT notify_on_state_change vm_and_task_state
crudini --set /etc/nova/nova.conf oslo_messaging_notifications driver messagingv2

systemctl enable openstack-ceilometer-compute.service
systemctl restart openstack-ceilometer-compute.service
systemctl restart openstack-nova-compute 


