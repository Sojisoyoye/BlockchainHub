pragma solidity ^0.4.15;

contract C1 {
  uint public num;
  address public sender;

  function callSetNum(address c2, uint _num) public {
    if(!c2.call(bytes4(sha3("setNum(uint256)")), _num)) revert(); // C2's num is set 
  }
  
  function c2setNum(address _c2, uint _num) public{
      C2 c2 = C2(_c2);
      c2.setNum(_num);
  }

  function callcodeSetNum(address c2, uint _num) public {
    if(!c2.callcode(bytes4(sha3("setNum(uint256)")), _num)) revert(); // C1's num is set
  }

  function delegatecallSetNum(address c2, uint _num) public {
    if(!c2.delegatecall(bytes4(sha3("setNum(uint256)")), _num)) revert(); // C1's num is set 
  }
}

contract C2 {
  uint public num;
  address public sender;

  function setNum(uint _num) public {
    num = _num;
    sender = msg.sender;
    // msg.sender is C1 if invoked by C1.callcodeSetNum
    // msg.sender is C3 if invoked by C3.foo()

  }
}

contract C3 {
    function f1(C1 c1, C2 c2, uint _num) public {
        c1.delegatecallSetNum(c2, _num);
    }
}