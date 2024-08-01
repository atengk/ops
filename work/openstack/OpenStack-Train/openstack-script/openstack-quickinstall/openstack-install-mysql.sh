#!/bin/bash
set -x
source /etc/cloudconfig/openrc.sh
ping $HOST_IP -c 4 >> /dev/null 2>&1
if [ 0  -ne  $? ]; then
        echo -e "\033[31m Warning\nPlease make sure the network configuration is correct!\033[0m"
        exit 1
fi

#  MariaDB
yum install -y mariadb mariadb-server python2-PyMySQL
cat > /etc/my.cnf.d/openstack.cnf << EOF
[mysqld]
bind-address = $HOST_IP
default-storage-engine = innodb
innodb_file_per_table = on
max_connections = 1024000
max_allowed_packet = 1G
collation-server = utf8mb4_general_ci
character-set-server = utf8mb4
read_rnd_buffer_size = 4M
table_cache=65535
table_definition_cache=65535
net_buffer_length=1M
bulk_insert_buffer_size=16M
query_cache_type=0
query_cache_size=0
key_buffer_size=8M
innodb_buffer_pool_size=4G
myisam_sort_buffer_size=32M
max_heap_table_size=16M
tmp_table_size=16M
sort_buffer_size=256K
read_buffer_size=128k
join_buffer_size=1M
thread_stack=256k
binlog_cache_size=64K
slow_query_log = ON
log_output = 'TABLE'
long_query_time = 3
EOF
crudini --set /usr/lib/systemd/system/mariadb.service Service LimitNOFILE 5000
crudini --set /usr/lib/systemd/system/mariadb.service Service LimitNPROC 5000
systemctl daemon-reload
systemctl enable mariadb.service
systemctl restart mariadb.service

expect -c "
spawn /usr/bin/mysql_secure_installation
expect \"Enter current password for root (enter for none):\"
send \"\r\"
expect \"Set root password?\"
send \"y\r\"
expect \"New password:\"
send \"$DB_PASS\r\"
expect \"Re-enter new password:\"
send \"$DB_PASS\r\"
expect \"Remove anonymous users?\"
send \"y\r\"
expect \"Disallow root login remotely?\"
send \"n\r\"
expect \"Remove test database and access to it?\"
send \"y\r\"
expect \"Reload privilege tables now?\"
send \"y\r\"
expect eof
"
mysql -uroot -p$DB_PASS -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'localhost' IDENTIFIED BY '$DB_PASS' ;"
mysql -uroot -p$DB_PASS -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY '$DB_PASS' ;"



# RabbitMQ
yum install rabbitmq-server -y
systemctl start rabbitmq-server.service
systemctl enable rabbitmq-server.service

rabbitmqctl add_user $RABBIT_USER $RABBIT_PASS
rabbitmqctl set_permissions $RABBIT_USER ".*" ".*" ".*"

# Memcache
yum install memcached python-memcached -y
sed -i  -e 's/OPTIONS.*/OPTIONS="-l 127.0.0.1,'$HOST_NAME'"/g' /etc/sysconfig/memcached
sed -i  -e 's/MAXCONN.*/MAXCONN="4096"/g' /etc/sysconfig/memcached
sed -i  -e 's/CACHESIZE.*/CACHESIZE="4096"/g' /etc/sysconfig/memcached

systemctl start memcached.service
systemctl enable memcached.service


# ETCD
yum install etcd -y
sed -i -e 's/#ETCD_LISTEN_PEER_URLS.*/ETCD_LISTEN_PEER_URLS="http:\/\/'$HOST_IP':2380"/g' \
-e 's/^ETCD_LISTEN_CLIENT_URLS.*/ETCD_LISTEN_CLIENT_URLS="http:\/\/'$HOST_IP':2379"/g' \
-e 's/^ETCD_NAME="default"/ETCD_NAME="'$HOST_NAME'"/g' \
-e 's/#ETCD_INITIAL_ADVERTISE_PEER_URLS.*/ETCD_INITIAL_ADVERTISE_PEER_URLS="http:\/\/'$HOST_IP':2380"/g' \
-e 's/^ETCD_ADVERTISE_CLIENT_URLS.*/ETCD_ADVERTISE_CLIENT_URLS="http:\/\/'$HOST_IP':2379"/g' \
-e 's/#ETCD_INITIAL_CLUSTER=.*/ETCD_INITIAL_CLUSTER="'$HOST_NAME'=http:\/\/'$HOST_IP':2380"/g' \
-e 's/#ETCD_INITIAL_CLUSTER_TOKEN.*/ETCD_INITIAL_CLUSTER_TOKEN="etcd-cluster-01"/g' \
-e 's/#ETCD_INITIAL_CLUSTER_STATE.*/ETCD_INITIAL_CLUSTER_STATE="new"/g' /etc/etcd/etcd.conf
systemctl start etcd
systemctl enable etcd
