#!/bin/bash

echo "Starting containers ..."
echo "***********************"
echo " "

echo "cleaning up ..."
echo "***************"
# clean previous containers in host
sudo docker stop $(sudo docker ps -qa)
sudo docker rm $(sudo docker ps -qa)
echo " "

# extract host machine ip
HOST_IP=$(ip -o -4 addr list eth0 | awk '{split($4,a,"/"); print a[1]}')

# start a etcd node, will provide service discovery endpoints
etcd0=$(docker run -d \
	-v /usr/share/ca-certificates/:/etc/ssl/certs \
	-p 4001:4001 \
	-p 2380:2380 \
	-p 2379:2379 \
	-e SERVICE_NAME=etcd \
	--name etcd.0 \
	quay.io/coreos/etcd etcd \
	-name etcd0 \
	-advertise-client-urls http://$HOST_IP:2379,http://$HOST_IP:4001 \
	-listen-client-urls http://0.0.0.0:2379,http://0.0.0.0:4001 \
	-initial-advertise-peer-urls http://$HOST_IP:2380 \
	-listen-peer-urls http://0.0.0.0:2380 \
	-initial-cluster-token etcd-cluster-1 \
	-initial-cluster etcd0=http://${HOST_IP}:2380 \
	-initial-cluster-state new)
echo "Starting etcd0 node ..."
echo "***********************"
echo $etcd0
echo " "

# adding needed configuration for dns service on etcd node
skydns_config=$(docker exec etcd.0 \
	etcdctl \
	--endpoint http://$HOST_IP:4001 \
	set /skydns/config '{"dns_addr":"0.0.0.0:53", "ttl":60, "domain": "cluster.local.", "nameservers": ["8.8.8.8:53","8.8.4.4:53"]}')
echo "configuring skydns on etcd ..."
echo "******************************"
echo " "

# start the dns service
skydns=$(docker run -d \
	-p $HOST_IP:53:53/udp \
	--name skydns \
	skynetservices/skydns:2.5.3a \
	-machines http://$HOST_IP:4001)
echo "Starting skydns service ..."
echo "***************************"
echo $skydns
echo " "

# start registrator
registrator=$(docker run -d \
    --name=registrator \
	-v /var/run/docker.sock:/tmp/docker.sock \
    gliderlabs/registrator \
    -ip $HOST_IP \
    skydns2://$HOST_IP:2379/cluster.local)
echo "Starting registrator ..."
echo "***********************"
echo $registrator
echo " "

# inspect the container to extract the IP of our DNS server
DNS_IP=$(sudo docker inspect --format '{{ .NetworkSettings.IPAddress }}' skydns)

# start some mysql instances, both of them without data just to show multiple instances supported per node
# this one includes dns configuration, access other services by name as they get registered
mysql1=$(docker run -d \
	--name mysql.1 \
	--dns=$DNS_IP \
	-P \
	-e SERVICE_NAME=mysql \
	-e SERVICE_ID=1 \
	-e MYSQL_ROOT_PASSWORD=root \
	mysql/mysql-server)
echo "Starting mysql.1 ..."
echo "********************"
echo $mysql1
echo " "

# no dns for you, just routing based on normal gateways (still have access to internet)
mysql2=$(docker run -d \
	--name mysql.2 \
	-P \
	-e SERVICE_NAME=mysql \
	-e SERVICE_ID=2 \
	-e MYSQL_ROOT_PASSWORD=root \
	mysql/mysql-server)
echo "Starting mysql.2 ..."
echo "********************"
echo $mysql2
echo " "

