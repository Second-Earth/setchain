#!/bin/bash
nodename="$1"
datadir="/setdata"
key="$2"
ostype=ubuntu
containerid=`docker ps -q`
intallers="setbin-v2.0.tar"

usage()
{
	echo "[Usage]updateset.sh nodename private_key."
}

if [ $# -ne 2 ]
then 
{
	usage
	exit 80
}
fi


if [ ! -f $datadir/$2 ]
then
{
	echo "the $2 key is not exist in /setdata, please upload the key"
	exit 90
}
fi


if [ -z $containerid ]
then	
{
   echo "setnode container is not exist"
   exit 1
}
fi

cat /proc/version |grep -i $ostype
if [ $? != 0 ]
then
{
	echo "Not Support $ostype Operating System Yet, Please Change The Ubuntu For The Installation."
	exit 100
}
fi

echo "Updating SetNode......"

docker cp $intallers $containerid:/set/bin/
docker exec $containerid tar xf $intallers

if [ $? != 0 ]
then
{
	echo "bin Updated Failed."
	exit 100
}
fi

docker restart $containerid
echo "Restarting SetNode....."
sleep 10s
docker exec -i $containerid ./set miner -i /setdata/set.ipc setcoinbase "$nodename" /setdata/$key
docker exec -i $containerid ./set miner -i /setdata/set.ipc start
if [ $? != 0 ]
then
{
	echo "bin Updated Successfully."
	exit 0
}
fi
