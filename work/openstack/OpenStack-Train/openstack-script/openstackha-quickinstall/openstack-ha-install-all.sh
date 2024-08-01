#!/bin/bash

start_time=$(date +%s)

/usr/local/bin/openstack-ha-pre-host.sh
echo -e "\033[1;34mOpenStack高可用-基础环境安装完毕！ \n\033[0m"
sleep 30

/usr/local/bin/openstack-ha-install-keystone.sh
echo -e "\033[1;34mOpenStack高可用-Keystone安装完毕！ \n\033[0m"
sleep 30

/usr/local/bin/openstack-ha-install-glance.sh
echo -e "\033[1;34mOpenStack高可用-Glance安装完毕！ \n\033[0m"
sleep 30

/usr/local/bin/openstack-ha-install-nova.sh
echo -e "\033[1;34mOpenStack高可用-Nova安装完毕！ \n\033[0m"
sleep 30

/usr/local/bin/openstack-ha-install-neutron.sh
echo -e "\033[1;34mOpenStack高可用-Neutron安装完毕！ \n\033[0m"
sleep 30

/usr/local/bin/openstack-ha-install-dashboard.sh
echo -e "\033[1;34mOpenStack高可用-Dashboard安装完毕！ \n\033[0m"
sleep 30

/usr/local/bin/openstack-ha-install-cinder.sh
echo -e "\033[1;34mOpenStack高可用-Cinder安装完毕！ \n\033[0m"
sleep 30

/usr/local/bin/openstack-ha-install-ceph.sh
echo -e "\033[1;34mCeph集群安装完毕！ \n\033[0m"
sleep 30

/usr/local/bin/openstack-ha-ceph-openstack.sh
echo -e "\033[1;34mOpenStack高可用集成Ceph完毕！ \n\033[0m"


end_time=$(date +%s)
cost_time=$[ $end_time-$start_time ]
printf "\033[1;35m\n脚本运行总时间：$(($cost_time/60)) min $(($cost_time%60)) s\n\n\033[0m"