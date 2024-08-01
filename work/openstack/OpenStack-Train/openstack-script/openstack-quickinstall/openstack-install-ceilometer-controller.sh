#!/bin/bash
set -x
source /etc/cloudconfig/openrc.sh
source /etc/keystone/admin-openrc.sh
yum install openstack-gnocchi-api openstack-gnocchi-metricd python2-gnocchiclient openstack-ceilometer-notification openstack-ceilometer-central python2-ceilometerclient python-ceilometermiddleware -y

openstack user create --domain $DOMAIN_NAME --password $CEILOMETER_PASS ceilometer
openstack role add --project service --user ceilometer admin
openstack service create --name ceilometer --description "OpenStack Telemetry Service" metering 
openstack user create --domain $DOMAIN_NAME --password $CEILOMETER_PASS gnocchi
openstack role add --project service --user gnocchi admin
openstack service create --name gnocchi --description "Metric Service" metric
openstack endpoint create --region RegionOne metric public http://$HOST_NAME:8041
openstack endpoint create --region RegionOne metric internal http://$HOST_NAME:8041
openstack endpoint create --region RegionOne metric admin http://$HOST_NAME:8041

openstack role create ResellerAdmin
openstack role add --project service --user ceilometer ResellerAdmin

mysql -uroot -p$DB_PASS -e "create database IF NOT EXISTS gnocchi ;"
mysql -uroot -p$DB_PASS -e "GRANT ALL PRIVILEGES ON gnocchi.* TO 'gnocchi'@'localhost' IDENTIFIED BY '$CEILOMETER_DBPASS' ;"
mysql -uroot -p$DB_PASS -e "GRANT ALL PRIVILEGES ON gnocchi.* TO 'gnocchi'@'%' IDENTIFIED BY '$CEILOMETER_DBPASS' ;"

crudini --set /etc/gnocchi/gnocchi.conf DEFAULT log_dir /var/log/gnocchi
crudini --set /etc/gnocchi/gnocchi.conf api auth_mode keystone
crudini --set /etc/gnocchi/gnocchi.conf database backend sqlalchemy

crudini --set /etc/gnocchi/gnocchi.conf keystone_authtoken auth_type password
crudini --set /etc/gnocchi/gnocchi.conf keystone_authtoken www_authenticate_uri http://$HOST_NAME:5000
crudini --set /etc/gnocchi/gnocchi.conf keystone_authtoken auth_url http://$HOST_NAME:5000
crudini --set /etc/gnocchi/gnocchi.conf keystone_authtoken memcached_servers $HOST_NAME:11211
crudini --set /etc/gnocchi/gnocchi.conf keystone_authtoken project_domain_name $DOMAIN_NAME
crudini --set /etc/gnocchi/gnocchi.conf keystone_authtoken user_domain_name $DOMAIN_NAME
crudini --set /etc/gnocchi/gnocchi.conf keystone_authtoken project_name service
crudini --set /etc/gnocchi/gnocchi.conf keystone_authtoken username gnocchi
crudini --set /etc/gnocchi/gnocchi.conf keystone_authtoken password $CEILOMETER_PASS
crudini --set /etc/gnocchi/gnocchi.conf keystone_authtoken service_token_roles_required true

crudini --set /etc/gnocchi/gnocchi.conf indexer url mysql+pymysql://gnocchi:$CEILOMETER_DBPASS@$HOST_NAME/gnocchi

crudini --set /etc/gnocchi/gnocchi.conf storage file_basepath /var/lib/gnocchi
crudini --set /etc/gnocchi/gnocchi.conf storage driver file

cat >/etc/httpd/conf.d/10-gnocchi_wsgi.conf<<- EOF

Listen 8041
<VirtualHost *:8041>
  DocumentRoot /var/www/cgi-bin/gnocchi

  <Directory /var/www/cgi-bin/gnocchi>
    AllowOverride None
    Require all granted
  </Directory>

  CustomLog /var/log/httpd/gnocchi_wsgi_access.log combined
  ErrorLog /var/log/httpd/gnocchi_wsgi_error.log
  SetEnvIf X-Forwarded-Proto https HTTPS=1
  WSGIApplicationGroup %{GLOBAL}
  WSGIDaemonProcess gnocchi display-name=gnocchi_wsgi user=gnocchi group=gnocchi processes=6 threads=6
  WSGIProcessGroup gnocchi
  WSGIScriptAlias / /var/www/cgi-bin/gnocchi/app
</VirtualHost>

EOF


mkdir /var/www/cgi-bin/gnocchi
cp /usr/lib/python2.7/site-packages/gnocchi/rest/gnocchi-api /var/www/cgi-bin/gnocchi/app
chown -R gnocchi. /var/www/cgi-bin/gnocchi 
su -s /bin/bash gnocchi -c "gnocchi-upgrade"

systemctl enable openstack-gnocchi-api.service openstack-gnocchi-metricd.service
systemctl restart openstack-gnocchi-api.service openstack-gnocchi-metricd.service
systemctl restart httpd memcached

echo "export OS_AUTH_TYPE=password" >> /etc/keystone/admin-openrc.sh
echo "export OS_AUTH_TYPE=password" >> /etc/keystone/demo-openrc.sh

crudini --set /etc/ceilometer/ceilometer.conf DEFAULT transport_url rabbit://$RABBIT_USER:$RABBIT_PASS@$HOST_NAME
crudini --set /etc/ceilometer/ceilometer.conf api auth_mode keystone
crudini --set /etc/ceilometer/ceilometer.conf dispatcher_gnocchi filter_service_activity False

crudini --set /etc/ceilometer/ceilometer.conf keystone_authtoken www_authenticate_uri = http://$HOST_NAME:5000
crudini --set /etc/ceilometer/ceilometer.conf keystone_authtoken auth_url = http://$HOST_NAME:5000
crudini --set /etc/ceilometer/ceilometer.conf keystone_authtoken memcached_servers = $HOST_NAME:11211
crudini --set /etc/ceilometer/ceilometer.conf keystone_authtoken auth_type = password
crudini --set /etc/ceilometer/ceilometer.conf keystone_authtoken project_domain_name = $DOMAIN_NAME
crudini --set /etc/ceilometer/ceilometer.conf keystone_authtoken user_domain_name = $DOMAIN_NAME
crudini --set /etc/ceilometer/ceilometer.conf keystone_authtoken project_name = service
crudini --set /etc/ceilometer/ceilometer.conf keystone_authtoken username = gnocchi
crudini --set /etc/ceilometer/ceilometer.conf keystone_authtoken password = $CEILOMETER_PASS

crudini --set /etc/ceilometer/ceilometer.conf service_credentials auth_type password
crudini --set /etc/ceilometer/ceilometer.conf service_credentials auth_url http://$HOST_NAME:5000
crudini --set /etc/ceilometer/ceilometer.conf service_credentials memcached_servers $HOST_NAME:11211
crudini --set /etc/ceilometer/ceilometer.conf service_credentials project_domain_name $DOMAIN_NAME
crudini --set /etc/ceilometer/ceilometer.conf service_credentials user_domain_name $DOMAIN_NAME
crudini --set /etc/ceilometer/ceilometer.conf service_credentials project_name service
crudini --set /etc/ceilometer/ceilometer.conf service_credentials username ceilometer
crudini --set /etc/ceilometer/ceilometer.conf service_credentials password $CEILOMETER_PASS

su -s /bin/bash ceilometer -c "ceilometer-upgrade --skip-metering-database" 
systemctl enable openstack-ceilometer-notification.service openstack-ceilometer-central.service
systemctl restart openstack-ceilometer-notification.service openstack-ceilometer-central.service


crudini --set /etc/glance/glance-api.conf DEFAULT transport_url rabbit://$RABBIT_USER:$RABBIT_PASS@$HOST_NAME
crudini --set /etc/glance/glance-api.conf oslo_messaging_notifications driver messagingv2
crudini --set /etc/glance/glance-registry.conf DEFAULT transport_url rabbit://$RABBIT_USER:$RABBIT_PASS@$HOST_NAME
crudini --set /etc/glance/glance-registry.conf oslo_messaging_notifications driver messagingv2

systemctl restart openstack-glance-api openstack-glance-registry 

crudini --set /etc/cinder/cinder.conf DEFAULT transport_url rabbit://$RABBIT_USER:$RABBIT_PASS@$HOST_NAME
crudini --set /etc/cinder/cinder.conf oslo_messaging_notifications driver messagingv2

systemctl restart openstack-cinder-api openstack-cinder-scheduler 

crudini --set /etc/heat/heat.conf oslo_messaging_notifications driver messagingv2
crudini --set /etc/heat/heat.conf DEFAULT transport_url rabbit://$RABBIT_USER:$RABBIT_PASS@$HOST_NAME
systemctl restart openstack-heat-api.service openstack-heat-api-cfn.service openstack-heat-engine.service

crudini --set /etc/neutron/neutron.conf oslo_messaging_notifications driver messagingv2
systemctl restart neutron-server.service

crudini --set /etc/swift/proxy-server.conf  filter:keystoneauth operator_roles "admin, user, ResellerAdmin"
crudini --set /etc/swift/proxy-server.conf pipeline:main pipeline "catch_errors gatekeeper healthcheck proxy-logging cache container_sync bulk ratelimit authtoken keystoneauth container-quotas account-quotas slo dlo versioned_writes proxy-logging ceilometer proxy-server"

crudini --set /etc/swift/proxy-server.conf filter:ceilometer paste.filter_factory ceilometermiddleware.swift:filter_factory
crudini --set /etc/swift/proxy-server.conf filter:ceilometer url  rabbit://$RABBIT_USER:$RABBIT_PASS@$HOST_NAME:5672/
crudini --set /etc/swift/proxy-server.conf filter:ceilometer driver  messagingv2
crudini --set /etc/swift/proxy-server.conf filter:ceilometer topic  notifications
crudini --set /etc/swift/proxy-server.conf filter:ceilometer log_level  WARN

systemctl restart openstack-swift-proxy.service