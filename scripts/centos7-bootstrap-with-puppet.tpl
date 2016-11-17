#!/bin/bash


echo "## Setting hostname to ${hostname}.${domain}"
DOMAIN=${domain}
HOSTNAME=${hostname}

[[ `which curl` ]] || yum install -y curl
IPV4=`curl -s http://169.254.169.254/latest/meta-data/private-ipv4`

# Set the host name
hostname $HOSTNAME
echo $HOSTNAME > /etc/hostname

[[ -e /etc/hosts.orig ]] || cp -f /etc/hosts /etc/hosts.orig

# Add fqdn to hosts file
cat<<EOF > /etc/hosts
##
# Host Database
#
# localhost is used to configure the loopback interface
# when the system is booting.  Do not change this entry.
##
127.0.0.1 localhost
$IPV4 $HOSTNAME

# The following lines are desirable for IPv6 capable hosts

::1 ip6-localhost ip6-loopback
fe00::0 ip6-localnet
ff00::0 ip6-mcastprefix
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters
ff02::3 ip6-allhosts
EOF

echo "## Installing Puppet Agent"
rpm -Uvh https://yum.puppetlabs.com/puppetlabs-release-pc1-el-7.noarch.rpm
yum install -y puppet-agent

/opt/puppetlabs/bin/puppet resource service puppet ensure=running enable=true