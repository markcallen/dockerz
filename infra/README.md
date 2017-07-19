# Terraform dockerz.ooo

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

````
./create_dockerz.sh -r b -n dockerz -d dockerz.ooo createcert
````

check email at webmaster@dockerz.ooo

### Create Swarm

````
./create_dockerz.sh -r b -n dockerz -d dockerz.ooo apply
````

### Provision Swarm

````
./provision.sh
````


## Setup Kong

docker service create --name kong-database --publish 5432:5432 --mount type=volume,src=kongdb,dst=/var/lib/postgresql/data,volume-driver=flocker,volume-opt=size=50gb --constraint node.role==manager --network appnet -e POSTGRES_USER=kong -e POSTGRES_DB=kong postgres:9.4

docker service create --name kong  --publish 8000:8000  --publish 8443:8443  --publish 8001:8001 \
--constraint node.role==manager --network appnet \
-e KONG_DATABASE=postgres -e KONG_PG_HOST=kong-database kong:0.10

## Setup viz

docker service create --name viz --publish 8080 --constraint node.role==manager --mount type=bind,src=/var/run/docker.sock,dst=/var/run/docker.sock --network appnet dockersamples/visualizer

curl -i -X POST --data 'name=viz' --data 'upstream_url=http://viz:8080/' --data 'hosts=viz.swarm-dockerz-a.dockerz.ooo' http://localhost:8001/apis/

curl -i -X GET \
  --url http://localhost:8000/ \
  --header 'Host: viz.swarm-dockerz-a.dockerz.ooo'

## Debug Flocker

From the manager node

````
sudo root
curl -sSL https://get.flocker.io |sh

IGNORE_NETWORK_CHECK=1 flockerctl --control-service=flocker-control.dockerz.a.dockerz.ooo --user=plugin --certs-path=/etc/flocker list-nodes
IGNORE_NETWORK_CHECK=1 flockerctl --control-service=flocker-control.dockerz.a.dockerz.ooo --user=plugin --certs-path=/etc/flocker list
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
