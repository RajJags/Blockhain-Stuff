// SPDX-License-Identifier: MIT
pragma solidity 0.6.0;

contract SimpleStorage {

uint256 favoriteNumber;

struct People {
    uint256 favoriteNumber;
    string name;
}

People[] public people;

function store (uint _favoriteNum) public{
 favoriteNumber=_favoriteNum;
}

mapping(string=>uint256) public NameToFavoriteNum;

function retrieve() public view returns(uint256){

    return favoriteNumber;
}

function AddPerson(string memory _name,  uint256 _favoriteNum) public {
    people.push(People(_favoriteNum, _name));
    NameToFavoriteNum[_name]=_favoriteNum;
}    

}