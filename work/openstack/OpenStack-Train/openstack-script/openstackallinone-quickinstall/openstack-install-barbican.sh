#!/bin/bash
set -x
source /etc/cloudconfig/openrc.sh
source /etc/keystone/admin-openrc.sh

yum install openstack-barbican-api cryptsetup -y

mysql -uroot -p$DB_PASS -e "create database IF NOT EXISTS barbican ;"
mysql -uroot -p$DB_PASS -e "GRANT ALL PRIVILEGES ON barbican.* TO 'barbican'@'localhost' IDENTIFIED BY '$BARBICAN_DBPASS' ;"
mysql -uroot -p$DB_PASS -e "GRANT ALL PRIVILEGES ON barbican.* TO 'barbican'@'%' IDENTIFIED BY '$BARBICAN_DBPASS' ;"

openstack user create --domain $DOMAIN_NAME --password $BARBICAN_PASS barbican
openstack role add --project service --user barbican admin
openstack role create creator
openstack role add --project service --user barbican creator
openstack service create --name barbican --description "Key Manager" key-manager

openstack endpoint create --region RegionOne key-manager public http://$HOST_NAME:9311
openstack endpoint create --region RegionOne key-manager internal http://$HOST_NAME:9311
openstack endpoint create --region RegionOne key-manager admin http://$HOST_NAME:9311

crudini --set /etc/barbican/barbican.conf DEFAULT sql_connection mysql+pymysql://barbican:$BARBICAN_DBPASS@$HOST_NAME/barbican
crudini --set /etc/barbican/barbican.conf DEFAULT transport_url rabbit://$RABBIT_USER:$RABBIT_PASS@$HOST_NAME
crudini --set /etc/barbican/barbican.conf keystone_authtoken www_authenticate_uri http://$HOST_NAME:5000
crudini --set /etc/barbican/barbican.conf keystone_authtoken auth_url http://$HOST_NAME:5000
crudini --set /etc/barbican/barbican.conf keystone_authtoken memcached_servers $HOST_NAME:11211
crudini --set /etc/barbican/barbican.conf keystone_authtoken auth_type password
crudini --set /etc/barbican/barbican.conf keystone_authtoken project_domain_name $DOMAIN_NAME
crudini --set /etc/barbican/barbican.conf keystone_authtoken user_domain_name $DOMAIN_NAME
crudini --set /etc/barbican/barbican.conf keystone_authtoken project_name service
crudini --set /etc/barbican/barbican.conf keystone_authtoken username barbican
crudini --set /etc/barbican/barbican.conf keystone_authtoken password $BARBICAN_PASS

crudini --set /etc/barbican/barbican-api-paste.ini pipeline:barbican_api pipeline cors\ authtoken\ context\ apiapp
crudini --set /etc/cinder/cinder.conf key_manager backend barbican
crudini --set /etc/nova/nova.conf key_manager backend barbican

su -s /bin/sh -c "barbican-manage db upgrade" barbican

cat > /etc/httpd/conf.d/wsgi-barbican.conf <<-EOF
Listen 9311
<VirtualHost  *:9311>

    ## Logging
    <IfVersion >= 2.4>
      ErrorLogFormat "%{cu}t %M"
    </IfVersion>
    ErrorLog /var/log/httpd/barbican_wsgi_main_error_ssl.log
    LogLevel debug
    ServerSignature Off
    CustomLog /var/log/httpd/barbican_wsgi_main_access_ssl.log combined

    WSGIApplicationGroup %{GLOBAL}
    WSGIDaemonProcess barbican-api display-name=barbican-api group=barbican processes=2 threads=8 user=barbican
    WSGIProcessGroup barbican-api
    WSGIScriptAlias / /usr/lib/python2.7/site-packages/barbican/api/app.wsgi
    WSGIPassAuthorization On

    <Directory /usr/lib>
        <IfVersion >= 2.4>
            Require all granted
        </IfVersion>
        <IfVersion < 2.4>
            Order allow,deny
            Allow from all
        </IfVersion>
    </Directory>
</VirtualHost>
EOF

systemctl enable httpd.service
systemctl restart httpd.service memcached
systemctl restart openstack-nova-* openstack-cinder-api

ssh -tt compute << EOF
crudini --set /etc/cinder/cinder.conf key_manager backend barbican
crudini --set /etc/cinder/cinder.conf barbican barbican_endpoint http://$HOST_IP:9311
crudini --set /etc/cinder/cinder.conf barbican auth_endpoint http://$HOST_IP/identity/v3
crudini --set /etc/nova/nova.conf key_manager backend barbican
crudini --set /etc/nova/nova.conf barbican barbican_endpoint http://$HOST_IP:9311
crudini --set /etc/nova/nova.conf barbican auth_endpoint http://$HOST_IP/identity/v3
systemctl restart openstack-nova-* openstack-cinder-*
exit
EOF

# openstack volume type create --encryption-provider luks --encryption-cipher aes-xts-plain64 --encryption-key-size 256 --encryption-control-location front-end LUKS
# openstack secret store --name mysecret --payload j4=]d21
