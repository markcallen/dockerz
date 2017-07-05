# Terraform dockerz.ooo

## Setup

## Requires

IAM user with


## Certificate

aws acm request-certificate --domain-name swarm-dockerz-a.dockerz.ooo --subject-alternative-names *.swarm-dockerz-a.dockerz.ooo --domain-validation-options DomainName=swarm-dockerz-a.dockerz.ooo,ValidationDomain=dockerz.ooo

check email at webmaster@dockerz.ooo

aws acm list-certificates

aws acm describe-certificate --certificate-arn ...


## Setup Kong

docker service create --name kong-database --publish 5432:5432 --mount type=volume,src=kongdb,dst=/var/lib/postgresql/data,volume-driver=flocker,volume-opt=size=50gb --constraint node.role==manager --network appnet -e POSTGRES_USER=kong -e POSTGRES_DB=kong postgres:9.4

docker service create --name kong  --publish 8000:8000  --publish 8443:8443  --publish 8001:8001 \
--constraint node.role==manager --network appnet \
-e KONG_DATABASE=postgres -e KONG_PG_HOST=kong-database kong:0.10

## Setup viz

docker service create --name viz --publish 8080:8080 --constraint node.role==manager --mount type=bind,src=/var/run/docker.sock,dst=/var/run/docker.sock --network appnet dockersamples/visualizer"

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
