//SPDX-License-Identifier: GPL-3.0
 
pragma solidity >=0.5.0 <0.9.0;

contract CrowdFunding{
    address public admin;
    mapping(address=>uint) public contributors;
    uint public minimumContribution;
    uint public goal;
    uint public raisedAmount;
    uint public deadline;
    uint public noOfContributors;

    constructor(uint _goal, uint _deadline)
    {
        goal=_goal;
        deadline= block.timestamp + _deadline;
        minimumContribution=100;
        admin=msg.sender;
    }

    struct Request
    {
        string description;
        address payable recipient;
        uint value;
        bool completed;
        uint noOfVoters;
        mapping(address => bool) voters;

    }

    mapping (uint => Request) public requests;
    uint public numRequests;

      // events to emit
    event ContributeEvent(address _sender, uint _value);
    event CreateRequestEvent(string _description, address _recipient, uint _value);
    event MakePaymentEvent(address _recipient, uint _value);

    modifier onlyAdmin()
    {
        require(msg.sender==admin);
        _;
    }

    modifier notAdmin()
    {
        require(msg.sender!=admin);
        _;
    }

    modifier goalNotAchieved()
    {
        require(raisedAmount<goal);
        _;
    }

    modifier goalAchieved()
    {
        require(raisedAmount>=goal);
        _;
    }

    modifier minAmount()
    {
        require(msg.value>=minimumContribution);
        _;
    }

    function Contribute() public payable notAdmin goalNotAchieved minAmount{
        uint amount=msg.value;
        contributors[msg.sender]=amount;
        if(contributors[msg.sender]==0)
        noOfContributors++;
        raisedAmount+=amount;

        emit ContributeEvent(msg.sender, msg.value);
    }

    function getBalance() public view returns(uint) {
        return address(this).balance;
    }

    receive() external payable{
        Contribute();
    }

    function Refund() public payable notAdmin goalNotAchieved{
        require(block.timestamp>deadline);
        payable(msg.sender).transfer(contributors[msg.sender]);
        contributors[msg.sender]=0;
    }

    function createRequest(string calldata _description, address payable _recipient, uint _value) public onlyAdmin {
        //numRequests starts from zero
        Request storage newRequest = requests[numRequests];
        numRequests++;
        
        newRequest.description = _description;
        newRequest.recipient = _recipient;
        newRequest.value = _value;
        newRequest.completed = false;
        newRequest.noOfVoters = 0;
        
        emit CreateRequestEvent(_description, _recipient, _value);
    }

}