pragma solidity 0.8.6;

import "@openzeppelin/contracts/access/AccessControl.sol";

contract ERC20 is AccessControl {
    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public totalSupply;

    mapping(address => uint256) private balances;
    mapping(address => mapping(address => uint256)) private allow;
    address private admin;

    bytes32 public constant BURNER_ROLE = keccak256("BURNER_ROLE");
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(
        address indexed _owner,
        address indexed _spender,
        uint256 _value
    );

    constructor(
        string memory _name,
        string memory _symbol,
        uint8 _decimals,
        uint256 _totalSupply,
        address _burner,
        address _minter
    ) {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        totalSupply = _totalSupply;

        balances[msg.sender] = _totalSupply;
        admin = msg.sender;

        _setupRole(MINTER_ROLE, _minter);
        _setupRole(BURNER_ROLE, _burner);
    }

    function balanceOf(address _owner) public view returns (uint256 balance) {
        require(_owner != address(0), "Address must be exist");
        return balances[_owner];
    }

    function transfer(address _to, uint256 _value)
    public
    returns (bool success)
    {
        require(_to != msg.sender, "Not allow transer himself");
        require(balances[msg.sender] >= _value, "Balance should be a more or equal of value");
        require(_to != address(0), "Address _to is exist");

        balances[msg.sender] -= _value;
        balances[_to] += _value;

        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    ) public returns (bool success) {
        require(balances[_from] >= _value, "Balance _from should be more or equal of value");
        require(_from != address(0), "Address _from should be exist");
        require(_to != address(0), "Address _to should be exist");
        require(_from != _to, "Addresses _from and _to should not be equal");
        require(allow[_from][msg.sender] >= _value, "Allow should be more or equal of value");

        balances[_from] -= _value;
        balances[_to] += _value;

        allow[_from][msg.sender] -= _value;

        emit Transfer(_from, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value)
    public
    returns (bool success)
    {
        require(_spender != address(0), "Address of spender should be exist");

        allow[msg.sender][_spender] = _value;

        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender)
    public
    view
    returns (uint256 remaining)
    {
        require(_owner != address(0), "Address _owner should be exist");
        require(_spender != address(0), "Address _spender should be exist");

        return allow[_owner][_spender];
    }

    function burn(address _from, uint256 _value) public onlyRole(BURNER_ROLE) {
        require(
            totalSupply >= _value,
            "TotalSupply should be more or equal of value"
        );
        totalSupply -= _value;
        balances[_from] -= _value;
        emit Transfer(_from, address(0), _value);
    }

    function mint(address _to, uint256 _value) public onlyRole(MINTER_ROLE) {
        totalSupply += _value;
        balances[_to] += _value;
        emit Transfer(address(0), _to, _value);
    }
}
