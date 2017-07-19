#!/bin/bash
#
# Provision DockerZ
# https://github.com/markcallen/dockerz
#
# version: 0.1.0
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

echo "[managers]" > inventory
MANAGERS=$(terraform output swarm_managers)
echo $MANAGERS ansible_connection=ssh ansible_ssh_user=ubuntu >> inventory
echo "" >> inventory
echo "[storage]" >> inventory
STORAGE=$(terraform output swarm_storage)
echo $STORAGE ansible_connection=ssh ansible_ssh_user=ubuntu >> inventory
echo "" >> inventory
echo "[app]" >> inventory
APP=$(terraform output swarm_app)
echo $APP ansible_connection=ssh ansible_ssh_user=ubuntu >> inventory
echo "" >> inventory
echo "[storage_nodes]" >> inventory
MANAGERS=$(terraform output swarm_managers_private)
echo $MANAGERS ansible_connection=ssh ansible_ssh_user=ubuntu >> inventory
STORAGE=$(terraform output swarm_storage_private)
echo $STORAGE ansible_connection=ssh ansible_ssh_user=ubuntu >> inventory
echo "" >> inventory

cat inventory

ansible-playbook -i inventory -b --private-key $AWS_SSH_KEY glusterfs.yml 
