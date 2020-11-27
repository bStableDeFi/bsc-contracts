pragma solidity ^0.6.0;
import "../interfaces/IBEP20.sol";

interface IBStableProxy is IBEP20 {
    function setPoolAddress(address poolAddress) external;

    function upgrade(address upgradeTo) external;

    function setUpgradeTo(address _upgradeTo) external;

    function setRevertTo(address _revertTo) external;

    function rollBack(address _revertTo) external;

    function getUpgradeTo() external view returns (address upgradeTo);
}
