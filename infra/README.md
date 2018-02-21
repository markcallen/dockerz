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


## Configure viz

docker service create --name viz --publish 8080 --constraint node.role==manager --mount type=bind,src=/var/run/docker.sock,dst=/var/run/docker.sock --network appnet dockersamples/visualizer

````
curl -i -X POST --data 'name=viz' --data 'upstream_url=http://viz:8080/' --data 'hosts=viz.swarm-dockerz-b.dockerz.ooo' http://localhost:8001/apis/

curl -i -X GET \
  --url http://localhost:8000/ \
  --header 'Host: viz.swarm-dockerz-b.dockerz.ooo'
````

Test

````
open https://viz.swarm-dockerz-b.dockerz.ooo
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
