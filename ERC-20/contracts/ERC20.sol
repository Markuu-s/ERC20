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

    address private burner;
    address private minter;

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

        minter = _minter;
        burner = _burner;
    }

    function balanceOf(address _owner) public view returns (uint256 balance) {
        require(_owner != address(0));
        return balances[_owner];
    }

    function transfer(address _to, uint256 _value)
        public
        returns (bool success)
    {
        require(_to != msg.sender);
        require(balances[msg.sender] >= _value);
        require(_to != address(0));

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
        require(balances[_from] >= _value);
        require(_from != address(0));
        require(_to != address(0));
        require(_from != _to);
        require(allow[_from][msg.sender] >= _value);

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
        require(_spender != address(0));

        allow[msg.sender][_spender] = _value;

        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender)
        public
        view
        returns (uint256 remaining)
    {
        require(_owner != address(0));
        require(_spender != address(0));

        return allow[_owner][_spender];
    }

    function burn(address _from, uint256 _value) public onlyRole(burner) {
        totalSupply[_from] -= _value;
        balances[_from] -= _value;
        emit Transfer(_from, address(0), _value);
    }

    function mint(address _to, uint256 _value) public onlyRole(minter) {
        totalSupply[_to] += _value;
        balances[_to] += _value;
        emit Transfer(address(0), _to, _value);
    }
}
