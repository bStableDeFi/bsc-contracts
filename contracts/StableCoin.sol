pragma solidity ^0.6.0;

import "./BEP20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

// for test, we create stable coin for ourself.
contract StableCoin is BEP20, Ownable {
    using SafeMath for uint256;

    constructor(
        string memory _name,
        string memory _symbol,
        uint256 _totalSupply
    ) public BEP20(_name, _symbol) {
        transferOwnership(msg.sender);
        _mint(msg.sender, _totalSupply);
    }
}
