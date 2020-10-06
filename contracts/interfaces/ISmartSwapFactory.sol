pragma solidity >=0.5.0;

interface ISmartSwapFactory {
    event PoolCreated(address indexed token0, address indexed token1, address pool, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPool(address tokenA, address tokenB) external view returns (address pool);
    function allPools(uint) external view returns (address pool);
    function allPoolsLength() external view returns (uint);

    function createPool(address tokenA, address tokenB) external returns (address pool);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}
