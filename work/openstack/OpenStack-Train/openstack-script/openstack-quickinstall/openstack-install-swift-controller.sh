#!/bin/bash
set -x
source /etc/cloudconfig/openrc.sh
source /etc/keystone/admin-openrc.sh
yum install openstack-swift-proxy python-swiftclient python-keystoneclient python-keystonemiddleware memcached -y

openstack user create --domain $DOMAIN_NAME --password $SWIFT_PASS swift
openstack role add --project service --user swift admin
openstack service create --name swift --description "OpenStack Object Storage" object-store
openstack endpoint create --region RegionOne object-store public http://$HOST_NAME:8080/v1/AUTH_%\(tenant_id\)s
openstack endpoint create --region RegionOne object-store internal http://$HOST_NAME:8080/v1/AUTH_%\(tenant_id\)s
openstack endpoint create --region RegionOne object-store admin http://$HOST_NAME:8080/v1

cat <<EOF > /etc/swift/proxy-server.conf
[DEFAULT]
bind_port = 8080
swift_dir = /etc/swift
user = swift
[pipeline:main]
pipeline = catch_errors gatekeeper healthcheck proxy-logging cache container_sync bulk ratelimit authtoken keystoneauth container-quotas account-quotas slo dlo versioned_writes proxy-logging proxy-server
[app:proxy-server]
use = egg:swift#proxy
account_autocreate = True
[filter:tempauth]
use = egg:swift#tempauth
user_admin_admin = admin .admin .reseller_admin
user_test_tester = testing .admin
user_test2_tester2 = testing2 .admin
user_test_tester3 = testing3
user_test5_tester5 = testing5 service
[filter:authtoken]
paste.filter_factory = keystonemiddleware.auth_token:filter_factory
auth_uri = http://$HOST_NAME:5000
auth_url = http://$HOST_NAME:5000
memcached_servers = $HOST_NAME:11211
auth_type = password
project_domain_name = $DOMAIN_NAME
user_domain_name = $DOMAIN_NAME
project_name = service
username = swift
password = $SWIFT_PASS
delay_auth_decision = True
[filter:keystoneauth]
use = egg:swift#keystoneauth
operator_roles = admin,user
[filter:healthcheck]
use = egg:swift#healthcheck
[filter:cache]
memcache_servers = $HOST_NAME:11211
use = egg:swift#memcache
[filter:ratelimit]
use = egg:swift#ratelimit
[filter:domain_remap]
use = egg:swift#domain_remap
[filter:catch_errors]
use = egg:swift#catch_errors
[filter:cname_lookup]
use = egg:swift#cname_lookup
[filter:staticweb]
use = egg:swift#staticweb
[filter:tempurl]
use = egg:swift#tempurl
[filter:formpost]
use = egg:swift#formpost
[filter:name_check]
use = egg:swift#name_check
[filter:list-endpoints]
use = egg:swift#list_endpoints
[filter:proxy-logging]
use = egg:swift#proxy_logging
[filter:bulk]
use = egg:swift#bulk
[filter:slo]
use = egg:swift#slo
[filter:dlo]
use = egg:swift#dlo
[filter:container-quotas]
use = egg:swift#container_quotas
[filter:account-quotas]
use = egg:swift#account_quotas
[filter:gatekeeper]
use = egg:swift#gatekeeper
[filter:container_sync]
use = egg:swift#container_sync
[filter:xprofile]
use = egg:swift#xprofile
[filter:versioned_writes]
use = egg:swift#versioned_writes
EOF

pushd /etc/swift
swift-ring-builder account.builder create 18 1 1
swift-ring-builder account.builder add --region 1 --zone 1 --ip $STORAGE_LOCAL_NET_IP --port 6002 --device $OBJECT_DISK --weight 100
swift-ring-builder account.builder
swift-ring-builder account.builder rebalance

swift-ring-builder container.builder create 10 1 1
swift-ring-builder container.builder add --region 1 --zone 1 --ip $STORAGE_LOCAL_NET_IP --port 6001 --device $OBJECT_DISK --weight 100
swift-ring-builder container.builder
swift-ring-builder container.builder rebalance


swift-ring-builder object.builder create 10 1 1
swift-ring-builder object.builder  add --region 1 --zone 1 --ip $STORAGE_LOCAL_NET_IP --port 6000 --device $OBJECT_DISK --weight 100  
swift-ring-builder object.builder
swift-ring-builder object.builder rebalance


popd
#---------------
cat << EOF > /etc/swift/swift.conf
[swift-hash]
swift_hash_path_suffix = changeme
swift_hash_path_prefix = changeme
[storage-policy:0]
name = Policy-0
default = yes
aliases = yellow, orange
[swift-constraints]
EOF


chown -R root:swift /etc/swift
systemctl enable openstack-swift-proxy.service memcached.service
systemctl restart openstack-swift-proxy.service memcached.service
