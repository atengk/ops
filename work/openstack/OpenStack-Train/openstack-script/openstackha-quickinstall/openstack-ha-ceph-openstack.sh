#!/bin/bash

source /etc/cloudconfig/openrc-ha-info.sh
source /etc/cloudconfig/openrc-ha.sh

for host in $openstack_controller_cluster_host_name
do
sshpass -p $openstack_cluster_root_password ssh -Tqo StrictHostKeychecking=no root@$host << eeooff
yum install -y python-rbd
eeooff
done


for host in $openstack_compute_cluster_host_name
do
sshpass -p $openstack_cluster_root_password ssh -Tqo StrictHostKeychecking=no root@$host << eeooff
yum install -y ceph-common 
eeooff
done

sshpass -p $openstack_cluster_root_password ssh -Tqo StrictHostKeychecking=no root@$ceph_name1 << eeooff
ceph osd pool create images 64
ceph osd pool create vms 64
ceph osd pool create volumes 64
ceph osd pool application enable images rbd
ceph osd pool application enable volumes rbd
ceph osd pool application enable vms rbd

cd /etc/ceph/
ceph-deploy admin $openstack_controller_cluster_host_name $openstack_compute_cluster_host_name
ceph auth get-or-create client.glance mon 'allow r' osd \
    'allow class-read object_prefix rbd_children, allow rwx pool=images'
ceph auth get-or-create client.cinder mon 'allow r' osd \
    'allow class-read object_prefix rbd_children, allow rwx pool=volumes, allow rwx pool=vms, allow rx pool=images' 
ceph auth get-or-create client.glance > /etc/ceph/ceph.client.glance.keyring
ceph auth get-or-create client.cinder > /etc/ceph/ceph.client.cinder.keyring
ceph auth get-key client.cinder > /etc/ceph/client.cinder.key
eeooff

for host in $openstack_controller_cluster_host_name
do
sshpass -p $openstack_cluster_root_password scp -ro StrictHostKeychecking=no $ceph_name1:/etc/ceph/ceph.client.glance.keyring $host:/etc/ceph
sshpass -p $openstack_cluster_root_password ssh -Tqo StrictHostKeychecking=no root@$host << eeooff
chown glance:glance /etc/ceph/ceph.client.glance.keyring
eeooff
done


for host in $openstack_compute_cluster_host_name
do
sshpass -p $openstack_cluster_root_password scp -ro StrictHostKeychecking=no $ceph_name1:/etc/ceph/ceph.client.cinder.keyring $host:/etc/ceph
sshpass -p $openstack_cluster_root_password scp -ro StrictHostKeychecking=no $ceph_name1:/etc/ceph/client.cinder.key $host:/etc/ceph
sshpass -p $openstack_cluster_root_password ssh -Tqo StrictHostKeychecking=no root@$host << eeooff
chown cinder:cinder /etc/ceph/ceph.client.cinder.keyring

cat > /etc/ceph/secret.xml <<EOF
<secret ephemeral='no' private='no'>
  <uuid>dfb11839-3d7c-4022-ad4c-7961172cc562</uuid>
  <usage type='ceph'>
    <name>client.cinder secret</name>
  </usage>
</secret>
EOF
virsh secret-define --file /etc/ceph/secret.xml
virsh secret-set-value --secret dfb11839-3d7c-4022-ad4c-7961172cc562 --base64 \$(cat /etc/ceph/client.cinder.key)
eeooff
done


for host in $openstack_controller_cluster_host_name
do
sshpass -p $openstack_cluster_root_password ssh -Tqo StrictHostKeychecking=no root@$host << eeooff
crudini --set /etc/glance/glance-api.conf DEFAULT default_store rbd
crudini --set /etc/glance/glance-api.conf DEFAULT show_image_direct_url True
crudini --set /etc/glance/glance-api.conf glance_store stores rbd
crudini --set /etc/glance/glance-api.conf glance_store default_store rbd
crudini --set /etc/glance/glance-api.conf glance_store rbd_store_pool images
crudini --set /etc/glance/glance-api.conf glance_store rbd_store_user glance
crudini --set /etc/glance/glance-api.conf glance_store rbd_store_ceph_conf /etc/ceph/ceph.conf
crudini --set /etc/glance/glance-api.conf glance_store rbd_store_chunk_size 8
sed -i "/^filesystem_store_datadir/d" /etc/glance/glance-api.conf
openstack-service restart glance
eeooff
done


for host in $openstack_compute_cluster_host_name
do
sshpass -p $openstack_cluster_root_password ssh -Tqo StrictHostKeychecking=no root@$host << eeooff
net1=\$(ip address | grep mtu | grep "state UP" | awk -F ':' 'NR==1{print \$2}')
ipaddress1=\$(ip a | grep \$net1 | grep -w inet | awk '{print \$2}' | awk -F '/' '{print \$1}' | head -n 1)
crudini --set /etc/nova/nova.conf libvirt images_type rbd
crudini --set /etc/nova/nova.conf libvirt images_rbd_pool vms
crudini --set /etc/nova/nova.conf libvirt images_rbd_ceph_conf /etc/ceph/ceph.conf
crudini --set /etc/nova/nova.conf libvirt rbd_user cinder
crudini --set /etc/nova/nova.conf libvirt rbd_secret_uuid dfb11839-3d7c-4022-ad4c-7961172cc562
crudini --set /etc/nova/nova.conf libvirt libvirt_disk_cachemodes \"network=writeback\"
crudini --set /etc/nova/nova.conf libvirt libvirt_live_migration_flag \"VIR_MIGRATE_UNDEFINE_SOURCE,VIR_MIGRATE_PEER2PEER,VIR_MIGRATE_LIVE,VIR_MIGRATE_PERSIST_DEST,VIR_MIGRATE_TUNNELLED\"
crudini --set /etc/nova/nova.conf libvirt libvirt_inject_password false
crudini --set /etc/nova/nova.conf libvirt libvirt_inject_key false
crudini --set /etc/nova/nova.conf libvirt libvirt_inject_partition -2
crudini --set /etc/nova/nova.conf libvirt hw_disk_discard unmap
sed -i 's/#listen_tls = 0/listen_tls = 0/g' /etc/libvirt/libvirtd.conf
sed -i 's/#listen_tcp = 1/listen_tcp = 1/g' /etc/libvirt/libvirtd.conf
sed -i 's/#tcp_port = "16509"/tcp_port = \"16509\"/g' /etc/libvirt/libvirtd.conf
sed -i "s/#listen_addr = .*/listen_addr = '\$ipaddress1'/g" /etc/libvirt/libvirtd.conf
sed -i 's/#auth_tcp = "sasl"/auth_tcp = \"none\"/g' /etc/libvirt/libvirtd.conf
sed -i 's/#LIBVIRTD_ARGS="--listen"/LIBVIRTD_ARGS="--listen"/g' /etc/sysconfig/libvirtd
systemctl restart libvirtd
openstack-service restart nova

crudini --set /etc/cinder/cinder.conf DEFAULT enabled_backends ceph
crudini --set /etc/cinder/cinder.conf ceph volume_driver cinder.volume.drivers.rbd.RBDDriver
crudini --set /etc/cinder/cinder.conf ceph rbd_pool volumes
crudini --set /etc/cinder/cinder.conf ceph rbd_ceph_conf /etc/ceph/ceph.conf
crudini --set /etc/cinder/cinder.conf ceph rbd_flatten_volume_from_snapshot false
crudini --set /etc/cinder/cinder.conf ceph rbd_max_clone_depth 5
crudini --set /etc/cinder/cinder.conf ceph rbd_store_chunk_size 4
crudini --set /etc/cinder/cinder.conf ceph rados_connect_timeout -1
crudini --set /etc/cinder/cinder.conf ceph glance_api_version 2
crudini --set /etc/cinder/cinder.conf ceph rbd_user cinder
crudini --set /etc/cinder/cinder.conf ceph rbd_secret_uuid dfb11839-3d7c-4022-ad4c-7961172cc562
crudini --set /etc/cinder/cinder.conf ceph volume_backend_name ceph
openstack-service restart cinder
eeooff
done


sshpass -p $openstack_cluster_root_password ssh -Tqo StrictHostKeychecking=no root@$controller_ip1 << eeooff
source /etc/profile
qemu-img convert -f qcow2 -O raw /opt/openstack/images/cirros.img /opt/openstack/images/cirros.raw
qemu-img convert -f qcow2 -O raw /opt/openstack/images/CentOS-7.5-1804-x86_64.qcow2 /opt/openstack/images/CentOS-7.5-1804-x86_64.raw
glance image-create --name cirros --disk-format raw --container-format bare --file /opt/openstack/images/cirros.raw --progress
sleep 10
echo

openstack quota set --cores 1000 --instances 1000 --networks 1000 --ram 1024000 --secgroups 1000 --subnets 1000 --floating-ips 1000 admin
openstack quota set --volumes 1000 --gigabytes 10240 admin

cinder create --name test 10
sleep 3

echo
echo "# openstack image list"
openstack image list
echo
echo "# openstack volume list"
openstack volume list
eeooff

sshpass -p $openstack_cluster_root_password ssh -Tqo StrictHostKeychecking=no root@$ceph_ip1 << eeooff
echo
echo "# ceph df"
ceph df
eeooff

sshpass -p $openstack_cluster_root_password ssh -Tqo StrictHostKeychecking=no root@$controller_ip1 << eeooff
echo -e "\033[1;34m\n浏览器访问OpenStack Dashboard：http://$openstack_cluster_vip/dashboard \n\033[0m"
eeooff