

if [[ $# -lt 2 ]]; then
	echo "command=>$0, no parameters"
	exit 1
fi

function setP2PNode() 
{
	minerName="minernodetest$1"
	./set --ipcpath data/$minerName/set.ipc p2p add "$2"
}


if [[ $# -eq 2 ]]; then
	setP2PNode $1 $2
	exit 1
fi

startNodeNum=$1
p2pNodeInfo=$3
while(( $startNodeNum<=$2 ))
do
	setP2PNode $startNodeNum $p2pNodeInfo
	let "startNodeNum++"	
done

