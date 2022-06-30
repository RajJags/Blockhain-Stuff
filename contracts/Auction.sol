//SPDX-License-Identifier: GPL-3.0
 
pragma solidity >=0.5.0 <0.9.0;

contract AuctionCreator{
    Auction[] public newAuctions;
    function CreateAuction() public{
        Auction new_Auction= new Auction(msg.sender);
        newAuctions.push(new_Auction);
    }
}

contract Auction {
    address payable public owner;
    uint startBlock;
    uint endBlock;
    string public ipfsHash;
    uint public HighestBid;
    address payable public HighestBidder;
    uint public HighestBindingBid;

    mapping (address => uint) bids;

    enum State {Started, Running, Ended, Cancelled}
    State public AuctionState;

    uint bidIncrement;

    constructor(address eoa)
    {
        owner = payable(eoa);
        startBlock = block.number;
        endBlock = startBlock + 3;
        bidIncrement = 1000000000000000000;
        HighestBindingBid=0;
        ipfsHash ="";
        HighestBid=0;
        AuctionState=State.Running;
    }

    modifier notOwner()
    {
        require(owner!=msg.sender);
        _;
    }

    modifier OwnerOnly()
    {
        require(owner==msg.sender);
        _;
    }

    modifier AfterStart()
    {
        require(block.number>=startBlock);
        _;
    }

    modifier BeforeEnd()
    {
        require(block.number<=endBlock);
        _;
    }

    function min(uint a, uint b) pure internal returns(uint)
    {
        if(a>=b)
        return a;
        else
        return b;
    }

    function CancelAuction() public OwnerOnly{
        AuctionState = State.Cancelled;
    }

    function PlaceBid() public payable notOwner AfterStart BeforeEnd{
        require(AuctionState==State.Running);
        require(msg.value>=100);
        uint currentBid = bids[msg.sender] + msg.value; 
        require(currentBid>HighestBindingBid);

        bids[msg.sender]=currentBid;
        if(currentBid<=HighestBid)
        {
            HighestBindingBid = min (currentBid + bidIncrement,HighestBid);
        }
        else
        {
            HighestBindingBid= min (currentBid, HighestBid+bidIncrement);
            HighestBid=currentBid;
            HighestBidder=payable(msg.sender);
        }
    }

    function finalizeAuction() public{
        require(AuctionState==State.Cancelled || block.number>endBlock);
        require(msg.sender == owner || bids[msg.sender]>0);

        address payable recipient;
        uint value;

        if(AuctionState==State.Cancelled)
        {
            recipient= payable(msg.sender);
            value= bids[msg.sender];
        }
       else if(msg.sender==owner)
            {
                recipient=owner;
                value=HighestBid;
            }
         
        else
        if(msg.sender==HighestBidder)
        { 
            recipient=HighestBidder;
            value = bids[HighestBidder]-HighestBindingBid;
        }
        
        
        else
        {
            recipient= payable(msg.sender);
            value = bids[msg.sender];
        }
        recipient.transfer(value);
        bids[recipient]=0;
        
    }


}