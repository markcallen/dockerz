# Library

## Docs

https://blog.toast38coza.me/kong-up-and-running-part-2-defining-our-api-gateway-with-ansible/

## Original

````
curl https://raw.githubusercontent.com/toast38coza/ansible-kong-module/master/library/kong_api.py > kong_api.py
curl https://raw.githubusercontent.com/toast38coza/ansible-kong-module/master/library/kong_plugin.py > kong_plugin.py
curl https://raw.githubusercontent.com/toast38coza/ansible-kong-module/master/library/kong_consumer.py > kong_consumer.py
````

Note updates have been made to work with Kong 0.10

If necessary install requests on the master swarm server

````
sudo apt install python-pip
sudo pip install requests
````

