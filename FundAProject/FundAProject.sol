// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.8.0;

contract FundMinigrid {

    // state
    mapping (address => uint) funders;
    address payable public provider;
    uint public noOfFunders;
    uint public minFunds;
    uint deadline;
    uint fundTarget;
    uint public totalAmount = 0;

    struct Request {
        string description;
        uint value;
        bool completed;
        uint noOfVoters;
        mapping (address => bool) voters;
    }

    Request[] public requests;
    
    event Contribute(address funder, uint value);
    event CreateRequest(string _description, uint _value);
    event MakePayment(string description, uint value);


    modifier onlyProvider() {
        require(msg.sender == provider);
        _;
    }

    constructor (uint _fundTarget, uint _deadline) public {
        fundTarget = _fundTarget;
        deadline = block.timestamp + _deadline;

        provider = msg.sender;
        minFunds = 0;
    }

    function contributeFund() public payable {
        require(block.timestamp < deadline);
        require(msg.value >= minFunds);

        if (funders[msg.sender] == 0) {
            noOfFunders++;
        }

        funders[msg.sender] += msg.value;
        totalAmount += msg.value;
        emit Contribute(msg.sender, msg.value);
    }

    function getBalance() public view returns (uint) {
        return address(this).balance;
    }

    function getRefund() public {
        require(block.timestamp > deadline);
        require(totalAmount < fundTarget);
        require(funders[msg.sender] > 0);

        address payable recipient = msg.sender;
        uint value = funders[msg.sender];

        recipient.transfer(value);
        funders[msg.sender] = 0;
    }

    /*
    This function is to allow providers request for funding to spend by updating the
    financiers on the thing to spend money on, the financiers can vote and decide if they agree the expense 
    to made is justified
     */
    function createRequest(string memory  _description, uint _value) public onlyProvider {
        Request memory newRequest = Request({
            description: _description,
            value: _value,
            completed: false,
            noOfVoters: 0
        });
        requests.push(newRequest);
        emit CreateRequest(_description, _value);
    }
    
    function voteRequest(uint index) public {
        Request storage thisRequest = requests[index];
        require(funders[msg.sender] > 0);
        require(thisRequest.voters[msg.sender] == false);
        
        thisRequest.voters[msg.sender] = true;
        thisRequest.noOfVoters++;
    }
    
   function withdrawFund(uint index) public onlyProvider {
       Request storage thisRequest = requests[index];
       require(thisRequest.completed == false);
       require(thisRequest.noOfVoters > noOfFunders / 2); // more than 50% voted
       
       provider.transfer(thisRequest.value); // transfer the fund required for the Request to the provider
       
       thisRequest.completed = true;
       
       emit MakePayment(thisRequest.description, thisRequest.value);
   }
    
}
