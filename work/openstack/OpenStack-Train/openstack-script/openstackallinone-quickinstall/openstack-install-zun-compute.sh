#!/bin/bash
set -x
source /etc/cloudconfig/openrc.sh
yum install -y yum-utils device-mapper-persistent-data lvm2
yum makecache fast
yum install docker-ce python-pip git kuryr-libnetwork openstack-zun-compute -y

systemctl enable docker
systemctl restart docker

cat <<EOF >> /etc/sysctl.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF
sysctl -p

crudini --set /etc/kuryr/kuryr.conf DEFAULT bindir /usr/libexec/kuryr

crudini --set /etc/kuryr/kuryr.conf neutron auth_uri http://$HOST_NAME:5000
crudini --set /etc/kuryr/kuryr.conf neutron auth_url http://$HOST_NAME:5000
crudini --set /etc/kuryr/kuryr.conf neutron username kuryr
crudini --set /etc/kuryr/kuryr.conf neutron user_domain_name $DOMAIN_NAME
crudini --set /etc/kuryr/kuryr.conf neutron password $KURYR_PASS
crudini --set /etc/kuryr/kuryr.conf neutron project_name service
crudini --set /etc/kuryr/kuryr.conf neutron project_domain_name $DOMAIN_NAME
crudini --set /etc/kuryr/kuryr.conf neutron auth_type password

systemctl enable kuryr-libnetwork
systemctl restart kuryr-libnetwork docker 

crudini --set /etc/zun/zun.conf DEFAULT transport_url rabbit://$RABBIT_USER:$RABBIT_PASS@$HOST_NAME
crudini --set /etc/zun/zun.conf DEFAULT state_path /var/lib/zun
crudini --set /etc/zun/zun.conf DEFAULT log_dir /var/log/zun

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

crudini --set /etc/zun/zun.conf websocket_proxy base_url ws://$HOST_NAME:6784/
crudini --set /etc/zun/zun.conf oslo_concurrency lock_path /var/lib/zun/tmp

mkdir -p /etc/systemd/system/docker.service.d

cat <<EOF > /etc/systemd/system/docker.service.d/docker.conf
[Service]
ExecStart=
ExecStart=/usr/bin/dockerd --group zun -H tcp://$HOST_NAME_NODE:2375 -H unix:///var/run/docker.sock --cluster-store etcd://$HOST_NAME:2379
EOF

systemctl daemon-reload
systemctl restart docker

crudini --set /etc/kuryr/kuryr.conf DEFAULT capability_scope global

systemctl restart kuryr-libnetwork
systemctl enable zun-compute
systemctl restart zun-compute

