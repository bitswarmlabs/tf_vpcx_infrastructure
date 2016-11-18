#!/bin/bash

mkdir -p /etc/facter/facts.d

# Exposing Rancher DB connection infos as facts
cat<<EOF > /etc/facter/facts.d/rancherdb.yaml
---
rancherdb_endpoint: ${rancherdb_endpoint}
rancherdb_host: ${rancherdb_host}
rancherdb_port: ${rancherdb_port}
rancherdb_name: ${rancherdb_name}
rancherdb_user: ${rancherdb_user}
rancherdb_pass: ${rancherdb_pass}

EOF
