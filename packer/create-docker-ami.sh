#!/bin/bash
#
#

set -e

if ! docker history -q hashicorp/terraform:light >/dev/null 2>&1; then
 docker pull hashicorp/terraform:light
fi

if ! docker history -q hashicorp/packer:light >/dev/null 2>&1; then
 docker pull hashicorp/packer:light
fi

if ! docker history -q byrnedo/alpine-curl >/dev/null 2>&1; then
 docker pull byrnedo/alpine-curl
fi

: ${AWS_ACCESS_KEY_ID:?"Need to set AWS_ACCESS_KEY_ID"}
: ${AWS_SECRET_ACCESS_KEY:?"Need to set AWS_SECRET_ACCESS_KEY"}
: ${AWS_DEFAULT_REGION:?"Need to set AWS_DEFAULT_REGION"}

TERRAFORM="docker run --rm -e AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID -e AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY -e AWS_DEFAULT_REGION=$AWS_DEFAULT_REGION -v $PWD:/terraform -v $PWD/.terraform:/.terraform -i -t hashicorp/terraform:light"

PUBLIC_IP=$(docker run --rm byrnedo/alpine-curl -Ls http://ipinfo.io/ip)

if [ -z $PUBLIC_IP ]; then
  PUBLIC_IP="0.0.0.0/0"
else
  PUBLIC_IP="${PUBLIC_IP}/32"
fi

$TERRAFORM init -no-color /terraform

$TERRAFORM apply \
	-var public_ip=${PUBLIC_IP} \
	-state=/terraform/terraform.tfstate \
	/terraform

AWS_VPC_ID=$($TERRAFORM output -state=/terraform/terraform.tfstate vpc_id | tr -d '\r')
AWS_SUBNET_ID=$($TERRAFORM output -state=/terraform/terraform.tfstate vpc_subnet_a | tr -d '\r')
AWS_SECURITY_GROUP_ID=$($TERRAFORM output -state=/terraform/terraform.tfstate security_group_id | tr -d '\r')

PACKER="docker run --rm -e AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID -e AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY -e AWS_DEFAULT_REGION=$AWS_DEFAULT_REGION -e AWS_VPC_ID=$AWS_VPC_ID -e AWS_SUBNET_ID=$AWS_SUBNET_ID -e AWS_SECURITY_GROUP_ID=$AWS_SECURITY_GROUP_ID -v $PWD:/packer -i -t hashicorp/packer:light"

$PACKER build \
	-var 'pwd=/packer' \
	/packer/docker-aws.json

$TERRAFORM destroy \
	-force \
	-state=/terraform/terraform.tfstate \
	/terraform

