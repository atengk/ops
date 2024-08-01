#!/bin/bash
source /etc/cloudconfig/openrc.sh
set -x

echo $HOST_PASS | passwd --stdin root

/usr/local/bin/openstack-pre-host.sh
/usr/local/bin/openstack-install-mysql.sh
/usr/local/bin/openstack-install-keystone.sh
/usr/local/bin/openstack-install-glance.sh
/usr/local/bin/openstack-install-nova-controller.sh
/usr/local/bin/openstack-install-nova-compute.sh
/usr/local/bin/openstack-install-neutron-controller.sh
/usr/local/bin/openstack-install-dashboard.sh

if [ $cinder -eq 1 ]
then
/usr/local/bin/openstack-install-cinder-controller.sh
/usr/local/bin/openstack-install-cinder-compute.sh
fi

if [ $swift -eq 1 ]
then
/usr/local/bin/openstack-install-swift-controller.sh
/usr/local/bin/openstack-install-swift-compute.sh
fi

if [ $heat -eq 1 ]
then
/usr/local/bin/openstack-install-heat.sh
fi

if [ $ceilometer -eq 1 ]
then
/usr/local/bin/openstack-install-ceilometer-controller.sh
/usr/local/bin/openstack-install-ceilometer-compute.sh
fi

if [ $zun -eq 1 ]
then
/usr/local/bin/openstack-install-zun-controller.sh
/usr/local/bin/openstack-install-zun-compute.sh
fi

if [ $aodh -eq 1 ]
then
/usr/local/bin/openstack-install-aodh.sh
fi

if [ $barbican -eq 1 ]
then
/usr/local/bin/openstack-install-barbican.sh
fi

source /etc/keystone/admin-openrc.sh
systemctl restart openstack-nova-compute.service
openstack token issue
glance image-list
openstack compute service list
openstack network agent list
set +x
printf "\033[35m浏览器访问：http://$HOST_IP/dashboard\n\033[0m"
