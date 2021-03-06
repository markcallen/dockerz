#!/bin/bash
#
# Create dockerz environment
#
# https://github.com/markcallen/dockerz
#
# License & Authors
#
# Author:: Mark Allen (mark@markcallen.com)
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

set -e

while getopts r:n:d: option
do
  case "${option}"
  in
    r) Z_REGION=${OPTARG};;
    n) Z_NETWORK=${OPTARG};;
    d) Z_DOMAIN=${OPTARG};;
  esac
done

: ${Z_REGION:?"Need a region"}
: ${Z_NETWORK:?"Need a network"}
: ${Z_DOMAIN:?"Need a domain"}

ACTION=${@: -1}

if [ "$ACTION" != "show" ] && [ "$ACTION" != "plan" ] && [ "$ACTION" != "apply" ] && [ "$ACTION" != "destroy" ] && [ "$ACTION" != "createcert" ]; then
    echo "Need an arguement of plan, apply, destory or createcert"
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

Z_ZONE_QUERY='HostedZones[?ends_with(`'"$Z_DOMAIN."'`,Name)].Id'
Z_ZONE_ID=$(aws route53 list-hosted-zones --query $Z_ZONE_QUERY --output text)

if [ -z ${Z_ZONE_ID} ]; then
  echo "Can't find hosted zone for ${Z_DOMAIN}"
  exit 1;
fi

STATE=${Z_NETWORK}-${Z_REGION}.${Z_DOMAIN}.tfstate

if [ "$ACTION" == "createcert" ]; then
  echo "Creating certificate request for swarm-${Z_NETWORK}-${Z_REGION}.${Z_DOMAIN} and *-swarm-${Z_NETWORK}-${Z_REGION}.${Z_DOMAIN}"
  aws acm request-certificate --domain-name swarm-${Z_NETWORK}-${Z_REGION}.${Z_DOMAIN} --subject-alternative-names *.swarm-${Z_NETWORK}-${Z_REGION}.${Z_DOMAIN} --domain-validation-options DomainName=swarm-${Z_NETWORK}-${Z_REGION}.${Z_DOMAIN},ValidationDomain=${Z_DOMAIN}
  echo "Check verification email for webmaster@${Z_DOMAIN}"

elif [ "$ACTION" == "show" ]; then
  terraform show ${STATE}

else
  CERTIFICATE_ARN=$(aws acm list-certificates --certificate-statuses ISSUED --query 'CertificateSummaryList[*].[DomainName, CertificateArn]' --output text | grep swarm-${Z_NETWORK}-${Z_REGION}.${Z_DOMAIN} | cut -f2)

  if [ -z ${CERTIFICATE_ARN} ]; then
    echo "Need to create a wildcard certificate for swarm-${Z_NETWORK}-${Z_REGION}.${Z_DOMAIN} in $AWS_DEFAULT_REGION"
    exit 1;
  fi

  AMI=$(aws ec2 describe-images --owners self --filters "Name=name,Values=dockerz*" --query 'Images[*].[ImageId,Name,CreationDate]' --output text | sort -k 3 -r | head -1 | awk '{print $1'})

  if [ -z ${AMI} ]; then
    echo "No AMIs found.  Go to the packer directory and create one"
    exit 1;
  fi

  KEY_PAIR_EXISTS=$(aws ec2 describe-key-pairs --filters Name=key-name,Values=${AWS_SSH_KEY_ID} --query KeyPairs[*].KeyName  --output text)

  if [ -z ${KEY_PAIR_EXISTS} ]; then
    echo "Creating key $AWS_SSH_KEY_ID using $AWS_SSH_KEY"
    KEY=$(ssh-keygen -y -f ${AWS_SSH_KEY})
    aws ec2 import-key-pair --key-name $AWS_SSH_KEY_ID --public-key-material "$KEY"
  fi

  case ${AWS_DEFAULT_REGION} in
  "us-east-1")
    VPC_CIDR_BLOCK=10.10.0.0/16
    ;;
  "us-east-2")
    VPC_CIDR_BLOCK=10.20.0.0/16
    ;;
  "us-west-1")
    VPC_CIDR_BLOCK=10.30.0.0/16
    ;;
  "us-west-2")
    VPC_CIDR_BLOCK=10.40.0.0/16
    ;;
  "ca-central-1")
    VPC_CIDR_BLOCK=10.50.0.0/16
    ;;
  "sa-east-1")
    VPC_CIDR_BLOCK=10.60.0.0/16
    ;;
  *)
    echo "${AWS_DEFAULT_REGION} unknown region"
    exit 1;
    ;;
  esac

  terraform init -no-color

  terraform $ACTION -auto-approve -state=${STATE} \
             -var aws_region=${AWS_DEFAULT_REGION} \
             -var vpc_cidr_block=${VPC_CIDR_BLOCK} \
             -var 'amis={ '${AWS_DEFAULT_REGION}' = "'${AMI}'" }' \
             -var ssh_key_name=${AWS_SSH_KEY_ID} \
             -var ssh_key_filename=${AWS_SSH_KEY} \
             -var z_region=${Z_REGION} \
             -var z_network=${Z_NETWORK} \
             -var z_domain=${Z_DOMAIN} \
             -var z_zone_id=${Z_ZONE_ID} \
             -var vpc_key=${Z_NETWORK}-${Z_REGION} \
	     -var cluster_manager_count=3 \
             -var cluster_storage_count=1 \
	     -var cluster_app_count=2 \
   	     -var certificate=${CERTIFICATE_ARN} 

fi
