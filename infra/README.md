# DockerZ - Infra

## Setup

## Requires

IAM user with
 - AmazonEC2FullAccess
 - AmazonRoute53DomainsFullAccess
 - AmazonVPCFullAccess
 - AmazonRoute53FullAccess
 - AWSCertificateManagerFullAccess

Create a key and secret and a key pair.


## Run

### Create Load Balancer Certificate

create a credentials file with the following

````
export AWS_ACCESS_KEY_ID=<aws access key>
export AWS_SECRET_ACCESS_KEY=<aws secret key>
export AWS_DEFAULT_REGION=<region>

export AWS_SSH_KEY_ID=<key pair name>
export AWS_SSH_KEY=`dirname $PWD/$BASH_SOURCE`/<key.pem>
````

network: -n
region: -r
domain: -d

To create a swarm located at: swarm-dockerz-b.dockerz.ooo

````
./create-dockerz.sh -r b -n dockerz -d dockerz.ooo createcert
````

check email at webmaster@dockerz.ooo

### Create Swarm

To create machines in: dockerz.b.dockerz.ooo

````
./create-dockerz.sh -r b -n dockerz -d dockerz.ooo apply
````

### Provision Swarm

Setup GlusterFS and create the swarm

````
./provision-dockerz.sh -r b -n dockerz -d dockerz.ooo swarm.yml glusterfs.yml
````

### Setup Kong

````
./provision-dockerz.sh -r b -n dockerz -d dockerz.ooo kong.yml
````


## Configure viz

````
./provision-dockerz.sh -r b -n dockerz -d dockerz.ooo viz.yml
````

Test

````
open https://viz.swarm-dockerz-b.dockerz.ooo
````

### Configure registry

````
./provision-dockerz.sh -r b -n dockerz -d dockerz.ooo registry.yml
````

Test

````
docker build . -t demo
docker tag demo:latest registry.swarm-dockerz-b.dockerz.ooo/dockerz/demo:latest
````

log into a manager

````
docker service create demo registry.swarm-dockerz-b.dockerz.ooo/dockerz/demo:latest
````

## Adding users

If using an existing keyname get the users public key form the keyname pem file

````
ssh-keygen -y -f <path to pem file>
````

otherwise just use the users public key

Create the user

````
./create-users.sh -n dockerz -r b -d dockerz.ooo -u marka -k "<public key>"
````

Make sure that you turn on forwarding in your local .ssh/config

````
Host *.amazonaws.com
  ForwardAgent yes
````



## License & Authors
- Author:: Mark Allen (mark@markcallen.com)

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
