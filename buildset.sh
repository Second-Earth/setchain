#!/bin/bash
nodename="$1"
datadir="/setdata"
key="$3"
ostype=ubuntu

usage()
{
	echo "[Usage]buildset.sh nodename private_key."
}

if [ $# -ne 2 ]
then 
{
	usage
	exit 80
}
fi


if [ ! -f $2 ]
then
{
	echo "the $2 key is not exist in /setdata, please upload the key"
	exit 90
}
fi


cat /proc/version |grep -i $ostype
if [ $? != 0 ]
then
{
	echo "Not Support Ubuntu Operating System Yet, Please Change The Ubuntu For The Installation."
	exit 100
}
fi

echo "Installing SetNode......"
mkdir $datadir

if [ ! -f $key ]
then 
{
	echo "$key is no exist,please upload them."
	exit 110
}
fi
 
cp -r ./$key $datadir/$key
echo "copied the key to $datadir."
sleep 5s 


apt-get remove docker docker-engine docker.io containerd runc
apt-get update
apt-get install -y apt-transport-https
apt-get install -y ca-certificates
apt-get install -y curl
apt-get install -y gnupg
apt-get install -y lsb-release
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo \
	  "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
	    $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
apt-get update
apt-get install -y docker-ce docker-ce-cli containerd.io
if [ $? -ne 0 ]
then	
{
   echo "docker installation failed."
   exit 1
}
fi

docker pull setchain/setimages:setnode
if [ $? -ne 0 ]
then
{
   echo "docker pull setnode images failed."
   exit 1
}
fi

rm -fr $datadir/nodedb $datadir/set
docker rm -f $nodename

#docker run --name $nodename -itd --restart=always -v $datadir:$datadir -p 8080:8080 -p 2021:2021 setnode -g $datadir/genesis.json --p2p_staticnodes=$datadir/nodes.txt --p2p_listenaddr :8989 --p2p_name $1 --http_host 0.0.0.0 --http_port 8080 --datadir /setdata  --ipcpath /setdata/oex.ipc --contractlog --http_modules=fee,miner,dpos,account,txpool,set
docker run --name $nodename -itd --restart=always -v $datadir:$datadir -p 2021:2021 setchain/setimages:setnode -g ../genesis.json --p2p_listenaddr :2021 --p2p_name $1 --p2p_staticnodes=../nodes.txt --http_host 0.0.0.0 --http_port 8080 --datadir $datadir  --ipcpath /setdata/set.ipc --contractlog --http_modules=fee,miner,dpos,account,txpool,set
docker exec -i $nodename ./set miner -i $datadir/set.ipc setcoinbase  "$nodename" $datadir/$key
sleep 10s
docker exec -i $nodename ./set miner -i $datadir/set.ipc start
