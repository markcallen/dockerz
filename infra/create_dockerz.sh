#!/bin/bash
#
#

set -e

export Z_REGION=a
export Z_NETWORK=dockerz
export Z_DOMAIN=dockerz.ooo

if [ "$*" == "" ]; then
    echo "Need an arguement of plan, apply or destory"
    exit 1
fi

path_to_terraform=$(which terraform)
if [ ! -x "$path_to_terraform" ] ; then
   echo "Can't find terraform, check that its in your path"
   exit 1;
fi

path_to_aws=$(which aws)
if [ ! -x "$path_to_aws" ] ; then
   echo "Can't find aws cli, check that its in your path"
   exit 1;
fi

: ${AWS_ACCESS_KEY_ID:?"Need to set AWS_ACCESS_KEY_ID"}
: ${AWS_SECRET_ACCESS_KEY:?"Need to set AWS_SECRET_ACCESS_KEY"}
: ${AWS_DEFAULT_REGION:?"Need to set AWS_DEFAULT_REGION"}
: ${AWS_SSH_KEY_ID:?"Need to set AWS_SSH_KEY_ID"}
: ${AWS_SSH_KEY:?"Need to set AWS_SSH_KEY"}

if [ -d ../flocker-openssl ]; then
  pushd ../flocker-openssl && git pull && popd
else
  pushd .. && git clone https://github.com/ClusterHQ/flocker-openssl && popd
fi

cat > agent.yml <<EOL
"version": 1
"control-service":
   "hostname": "flocker-control.${Z_NETWORK}.${Z_REGION}.${Z_DOMAIN}"
   "port": 4524

# The dataset key below selects and configures a dataset backend (see below: aws/openstack/etc).
# All nodes will be configured to use only one backend

dataset:
   backend: "aws"
   region: "${AWS_DEFAULT_REGION}"
   zone: "${AWS_DEFAULT_REGION}a"
   access_key_id: "${AWS_ACCESS_KEY_ID}"
   secret_access_key: "${AWS_SECRET_ACCESS_KEY}"
EOL

if [ $1 == "apply" ]; then
  OLDPATH=$PATH
  # TODO: Fix the problem with readlink -f not working on osx and needing to using coreutils version instead
  PATH="/usr/local/opt/coreutils/libexec/gnubin:$PATH"
  # TODO: create -n dynamically
  if [ ! -d ../flocker-openssl/clusters/${Z_NETWORK}.${Z_REGION}.${Z_DOMAIN} ]; then
    pushd ../flocker-openssl && ./generate_flocker_certs.sh new -d=flocker-control.${Z_NETWORK}.${Z_REGION}.${Z_DOMAIN} -c=${Z_NETWORK}.${Z_REGION}.${Z_DOMAIN} -n=swarm-manager-0,swarm-manager-1,swarm-manager-2,swarm-node-0,swarm-node-1,swarm-node-2 && popd
  fi
  PATH=$OLDPATH
fi

CA_CENTRAL1_AMI=$(aws ec2 describe-images --owners self --filters "Name=name,Values=dockerz*" --query 'Images[*].[ImageId,Name,CreationDate]' --output text | sort -k 3 -r | head -1 | awk '{print $1'})

Z_ZONE_QUERY='HostedZones[?ends_with(`'"$Z_DOMAIN."'`,Name)].Id'
Z_ZONE_ID=$(aws route53 list-hosted-zones --query $Z_ZONE_QUERY --output text)

terraform $1 -var aws_region=${AWS_DEFAULT_REGION} \
             -var 'amis={ ca-central-1 = "'${CA_CENTRAL1_AMI}'" }' \
             -var ssh_key_name=${AWS_SSH_KEY_ID} \
             -var ssh_key_filename=${AWS_SSH_KEY} \
             -var z_region=${Z_REGION} \
             -var z_domain=${Z_DOMAIN} \
             -var z_zone_id=${Z_ZONE_ID} \
             -var vpc_key=dockerz \
	     -var cluster_manager_count=1 \
	     -var cluster_node_count=2 \
	     -var cluster_control_count=1
