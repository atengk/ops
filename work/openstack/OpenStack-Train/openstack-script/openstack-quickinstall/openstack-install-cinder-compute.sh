#!/bin/bash
set -x
source /etc/cloudconfig/openrc.sh
yum install lvm2 device-mapper-persistent-data openstack-cinder targetcli python-keystone -y
systemctl enable lvm2-lvmetad.service
systemctl restart lvm2-lvmetad.service

pvcreate -f /dev/$BLOCK_DISK
vgcreate cinder-volumes /dev/$BLOCK_DISK
sed -i "131a \ \ \ \ \ \ \ \ filter = [ \"a/$BLOCK_DISK/\", \"r/.*/\"]" /etc/lvm/lvm.conf
systemctl restart lvm2-lvmetad.service

crudini --set /etc/cinder/cinder.conf database connection mysql+pymysql://cinder:$CINDER_DBPASS@$HOST_NAME/cinder
crudini --set /etc/cinder/cinder.conf DEFAULT transport_url rabbit://$RABBIT_USER:$RABBIT_PASS@$HOST_NAME
crudini --set /etc/cinder/cinder.conf DEFAULT auth_strategy keystone
crudini --set /etc/cinder/cinder.conf DEFAULT enabled_backends  lvm
crudini --set /etc/cinder/cinder.conf keystone_authtoken auth_uri  http://$HOST_NAME:5000
crudini --set /etc/cinder/cinder.conf keystone_authtoken auth_url  http://$HOST_NAME:5000
crudini --set /etc/cinder/cinder.conf keystone_authtoken memcached_servers  $HOST_NAME:11211
crudini --set /etc/cinder/cinder.conf keystone_authtoken auth_type  password
crudini --set /etc/cinder/cinder.conf keystone_authtoken project_domain_name  $DOMAIN_NAME
crudini --set /etc/cinder/cinder.conf keystone_authtoken user_domain_name $DOMAIN_NAME
crudini --set /etc/cinder/cinder.conf keystone_authtoken project_name  service
crudini --set /etc/cinder/cinder.conf keystone_authtoken username  cinder
crudini --set /etc/cinder/cinder.conf keystone_authtoken password  $CINDER_PASS

crudini --set /etc/cinder/cinder.conf DEFAULT my_ip $HOST_IP_NODE
crudini --set /etc/cinder/cinder.conf lvm volume_driver cinder.volume.drivers.lvm.LVMVolumeDriver
crudini --set /etc/cinder/cinder.conf lvm volume_group cinder-volumes
crudini --set /etc/cinder/cinder.conf lvm target_protocol iscsi
crudini --set /etc/cinder/cinder.conf lvm target_helper lioadm

crudini --set /etc/cinder/cinder.conf DEFAULT glance_api_servers  http://$HOST_NAME:9292
crudini --set /etc/cinder/cinder.conf oslo_concurrency lock_path /var/lib/cinder/tmp

systemctl enable openstack-cinder-volume.service target.service
systemctl restart openstack-cinder-volume.service target.service
