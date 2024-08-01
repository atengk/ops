#!/bin/bash

set -x

rpm -e $(rpm -qa | grep kernel-tools)
yum localinstall -y packages/*.rpm
grub2-set-default 0 && grub2-mkconfig -o /etc/grub2.cfg
grubby --default-kernel
grubby --args="user_namespace.enable=1" --update-kernel="$(grubby --default-kernel)"
#reboot

