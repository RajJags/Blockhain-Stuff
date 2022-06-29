//SPDX-License-Identifier: GPL-3.0
 
pragma solidity >=0.5.0 <0.9.0;
 
contract Lottery{
    address payable[] public players;
    address public manager;
    constructor()
    {
        manager=msg.sender;
    }
    receive() external payable
    {
        require(msg.sender!=manager);
        require(msg.value==1 ether,"The ticket price is 1 ether");
        players.push(payable(msg.sender));
    } 
    function getBalance() public view returns(uint){
        require(msg.sender==manager);
        return address(this).balance;
    }
    function random() private view returns(uint)
    {
        return uint(keccak256(abi.encodePacked(block.difficulty,block.timestamp,players.length)));
    }
    function PickWinner() public returns(address)
    {
        require(msg.sender==manager);
        uint index= random()%players.length;
        payable(players[index]).transfer(getBalance());
        players = new address payable[](0); //Lottery is reset with the players array length reset to 0.
        return players[index];
    }
   
}