#!/bin/bash
yum_install='yum install -y'

mkdir -p /usr/local/bin
mkdir -p /usr/local/sbin

mkdir -p /root/.ssh
chmod 700 /root/.ssh

echo "## Installing minimal dependencies"
[[ `which curl` ]] || $yum_install curl
[[ `which wget` ]] || $yum_install wget

echo "## Setting hostname to ${hostname}.${domain}"
DOMAIN='${domain}'
HOSTNAME='${hostname}'

IPV4=$(curl -s http://169.254.169.254/latest/meta-data/private-ipv4)
if [[ $? ]]; then
  IPV4='127.0.0.1'
fi

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

echo "## Installing Puppet (agent)"

# configure the puppet package sources
# see: http://docs.puppetlabs.com/guides/puppetlabs_package_repositories.html
rpm -Uvh https://yum.puppetlabs.com/puppetlabs-release-pc1-el-7.noarch.rpm

# install puppet
$yum_install puppet-agent

echo "## Creating symlink for Puppet binaries in /usr/bin"
for f in $(find /opt/puppetlabs/bin -type l -or -type f); do
ln -svf $(readlink -f "$f") /usr/bin/$(basename "$f")
done

echo "## Puppet executable $(which puppet) version $(puppet --version)"

echo "## Activating Puppet Agent service"
puppet resource service puppet ensure=running enable=true