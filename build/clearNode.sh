
if [[ $# -eq 0 ]]; then
	echo "command=>$0, no parameters"
	exit 1
fi

function clearNode () 
{
	minerName="minernodetest$1"
	rm -rf data/$minerName/*
	rm -f logs/$minerName.log
	ps -ef |grep $minerName |awk '{print $2}'|xargs kill -9
}


if [[ $# -eq 1 ]]; then
	clearNode $1
	exit 1
fi

startNodeNum=$1
while(( $startNodeNum<=$2 ))
do
	clearNode $startNodeNum
	let "startNodeNum++"	
done

