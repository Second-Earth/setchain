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

package setservice

import (
	"math/big"

	"github.com/Second-Earth/setchain/blockchain"
	"github.com/Second-Earth/setchain/consensus"
	"github.com/Second-Earth/setchain/consensus/dpos"
	"github.com/Second-Earth/setchain/consensus/miner"
	"github.com/Second-Earth/setchain/node"
	"github.com/Second-Earth/setchain/p2p"
	adaptor "github.com/Second-Earth/setchain/p2p/protoadaptor"
	"github.com/Second-Earth/setchain/params"
	"github.com/Second-Earth/setchain/processor"
	"github.com/Second-Earth/setchain/processor/vm"
	"github.com/Second-Earth/setchain/rpc"
	"github.com/Second-Earth/setchain/rpcapi"
	"github.com/Second-Earth/setchain/setservice/gasprice"
	"github.com/Second-Earth/setchain/txpool"
	"github.com/Second-Earth/setchain/utils/fdb"
	"github.com/ethereum/go-ethereum/log"
)

// SETService implements the set service.
type SETService struct {
	config       *Config
	chainConfig  *params.ChainConfig
	shutdownChan chan bool // Channel for shutting down the service
	blockchain   *blockchain.BlockChain
	txPool       *txpool.TxPool
	chainDb      fdb.Database // Block chain database
	engine       consensus.IEngine
	miner        *miner.Miner
	p2pServer    *adaptor.ProtoAdaptor
	APIBackend   *APIBackend
}

// New creates a new setservice object (including the initialisation of the common setservice object)
func New(ctx *node.ServiceContext, config *Config) (*SETService, error) {
	chainDb, err := CreateDB(ctx, config, "chaindata")
	if err != nil {
		return nil, err
	}

	chainCfg, dposCfg, _, err := blockchain.SetupGenesisBlock(chainDb, config.Genesis)
	if err != nil {
		return nil, err
	}

	ctx.AppendBootNodes(chainCfg.BootNodes)

	setService := &SETService{
		config:       config,
		chainDb:      chainDb,
		chainConfig:  chainCfg,
		p2pServer:    ctx.P2P,
		shutdownChan: make(chan bool),
	}

	//blockchain
	vmconfig := vm.Config{
		ContractLogFlag: config.ContractLogFlag,
	}

	setService.blockchain, err = blockchain.NewBlockChain(chainDb, config.StatePruning, vmconfig, setService.chainConfig, config.BadHashes, config.StartNumber, txpool.SenderCacher)
	if err != nil {
		return nil, err
	}

	// txpool
	if config.TxPool.Journal != "" {
		config.TxPool.Journal = ctx.ResolvePath(config.TxPool.Journal)
	}

	setService.txPool = txpool.New(*config.TxPool, setService.chainConfig, setService.blockchain)

	engine := dpos.New(dposCfg, setService.blockchain)
	setService.engine = engine

	type bc struct {
		*blockchain.BlockChain
		consensus.IEngine
		*txpool.TxPool
		processor.Processor
	}

	bcc := &bc{
		setService.blockchain,
		setService.engine,
		setService.txPool,
		nil,
	}

	validator := processor.NewBlockValidator(bcc, setService.engine)
	txProcessor := processor.NewStateProcessor(bcc, setService.engine)

	setService.blockchain.SetValidator(validator)
	setService.blockchain.SetProcessor(txProcessor)

	bcc.Processor = txProcessor
	setService.miner = miner.NewMiner(bcc)
	setService.miner.SetDelayDuration(config.Miner.Delay)
	setService.miner.SetCoinbase(config.Miner.Name, config.Miner.PrivateKeys)
	setService.miner.SetExtra([]byte(config.Miner.ExtraData))
	if config.Miner.Start {
		setService.miner.Start(false)
	}

	setService.APIBackend = &APIBackend{ftservice: setService}

	setService.SetGasPrice(setService.TxPool().GasPrice())
	return setService, nil
}

// APIs return the collection of RPC services the setservice package offers.
func (fs *SETService) APIs() []rpc.API {
	return rpcapi.GetAPIs(fs.APIBackend)
}

// Start implements node.Service, starting all internal goroutines.
func (fs *SETService) Start() error {
	log.Info("start set service...")
	return nil
}

// Stop implements node.Service, terminating all internal goroutine
func (fs *SETService) Stop() error {
	fs.miner.Stop()
	fs.blockchain.Stop()
	fs.txPool.Stop()
	fs.chainDb.Close()
	close(fs.shutdownChan)
	log.Info("setservice stopped")
	return nil
}

func (fs *SETService) GasPrice() *big.Int {
	return fs.txPool.GasPrice()
}

func (fs *SETService) SetGasPrice(gasPrice *big.Int) bool {
	fs.config.GasPrice.Default = new(big.Int).SetBytes(gasPrice.Bytes())
	fs.APIBackend.gpo = gasprice.NewOracle(fs.APIBackend, fs.config.GasPrice)
	fs.txPool.SetGasPrice(new(big.Int).SetBytes(gasPrice.Bytes()))
	return true
}

// CreateDB creates the chain database.
func CreateDB(ctx *node.ServiceContext, config *Config, name string) (fdb.Database, error) {
	db, err := ctx.OpenDatabase(name, config.DatabaseCache, config.DatabaseHandles)
	if err != nil {
		return nil, err
	}
	return db, nil
}

func (s *SETService) BlockChain() *blockchain.BlockChain { return s.blockchain }
func (s *SETService) TxPool() *txpool.TxPool             { return s.txPool }
func (s *SETService) Engine() consensus.IEngine          { return s.engine }
func (s *SETService) ChainDb() fdb.Database              { return s.chainDb }
func (s *SETService) Protocols() []p2p.Protocol          { return nil }
