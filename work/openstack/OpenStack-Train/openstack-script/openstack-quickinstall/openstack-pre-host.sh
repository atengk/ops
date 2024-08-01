#!/bin/bash
set -x

## 获取主机信息
source /etc/cloudconfig/openrc.sh

## 关闭selinux firewalld
sed -i 's/SELINUX=.*/SELINUX=disabled/g' /etc/selinux/config
setenforce 0
systemctl stop firewalld
systemctl disable firewalld

## 关闭NetworkManager
systemctl stop NetworkManager
systemctl disable NetworkManager
yum remove -y NetworkManager firewalld
systemctl restart network

## 关闭iptables
yum install  iptables-services  -y 
if [ 0  -ne  $? ]; then
	echo -e "\033[31mThe installation source configuration errors\033[0m"
	exit 1
fi
systemctl restart iptables
iptables -F
iptables -X
iptables -Z 
/usr/sbin/iptables-save
systemctl stop iptables
systemctl disable iptables

## 安装OpenStack基础包 
sed -i -e 's/#UseDNS yes/UseDNS no/g' \
    -e 's/GSSAPIAuthentication yes/GSSAPIAuthentication no/g' \
    /etc/ssh/sshd_config
sed -i 's/#   StrictHostKeyChecking ask/   StrictHostKeyChecking no/g' /etc/ssh/ssh_config
systemctl restart sshd
yum upgrade -y
yum install python-openstackclient openstack-selinux openstack-utils crudini expect net-tools -y

## 配置主机名和hosts
if [[ `ip a |grep -w $HOST_IP ` != '' ]];then 
    hostnamectl set-hostname $HOST_NAME
elif [[ `ip a |grep -w $HOST_IP_NODE ` != '' ]];then 
    hostnamectl set-hostname $HOST_NAME_NODE
else
    hostnamectl set-hostname $HOST_NAME
fi
sed -i -e "/$HOST_NAME/d" -e "/$HOST_NAME_NODE/d" /etc/hosts
echo "$HOST_IP $HOST_NAME" >> /etc/hosts
echo "$HOST_IP_NODE $HOST_NAME_NODE" >> /etc/hosts

## 配置ssh免秘钥
if [[ ! -s ~/.ssh/id_rsa.pub ]];then
	ssh-keygen -t rsa -P "" -f ~/.ssh/id_rsa -C "2385569970@qq.com"
fi
name=`hostname`
if [[ $name == $HOST_NAME ]];then
expect -c "set timeout -1;
               spawn ssh-copy-id  -i /root/.ssh/id_rsa $HOST_NAME_NODE;
               expect {
                   *password:* {send -- $HOST_PASS_NODE\r;
                        expect {
                            *denied* {exit 2;}
                            eof}
                    }
                   *(yes/no)* {send -- yes\r;exp_continue;}
                   eof         {exit 1;}
               }
               "
else
expect -c "set timeout -1;
               spawn ssh-copy-id  -i /root/.ssh/id_rsa $HOST_NAME;
               expect {
                   *password:* {send -- $HOST_PASS\r;
                        expect {
                            *denied* {exit 2;}
                            eof}
                    }
                   *(yes/no)* {send -- yes\r;exp_continue;}
                   eof         {exit 1;}
               }
               "
fi

## 配置chrony时间同步
yum install -y chrony
if [[ $name == $HOST_NAME ]];then
        sed -i '3,6s/^/#/g' /etc/chrony.conf
        sed -i '7s/^/server controller iburst/g' /etc/chrony.conf
        echo "allow $network_segment_IP" >> /etc/chrony.conf
        echo "local stratum 10" >> /etc/chrony.conf
else
        sed -i '3,6s/^/#/g' /etc/chrony.conf
        sed -i '7s/^/server controller iburst/g' /etc/chrony.conf
fi

systemctl restart chronyd
systemctl enable chronyd

## 配置时区
yum -y install ntpdate
timedatectl set-timezone Asia/Shanghai
ntpdate -u ntp.api.bz &> /dev/null
hwclock --systohc
timedatectl set-local-rtc 1

## 配置ulimit
cat << EOF > /etc/security/limits.conf
root soft nofile 655360
root hard nofile 655360
root soft nproc 655360
root hard nproc 655360
root soft core unlimited
root hard core unlimited

* soft nofile 655360
* hard nofile 655360
* soft nproc 655360
* hard nproc 655360
* soft core unlimited
* hard core unlimited
EOF
sed -i 's#4096#655360#g' /etc/security/limits.d/20-nproc.conf
cat << EOF >> /etc/systemd/system.conf
DefaultLimitCORE=infinity
DefaultLimitNOFILE=655360
DefaultLimitNPROC=655360
DefaultTasksMax=75%
EOF

## history相关配置
cat <<EOF >>/etc/bashrc
# history actions record，include action time, user, login ip
HISTFILESIZE=100000
HISTSIZE=100000
USER_IP=\$(who -u am i 2>/dev/null | awk '{print \$NF}' | sed -e 's/[()]//g')
if [ -z \$USER_IP ]
then
  USER_IP=\$(hostname -i)
fi
HISTTIMEFORMAT="%Y-%m-%d %H:%M:%S \$USER_IP:\$(whoami) "
HISTFILE=~/.bash_history
shopt -s histappend
PROMPT_COMMAND="history -a"
export HISTFILESIZE HISTSIZE HISTTIMEFORMAT HISTFILE PROMPT_COMMAND

# PS1
PS1='\[\033[0m\]\[\033[1;36m\][\u\[\033[0m\]@\[\033[1;32m\]\h\[\033[0m\] \[\033[1;31m\]\W\[\033[0m\]\[\033[1;36m\]]\[\033[33;1m\]\\$ \[\033[0m\]'
EOF


## 配置DNS
if [[ $name == $HOST_NAME ]];then
yum install bind -y
sed -i -e '13,14s/^/\/\//g' \
-e '19s/^/\/\//g' \
-e '37,42s/^/\/\//g' \
-e 's/recursion yes/recursion no/g' \
-e 's/dnssec-enable yes/dnssec-enable no/g' \
-e 's/dnssec-validation yes/dnssec-validation no/g' /etc/named.conf 
systemctl start named.service
systemctl enable named.service
fi
printf "\033[35mPlease Reboot or Reconnect the terminal\n\033[0m"
