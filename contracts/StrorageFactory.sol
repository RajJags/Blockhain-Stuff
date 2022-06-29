// SPDX-License-Identifier: MIT
pragma solidity 0.6.0;

import "./SimpleStorage.sol";
contract Storagefactory {
SimpleStorage[] public SimpleStoreArray;
function createSimpleStorageContract() public {

    

    SimpleStorage simplestorage = new SimpleStorage();
    SimpleStoreArray.push(simplestorage);
}

function sfStore (uint256 ArrayIndex, uint256 StoreNum) public{
    SimpleStorage simplestorage= SimpleStorage(address(SimpleStoreArray[ArrayIndex]));
    simplestorage.store(StoreNum);
}

function sfGet(uint256 ArrayIndex) public view returns (uint256) {
    SimpleStorage simplestorage= SimpleStorage(address(SimpleStoreArray[ArrayIndex]));
    return simplestorage.retrieve();
}
}
