#!/bin/bash
export LC_ALL=C
export DEBIAN_FRONTEND=noninteractive
minimal_apt_get_install='apt-get install -y'

os_distro=$(lsb_release -is | tr '[:upper:]' '[:lower:]')
os_release=$(lsb_release -cs)

echo "## OS Distro: $${os_distro}  Release: $${os_release}"

# update the apt cache and packages
case $os_release in
    'precise')
        echo "## Purging apt sources.list"
        mv /etc/apt/sources.list /etc/apt/sources.list.bak
        touch /etc/apt/sources.list
        apt-get update -qy
        mv /etc/apt/sources.list.bak /etc/apt/sources.list
        apt-get update -qy
        echo "## Adding Git PPA for Ubuntu Precise"
        apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys E1DD270288B4E6030699E45FA1715D88E1DF1F24
        echo 'deb http://ppa.launchpad.net/git-core/ppa/ubuntu precise main' | sudo tee /etc/apt/sources.list.d/git.list
    ;;
    'trusty')
        echo "## Purging apt sources.list"
        mv /etc/apt/sources.list /etc/apt/sources.list.bak
        touch /etc/apt/sources.list
        apt-get update -qy
        mv /etc/apt/sources.list.bak /etc/apt/sources.list
        apt-get update -qy
        echo "## Adding Git PPA for Ubuntu Trusty"
        apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys E1DD270288B4E6030699E45FA1715D88E1DF1F24
        echo 'deb http://ppa.launchpad.net/git-core/ppa/ubuntu trusty main' | sudo tee /etc/apt/sources.list.d/git.list
    ;;
    'jessie')
        echo "## Fixing hash sum mismatch issues re https://gist.github.com/trastle/5722089 and \
         http://stackoverflow.com/questions/15505775/debian-apt-packages-hash-sum-mismatch"
        echo 'Acquire::http::Pipeline-Depth "0";' > /etc/apt/apt.conf.d/99fixbadproxy
        echo 'Acquire::http::No-Cache=True;' >>  /etc/apt/apt.conf.d/99fixbadproxy
        echo 'Acquire::BrokenProxy=true;' >>  /etc/apt/apt.conf.d/99fixbadproxy
        rm  -rf /var/lib/apt/lists/*
    ;;
    *)
    ;;
esac

apt-get -qy update

mkdir -p /usr/local/bin
mkdir -p /usr/local/sbin

mkdir -p /root/.ssh
chmod 700 /root/.ssh

echo "## Installing minimal dependencies"
[[ `which curl` ]] || $minimal_apt_get_install curl
[[ `which wget` ]] || $minimal_apt_get_install wget

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

cd /tmp

# configure the puppet package sources
# see: http://docs.puppetlabs.com/guides/puppetlabs_package_repositories.html
wget https://apt.puppetlabs.com/puppetlabs-release-pc1-$os_release.deb
dpkg -i puppetlabs-release-pc1-$os_release.deb
apt-get -q update

# install puppet
$minimal_apt_get_install puppet-agent

echo "## Creating symlink for Puppet binaries in /usr/bin"
for f in $(find /opt/puppetlabs/bin -type l -or -type f); do
  ln -svf $(readlink -f "$f") /usr/bin/$(basename "$f")
done

echo "## Puppet executable $(which puppet) version $(puppet --version)"

echo "## Activating Puppet Agent service"
puppet resource service puppet ensure=running enable=true