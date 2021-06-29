// Copyright 2018 The SET Team Authors
// This file is part of the SET project.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program. If not, see <http://www.gnu.org/licenses/>.

package main

import (
	"github.com/Second-Earth/setchain/cmd/utils"
	"github.com/Second-Earth/setchain/debug"
	"github.com/Second-Earth/setchain/metrics"
	"github.com/Second-Earth/setchain/node"
	"github.com/Second-Earth/setchain/p2p"
	"github.com/Second-Earth/setchain/params"
	"github.com/Second-Earth/setchain/setservice"
	"github.com/Second-Earth/setchain/setservice/gasprice"
	"github.com/Second-Earth/setchain/txpool"
	"github.com/ethereum/go-ethereum/log"
)

var (
	//set config instance
	ftCfgInstance = defaultFtConfig()
	ipcEndpoint   string
)

type ftConfig struct {
	GenesisFile  string             `mapstructure:"genesis"`
	DebugCfg     *debug.Config      `mapstructure:"debug"`
	LogCfg       *utils.LogConfig   `mapstructure:"log"`
	NodeCfg      *node.Config       `mapstructure:"node"`
	FtServiceCfg *setservice.Config `mapstructure:"setservice"`
}

func defaultFtConfig() *ftConfig {
	return &ftConfig{
		DebugCfg:     debug.DefaultConfig(),
		LogCfg:       utils.DefaultLogConfig(),
		NodeCfg:      defaultNodeConfig(),
		FtServiceCfg: defaultFtServiceConfig(),
	}
}

func defaultNodeConfig() *node.Config {
	return &node.Config{
		Name:             params.ClientIdentifier,
		DataDir:          defaultDataDir(),
		IPCPath:          params.ClientIdentifier + ".ipc",
		HTTPHost:         "localhost",
		HTTPPort:         8545,
		HTTPModules:      []string{"set", "dpos", "fee", "account"},
		HTTPVirtualHosts: []string{"localhost"},
		HTTPCors:         []string{"*"},
		WSHost:           "localhost",
		WSPort:           8546,
		WSModules:        []string{"set"},
		Logger:           log.New(),
		P2PNodeDatabase:  "nodedb",
		P2PConfig:        defaultP2pConfig(),
	}
}

func defaultP2pConfig() *p2p.Config {
	cfg := &p2p.Config{
		MaxPeers:   10,
		Name:       "set-P2P",
		ListenAddr: ":2018",
	}
	return cfg
}

func defaultFtServiceConfig() *setservice.Config {
	return &setservice.Config{
		DatabaseHandles: makeDatabaseHandles(),
		DatabaseCache:   768,
		TxPool:          txpool.DefaultTxPoolConfig,
		Miner:           defaultMinerConfig(),
		GasPrice: gasprice.Config{
			Blocks: 20,
		},
		MetricsConf:     defaultMetricsConfig(),
		ContractLogFlag: false,
		StatePruning:    true,
	}
}

func defaultMinerConfig() *setservice.MinerConfig {
	return &setservice.MinerConfig{
		Name:        params.DefaultChainconfig.SysName,
		PrivateKeys: []string{"1c09e6d3353669a66ff36f794ce9111b25b704b2589f92165420531d951f3d12"},
		ExtraData:   "system",
		Delay:       0,
	}
}

func defaultMetricsConfig() *metrics.Config {
	return &metrics.Config{
		MetricsFlag:  false,
		InfluxDBFlag: false,
		URL:          "http://localhost:8086",
		DataBase:     "metrics",
		UserName:     "",
		PassWd:       "",
		NameSpace:    "set/",
	}
}
