// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.8.0;

// pragma solidity ^0.4.21;

interface ERC20Interface {

    function totalSupply() external view returns (uint);
    function balanceOf(address tokenOwner) external view returns (uint balance);
    function transfer(address to, uint tokens) external returns (bool success);
    

    function allowance(address tokenOwner, address spender) external view returns (uint remaining);
    function approve(address spender, uint tokens) external returns (bool success);
    function transferFrom(address from, address to, uint tokens) external returns (bool success);

    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}

library SafeMath {
    function add(uint a, uint b) internal pure returns (uint c) {
        c = a + b;
        require(c >= a);
    }
    
    function sub(uint a, uint b) internal pure returns (uint c) {
        require(b <= a);
        c = a - b;
    }
    
    function mul(uint a, uint b) internal pure returns (uint c) {
        c = a * b;
        require(a == 0 || c / a == b);
    }
    
    function div(uint a, uint b) internal pure returns (uint c) {
        require(b > 0);
        c = a / b;
    }
}

contract ICO is ERC20Interface {
     using SafeMath for uint;
    
     string public name;
     string public symbol;
     uint256 public decimals;
     uint256 public bonusEnds;
     uint256 public icoEnds;
     uint256 public icoStarts;
     uint256 public allContributors;
     uint256 allTokens;
     address payable admin;
     mapping (address => uint) public balances;
     mapping (address => mapping(address => uint)) allowed;
     
     constructor () public {
         name = 'Demo coin';
         decimals = 18;
         symbol ='DC';
         bonusEnds = now + 2 weeks;
         icoStarts = now + 4 weeks;
         allTokens = 100000000000000000000; // equal 100 ether * 100DC
         admin  = msg.sender;
         balances[msg.sender] = allTokens;
     }
     
     function buyTokens() public payable {
         
         uint tokens;
         
         if (block.timestamp <= bonusEnds) {
             tokens = msg.value.mul(125); // 25% bonus
         } else {
             tokens = msg.value.mul(100); // no bonus
         }
         
         tokens = msg.value.mul(100);
         balances[msg.sender] = balances[msg.sender].add(tokens);
         allTokens = allTokens.add(tokens);
         emit Transfer(address(0), msg.sender, tokens);
         
         allContributors++;
     }
     
    // needed for ecr20 interface
     function totalSupply() public override view returns (uint) {
         return allTokens;
     }
     
     function balanceOf(address tokenOwner) public override view returns (uint balance) {
        return balances[tokenOwner];
    }
    
    function transfer(address to, uint tokens) public override returns (bool success) {
        balances[msg.sender] = balances[msg.sender].sub(tokens);
        balances[to] = balances[to].add(tokens);
        emit Transfer(msg.sender, to, tokens);
        return true;
    }
    
    function approve(address spender, uint tokens) public override returns (bool) {
        allowed[msg.sender][spender] = tokens;
        
        emit Approval(msg.sender, spender, tokens);
        
        return true;
    }
    
    function transferFrom(address from, address to, uint tokens) public override returns (bool) {
        balances[from] = balances[from].sub(tokens);
        allowed[from][msg.sender] = allowed[from][msg.sender].sub(tokens);
        balances[to] = balances[to].add(tokens);
        emit Transfer(from, to, tokens);
        return true;
    }
    
    function allowance(address tokenOwner, address spender) public override view returns (uint) {
        return allowed[tokenOwner][spender];
    }
    
     
     
     function myBalance() public view returns (uint) {
       return balances[msg.sender];  
     }
     
     
     function myAddress() public view returns (address) {
         return msg.sender;
     }
     
     function endSale() public {
         require(msg.sender == admin);
         admin.transfer(address(this).balance);
     }
}
