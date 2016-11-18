#!/bin/bash

yum_install='yum install -y'

echo "## Installing Puppet (server)"

# configure the puppet package sources
# see: http://docs.puppetlabs.com/guides/puppetlabs_package_repositories.html
rpm -Uvh https://yum.puppetlabs.com/puppetlabs-release-pc1-el-7.noarch.rpm

# install puppetserver
$yum_install puppetserver

echo "## Creating symlink for Puppet binaries in /usr/bin"
for f in $(find /opt/puppetlabs/bin -type l -or -type f); do
ln -svf $(readlink -f "$f") /usr/bin/$(basename "$f")
done

echo "## Activating Puppet Server service"
puppet resource service puppetserver ensure=running enable=true

echo "## Activating Puppet DB service"
puppet resource service puppetdb ensure=running enable=true
