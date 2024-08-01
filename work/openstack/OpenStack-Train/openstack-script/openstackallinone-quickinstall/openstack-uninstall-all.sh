#/bin/bash
set -x
source /etc/cloudconfig/openrc.sh
cat <<- EOF

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!! Please confirm whether or not to clear all data in the system      !!    
!!                    Please careful operation                        !!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

EOF
printf "\033[35mPlease Confirm : yes or no !\n\033[0m"
read ans
while [[ "x"$ans != "xyes" && "x"$ans != "xno" ]] 
do
    echo "yes or no"
        read ans
done
if [ "$ans" = no ]; then
exit 1
fi


printf "\033[35mPlease wait ...\n\033[0m"
openstack-service stop   >/dev/null 2>&1
if [[ -f /etc/keystone/admin-openrc.sh ]]; then
	source  /etc/keystone/admin-openrc.sh  >/dev/null 2>&1
	for i in `nova list | sed -e '1,3d' -e '$d' |awk '{print $2}'`;do nova delete $i;done >/dev/null 2>&1
fi
for i in `virsh  list  |grep running  |awk '{print $2}'`;do virsh destroy  $i;done >/dev/null 2>&1
for i in `virsh  list --all  | grep -w '-' |awk '{print $2}' `;do virsh undefine $i;done >/dev/null 2>&1
systemctl stop mariadb.service rabbitmq-server openvswitch   >/dev/null 2>&1

if [[ `vgs |grep cinder-volumes` != '' ]];then 
	for i in `lvs |grep volume |awk '{print $1}'`; do
	lvremove -f /dev/cinder-volumes/$i
	done 
	vgremove -f cinder-volumes
	pvremove -f /dev/$BLOCK_DISK
fi

IfSwifExists=`df -h |grep "/swift/node"`
if [[ "$IfSwifExists" != '' ]];then 
	umount /swift/node/$OBJECT_DISK
        sed -i '/swift/d' /etc/fstab
fi

IfDockerRun=`docker ps -a |sed -e '1d'|awk '{print $1}'`
if [[ $IfDockerRun != '' ]]; then
	for i in $IfDockerRun; do
		docker rm -f $i >/dev/null 2>&1
	done
fi

IfDockerImage=`docker images |sed -e '1d'|awk '{print $3}'`
if [[ $IfDockerImage != '' ]]; then
	for i in $IfDockerImage; do
		docker rmi $i >/dev/null 2>&1
	done
fi

DockerNetwork=`brctl show | sed -e '1d' -e '$d'`
if [[ $DockerNetwork != '' ]]; then
	for i in $DockerNetwork; do
		ip link set dev $i down
		brctl delbr $i 
	done

fi

IPlinkList=`ip link list |grep -w "qdisc noqueue" | sed -e '1d' -e '$d' | awk -F ':' '{print $2}'`
if [[ $IPlinkList != '' ]]; then
	for i in $IPlinkList; do
		ip link set dev $i down
		ip link delete $i
	done
fi

yum remove -y openstack-* \
python-keystone httpd mod_wsgi vsftpd \
python2-ceilometerclient python2-pecan \
python2-ceilometermiddleware python2-gnocchiclient gnocchi-common python-gnocchi \
mariadb* python2-PyMySQL rabbitmq-server memcached python-memcached etcd \
python-openstackclient crudini expect chrony bind \
lvm2 device-mapper-persistent-data targetcli \
python-swiftclient python-keystoneclient python-keystonemiddleware xfsprogs rsync \
yum-utils docker-ce docker-ce-cli python-pip git kuryr-libnetwork \
qemu* libvirt* virt-* vim-common qemu-kvm-common-ev dhcp-common iaas-xiandian 


###
rm -rf /etc/keystone/ /etc/etcd/ /etc/nova/ /etc/glance/ /etc/neutron/ /etc/openstack-dashboard/  /etc/cinder/ /etc/swift /etc/heat/ /etc/aodh/ /etc/zun/ /etc/docker/ /etc/kuryr/ /etc/mongod.conf  /etc/chrony* /etc/name* /etc/httpd /etc/ceilometer /etc/gnocchi/ >/dev/null 2>&1
rm -rf /var/lib/keystone/ /var/lib/libvirt /var/lib/etcd /var/lib/gnocchi /var/lib/rabbitmq/ /var/lib/glance/ /var/lib/nova/ /var/lib/neutron/ /var/lib/cinder/ /var/lib/swift /var/lib/mysql/ /var/lib/kuryr /var/lib/zun >/dev/null 2>&1
rm -rf /var/www/cgi-bin/gnocchi /var/www/cgi-bin/aodh  /swift/node
rm -rf /etc/my.cnf*  /root/.ssh/*   >/dev/null 2>&1

###
service network restart
hostnamectl  set-hostname localhost.localdomain
cat <<EOF > /etc/sysctl.conf    
# System default settings live in /usr/lib/sysctl.d/00-system.conf.
# To override those settings, enter new settings here, or in an /etc/sysctl.d/<name>.conf file
#
# For more information, see sysctl.conf(5) and sysctl.d(5).
EOF
cat <<EOF > /etc/hosts
127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
::1         localhost localhost.localdomain localhost6 localhost6.localdomain6
EOF
printf "\033[35mPlease wait....\nThe system will reboot immediately ! \nPlease reconnect after system restart ! \n\033[0m"
sleep 3
reboot
