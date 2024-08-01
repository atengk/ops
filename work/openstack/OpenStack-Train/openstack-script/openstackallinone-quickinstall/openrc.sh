# author:	kongyu
# QQ:		2385569970
# version:	1.1
# date:	2022-05-26


## 主机基础信息，root密码和磁盘名
HOST_PASS=Admin@123
HOST_DISK_CINDER=sdb1
HOST_DISK_SWIFT=sdb2


## 安装组件，1：安装，0：不安装
keystone=1
glance=1
nova=1
neutron=1
dashboard=1
cinder=0
swift=0
heat=0
ceilometer=0
zun=0
aodh=0
barbican=0





















#--------------------system Config--------------------##
#Controller Server Manager IP. example:x.x.x.x
net=$(ip -4 route get 114.114.114.114 | head -n 1 | awk '{print $5}')
ipaddress=$(ip -4 route get 114.114.114.114 | head -n 1 | awk '{print $7}')
HOST_IP=$ipaddress

#Controller HOST Password. example:$HOST_PASS 


#Controller Server hostname. example:controller
HOST_NAME=controller

#Compute Node Manager IP. example:x.x.x.x
HOST_IP_NODE=$HOST_IP

#Compute HOST Password. example:$HOST_PASS 
HOST_PASS_NODE=$HOST_PASS

#Compute Node hostname. example:compute
HOST_NAME_NODE=controller

#--------------------Chrony Config-------------------##
#Controller network segment IP.  example:x.x.0.0/16(x.x.x.0/24)
network_segment_IP=$(echo $ipaddress | awk -F '.' '{print $1"."$2"."$3"."0"/"24}')

#--------------------Rabbit Config ------------------##
#user for rabbit. example:openstack
RABBIT_USER=openstack

#Password for rabbit user .example:$HOST_PASS
RABBIT_PASS=$HOST_PASS

#--------------------MySQL Config---------------------##
#Password for MySQL root user . exmaple:$HOST_PASS
DB_PASS=$HOST_PASS

#--------------------Keystone Config------------------##
#Password for Keystore admin user. exmaple:$HOST_PASS
DOMAIN_NAME=Default
ADMIN_PASS=$HOST_PASS
DEMO_PASS=$HOST_PASS

#Password for Mysql keystore user. exmaple:$HOST_PASS
KEYSTONE_DBPASS=$HOST_PASS

#--------------------Glance Config--------------------##
#Password for Mysql glance user. exmaple:$HOST_PASS
GLANCE_DBPASS=$HOST_PASS

#Password for Keystore glance user. exmaple:$HOST_PASS
GLANCE_PASS=$HOST_PASS

#--------------------Nova Config----------------------##
#Password for Mysql nova user. exmaple:$HOST_PASS
NOVA_DBPASS=$HOST_PASS

#Password for Keystore nova user. exmaple:$HOST_PASS
NOVA_PASS=$HOST_PASS

#--------------------Neturon Config-------------------##
#Password for Mysql neutron user. exmaple:$HOST_PASS
NEUTRON_DBPASS=$HOST_PASS

#Password for Keystore neutron user. exmaple:$HOST_PASS
NEUTRON_PASS=$HOST_PASS

#metadata secret for neutron. exmaple:$HOST_PASS
METADATA_SECRET=$HOST_PASS

#Tunnel Network Interface. example:x.x.x.x
INTERFACE_IP=$HOST_IP

#External Network Interface. example:eth1

INTERFACE_NAME=$(ip address | grep mtu | grep "state UP" | awk -F ':' 'NR==2{print $2}' | awk '{print $1}')

#External Network The Physical Adapter. example:provider
Physical_NAME=provider

#First Vlan ID in VLAN RANGE for VLAN Network. exmaple:101
minvlan=2

#Last Vlan ID in VLAN RANGE for VLAN Network. example:200
maxvlan=4094

#--------------------Cinder Config--------------------##
#Password for Mysql cinder user. exmaple:$HOST_PASS
CINDER_DBPASS=$HOST_PASS

#Password for Keystore cinder user. exmaple:$HOST_PASS
CINDER_PASS=$HOST_PASS

#Cinder Block Disk. example:md126p3
BLOCK_DISK=$HOST_DISK_CINDER

#--------------------Swift Config---------------------##
#Password for Keystore swift user. exmaple:$HOST_PASS
SWIFT_PASS=$HOST_PASS

#The NODE Object Disk for Swift. example:md126p4.
OBJECT_DISK=$HOST_DISK_SWIFT

#The NODE IP for Swift Storage Network. example:x.x.x.x.
STORAGE_LOCAL_NET_IP=$HOST_IP

#--------------------Heat Config----------------------##
#Password for Mysql heat user. exmaple:$HOST_PASS
HEAT_DBPASS=$HOST_PASS

#Password for Keystore heat user. exmaple:$HOST_PASS
HEAT_PASS=$HOST_PASS

#--------------------Zun Config-----------------------##
#Password for Mysql Zun user. exmaple:$HOST_PASS
ZUN_DBPASS=$HOST_PASS

#Password for Keystore Zun user. exmaple:$HOST_PASS
ZUN_PASS=$HOST_PASS

#Password for Mysql Kuryr user. exmaple:$HOST_PASS
KURYR_DBPASS=$HOST_PASS

#Password for Keystore Kuryr user. exmaple:$HOST_PASS
KURYR_PASS=$HOST_PASS

#--------------------Ceilometer Config----------------##
#Password for Gnocchi ceilometer user. exmaple:$HOST_PASS
CEILOMETER_DBPASS=$HOST_PASS

#Password for Keystore ceilometer user. exmaple:$HOST_PASS
CEILOMETER_PASS=$HOST_PASS

#--------------------AODH Config----------------##
#Password for Mysql AODH user. exmaple:$HOST_PASS
AODH_DBPASS=$HOST_PASS

#Password for Keystore AODH user. exmaple:$HOST_PASS
AODH_PASS=$HOST_PASS

#--------------------Barbican Config----------------##
#Password for Mysql Barbican user. exmaple:$HOST_PASS
BARBICAN_DBPASS=$HOST_PASS

#Password for Keystore Barbican user. exmaple:$HOST_PASS
BARBICAN_PASS=$HOST_PASS
