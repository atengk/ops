#!/bin/bash

source /etc/cloudconfig/openrc-ha-info.sh
source /etc/cloudconfig/openrc-ha.sh

for host in $openstack_ceph_cluster_host_name
do
sshpass -p $openstack_cluster_root_password ssh -Tqo StrictHostKeychecking=no root@$host << eeooff
if [[ "$openstack_controller_cluster_host_name" =~ "\$(hostname)" ]]
then
yum install ceph ceph-mon ceph-mgr ceph-mgr-dashboard ceph-radosgw ceph-mds -y
umount /dev/$openstack_ceph_disk &> /dev/null
yum -y install sshpass
for i in $openstack_ceph_cluster_host_name
do
sshpass -p $openstack_cluster_root_password scp -ro StrictHostKeychecking=no /etc/hosts root@\$i:/etc
done

elif [[ "$openstack_compute_cluster_host_name" =~ "\$(hostname)" ]]
then
yum install ceph ceph-mon ceph-mgr ceph-mgr-dashboard ceph-radosgw ceph-mds -y
umount /dev/$openstack_ceph_disk &> /dev/null
yum -y install sshpass
for i in $openstack_ceph_cluster_host_name
do
sshpass -p $openstack_cluster_root_password scp -ro StrictHostKeychecking=no /etc/hosts root@\$i:/etc
done

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
yum install ceph ceph-mon ceph-mgr ceph-mgr-dashboard ceph-radosgw ceph-mds -y
umount /dev/$openstack_ceph_disk &> /dev/null
yum -y install sshpass
for i in $openstack_ceph_cluster_host_name
do
sshpass -p $openstack_cluster_root_password scp -ro StrictHostKeychecking=no /etc/hosts root@\$i:/etc
done
eeooff
done


sshpass -p $openstack_cluster_root_password ssh -Tqo StrictHostKeychecking=no root@$ceph_name1 << eeooff
if [[ "$openstack_controller_cluster_host_name" =~ "\$(hostname)" ]]
then
yum install -y python-setuptools ceph-deploy
mkdir -p /etc/ceph && cd /etc/ceph/
ceph-deploy new  $openstack_controller_cluster_host_name
cat >> /etc/ceph/ceph.conf <<EOF
osd pool default size = 3
public network = $openstack_network_lan
EOF
ceph-deploy mon create-initial
ceph-deploy mgr create $openstack_controller_cluster_host_name
ceph-deploy osd create $controller_name1 --data /dev/$openstack_ceph_disk
ceph-deploy osd create $controller_name2 --data /dev/$openstack_ceph_disk
ceph-deploy osd create $controller_name3 --data /dev/$openstack_ceph_disk
ceph-deploy mds create $openstack_controller_cluster_host_name
sleep 10
echo "# ceph -s"
ceph -s

elif [[ "$openstack_compute_cluster_host_name" =~ "\$(hostname)" ]]
then
yum install -y python-setuptools ceph-deploy
mkdir -p /etc/ceph && cd /etc/ceph/
ceph-deploy new  $openstack_compute_cluster_host_name
cat >> /etc/ceph/ceph.conf <<EOF
osd pool default size = 3
public network = $openstack_network_lan
EOF
ceph-deploy mon create-initial
ceph-deploy mgr create $openstack_compute_cluster_host_name
ceph-deploy osd create $compute_name1 --data /dev/$openstack_ceph_disk
ceph-deploy osd create $compute_name2 --data /dev/$openstack_ceph_disk
ceph-deploy osd create $compute_name3 --data /dev/$openstack_ceph_disk
ceph-deploy mds create $openstack_compute_cluster_host_name
sleep 10
echo "# ceph -s"
ceph -s

else
yum install -y python-setuptools ceph-deploy
mkdir -p /etc/ceph && cd /etc/ceph/
ceph-deploy new  $openstack_ceph_cluster_host_name
cat >> /etc/ceph/ceph.conf <<EOF
osd pool default size = 3
public network = $openstack_network_lan
EOF
ceph-deploy mon create-initial
ceph-deploy mgr create $openstack_ceph_cluster_host_name
ceph-deploy osd create $ceph_name1 --data /dev/$openstack_ceph_disk
ceph-deploy osd create $ceph_name2 --data /dev/$openstack_ceph_disk
ceph-deploy osd create $ceph_name3 --data /dev/$openstack_ceph_disk
ceph-deploy mds create $openstack_ceph_cluster_host_name
sleep 10
echo "# ceph -s"
ceph -s
fi
eeooff
