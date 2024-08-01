#!/bin/bash

source /etc/cloudconfig/openrc-ha-info.sh
source /etc/cloudconfig/openrc-ha.sh


for host in $openstack_controller_cluster_host_name
do
sshpass -p $openstack_cluster_root_password ssh -Tqo StrictHostKeychecking=no root@$host << eeooff
yum install openstack-dashboard -y 
sed -i -e "s/^ALLOWED_HOSTS.*/ALLOWED_HOSTS = ['*', 'localhost']/g" \
-e 's/^OPENSTACK_HOST.*/OPENSTACK_HOST = "'openstack'"/g' \
-e 's/#OPENSTACK_KEYSTONE_MULTIDOMAIN_SUPPORT.*/OPENSTACK_KEYSTONE_MULTIDOMAIN_SUPPORT = False/g' \
-e 's/^OPENSTACK_KEYSTONE_URL .*/OPENSTACK_KEYSTONE_URL = "http:\/\/%s:5000\/v3" % OPENSTACK_HOST/g' \
-e 's/#OPENSTACK_KEYSTONE_DEFAULT_DOMAIN.*/OPENSTACK_KEYSTONE_DEFAULT_DOMAIN = "demo"/g' \
-e 's/^OPENSTACK_KEYSTONE_DEFAULT_ROLE.*/OPENSTACK_KEYSTONE_DEFAULT_ROLE = "user"/g' /etc/openstack-dashboard/local_settings
echo "SESSION_ENGINE = 'django.contrib.sessions.backends.cache'
CACHES = {
    'default': {
         'BACKEND': 'django.core.cache.backends.memcached.MemcachedCache',
         'LOCATION': '$openstack_controller_cluster_memcache_servers',
    }
}
OPENSTACK_API_VERSIONS = {
    "\"identity"\": 3,
    "\"image"\": 2,
    "\"volume"\": 2,
}" >> /etc/openstack-dashboard/local_settings
sed -i 'N;4aWSGIApplicationGroup %{GLOBAL}' /etc/httpd/conf.d/openstack-dashboard.conf
systemctl restart httpd memcached
eeooff
done
