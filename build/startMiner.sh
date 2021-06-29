

#declare -a p2pNodes

#index=0
#for line in `cat filename(p2pNodes.txt)`
#do
#	p2pNodes[$index]=line
#	let "index++"
#done
#echo ${p2pNodes[*]}


if [[ $# -eq 0 ]]; then
	echo "command=>$0, no parameters"
	exit 1
fi

function startOneMinerNode () 
{
	minerName="minernodetest$1"
	p2pPort=`expr 8090 + $1`
	httpPort=`expr 8900 + $1 + $1`
	wsPort=`expr $httpPort + 1`
	echo "minerName=$minerName, p2pport=$p2pPort, httpPort=$httpPort, wsPort=$wsPort"
	#mkdir ./data/$minerName
	nohup ./set --genesis=../testnet.json --datadir=./data/$minerName --contractlog --p2p_listenaddr :$p2pPort --http_port $httpPort --ws_port $wsPort --http_modules=fee,miner,dpos,account,txpool,set >> logs/$minerName.log &
	sleep 5
	./set miner start -i ./data/$minerName/set.ipc
}


if [[ $# -eq 1 ]]; then
	startOneMinerNode $1
	exit 1
fi

startNodeNum=$1
while(( $startNodeNum<=$2 ))
do
	startOneMinerNode $startNodeNum
	let "startNodeNum++"	
done
