#!/bin/bash

source /etc/cloudconfig/openrc-ha.sh

net=$(ip address | grep mtu | grep "state UP" | awk -F ':' 'NR==1{print $2}')
ipaddress=$(ip a | grep $net | grep -w inet | awk '{print $2}' | awk -F '/' '{print $1}')
openstack_network_lan="$(echo $ipaddress | awk -F '.' '{print $1"."$2"."$3}')"".0/24"
rm -rf /etc/cloudconfig/openrc-ha-info.sh && mkdir -p /etc/cloudconfig
cat > /etc/hosts <<EOF
127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4 kongyu
::1         localhost localhost.localdomain localhost6 localhost6.localdomain6 kongyu
EOF
echo "$openstack_cluster_vip openstack vip" >> /etc/hosts
## 获取控制节点主机名与IP对应
openstack_controller_cluster_host_name=""
openstack_controller_cluster_memcache_servers=""
openstack_controller_cluster_transport_url="rabbit://"
count=1
openstack_controller_cluster_ip2=(${openstack_controller_cluster_ip//,/ })
for ip in ${openstack_controller_cluster_ip2[@]}
do
    openstack_controller_cluster_host_name="$openstack_controller_cluster_host_name""controller""$count "
	openstack_controller_cluster_memcache_servers="$openstack_controller_cluster_memcache_servers""controller""$count:11211,"
	openstack_controller_cluster_transport_url="$openstack_controller_cluster_transport_url""openstack:$openstack_service_password@controller$count,"
    echo "$ip controller$count" >> /etc/hosts
    echo "controller_ip$count=$ip" >> /etc/cloudconfig/openrc-ha-info.sh
	echo "controller_name$count=controller$count" >> /etc/cloudconfig/openrc-ha-info.sh
    ((count++))
done

## 获取计算节点主机名与IP对应
openstack_compute_cluster_host_name=""
count=1
openstack_compute_cluster_ip2=(${openstack_compute_cluster_ip//,/ })
for ip in ${openstack_compute_cluster_ip2[@]}
do
    openstack_compute_cluster_host_name="$openstack_compute_cluster_host_name""compute""$count "
    echo "$ip compute$count" >> /etc/hosts
    echo "compute_ip$count=$ip" >> /etc/cloudconfig/openrc-ha-info.sh
	echo "compute_name$count=compute$count" >> /etc/cloudconfig/openrc-ha-info.sh
    ((count++))
done


## 获取ceph节点主机名与IP对应
openstack_ceph_cluster_host_name=""
count=1
openstack_ceph_cluster_ip2=(${openstack_ceph_cluster_ip//,/ })
for ip in ${openstack_ceph_cluster_ip2[@]}
do
    openstack_ceph_cluster_host_name="$openstack_ceph_cluster_host_name""ceph""$count "
    echo "$ip ceph$count" >> /etc/hosts
    echo "ceph_ip$count=$ip" >> /etc/cloudconfig/openrc-ha-info.sh
	echo "ceph_name$count=ceph$count" >> /etc/cloudconfig/openrc-ha-info.sh
    ((count++))
done


echo "openstack_controller_cluster_host_name='${openstack_controller_cluster_host_name:0:-1}'" >> /etc/cloudconfig/openrc-ha-info.sh
echo "openstack_compute_cluster_host_name='${openstack_compute_cluster_host_name:0:-1}'" >> /etc/cloudconfig/openrc-ha-info.sh
echo "openstack_ceph_cluster_host_name='${openstack_ceph_cluster_host_name:0:-1}'" >> /etc/cloudconfig/openrc-ha-info.sh
openstack_all_cluster_host_name="$openstack_controller_cluster_host_name $openstack_compute_cluster_host_name $openstack_ceph_cluster_host_name"
echo "openstack_all_cluster_host_name='${openstack_all_cluster_host_name:0:-1}'" >> /etc/cloudconfig/openrc-ha-info.sh
echo "openstack_controller_cluster_memcache_servers=${openstack_controller_cluster_memcache_servers:0:-1}" >> /etc/cloudconfig/openrc-ha-info.sh
echo "openstack_controller_cluster_transport_url=${openstack_controller_cluster_transport_url:0:-1}" >> /etc/cloudconfig/openrc-ha-info.sh
echo "openstack_network_lan=$openstack_network_lan" >> /etc/cloudconfig/openrc-ha-info.sh


chmod 755 /etc/cloudconfig/openrc-ha-info.sh
source /etc/cloudconfig/openrc-ha-info.sh
## 配置ssh免秘钥登录、配置ftp yum源
yum -y install sshpass expect vsftpd
echo anon_root=/opt >> /etc/vsftpd/vsftpd.conf
systemctl start vsftpd && systemctl enable vsftpd
#selinux
sed -i 's/SELINUX=.*/SELINUX=permissive/g' /etc/selinux/config
setenforce 0
#firewalld
systemctl stop firewalld
systemctl disable firewalld

rm -rf /root/.ssh
ssh-keygen -t rsa -P "" -f ~/.ssh/id_rsa
expect <<-EOF
spawn ssh-copy-id localhost
expect {
"*(yes/no)?*" {send "yes\n";exp_continue}
"*root@localhost's password:*" {send "$openstack_cluster_root_password\n";exp_continue}
}
exit
expect eof
EOF
the_script_net_name1=$(ip address | grep mtu | grep "state UP" | awk -F ':' 'NR==1{print $2}')
the_script_ip=$(ip a | grep $the_script_net_name1 | grep -w inet | awk '{print $2}' | awk -F '/' '{print $1}')
for host in $openstack_all_cluster_host_name
do
sshpass -p $openstack_cluster_root_password scp -ro StrictHostKeychecking=no /root/.ssh root@$host:/root
sshpass -p $openstack_cluster_root_password scp -ro StrictHostKeychecking=no /etc/cloudconfig root@$host:/etc
sshpass -p $openstack_cluster_root_password scp -ro StrictHostKeychecking=no /etc/hosts root@$host:/etc
sshpass -p $openstack_cluster_root_password ssh -Tqo StrictHostKeychecking=no root@$host << eeooff
if [[ "$openstack_all_cluster_host_name" =~ "\$(hostname)" ]]
then
echo
else
hostnamectl set-hostname $host
fi
sed -i -e 's/#UseDNS yes/UseDNS no/g' \
    -e 's/GSSAPIAuthentication yes/GSSAPIAuthentication no/g' \
    /etc/ssh/sshd_config
systemctl restart sshd
#selinux
sed -i 's/SELINUX=.*/SELINUX=permissive/g' /etc/selinux/config
setenforce 0
#firewalld
systemctl stop firewalld
systemctl disable firewalld
mkdir -p /etc/yum.repos.d/backup
mv /etc/yum.repos.d/* /etc/yum.repos.d/backup &> /dev/null
cat > /etc/yum.repos.d/ftp.repo <<EOF
[openstack]
name=openstack
baseurl=ftp://$the_script_ip/openstack/openstack-repo
gpgcheck=0
enabled=1
EOF
eeooff
done

yum -y install keepalived haproxy
cat > /etc/keepalived/keepalived.conf <<EOF
vrrp_instance VI_1 {
    state MASTER
    interface $net
    virtual_router_id 100
    mcast_src_ip $ipaddress
    priority 100
    advert_int 1
    authentication {
        auth_type PASS
        auth_pass $openstack_service_password
    }
    virtual_ipaddress {
        $openstack_cluster_vip/24
    }
}
EOF
systemctl start keepalived
systemctl enable keepalived

cat > /etc/haproxy/haproxy.cfg <<EOF
global
  log 127.0.0.1 local0 info
  group haproxy
  user haproxy
  chroot /var/lib/haproxy
  pidfile /var/run/haproxy.pid
  maxconn 10240
  ## 设置为后台进程
  daemon

defaults
  log global
  mode http
  ## 每个进程的最大连接数
  maxconn 4000
  option redispatch
  ## 服务器连接失败后的重试次数
  retries 3
  timeout http-request 10s
  timeout queue 1m
  timeout connect 10s
  timeout client 1m
  timeout server 1m
  timeout check 10s

## haproxy服务
listen stats
  ## 本机IP地址
  bind $ipaddress:1080
  mode http
  stats enable
  stats uri /
  stats realm OpenStack\ Haproxy
  ## 指定监控页面登陆的用户名和密码
  stats auth kongyu:kongyu
  ## 页面刷新间隔为5s
  stats refresh 5s
  stats show-node
  stats show-legends
  stats hide-version

## haproxy监控页
listen Haproxy_Cluster:1080
  bind $openstack_cluster_vip:1080
  mode tcp
  option tcpka
  balance roundrobin
  timeout client  3h
  timeout server  3h
  option  clitcpka
  ## 每2000毫秒健康检查一次，连续3次正常则认为是有效的，连续3次健康检查失败则认为服务器宕机
  server $controller_name1 $controller_ip1:1080 check inter 2000 rise 3 fall 3
  server $controller_name2 $controller_ip2:1080 check inter 2000 rise 3 fall 3
  server $controller_name3 $controller_ip3:1080 check inter 2000 rise 3 fall 3

## mariadb服务
listen MariaDB_Galera_Cluster:3306
  bind $openstack_cluster_vip:3306
  balance  source
  mode    tcp
  server $controller_name1 $controller_ip1:3306 check inter 2000 rise 3 fall 3
  server $controller_name2 $controller_ip2:3306 backup check inter 2000 rise 3 fall 3
  server $controller_name3 $controller_ip3:3306 backup check inter 2000 rise 3 fall 3

## http服务&horizon服务
listen Dashboard_Cluster:80
  bind $openstack_cluster_vip:80
  balance source
  option tcpka
  option httpchk
  option tcplog
  server $controller_name1 $controller_ip1:80 check inter 2000 rise 3 fall 3
  server $controller_name2 $controller_ip2:80 check inter 2000 rise 3 fall 3
  server $controller_name3 $controller_ip3:80 check inter 2000 rise 3 fall 3

## keystone_admin_api服务
listen Keystone_Admin_Cluster:35357
  bind $openstack_cluster_vip:35357
  mode tcp
  option tcpka
  balance roundrobin
  timeout client  3h
  timeout server  3h
  option  clitcpka
  server $controller_name1 $controller_ip1:35357 check inter 2000 rise 3 fall 3
  server $controller_name2 $controller_ip2:35357 check inter 2000 rise 3 fall 3
  server $controller_name3 $controller_ip3:35357 check inter 2000 rise 3 fall 3

## keystone_public_api服务
listen Keystone_Public_Cluster:5000
  bind $openstack_cluster_vip:5000
  mode tcp
  option tcpka
  balance roundrobin
  timeout client  3h
  timeout server  3h
  option  clitcpka
  server $controller_name1 $controller_ip1:5000 check inter 2000 rise 3 fall 3
  server $controller_name2 $controller_ip2:5000 check inter 2000 rise 3 fall 3
  server $controller_name3 $controller_ip3:5000 check inter 2000 rise 3 fall 3

## glance_api服务
listen Glance_Api_Cluster:9292
  bind $openstack_cluster_vip:9292
  balance  source
  option  tcpka
  option  httpchk
  option  tcplog
  server $controller_name1 $controller_ip1:9292 check inter 2000 rise 3 fall 3
  server $controller_name2 $controller_ip2:9292 check inter 2000 rise 3 fall 3
  server $controller_name3 $controller_ip3:9292 check inter 2000 rise 3 fall 3

## glance_registry服务
listen Glance_Registry_Cluster:9191
  bind $openstack_cluster_vip:9191
  balance  source
  option  tcpka
  option  tcplog
  server $controller_name1 $controller_ip1:9191 check inter 2000 rise 3 fall 3
  server $controller_name2 $controller_ip2:9191 check inter 2000 rise 3 fall 3
  server $controller_name3 $controller_ip3:9191 check inter 2000 rise 3 fall 3

## nova_placement服务
listen Nova_Placement_Cluster:8778
  bind $openstack_cluster_vip:8778
  balance  source
  option  tcpka
  option  tcplog
  server $controller_name1 $controller_ip1:8778 check inter 2000 rise 3 fall 3
  server $controller_name2 $controller_ip2:8778 check inter 2000 rise 3 fall 3
  server $controller_name3 $controller_ip3:8778 check inter 2000 rise 3 fall 3

## nova_metadata_api服务
listen Nova_Metadata_Api_Cluster:8775
  bind $openstack_cluster_vip:8775
  balance  source
  option  tcpka
  option  tcplog
  server $controller_name1 $controller_ip1:8775 check inter 2000 rise 3 fall 3
  server $controller_name2 $controller_ip2:8775 check inter 2000 rise 3 fall 3
  server $controller_name3 $controller_ip3:8775 check inter 2000 rise 3 fall 3

## nova_vncproxy服务
listen Nova_Vncproxy_Cluster:6080
  bind $openstack_cluster_vip:6080
  balance  source
  option  tcpka
  option  tcplog
  server $controller_name1 $controller_ip1:6080 check inter 2000 rise 3 fall 3
  server $controller_name2 $controller_ip2:6080 check inter 2000 rise 3 fall 3
  server $controller_name3 $controller_ip3:6080 check inter 2000 rise 3 fall 3

## nova_compute_api服务
listen Nova_Compute_Api_Cluster:8774
  bind $openstack_cluster_vip:8774
  balance  source
  option  tcpka
  option  httpchk
  option  tcplog
  server $controller_name1 $controller_ip1:8774 check inter 2000 rise 3 fall 3
  server $controller_name2 $controller_ip2:8774 check inter 2000 rise 3 fall 3
  server $controller_name3 $controller_ip3:8774 check inter 2000 rise 3 fall 3

## neutron_api服务
listen Neutron_Api_Cluster:9696
  bind $openstack_cluster_vip:9696
  balance  source
  option  tcpka
  option  httpchk
  option  tcplog
  server $controller_name1 $controller_ip1:9696 check inter 2000 rise 3 fall 3
  server $controller_name2 $controller_ip2:9696 check inter 2000 rise 3 fall 3
  server $controller_name3 $controller_ip3:9696 check inter 2000 rise 3 fall 3

## cinder_api服务
listen Cinder_Api_Cluster:8776
  bind $openstack_cluster_vip:8776
  balance  source
  option  tcpka
  option  httpchk
  option  tcplog
  server $controller_name1 $controller_ip1:8776 check inter 2000 rise 3 fall 3
  server $controller_name2 $controller_ip2:8776 check inter 2000 rise 3 fall 3
  server $controller_name3 $controller_ip3:8776 check inter 2000 rise 3 fall 3
EOF
cat >> /etc/sysctl.conf <<EOF
net.ipv4.ip_nonlocal_bind = 1
net.ipv4.ip_forward = 1
EOF
sysctl -p
systemctl start haproxy
systemctl enable haproxy



yum install  iptables-services  -y 
systemctl restart iptables
iptables -F
iptables -X
iptables -Z 
/usr/sbin/iptables-save
systemctl stop iptables
systemctl disable iptables

yum upgrade -y
yum install -y python-openstackclient openstack-selinux \
    openstack-utils crudini expect
openstack_network_lan="$(echo $ipaddress | awk -F '.' '{print $1"."$2"."$3}')"".0/24"
cat > /etc/chrony.conf <<EOF
driftfile /var/lib/chrony/drift
makestep 1.0 3
rtcsync 
logdir /var/log/chrony
server $controller_name1 iburst
allow $openstack_network_lan
local stratum 10
EOF
systemctl restart chronyd
systemctl enable chronyd


yum install -y MariaDB-server python2-PyMySQL
crudini --set /etc/my.cnf.d/server.cnf mysqld bind-address $ipaddress
crudini --set /etc/my.cnf.d/server.cnf mysqld default-storage-engine innodb
crudini --set /etc/my.cnf.d/server.cnf mysqld innodb_file_per_table on
crudini --set /etc/my.cnf.d/server.cnf mysqld max_connections 4096
crudini --set /etc/my.cnf.d/server.cnf mysqld max_allowed_packet 1073741824
crudini --set /etc/my.cnf.d/server.cnf mysqld collation-server utf8_general_ci
crudini --set /etc/my.cnf.d/server.cnf mysqld character-set-server utf8
crudini --set /etc/my.cnf.d/server.cnf mysqld read_rnd_buffer_size 4M
crudini --set /etc/my.cnf.d/server.cnf mysqld table_cache 65535
crudini --set /etc/my.cnf.d/server.cnf mysqld table_definition_cache 65535
crudini --set /etc/my.cnf.d/server.cnf mysqld net_buffer_length 1M
crudini --set /etc/my.cnf.d/server.cnf mysqld bulk_insert_buffer_size 16M
crudini --set /etc/my.cnf.d/server.cnf mysqld query_cache_type 0
crudini --set /etc/my.cnf.d/server.cnf mysqld query_cache_size 0
crudini --set /etc/my.cnf.d/server.cnf mysqld key_buffer_size 8M
crudini --set /etc/my.cnf.d/server.cnf mysqld innodb_buffer_pool_size 4G
crudini --set /etc/my.cnf.d/server.cnf mysqld myisam_sort_buffer_size 32M
crudini --set /etc/my.cnf.d/server.cnf mysqld max_heap_table_size 16M
crudini --set /etc/my.cnf.d/server.cnf mysqld tmp_table_size 16M
crudini --set /etc/my.cnf.d/server.cnf mysqld sort_buffer_size 256K
crudini --set /etc/my.cnf.d/server.cnf mysqld read_buffer_size 128k
crudini --set /etc/my.cnf.d/server.cnf mysqld join_buffer_size 1M
crudini --set /etc/my.cnf.d/server.cnf mysqld thread_stack 256k
crudini --set /etc/my.cnf.d/server.cnf mysqld binlog_cache_size 64K
crudini --set /etc/my.cnf.d/server.cnf mysqld slow_query_log ON
crudini --set /etc/my.cnf.d/server.cnf mysqld log_output 'TABLE'
crudini --set /etc/my.cnf.d/server.cnf mysqld long_query_time 3

## 对应修改，本机IP
crudini --set /etc/my.cnf.d/server.cnf galera bind-address $ipaddress
crudini --set /etc/my.cnf.d/server.cnf galera wsrep_on ON
crudini --set /etc/my.cnf.d/server.cnf galera wsrep_provider /usr/lib64/galera/libgalera_smm.so
## 对应修改，集群IP
crudini --set /etc/my.cnf.d/server.cnf galera wsrep_cluster_address gcomm://$openstack_controller_cluster_ip
crudini --set /etc/my.cnf.d/server.cnf galera binlog_format row
crudini --set /etc/my.cnf.d/server.cnf galera default_storage_engine InnoDB
crudini --set /etc/my.cnf.d/server.cnf galera innodb_autoinc_lock_mode 2
crudini --set /etc/my.cnf.d/server.cnf galera wsrep_cluster_name OpenStackHA-Cluster
crudini --set /etc/my.cnf.d/server.cnf galera wsrep_node_name $(hostname)
## 对应修改，本机IP和主机名
crudini --set /etc/my.cnf.d/server.cnf galera wsrep_node_address $ipaddress
crudini --set /etc/my.cnf.d/server.cnf galera wsrep_sst_method rsync

/bin/galera_new_cluster
systemctl start mariadb
systemctl enable mariadb
sleep 3
expect -c "
spawn /usr/bin/mysql_secure_installation
expect \"Enter current password for root (enter for none):\"
send \"\r\"
expect \"Set root password?\"
send \"y\r\"
expect \"New password:\"
send \"$openstack_service_password\r\"
expect \"Re-enter new password:\"
send \"$openstack_service_password\r\"
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


yum -y install rabbitmq-server
sshpass -p $openstack_cluster_root_password ssh -Tqo StrictHostKeychecking=no root@localhost << eeooff
systemctl start rabbitmq-server
systemctl enable rabbitmq-server
rabbitmq-plugins enable rabbitmq_management
eeooff


yum install memcached python-memcached -y
net1=$(ip address | grep mtu | grep "state UP" | awk -F ':' 'NR==1{print $2}')
ipaddress1=$(ip a | grep $net1 | grep -w inet | awk '{print $2}' | awk -F '/' '{print $1}' | head -n 1)
sed -i "s/OPTIONS=.*/OPTIONS=\"-l $ipaddress1\"/g" /etc/sysconfig/memcached
systemctl start memcached
systemctl enable memcached


for host in $openstack_controller_cluster_host_name
do
sshpass -p $openstack_cluster_root_password ssh -Tqo StrictHostKeychecking=no root@$host << eeooff
if [[ "$controller_name1" =~ "\$(hostname)" ]]
then
echo
else
net1=\$(ip address | grep mtu | grep "state UP" | awk -F ':' 'NR==1{print \$2}')
ipaddress1=\$(ip a | grep \$net1 | grep -w inet | awk '{print \$2}' | awk -F '/' '{print \$1}' | head -n 1)
yum -y install keepalived haproxy
cat > /etc/keepalived/keepalived.conf <<EOF
vrrp_instance VI_1 {
    state BACKUP
    interface $net
    virtual_router_id 100
    mcast_src_ip \$ipaddress1
    priority \$(openssl rand -base64 8 | cksum | cut -c1-2)
    advert_int 1
    authentication {
        auth_type PASS
        auth_pass $openstack_service_password
    }
    virtual_ipaddress {
        $openstack_cluster_vip/24
    }
}
EOF
systemctl start keepalived
systemctl enable keepalived

cat > /etc/haproxy/haproxy.cfg <<EOF
global
  log 127.0.0.1 local0 info
  group haproxy
  user haproxy
  chroot /var/lib/haproxy
  pidfile /var/run/haproxy.pid
  maxconn 10240
  ## 设置为后台进程
  daemon

defaults
  log global
  mode http
  ## 每个进程的最大连接数
  maxconn 4000
  option redispatch
  ## 服务器连接失败后的重试次数
  retries 3
  timeout http-request 10s
  timeout queue 1m
  timeout connect 10s
  timeout client 1m
  timeout server 1m
  timeout check 10s

## haproxy服务
listen stats
  ## 本机IP地址
  bind \$ipaddress:1080
  mode http
  stats enable
  stats uri /
  stats realm OpenStack\ Haproxy
  ## 指定监控页面登陆的用户名和密码
  stats auth kongyu:kongyu
  ## 页面刷新间隔为5s
  stats refresh 5s
  stats show-node
  stats show-legends
  stats hide-version

## haproxy监控页
listen Haproxy_Cluster:1080
  bind $openstack_cluster_vip:1080
  mode tcp
  option tcpka
  balance roundrobin
  timeout client  3h
  timeout server  3h
  option  clitcpka
  ## 每2000毫秒健康检查一次，连续3次正常则认为是有效的，连续3次健康检查失败则认为服务器宕机
  server $controller_name1 $controller_ip1:1080 check inter 2000 rise 3 fall 3
  server $controller_name2 $controller_ip2:1080 check inter 2000 rise 3 fall 3
  server $controller_name3 $controller_ip3:1080 check inter 2000 rise 3 fall 3

## mariadb服务
listen MariaDB_Galera_Cluster:3306
  bind $openstack_cluster_vip:3306
  balance  source
  mode    tcp
  server $controller_name1 $controller_ip1:3306 check inter 2000 rise 3 fall 3
  server $controller_name2 $controller_ip2:3306 backup check inter 2000 rise 3 fall 3
  server $controller_name3 $controller_ip3:3306 backup check inter 2000 rise 3 fall 3

## http服务&horizon服务
listen Dashboard_Cluster:80
  bind $openstack_cluster_vip:80
  balance source
  option tcpka
  option httpchk
  option tcplog
  server $controller_name1 $controller_ip1:80 check inter 2000 rise 3 fall 3
  server $controller_name2 $controller_ip2:80 check inter 2000 rise 3 fall 3
  server $controller_name3 $controller_ip3:80 check inter 2000 rise 3 fall 3

## keystone_admin_api服务
listen Keystone_Admin_Cluster:35357
  bind $openstack_cluster_vip:35357
  mode tcp
  option tcpka
  balance roundrobin
  timeout client  3h
  timeout server  3h
  option  clitcpka
  server $controller_name1 $controller_ip1:35357 check inter 2000 rise 3 fall 3
  server $controller_name2 $controller_ip2:35357 check inter 2000 rise 3 fall 3
  server $controller_name3 $controller_ip3:35357 check inter 2000 rise 3 fall 3

## keystone_public_api服务
listen Keystone_Public_Cluster:5000
  bind $openstack_cluster_vip:5000
  mode tcp
  option tcpka
  balance roundrobin
  timeout client  3h
  timeout server  3h
  option  clitcpka
  server $controller_name1 $controller_ip1:5000 check inter 2000 rise 3 fall 3
  server $controller_name2 $controller_ip2:5000 check inter 2000 rise 3 fall 3
  server $controller_name3 $controller_ip3:5000 check inter 2000 rise 3 fall 3

## glance_api服务
listen Glance_Api_Cluster:9292
  bind $openstack_cluster_vip:9292
  balance  source
  option  tcpka
  option  httpchk
  option  tcplog
  server $controller_name1 $controller_ip1:9292 check inter 2000 rise 3 fall 3
  server $controller_name2 $controller_ip2:9292 check inter 2000 rise 3 fall 3
  server $controller_name3 $controller_ip3:9292 check inter 2000 rise 3 fall 3

## glance_registry服务
listen Glance_Registry_Cluster:9191
  bind $openstack_cluster_vip:9191
  balance  source
  option  tcpka
  option  tcplog
  server $controller_name1 $controller_ip1:9191 check inter 2000 rise 3 fall 3
  server $controller_name2 $controller_ip2:9191 check inter 2000 rise 3 fall 3
  server $controller_name3 $controller_ip3:9191 check inter 2000 rise 3 fall 3

## nova_placement服务
listen Nova_Placement_Cluster:8778
  bind $openstack_cluster_vip:8778
  balance  source
  option  tcpka
  option  tcplog
  server $controller_name1 $controller_ip1:8778 check inter 2000 rise 3 fall 3
  server $controller_name2 $controller_ip2:8778 check inter 2000 rise 3 fall 3
  server $controller_name3 $controller_ip3:8778 check inter 2000 rise 3 fall 3

## nova_metadata_api服务
listen Nova_Metadata_Api_Cluster:8775
  bind $openstack_cluster_vip:8775
  balance  source
  option  tcpka
  option  tcplog
  server $controller_name1 $controller_ip1:8775 check inter 2000 rise 3 fall 3
  server $controller_name2 $controller_ip2:8775 check inter 2000 rise 3 fall 3
  server $controller_name3 $controller_ip3:8775 check inter 2000 rise 3 fall 3

## nova_vncproxy服务
listen Nova_Vncproxy_Cluster:6080
  bind $openstack_cluster_vip:6080
  balance  source
  option  tcpka
  option  tcplog
  server $controller_name1 $controller_ip1:6080 check inter 2000 rise 3 fall 3
  server $controller_name2 $controller_ip2:6080 check inter 2000 rise 3 fall 3
  server $controller_name3 $controller_ip3:6080 check inter 2000 rise 3 fall 3

## nova_compute_api服务
listen Nova_Compute_Api_Cluster:8774
  bind $openstack_cluster_vip:8774
  balance  source
  option  tcpka
  option  httpchk
  option  tcplog
  server $controller_name1 $controller_ip1:8774 check inter 2000 rise 3 fall 3
  server $controller_name2 $controller_ip2:8774 check inter 2000 rise 3 fall 3
  server $controller_name3 $controller_ip3:8774 check inter 2000 rise 3 fall 3

## neutron_api服务
listen Neutron_Api_Cluster:9696
  bind $openstack_cluster_vip:9696
  balance  source
  option  tcpka
  option  httpchk
  option  tcplog
  server $controller_name1 $controller_ip1:9696 check inter 2000 rise 3 fall 3
  server $controller_name2 $controller_ip2:9696 check inter 2000 rise 3 fall 3
  server $controller_name3 $controller_ip3:9696 check inter 2000 rise 3 fall 3

## cinder_api服务
listen Cinder_Api_Cluster:8776
  bind $openstack_cluster_vip:8776
  balance  source
  option  tcpka
  option  httpchk
  option  tcplog
  server $controller_name1 $controller_ip1:8776 check inter 2000 rise 3 fall 3
  server $controller_name2 $controller_ip2:8776 check inter 2000 rise 3 fall 3
  server $controller_name3 $controller_ip3:8776 check inter 2000 rise 3 fall 3
EOF
cat >> /etc/sysctl.conf <<EOF
net.ipv4.ip_nonlocal_bind = 1
net.ipv4.ip_forward = 1
EOF
sysctl -p
systemctl start haproxy
systemctl enable haproxy

yum install  iptables-services  -y 
systemctl restart iptables
iptables -F
iptables -X
iptables -Z 
/usr/sbin/iptables-save
systemctl stop iptables
systemctl disable iptables

yum upgrade -y
yum install -y python-openstackclient openstack-selinux \
    openstack-utils crudini expect

cat > /etc/chrony.conf <<EOF
driftfile /var/lib/chrony/drift
makestep 1.0 3
rtcsync 
logdir /var/log/chrony
server $controller_name1 iburst
local stratum 10
EOF
systemctl restart chronyd
systemctl enable chronyd


yum install -y MariaDB-server python2-PyMySQL sshpass expect
crudini --set /etc/my.cnf.d/server.cnf mysqld bind-address \$ipaddress1
crudini --set /etc/my.cnf.d/server.cnf mysqld default-storage-engine innodb
crudini --set /etc/my.cnf.d/server.cnf mysqld innodb_file_per_table on
crudini --set /etc/my.cnf.d/server.cnf mysqld max_connections 4096
crudini --set /etc/my.cnf.d/server.cnf mysqld max_allowed_packet 1073741824
crudini --set /etc/my.cnf.d/server.cnf mysqld collation-server utf8_general_ci
crudini --set /etc/my.cnf.d/server.cnf mysqld character-set-server utf8
crudini --set /etc/my.cnf.d/server.cnf mysqld read_rnd_buffer_size 4M
crudini --set /etc/my.cnf.d/server.cnf mysqld table_cache 65535
crudini --set /etc/my.cnf.d/server.cnf mysqld table_definition_cache 65535
crudini --set /etc/my.cnf.d/server.cnf mysqld net_buffer_length 1M
crudini --set /etc/my.cnf.d/server.cnf mysqld bulk_insert_buffer_size 16M
crudini --set /etc/my.cnf.d/server.cnf mysqld query_cache_type 0
crudini --set /etc/my.cnf.d/server.cnf mysqld query_cache_size 0
crudini --set /etc/my.cnf.d/server.cnf mysqld key_buffer_size 8M
crudini --set /etc/my.cnf.d/server.cnf mysqld innodb_buffer_pool_size 4G
crudini --set /etc/my.cnf.d/server.cnf mysqld myisam_sort_buffer_size 32M
crudini --set /etc/my.cnf.d/server.cnf mysqld max_heap_table_size 16M
crudini --set /etc/my.cnf.d/server.cnf mysqld tmp_table_size 16M
crudini --set /etc/my.cnf.d/server.cnf mysqld sort_buffer_size 256K
crudini --set /etc/my.cnf.d/server.cnf mysqld read_buffer_size 128k
crudini --set /etc/my.cnf.d/server.cnf mysqld join_buffer_size 1M
crudini --set /etc/my.cnf.d/server.cnf mysqld thread_stack 256k
crudini --set /etc/my.cnf.d/server.cnf mysqld binlog_cache_size 64K
crudini --set /etc/my.cnf.d/server.cnf mysqld slow_query_log ON
crudini --set /etc/my.cnf.d/server.cnf mysqld log_output 'TABLE'
crudini --set /etc/my.cnf.d/server.cnf mysqld long_query_time 3

## 对应修改，本机IP
crudini --set /etc/my.cnf.d/server.cnf galera bind-address \$ipaddress1
crudini --set /etc/my.cnf.d/server.cnf galera wsrep_on ON
crudini --set /etc/my.cnf.d/server.cnf galera wsrep_provider /usr/lib64/galera/libgalera_smm.so
## 对应修改，集群IP
crudini --set /etc/my.cnf.d/server.cnf galera wsrep_cluster_address gcomm://$openstack_controller_cluster_ip
crudini --set /etc/my.cnf.d/server.cnf galera binlog_format row
crudini --set /etc/my.cnf.d/server.cnf galera default_storage_engine InnoDB
crudini --set /etc/my.cnf.d/server.cnf galera innodb_autoinc_lock_mode 2
crudini --set /etc/my.cnf.d/server.cnf galera wsrep_cluster_name OpenStackHA-Cluster
crudini --set /etc/my.cnf.d/server.cnf galera wsrep_node_name \$(hostname)
## 对应修改，本机IP和主机名
crudini --set /etc/my.cnf.d/server.cnf galera wsrep_node_address \$ipaddress1
crudini --set /etc/my.cnf.d/server.cnf galera wsrep_sst_method rsync


systemctl start mariadb
systemctl enable mariadb

yum -y install rabbitmq-server
systemctl start rabbitmq-server
systemctl enable rabbitmq-server

yum install memcached python-memcached -y
sed -i "s/OPTIONS=.*/OPTIONS=\"-l \$ipaddress1\"/g" /etc/sysconfig/memcached
systemctl start memcached
systemctl enable memcached

fi
eeooff
done

sshpass -p $openstack_cluster_root_password scp -ro StrictHostKeychecking=no /var/lib/rabbitmq/.erlang.cookie $controller_name2:/var/lib/rabbitmq
sshpass -p $openstack_cluster_root_password scp -ro StrictHostKeychecking=no /var/lib/rabbitmq/.erlang.cookie $controller_name3:/var/lib/rabbitmq
for host in $openstack_controller_cluster_host_name
do
sshpass -p $openstack_cluster_root_password ssh -Tqo StrictHostKeychecking=no root@$host << eeooff
if [[ "$controller_name1" =~ "\$(hostname)" ]]
then
echo
else
systemctl restart rabbitmq-server
rabbitmqctl stop_app
rabbitmqctl join_cluster --ram rabbit@$controller_name1
rabbitmqctl start_app
rabbitmq-plugins enable rabbitmq_management
fi
eeooff
done

for host in $openstack_compute_cluster_host_name
do
sshpass -p $openstack_cluster_root_password ssh -Tqo StrictHostKeychecking=no root@$host << eeooff
if [[ "$controller_name1" =~ "\$(hostname)" ]]
then
echo
else
yum install  iptables-services  -y 
systemctl restart iptables
iptables -F
iptables -X
iptables -Z 
/usr/sbin/iptables-save
systemctl stop iptables
systemctl disable iptables

yum upgrade -y
yum install -y python-openstackclient openstack-selinux \
    openstack-utils crudini expect
fi
eeooff
done

for host in $openstack_compute_cluster_host_name $openstack_ceph_cluster_host_name
do
sshpass -p $openstack_cluster_root_password ssh -Tqo StrictHostKeychecking=no root@$host << eeooff
if [[ "$controller_name1" =~ "\$(hostname)" ]]
then
echo
else
cat > /etc/chrony.conf <<EOF
driftfile /var/lib/chrony/drift
makestep 1.0 3
rtcsync 
logdir /var/log/chrony
server $controller_name1 iburst
local stratum 10
EOF
systemctl restart chronyd
systemctl enable chronyd
fi
eeooff
done

#echo -e "\033[1;34m请重新登录集群所有主机：Ctrl+D \n\033[0m"