#!/bin/bash
#
# Remove users in the dockerz environment
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

path_to_ansible=$(which ansible-playbook)
if [ ! -x "$path_to_ansible" ] ; then
   echo "Can't find ansible-playbook, check that its in your path"
   exit 1;
fi

: ${AWS_ACCESS_KEY_ID:?"Need to set AWS_ACCESS_KEY_ID"}
: ${AWS_SECRET_ACCESS_KEY:?"Need to set AWS_SECRET_ACCESS_KEY"}
: ${AWS_DEFAULT_REGION:?"Need to set AWS_DEFAULT_REGION"}
: ${AWS_SSH_KEY_ID:?"Need to set AWS_SSH_KEY_ID"}
: ${AWS_SSH_KEY:?"Need to set AWS_SSH_KEY"}

while getopts r:n:d:u:k: option
do
  case "${option}"
  in
    r) Z_REGION=${OPTARG};;
    n) Z_NETWORK=${OPTARG};;
    d) Z_DOMAIN=${OPTARG};;
    u) USERNAME=${OPTARG};;
  esac
done

: ${Z_REGION:?"Need a region"}
: ${Z_NETWORK:?"Need a network"}
: ${Z_DOMAIN:?"Need a domain"}
: ${USERNAME:?"Need a username"}

STATE=${Z_NETWORK}-${Z_REGION}.${Z_DOMAIN}.tfstate

echo "[manager]" > inventory
MANAGERS=$(terraform output -state=${STATE} swarm_managers | tr "," " ")
for HOST in $MANAGERS; do
    echo $HOST ansible_connection=ssh ansible_ssh_user=ubuntu >> inventory
done
echo "" >> inventory
echo "[storage]" >> inventory
STORAGE=$(terraform output -state=${STATE} swarm_storage | tr "," " ")
for HOST in $STORAGE; do
    echo $HOST ansible_connection=ssh ansible_ssh_user=ubuntu >> inventory
done
echo "" >> inventory
echo "[worker]" >> inventory
APP=$(terraform output -state=${STATE} swarm_app | tr "," " ")
for HOST in $APP; do
    echo $HOST ansible_connection=ssh ansible_ssh_user=ubuntu >> inventory
done
echo "" >> inventory
echo "[storage_nodes]" >> inventory
MANAGERS=$(terraform output -state=${STATE} swarm_managers_private | tr "," " ")
for HOST in $MANAGERS; do
    echo $HOST ansible_connection=ssh ansible_ssh_user=ubuntu >> inventory
done
STORAGE=$(terraform output -state=${STATE} swarm_storage_private | tr "," " ")
for HOST in $STORAGE; do
    echo $HOST ansible_connection=ssh ansible_ssh_user=ubuntu >> inventory
done
echo "" >> inventory

echo "Running tasks/user-del.yml ..."
ansible-playbook -i inventory -b --private-key $AWS_SSH_KEY -e username=$USERNAME tasks/user-del.yml

