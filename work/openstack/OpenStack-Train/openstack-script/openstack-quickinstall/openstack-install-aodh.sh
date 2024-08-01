#!/bin/bash
set -x
source /etc/cloudconfig/openrc.sh
source /etc/keystone/admin-openrc.sh

yum -y install openstack-aodh-api openstack-aodh-evaluator openstack-aodh-notifier openstack-aodh-listener openstack-aodh-expirer python2-aodhclient

openstack user create --domain $DOMAIN_NAME --password $AODH_PASS aodh
openstack role add --project service --user aodh admin
openstack service create --name aodh --description "Telemetry Alarming" alarming
openstack endpoint create --region RegionOne alarming public http://$HOST_NAME:8042
openstack endpoint create --region RegionOne alarming internal http://$HOST_NAME:8042
openstack endpoint create --region RegionOne alarming admin http://$HOST_NAME:8042

mysql -uroot -p$DB_PASS -e "create database IF NOT EXISTS aodh;"
mysql -uroot -p$DB_PASS -e "GRANT ALL PRIVILEGES ON aodh.* TO 'aodh'@'localhost' IDENTIFIED BY '$AODH_DBPASS' ;"
mysql -uroot -p$DB_PASS -e "GRANT ALL PRIVILEGES ON aodh.* TO 'aodh'@'%' IDENTIFIED BY '$AODH_DBPASS' ;"

crudini --set /etc/aodh/aodh.conf DEFAULT log_dir /var/log/aodh
crudini --set /etc/aodh/aodh.conf DEFAULT transport_url rabbit://$RABBIT_USER:$RABBIT_PASS@$HOST_NAME
crudini --set /etc/aodh/aodh.conf api auth_mode keystone
crudini --set /etc/aodh/aodh.conf api gnocchi_external_project_owner service
crudini --set /etc/aodh/aodh.conf database connection mysql+pymysql://aodh:$AODH_DBPASS@$HOST_NAME/aodh

crudini --set /etc/aodh/aodh.conf keystone_authtoken www_authenticate_uri http://$HOST_NAME:5000
crudini --set /etc/aodh/aodh.conf keystone_authtoken auth_url http://$HOST_NAME:5000
crudini --set /etc/aodh/aodh.conf keystone_authtoken memcached_servers $HOST_NAME:11211
crudini --set /etc/aodh/aodh.conf keystone_authtoken auth_type password
crudini --set /etc/aodh/aodh.conf keystone_authtoken project_domain_name $DOMAIN_NAME
crudini --set /etc/aodh/aodh.conf keystone_authtoken user_domain_name $DOMAIN_NAME
crudini --set /etc/aodh/aodh.conf keystone_authtoken project_name service
crudini --set /etc/aodh/aodh.conf keystone_authtoken username aodh
crudini --set /etc/aodh/aodh.conf keystone_authtoken password $AODH_PASS

crudini --set /etc/aodh/aodh.conf service_credentials auth_url http://$HOST_NAME:5000/v3
crudini --set /etc/aodh/aodh.conf service_credentials auth_type password
crudini --set /etc/aodh/aodh.conf service_credentials project_domain_name $DOMAIN_NAME
crudini --set /etc/aodh/aodh.conf service_credentials user_domain_name $DOMAIN_NAME
crudini --set /etc/aodh/aodh.conf service_credentials project_name service
crudini --set /etc/aodh/aodh.conf service_credentials username aodh
crudini --set /etc/aodh/aodh.conf service_credentials password $AODH_PASS
crudini --set /etc/aodh/aodh.conf service_credentials interface internalURL

cat >/etc/httpd/conf.d/20-aodh_wsgi.conf<<- EOF

Listen 8042
<VirtualHost *:8042>
    DocumentRoot "/var/www/cgi-bin/aodh"
    <Directory "/var/www/cgi-bin/aodh">
        AllowOverride None
        Require all granted
    </Directory>

    CustomLog "/var/log/httpd/aodh_wsgi_access.log" combined
    ErrorLog "/var/log/httpd/aodh_wsgi_error.log"
    SetEnvIf X-Forwarded-Proto https HTTPS=1
    WSGIApplicationGroup %{GLOBAL}
    WSGIDaemonProcess aodh display-name=aodh_wsgi user=aodh group=aodh processes=6 threads=3
    WSGIProcessGroup aodh
    WSGIScriptAlias / "/var/www/cgi-bin/aodh/app"
</VirtualHost>

EOF

mkdir /var/www/cgi-bin/aodh 
cp /usr/lib/python2.7/site-packages/aodh/api/app.wsgi /var/www/cgi-bin/aodh/app 
chown -R aodh. /var/www/cgi-bin/aodh 
su -s /bin/bash aodh -c "aodh-dbsync" 

systemctl restart openstack-aodh-evaluator openstack-aodh-notifier openstack-aodh-listener 
systemctl enable openstack-aodh-evaluator openstack-aodh-notifier openstack-aodh-listener 
systemctl restart httpd memcached