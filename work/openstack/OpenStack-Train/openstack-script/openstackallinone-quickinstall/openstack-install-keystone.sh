#!/bin/bash
set -x
source /etc/cloudconfig/openrc.sh
#keystone mysql
mysql -uroot -p$DB_PASS -e "create database IF NOT EXISTS keystone ;"
mysql -uroot -p$DB_PASS -e "GRANT ALL PRIVILEGES ON keystone.* TO 'keystone'@'localhost' IDENTIFIED BY '$KEYSTONE_DBPASS' ;"
mysql -uroot -p$DB_PASS -e "GRANT ALL PRIVILEGES ON keystone.* TO 'keystone'@'%' IDENTIFIED BY '$KEYSTONE_DBPASS' ;"

#install keystone
yum install openstack-keystone httpd mod_wsgi -y

#/etc/keystone/keystone.conf
crudini --set /etc/keystone/keystone.conf database connection  mysql+pymysql://keystone:$KEYSTONE_DBPASS@$HOST_NAME/keystone
crudini --set /etc/keystone/keystone.conf token provider  fernet
sed -i 's/#expiration_time = 600/expiration_time = 86400/g' /etc/keystone/keystone.conf
su -s /bin/sh -c "keystone-manage db_sync" keystone
keystone-manage fernet_setup --keystone-user keystone --keystone-group keystone
keystone-manage credential_setup --keystone-user keystone --keystone-group keystone
sed -i "s/#ServerName www.example.com:80/ServerName $HOST_NAME/g" /etc/httpd/conf/httpd.conf 
ln -s /usr/share/keystone/wsgi-keystone.conf /etc/httpd/conf.d/  
systemctl enable httpd.service
systemctl restart httpd.service

keystone-manage bootstrap --bootstrap-password $ADMIN_PASS \
  --bootstrap-admin-url http://$HOST_NAME:5000/v3  \
  --bootstrap-internal-url http://$HOST_NAME:5000/v3 \
  --bootstrap-public-url http://$HOST_NAME:5000/v3 \
  --bootstrap-region-id RegionOne

export OS_PROJECT_DOMAIN_NAME=$DOMAIN_NAME
export OS_USER_DOMAIN_NAME=$DOMAIN_NAME
export OS_PROJECT_NAME=admin
export OS_USERNAME=admin
export OS_PASSWORD=$ADMIN_PASS
export OS_AUTH_URL=http://$HOST_NAME:5000/v3
export OS_IDENTITY_API_VERSION=3
export OS_IMAGE_API_VERSION=2

openstack project create --domain $DOMAIN_NAME --description "Service Project" service
openstack project create --domain $DOMAIN_NAME --description "Demo Project" demo

openstack user create --domain $DOMAIN_NAME --password $DEMO_PASS demo
openstack role create user
openstack role add --project demo --user demo user

unset OS_TOKEN OS_URL

cat > /etc/keystone/admin-openrc.sh <<-EOF
export OS_PROJECT_DOMAIN_NAME=$DOMAIN_NAME
export OS_USER_DOMAIN_NAME=$DOMAIN_NAME
export OS_PROJECT_NAME=admin
export OS_USERNAME=admin
export OS_PASSWORD=$ADMIN_PASS
export OS_AUTH_URL=http://$HOST_NAME:5000/v3
export OS_IDENTITY_API_VERSION=3
export OS_IMAGE_API_VERSION=2
EOF

cat > /etc/keystone/demo-openrc.sh <<-EOF
export OS_PROJECT_DOMAIN_NAME=$DOMAIN_NAME
export OS_USER_DOMAIN_NAME=$DOMAIN_NAME
export OS_PROJECT_NAME=demo
export OS_USERNAME=demo
export OS_PASSWORD=$DEMO_PASS
export OS_AUTH_URL=http://$HOST_NAME:5000/v3
export OS_IDENTITY_API_VERSION=3
export OS_IMAGE_API_VERSION=2
EOF

source /etc/keystone/admin-openrc.sh 
openstack token issue
