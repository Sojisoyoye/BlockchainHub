// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.8.0;

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


// we have implemented a Cryptos contract
contract Cryptos is ERC20Interface {
    string public name = 'Cryptos';
    string public symbol = 'CRPT';
    uint public decimals = 0;

    uint public supply; // the no of Cryptos wanted by the founder
    address public founder; // the account that deploys this contract(Cryptos)

    mapping(address => uint) public balances;
    
    // allowed[0x111...][0x222...] = 100;  allowed[owner's address][spender's address] = 100;
    mapping(address => mapping(address => uint)) allowed;
    
    event Transfer(address indexed from, address indexed to, uint tokens);
    
    constructor() public {
        supply = 1000000; // can be an argument. here its 1000000 Cryptos
        founder = msg.sender;
        balances[founder] = supply; // at the beginning the founder has all the tokens (1000000 Cryptos). and can transfer to other accts.
    }
    
    function allowance(address tokenOwner, address spender) public override view returns (uint) {
        return allowed[tokenOwner][spender];
    }
    
    function approve(address spender, uint tokens) public override returns (bool) {
        require(balances[msg.sender] >= tokens);
        require(tokens > 0);
        allowed[msg.sender][spender] = tokens;
        
        emit Approval(msg.sender, spender, tokens);
        
        return true;
    }
    
    function transferFrom(address from, address to, uint tokens) public override returns (bool) {
        require(allowed[from][to] >= tokens);
        require(balances[from] >= tokens);
        
        balances[from] -= tokens;
        balances[to] += tokens;
        
        allowed[from][to] -= tokens;
        
        return true;
    }

    
    function totalSupply() public override view returns (uint) {
        return supply;
    }
    
    function balanceOf(address tokenOwner) public override view returns (uint balance) {
        return balances[tokenOwner];
    }
    
    function transfer(address to, uint tokens) public override returns (bool success) {
        require(balances[msg.sender] > tokens && tokens > 0);
        
        balances[to] += tokens;
        balances[msg.sender] -= tokens;
        emit Transfer(msg.sender, to, tokens);
        return true;
    }
    
    /*
    Very important, when someone wants to Transfer a token
    the acct doesnt transfer token to the contract address, if you do, you can loose the token.
    the tokens are sent to an externally owned acct(user) address, behind the scene the acct that sends tokens
    calls the transfer function of the token contract.
    */
}
