# author:	kongyu
# QQ:		2385569970
# version:	1.1
# date:	2022-05-26

#--------------------system Config--------------------##
#Controller Server Manager IP. example:x.x.x.x
HOST_IP=192.168.1.201

#Controller HOST Password. example:Admin@123 
HOST_PASS=Admin@123

#Controller Server hostname. example:controller
HOST_NAME=controller

#Compute Node Manager IP. example:x.x.x.x
HOST_IP_NODE=192.168.1.202

#Compute HOST Password. example:Admin@123 
HOST_PASS_NODE=Admin@123

#Compute Node hostname. example:compute
HOST_NAME_NODE=compute01

#--------------------Chrony Config-------------------##
#Controller network segment IP.  example:x.x.0.0/16(x.x.x.0/24)
network_segment_IP=192.168.1.0/24

#--------------------Rabbit Config ------------------##
#user for rabbit. example:openstack
RABBIT_USER=openstack

#Password for rabbit user .example:Admin@123
RABBIT_PASS=Admin@123

#--------------------MySQL Config---------------------##
#Password for MySQL root user . exmaple:Admin@123
DB_PASS=Admin@123

#--------------------Keystone Config------------------##
#Password for Keystore admin user. exmaple:Admin@123
DOMAIN_NAME=Default
ADMIN_PASS=Admin@123
DEMO_PASS=Admin@123

#Password for Mysql keystore user. exmaple:Admin@123
KEYSTONE_DBPASS=Admin@123

#--------------------Glance Config--------------------##
#Password for Mysql glance user. exmaple:Admin@123
GLANCE_DBPASS=Admin@123

#Password for Keystore glance user. exmaple:Admin@123
GLANCE_PASS=Admin@123

#--------------------Nova Config----------------------##
#Password for Mysql nova user. exmaple:Admin@123
NOVA_DBPASS=Admin@123

#Password for Keystore nova user. exmaple:Admin@123
NOVA_PASS=Admin@123

#--------------------Neturon Config-------------------##
#Password for Mysql neutron user. exmaple:Admin@123
NEUTRON_DBPASS=Admin@123

#Password for Keystore neutron user. exmaple:Admin@123
NEUTRON_PASS=Admin@123

#metadata secret for neutron. exmaple:Admin@123
METADATA_SECRET=Admin@123

#Tunnel Network Interface. example:x.x.x.x
INTERFACE_IP=192.168.1.201

#External Network Interface. example:eth1
INTERFACE_NAME=ens33

#External Network The Physical Adapter. example:provider
Physical_NAME=provider

#First Vlan ID in VLAN RANGE for VLAN Network. exmaple:101
minvlan=2

#Last Vlan ID in VLAN RANGE for VLAN Network. example:200
maxvlan=4094

#--------------------Cinder Config--------------------##
#Password for Mysql cinder user. exmaple:Admin@123
CINDER_DBPASS=Admin@123

#Password for Keystore cinder user. exmaple:Admin@123
CINDER_PASS=Admin@123

#Cinder Block Disk. example:md126p3
BLOCK_DISK=sdb1

#--------------------Swift Config---------------------##
#Password for Keystore swift user. exmaple:Admin@123
SWIFT_PASS=Admin@123

#The NODE Object Disk for Swift. example:md126p4.
OBJECT_DISK=sdb2

#The NODE IP for Swift Storage Network. example:x.x.x.x.
STORAGE_LOCAL_NET_IP=192.168.1.202

#--------------------Heat Config----------------------##
#Password for Mysql heat user. exmaple:Admin@123
HEAT_DBPASS=Admin@123

#Password for Keystore heat user. exmaple:Admin@123
HEAT_PASS=Admin@123

#--------------------Zun Config-----------------------##
#Password for Mysql Zun user. exmaple:Admin@123
ZUN_DBPASS=Admin@123

#Password for Keystore Zun user. exmaple:Admin@123
ZUN_PASS=Admin@123

#Password for Mysql Kuryr user. exmaple:Admin@123
KURYR_DBPASS=Admin@123

#Password for Keystore Kuryr user. exmaple:Admin@123
KURYR_PASS=Admin@123

#--------------------Ceilometer Config----------------##
#Password for Gnocchi ceilometer user. exmaple:Admin@123
CEILOMETER_DBPASS=Admin@123

#Password for Keystore ceilometer user. exmaple:Admin@123
CEILOMETER_PASS=Admin@123

#--------------------AODH Config----------------##
#Password for Mysql AODH user. exmaple:Admin@123
AODH_DBPASS=Admin@123

#Password for Keystore AODH user. exmaple:Admin@123
AODH_PASS=Admin@123

#--------------------Barbican Config----------------##
#Password for Mysql Barbican user. exmaple:Admin@123
BARBICAN_DBPASS=Admin@123

#Password for Keystore Barbican user. exmaple:Admin@123
BARBICAN_PASS=Admin@123
