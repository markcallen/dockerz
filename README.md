# DockerZ

Creates a docker swarm and provisions management tools

## Packer

Creates a packer images for AWS

## Infra

Builds the infrastructure for the docker swarm


## Running

Status of the glusterfs volumes

````
gluster volume status 
````

Restarting a single stack service

````
$ docker stack services <stack_name>
ID                  NAME              ...
3xrdy2c7pfm3        stack-name_api    ...

$ docker service update --force 3xrdy2c7pfm3
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
