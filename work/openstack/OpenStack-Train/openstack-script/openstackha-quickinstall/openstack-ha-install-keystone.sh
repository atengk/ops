#!/bin/bash

source /etc/cloudconfig/openrc-ha-info.sh
source /etc/cloudconfig/openrc-ha.sh



sshpass -p $openstack_cluster_root_password ssh -Tqo StrictHostKeychecking=no root@$controller_ip1 << eeooff
mysql -uroot -p$openstack_service_password -e "create database IF NOT EXISTS keystone ;"
mysql -uroot -p$openstack_service_password -e "GRANT ALL PRIVILEGES ON keystone.* TO 'keystone'@'localhost' IDENTIFIED BY '$openstack_service_password' ;"
mysql -uroot -p$openstack_service_password -e "GRANT ALL PRIVILEGES ON keystone.* TO 'keystone'@'%' IDENTIFIED BY '$openstack_service_password' ;"
eeooff


for host in $openstack_controller_cluster_host_name
do
sshpass -p $openstack_cluster_root_password ssh -Tqo StrictHostKeychecking=no root@$host << eeooff
yum install openstack-keystone httpd mod_wsgi -y
crudini --set /etc/keystone/keystone.conf database connection  mysql+pymysql://keystone:$openstack_service_password@openstack/keystone
crudini --set /etc/keystone/keystone.conf cache backend oslo_cache.memcache_pool
crudini --set /etc/keystone/keystone.conf cache enabled true
crudini --set /etc/keystone/keystone.conf cache memcache_servers $openstack_controller_cluster_memcache_servers
crudini --set /etc/keystone/keystone.conf token provider fernet
eeooff
done

sshpass -p $openstack_cluster_root_password ssh -Tqo StrictHostKeychecking=no root@$controller_ip1 << eeooff
su -s /bin/sh -c "keystone-manage db_sync" keystone
keystone-manage fernet_setup --keystone-user keystone --keystone-group keystone
keystone-manage credential_setup --keystone-user keystone --keystone-group keystone
## 分发同步秘钥
scp -r /etc/keystone/fernet-keys/ /etc/keystone/credential-keys/ $controller_name2:/etc/keystone/
scp -r /etc/keystone/fernet-keys/ /etc/keystone/credential-keys/ $controller_name3:/etc/keystone/
eeooff

for host in $openstack_controller_cluster_host_name
do
sshpass -p $openstack_cluster_root_password ssh -Tqo StrictHostKeychecking=no root@$host << eeooff
net1=\$(ip address | grep mtu | grep "state UP" | awk -F ':' 'NR==1{print \$2}')
ipaddress1=\$(ip a | grep \$net1 | grep -w inet | awk '{print \$2}' | awk -F '/' '{print \$1}' | head -n 1)
chown -R keystone:keystone /etc/keystone/credential-keys/
chown -R keystone:keystone /etc/keystone/fernet-keys/
sed -i "s/#ServerName www.example.com:80/ServerName $host:80/g" /etc/httpd/conf/httpd.conf
sed -i "s/Listen 80/Listen \$ipaddress1:80/g" /etc/httpd/conf/httpd.conf

ln -s /usr/share/keystone/wsgi-keystone.conf /etc/httpd/conf.d/
sed -i "s/Listen 5000/Listen \$ipaddress1:5000/g" /etc/httpd/conf.d/wsgi-keystone.conf
sed -i "s/Listen 35357/Listen \$ipaddress1:35357/g" /etc/httpd/conf.d/wsgi-keystone.conf
sed -i "s/*:5000/\$ipaddress1:5000/g" /etc/httpd/conf.d/wsgi-keystone.conf
sed -i "s/*:35357/\$ipaddress1:35357/g" /etc/httpd/conf.d/wsgi-keystone.conf

systemctl enable httpd
systemctl restart httpd
eeooff


done

sshpass -p $openstack_cluster_root_password ssh -Tqo StrictHostKeychecking=no root@$controller_ip1 << eeooff

keystone-manage bootstrap --bootstrap-password 000000 \
  --bootstrap-admin-url http://controller:5000/v3/ \
  --bootstrap-internal-url http://controller:5000/v3/ \
  --bootstrap-public-url http://controller:5000/v3/ \
  --bootstrap-region-id RegionOne
sleep 5
export OS_PROJECT_DOMAIN_NAME=Default
export OS_USER_DOMAIN_NAME=Default
export OS_PROJECT_NAME=admin
export OS_USERNAME=admin
export OS_PASSWORD=$openstack_service_password
export OS_AUTH_URL=http://openstack:5000/v3
export OS_IDENTITY_API_VERSION=3
export OS_IMAGE_API_VERSION=2

openstack project create --domain demo --description "Service Project" service
openstack project create --domain demo --description "Demo Project" demo
openstack user create --domain demo --password $openstack_service_password demo
openstack role create user
openstack role add --project demo --user demo user
unset OS_TOKEN OS_URL

## admin用户
cat > /etc/keystone/admin-openrc.sh <<-EOF
export OS_PROJECT_DOMAIN_NAME=demo
export OS_USER_DOMAIN_NAME=demo
export OS_PROJECT_NAME=admin
export OS_USERNAME=admin
export OS_PASSWORD=$openstack_service_password
export OS_AUTH_URL=http://openstack:5000/v3
export OS_IDENTITY_API_VERSION=3
export OS_IMAGE_API_VERSION=2
EOF
cat /etc/keystone/admin-openrc.sh >> /etc/profile && source /etc/profile
## demo用户
cat > /etc/keystone/demo-openrc.sh <<-EOF
export OS_PROJECT_DOMAIN_NAME=demo
export OS_USER_DOMAIN_NAME=demo
export OS_PROJECT_NAME=demo
export OS_USERNAME=demo
export OS_PASSWORD=$openstack_service_password
export OS_AUTH_URL=http://openstack:5000/v3
export OS_IDENTITY_API_VERSION=3
export OS_IMAGE_API_VERSION=2
EOF
sshpass -p $openstack_cluster_root_password scp -ro StrictHostKeychecking=no /etc/keystone/{admin-openrc.sh,demo-openrc.sh} $controller_name2:/etc/keystone/
sshpass -p $openstack_cluster_root_password scp -ro StrictHostKeychecking=no /etc/keystone/{admin-openrc.sh,demo-openrc.sh} $controller_name3:/etc/keystone/
sshpass -p $openstack_cluster_root_password scp -ro StrictHostKeychecking=no /etc/profile $controller_name2:/etc
sshpass -p $openstack_cluster_root_password scp -ro StrictHostKeychecking=no /etc/profile $controller_name3:/etc
source /etc/keystone/admin-openrc.sh
echo "# openstack token issue"
openstack token issue
eeooff

