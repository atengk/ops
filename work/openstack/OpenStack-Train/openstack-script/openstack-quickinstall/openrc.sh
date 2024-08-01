## author:	kongyu
## QQ:		2385569970
## version:	1.1
## date:	2022-05-26

##--------------------system Config--------------------##
##Controller Server Manager IP. example:x.x.x.x
#HOST_IP=

##Controller HOST Password. example:000000 
#HOST_PASS=

##Controller Server hostname. example:controller
#HOST_NAME=

##Compute Node Manager IP. example:x.x.x.x
#HOST_IP_NODE=

##Compute HOST Password. example:000000 
#HOST_PASS_NODE=

##Compute Node hostname. example:compute
#HOST_NAME_NODE=

##--------------------Chrony Config-------------------##
##Controller network segment IP.  example:x.x.0.0/16(x.x.x.0/24)
#network_segment_IP=

##--------------------Rabbit Config ------------------##
##user for rabbit. example:openstack
#RABBIT_USER=

##Password for rabbit user .example:000000
#RABBIT_PASS=

##--------------------MySQL Config---------------------##
##Password for MySQL root user . exmaple:000000
#DB_PASS=

##--------------------Keystone Config------------------##
##Password for Keystore admin user. exmaple:000000
#DOMAIN_NAME=
#ADMIN_PASS=
#DEMO_PASS=

##Password for Mysql keystore user. exmaple:000000
#KEYSTONE_DBPASS=

##--------------------Glance Config--------------------##
##Password for Mysql glance user. exmaple:000000
#GLANCE_DBPASS=

##Password for Keystore glance user. exmaple:000000
#GLANCE_PASS=

##--------------------Nova Config----------------------##
##Password for Mysql nova user. exmaple:000000
#NOVA_DBPASS=

##Password for Keystore nova user. exmaple:000000
#NOVA_PASS=

##--------------------Neturon Config-------------------##
##Password for Mysql neutron user. exmaple:000000
#NEUTRON_DBPASS=

##Password for Keystore neutron user. exmaple:000000
#NEUTRON_PASS=

##metadata secret for neutron. exmaple:000000
#METADATA_SECRET=

##Tunnel Network Interface. example:x.x.x.x
#INTERFACE_IP=

##External Network Interface. example:eth1
#INTERFACE_NAME=

##External Network The Physical Adapter. example:provider
#Physical_NAME=

##First Vlan ID in VLAN RANGE for VLAN Network. exmaple:101
#minvlan=

##Last Vlan ID in VLAN RANGE for VLAN Network. example:200
#maxvlan=

##--------------------Cinder Config--------------------##
##Password for Mysql cinder user. exmaple:000000
#CINDER_DBPASS=

##Password for Keystore cinder user. exmaple:000000
#CINDER_PASS=

##Cinder Block Disk. example:md126p3
#BLOCK_DISK=

##--------------------Swift Config---------------------##
##Password for Keystore swift user. exmaple:000000
#SWIFT_PASS=

##The NODE Object Disk for Swift. example:md126p4.
#OBJECT_DISK=

##The NODE IP for Swift Storage Network. example:x.x.x.x.
#STORAGE_LOCAL_NET_IP=

##--------------------Heat Config----------------------##
##Password for Mysql heat user. exmaple:000000
#HEAT_DBPASS=

##Password for Keystore heat user. exmaple:000000
#HEAT_PASS=

##--------------------Zun Config-----------------------##
##Password for Mysql Zun user. exmaple:000000
#ZUN_DBPASS=

##Password for Keystore Zun user. exmaple:000000
#ZUN_PASS=

##Password for Mysql Kuryr user. exmaple:000000
#KURYR_DBPASS=

##Password for Keystore Kuryr user. exmaple:000000
#KURYR_PASS=

##--------------------Ceilometer Config----------------##
##Password for Gnocchi ceilometer user. exmaple:000000
#CEILOMETER_DBPASS=

##Password for Keystore ceilometer user. exmaple:000000
#CEILOMETER_PASS=

##--------------------AODH Config----------------##
##Password for Mysql AODH user. exmaple:000000
#AODH_DBPASS=

##Password for Keystore AODH user. exmaple:000000
#AODH_PASS=

##--------------------Barbican Config----------------##
##Password for Mysql Barbican user. exmaple:000000
#BARBICAN_DBPASS=

##Password for Keystore Barbican user. exmaple:000000
#BARBICAN_PASS=
