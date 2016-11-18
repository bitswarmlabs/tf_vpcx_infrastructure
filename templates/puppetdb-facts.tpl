#!/bin/bash

mkdir -p /etc/facter/facts.d

# Exposing Puppet DB connection infos as facts
cat<<EOF > /etc/facter/facts.d/puppetdb.yaml
---
puppetdb_endpoint: ${puppetdb_endpoint}
puppetdb_host: ${puppetdb_host}
puppetdb_port: ${puppetdb_port}
puppetdb_name: ${puppetdb_name}
puppetdb_user: ${puppetdb_user}
puppetdb_pass: ${puppetdb_pass}

EOF
