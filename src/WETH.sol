// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

interface IERC20 {
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(
        address indexed _owner,
        address indexed _spender,
        uint256 _value
    );

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function totalSupply() external view returns (uint256);

    function decimals() external view returns (uint8);

    function balanceOf(address _owner) external view returns (uint256 balance);

    function transfer(
        address _to,
        uint256 _value
    ) external returns (bool success);

    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    ) external returns (bool success);

    function approve(
        address _spender,
        uint256 _value
    ) external returns (bool success);

    function allowance(
        address _owner,
        address _spender
    ) external view returns (uint256 remaining);
}

contract WETH is IERC20 {
    event Deposit(address indexed from, uint indexed amount);
    event Withdraw(address indexed to, uint indexed amount);
    string public name = "Wrapped Ether";
    string public symbol = "WETH";
    uint8 public decimals = 18;

    mapping(address => uint) balances;
    mapping(address => mapping(address => uint)) allowances;

    function totalSupply() external view returns (uint256) {
        return address(this).balance;
    }

    function balanceOf(address _owner) external view returns (uint balance) {
        return balances[_owner];
    }

    function transfer(
        address _to,
        uint256 _value
    ) external returns (bool success) {
        _checkAddress(_to);
        _checkBalance(msg.sender, _value);
        _transfer(msg.sender, _to, _value);
        return true;
    }

    function approve(
        address _spender,
        uint256 _value
    ) external returns (bool success) {
        _checkAddress(_spender);
        _checkBalance(msg.sender, _value);
        allowances[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(
        address _owner,
        address _spender
    ) external view returns (uint256 remaining) {
        _checkAddress(_owner);
        _checkAddress(_spender);
        return allowances[_owner][_spender];
    }

    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    ) external returns (bool success) {
        _checkAddress(_from);
        _checkAddress(_to);
        allowances[_from][msg.sender] > _value;
        allowances[_from][msg.sender] -= _value;
        _transfer(_from, _to, _value);
        return true;
    }

    function deposit() public payable {
        require(msg.value > 0, "You need to use some ETH to swap.");
        _mint(msg.value, msg.sender);
        emit Deposit(msg.sender, msg.value);
    }

    function withdraw(uint amount) public payable {
        require(amount > 0, "You need to use some WETH to swap");
        require(balances[msg.sender] >= amount, "You don't have enough WETH.");
        balances[msg.sender] -= amount;
        payable(msg.sender).transfer(amount);
        emit Withdraw(msg.sender, amount);
    }

    function _mint(uint amount, address owner) private {
        balances[owner] += amount;
    }

    function _checkAddress(address _address) private pure {
        require(_address != address(0), "Invalid address.");
    }

    function _checkBalance(address _address, uint _value) private view {
        require(
            this.balanceOf(_address) > _value,
            "You don't have enough WETH."
        );
    }

    function _transfer(address _from, address _to, uint _value) private {
        require(
            balances[_from] >= _value,
            "The adress dosen't have enough WETH."
        );
        balances[_from] -= _value;
        balances[_to] += _value;
        emit Transfer(_from, _to, _value);
    }

    receive() external payable {
        _mint(msg.value, msg.sender);
    }

    fallback() external payable {
        _mint(msg.value, msg.sender);
    }
}
