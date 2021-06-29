pragma solidity ^0.4.24;

contract MultiAsset {
    uint256 assetID = 1;
    constructor() public payable {
    }
    function reg(string desc) public payable{
        assetID = issueasset(desc);
    } 
    function add(uint256 assetId, address to, uint256 value ) public {
        addasset(assetId,to,value);
    }
    function transAsset(address to, uint256 value) public payable {
	    to.transfer(msg.extassetid1, msg.extvalue1);
        to.transfer(msg.extassetid2, msg.extvalue2);
        to.transfer(msg.extassetid3, msg.extvalue3);
        to.transfer(msg.extassetid4, msg.extvalue4);
        to.transfer(msg.extassetid5, msg.extvalue5);
        to.transfer(msg.extassetid6, msg.extvalue6);
        to.transfer(msg.extassetid7, msg.extvalue7);
        to.transfer(msg.extassetid8, msg.extvalue8);
        to.transfer(assetID, value);
    }
    function changeOwner(address newOwner, uint256 assetId) public {
        setassetowner(assetId, newOwner);
    }
}
