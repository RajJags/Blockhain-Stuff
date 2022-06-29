// SPDX-License-Identifier: MIT
pragma solidity >=0.6.6 <0.9.0;
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";


contract FundMe {

    address[] public funders;
    address public owner;
    constructor()  {
        owner=msg.sender;
    }
    
    mapping(address=>uint256) public AmountFunderByAddress;
    uint256 minimumUSD=1*10**18;
    
    function Fund() public payable {
        require(msg.value>=minimumUSD, "Send more ETH!");
        AmountFunderByAddress[msg.sender]+=msg.value;
        funders.push(msg.sender);
    }

    function getVersion() public view returns(uint256) {
        AggregatorV3Interface PriceFeed = AggregatorV3Interface(0x8A753747A1Fa494EC906cE90E9f37563A8AF630e);
        return PriceFeed.version();
    }

    function getPrice() public view returns(uint256) {
        AggregatorV3Interface PriceFeed = AggregatorV3Interface(0x8A753747A1Fa494EC906cE90E9f37563A8AF630e);
        (,int256 answer,,,)=PriceFeed.latestRoundData();
    return uint256(answer*10000000000); 
    }
 
    function getConversionRate(uint256 EthAmount) public view returns(uint256) {
        uint256 UsdPrice = getPrice();
        uint256 UsdAmount = EthAmount*UsdPrice/1000000000000000000;
        return UsdAmount;
    }

    modifier onlyOwner {
        require(msg.sender==owner);
        _;
    }
    function withdraw() payable onlyOwner public {
        payable(msg.sender).transfer(address(this).balance);
        for (uint256 FunderIndex=0; FunderIndex<funders.length;FunderIndex++)
        {
            address funder=funders[FunderIndex];
            AmountFunderByAddress[funder]=0;
        }
        funders = new address[](0);
    }
}