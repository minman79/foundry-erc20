// SPDX-License-Identifier: MIT

pragma solidity 0.8.18;

contract ManualToken {
    mapping(address owner => uint256 balance) private s_balances;

    // event Transfer(address indexed _from, address indexed _to, uint256 _value){}
    // event Approval(address indexed _owner, address indexed _spender, uint256 _value){}

    // This is optional
    function name() public pure returns (string memory tokenName) {
        return "Manual Token";
    }
    // string public constant name = "Manual Token";  // This is more gas efficient

    // This is optional
    function symbol() public pure returns (string memory tokenSymbol) {
        return "MTK";
    }
    // string public constant symbol = "MTK";  // This is more gas efficient

    // This is optional
    function decimals() public pure returns (uint8 decimalForToken) {
        // means the token can be divided by 1000000000000000000
        return 18;
    }
    // uint8 public constant decimals = 18;  // This is more gas efficient

    // We are saying this token needs to be 100 ether big therefore good idea to add the decimals function to show 1 ether is 1e18;
    function tokenSupply() public pure returns (uint256 totalSupply) {
        return 100 ether;
    }

    // Need to create a mapping to show balances of holders and keep it private
    function balanceOf(address _owner) public view returns (uint256 balance) {
        return (s_balances[_owner]);
    }

    function transfer(address _to, uint256 _amount) public returns (bool success) {
        uint256 previousBalances = balanceOf(msg.sender) + balanceOf(_to);
        s_balances[msg.sender] -= _amount;
        s_balances[_to] += _amount;
        require(balanceOf(msg.sender) + balanceOf(_to) == previousBalances);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {}

    function approve(address _spender, uint256 _value) public returns (bool success) {}

    function allowance(address _owner, address _spender) public view returns (uint256 remaining) {}
}
