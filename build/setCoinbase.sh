
if [[ $# -eq 0 ]]; then
        echo "command=>$0, no parameters"
        exit 1
fi

function setCoinbase ()
{
        minerName="minernodetest$1"
        ./set miner -i ./data/$minerName/set.ipc setcoinbase "$minerName" keys/minernodetestKey.txt
}


if [[ $# -eq 1 ]]; then
        startOneMinerNode $1
        exit 1
fi

startNodeNum=$1
while(( $startNodeNum<=$2 ))
do
        setCoinbase $startNodeNum
        let "startNodeNum++"
done

