#!/bin/bash
# Script to register with redhat and enable the packages required to install openshift on bastion machine.


# Unregister with softlayer subscription
# subscription-manager unregister

# rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-redhat-release

# username=$1
# password=$2
# #orgid=$1
# #key=$2
# poolID=$3

# subscription-manager register --serverurl subscription.rhsm.redhat.com:443/subscription --baseurl cdn.redhat.com --username $username --password $password
# #subscription-manager register --serverurl subscription.rhsm.redhat.com:443/subscription --baseurl cdn.redhat.com --org 7869572 --activationkey Test


# subscription-manager refresh

# sed -i 's/%(ca_cert_dir)skatello-server-ca.pem/%(ca_cert_dir)sredhat-uep.pem/g' /etc/rhsm/rhsm.conf

# subscription-manager attach --pool=$poolID

# subscription-manager repos --disable="*"

# #yum-config-manager --disable \*


# subscription-manager repos --enable="rhel-7-server-rpms"  --enable="rhel-7-server-extras-rpms"  --enable="rhel-7-server-ose-3.11-rpms" --enable="rhel-7-server-ansible-2.6-rpms" --enable="rhel-7-server-optional-rpms"


### The following has been moved to bastion_install_ansible.sh
#
########## Install OCP and its prerequisits
#
#yum clean all
#
#yum install -y wget git net-tools bind-utils yum-utils iptables-services bridge-utils bash-completion kexec-tools sos psacct
#
#yum install -y vim 
#
#yum install -y tmux
#
#yum update -y 
#
#yum install -y  openshift-ansible
#
####### Define the bastian as Gateway for all other nodes (disabled by Red Hat):
#
##sysctl net.ipv4.ip_forward=1
#

# Set parameter for constructing yum repo file usage.
path_to_ansible_rpms_at_media_server=$1
path_to_ose_rpms_at_media_server=$2

sed -i "s/^PasswordAuthentication yes$/PasswordAuthentication no/" /etc/ssh/sshd_config
cat <<EOL | tee -a /etc/ssh/sshd_config

Match Address 10.0.0.0/8,172.16.0.0/12,192.168.0.0/16
    PasswordAuthentication yes
EOL
systemctl restart sshd


echo "=================================================="
echo "= Continue of setup_repo.sh"
echo "= Disable password authentication on public network "
echo "=================================================="


# Use $1 variable here
cat > /etc/yum.repos.d/ose.repo <<EOL
[rhel-7-server-ansible-2.6-rpms]
name=rhel-7-server-ansible-2.6-rpms
baseurl=$path_to_ansible_rpms_at_media_server
enabled=1
gpgcheck=0
[rhel-7-server-ose-3.11-rpms]
name=rhel-7-server-ose-3.11-rpms
baseurl=$path_to_ose_rpms_at_media_server
enabled=1
gpgcheck=0

EOL

echo "=================================================="
echo "= Continue of setup_repo.sh"
echo "= Setup require rpms on local network "
echo "=================================================="

# For subscription manager to enable extra repo, which is disable by default
# https://docs.openshift.com/container-platform/3.11/install/disconnected_install.html

 subscription-manager repos \
    --enable="rhel-7-server-rpms" \
    --enable="rhel-7-server-extras-rpms" \
    --enable="rhel-7-server-ose-3.11-rpms" \
    --enable="rhel-7-server-ansible-2.6-rpms"

echo "=================================================="
echo "= Continue of setup_repo.sh"
echo "= Setup require rpms on local network "
echo "=================================================="


echo "vm.max_map_count=1048576" | sudo tee /etc/sysctl.d/90-icp.conf
echo "net.ipv4.ip_local_port_range=10240 60999" | sudo tee -a /etc/sysctl.d/90-icp.conf
sudo sysctl -p /etc/sysctl.d/90-icp.conf



echo "=================================================="
echo "= Start of icp_prep.sh"
echo "= Changed vm_max_map_count to max = 1048576 "
echo "=================================================="


#--- edit the manage_etc_host setting to be False
cat /etc/cloud/cloud.cfg
sudo sed -i -e 's/manage_etc_hosts: True/manage_etc_hosts: False/g' /etc/cloud/cloud.cfg

echo "=================================================="
echo "= Modified manage_etc_hosts in /etc/cloud/cloud.cfg "
echo "=================================================="

sed -i 's/^SELINUX=.*/SELINUX=enforcing/' /etc/selinux/config
setenforce 1

echo "=================================================="
echo "= Set selinux to be enforcing "
echo "=================================================="


cat /etc/sysconfig/network-scripts/ifcfg-eth0
sed -i 's/^NM_CONTROLLED=no//' /etc/sysconfig/network-scripts/ifcfg-eth0
sed -i 's/^BOOTPROTO=none/BOOTPROTO=static/' /etc/sysconfig/network-scripts/ifcfg-eth0
sed -i 's/^TYPE=Ethernet//' /etc/sysconfig/network-scripts/ifcfg-eth0
sed -i 's/^USERCTL=no//' /etc/sysconfig/network-scripts/ifcfg-eth0
cat /etc/sysconfig/network-scripts/ifcfg-eth0


cat /etc/sysconfig/network-scripts/ifcfg-eth1
sed -i 's/^BOOTPROTO=none/BOOTPROTO=static/' /etc/sysconfig/network-scripts/ifcfg-eth1
sed -i 's/^NM_CONTROLLED=no//' /etc/sysconfig/network-scripts/ifcfg-eth1
sed -i 's/^TYPE=Ethernet//' /etc/sysconfig/network-scripts/ifcfg-eth1
sed -i 's/^USERCTL=no//' /etc/sysconfig/network-scripts/ifcfg-eth1
sed -i 's/^DEFROUTE=yes//' /etc/sysconfig/network-scripts/ifcfg-eth1
cat /etc/sysconfig/network-scripts/ifcfg-eth1

echo "=================================================="
echo "= Check and replace the NM_CONTROLLED proeprties "
echo "= See more from https://access.redhat.com/solutions/44839 "
echo "=================================================="


