openHttp="--http_host 0.0.0.0 --http_port 8080"

nohup ./set --genesis=../testnet.json --datadir=./data/founder --miner_start --contractlog --p2p_listenaddr :9090 $openHttp --http_modules=fee,miner,dpos,account,txpool,set >> founder.log &
sleep 5s
./set miner -i ./data/founder/set.ipc setcoinbase "setchain.founder" keys/founderKey.txt
