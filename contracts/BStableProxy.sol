pragma solidity ^0.6.0;

import "./BEP20.sol";
import "./interfaces/IBEP20.sol";
import "./interfaces/IBStablePool.sol";
import "./interfaces/IBStableProxy.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "./lib/TransferHelper.sol";

// Proxy
contract BStableProxy is IBStableProxy, BEP20, Ownable, ReentrancyGuard {
    using SafeMath for uint256;

    address poolAddress;
    address[] coins;
    address upgradeTo;
    address revertTo;
    bool _deprecated = false;

    constructor(
        string memory _name,
        string memory _symbol,
        address[] memory _coins
    ) public BEP20(_name, _symbol) {
        transferOwnership(msg.sender);
        for (uint256 i = 0; i < _coins.length; i++) {
            require(_coins[i] != address(0), "BNB is not support.");
        }
        coins = _coins;
    }

    function A() external view returns (uint256 A1) {
        require(poolAddress != address(0), "address(0) can't be a pool");
        A1 = IBStablePool(poolAddress).A();
    }

    function get_virtual_price() external view returns (uint256 price) {
        require(poolAddress != address(0), "address(0) can't be a pool");
        price = IBStablePool(poolAddress).get_virtual_price();
    }

    function calc_token_amount(uint256[] calldata amounts, bool deposit)
        external
        view
        returns (uint256 result)
    {
        require(poolAddress != address(0), "address(0) can't be a pool");
        result = IBStablePool(poolAddress).calc_token_amount(amounts, deposit);
    }

    function add_liquidity(uint256[] calldata amounts, uint256 min_mint_amount)
        external
        nonReentrant
    {
        require(_deprecated == false, "derecated");
        require(poolAddress != address(0), "address(0) can't be a pool");
        for (uint256 i = 0; i < coins.length; i++) {
            TransferHelper.safeTransferFrom(
                coins[i],
                msg.sender,
                address(this),
                amounts[i]
            );
            TransferHelper.safeApprove(coins[i], poolAddress, amounts[i]);
        }
        IBStablePool(poolAddress).add_liquidity(amounts, min_mint_amount);
        uint256 lpBalance = IBStablePool(poolAddress).balanceOf(address(this));
        TransferHelper.safeTransfer(poolAddress, msg.sender, lpBalance);
    }

    function get_dy(
        uint256 i,
        uint256 j,
        uint256 dx
    ) external view returns (uint256 result) {
        require(poolAddress != address(0), "address(0) can't be a pool");
        result = IBStablePool(poolAddress).get_dy(i, j, dx);
    }

    function get_dy_underlying(
        uint256 i,
        uint256 j,
        uint256 dx
    ) external view returns (uint256 result) {
        require(poolAddress != address(0), "address(0) can't be a pool");
        result = IBStablePool(poolAddress).get_dy_underlying(i, j, dx);
    }

    function exchange(
        uint256 i,
        uint256 j,
        uint256 dx,
        uint256 min_dy
    ) external nonReentrant {
        require(_deprecated == false, "derecated");
        require(poolAddress != address(0), "address(0) can't be a pool");
        TransferHelper.safeTransferFrom(
            coins[i],
            msg.sender,
            address(this),
            dx
        );
        TransferHelper.safeApprove(coins[i], poolAddress, dx);
        IBStablePool(poolAddress).exchange(i, j, dx, min_dy);
        uint256 dy = IBEP20(coins[j]).balanceOf(address(this));
        TransferHelper.safeTransfer(coins[j], msg.sender, dy);
    }

    function remove_liquidity(uint256 _amount, uint256[] calldata min_amounts)
        external
        nonReentrant
    {
        require(_deprecated == false, "derecated");
        require(poolAddress != address(0), "address(0) can't be a pool");
        TransferHelper.safeTransferFrom(
            poolAddress,
            msg.sender,
            address(this),
            _amount
        );
        IBStablePool(poolAddress).remove_liquidity(_amount, min_amounts);
        uint256 lpBalance = IBStablePool(poolAddress).balanceOf(address(this));
        if (lpBalance > 0) {
            TransferHelper.safeTransfer(poolAddress, msg.sender, lpBalance);
        }
        for (uint256 i = 0; i < coins.length; i++) {
            uint256 balance = IBEP20(coins[i]).balanceOf(address(this));
            TransferHelper.safeTransfer(coins[i], msg.sender, balance);
        }
    }

    function remove_liquidity_imbalance(
        uint256[] calldata amounts,
        uint256 max_burn_amount
    ) external nonReentrant {
        require(_deprecated == false, "derecated");
        require(poolAddress != address(0), "address(0) can't be a pool");
        TransferHelper.safeTransferFrom(
            poolAddress,
            msg.sender,
            address(this),
            max_burn_amount
        );
        IBStablePool(poolAddress).remove_liquidity_imbalance(
            amounts,
            max_burn_amount
        );
        uint256 lpBalance = IBStablePool(poolAddress).balanceOf(address(this));
        if (lpBalance > 0) {
            TransferHelper.safeTransfer(poolAddress, msg.sender, lpBalance);
        }
        for (uint256 i = 0; i < coins.length; i++) {
            uint256 balance = IBEP20(coins[i]).balanceOf(address(this));
            TransferHelper.safeTransfer(coins[i], msg.sender, balance);
        }
    }

    function calc_withdraw_one_coin(uint256 _token_amount, uint256 i)
        external
        view
        returns (uint256 result)
    {
        require(poolAddress != address(0), "address(0) can't be a pool");
        result = IBStablePool(poolAddress).calc_withdraw_one_coin(
            _token_amount,
            i
        );
    }

    function remove_liquidity_one_coin(
        uint256 _token_amount,
        uint256 i,
        uint256 min_amount
    ) external nonReentrant {
        require(_deprecated == false, "derecated");
        require(poolAddress != address(0), "address(0) can't be a pool");
        TransferHelper.safeTransferFrom(
            poolAddress,
            msg.sender,
            address(this),
            _token_amount
        );
        IBStablePool(poolAddress).remove_liquidity_one_coin(
            _token_amount,
            i,
            min_amount
        );
        uint256 lpBalance = IBStablePool(poolAddress).balanceOf(address(this));
        if (lpBalance > 0) {
            TransferHelper.safeTransfer(poolAddress, msg.sender, lpBalance);
        }
        uint256 iBalance = IBEP20(coins[i]).balanceOf(address(this));
        TransferHelper.safeTransfer(coins[i], msg.sender, iBalance);
    }

    function getPoolAddress() external view returns (address _poolAddress) {
        _poolAddress = poolAddress;
    }

    function getUpgradeTo()
        external
        override
        view
        returns (address _upgradeTo)
    {
        if (upgradeTo != address(0)) {
            _upgradeTo = upgradeTo;
        } else {
            _upgradeTo = address(0);
        }
    }

    function getRevertTo() external view returns (address _revertTo) {
        _revertTo = revertTo;
    }

    function poolOwner() external view returns (address _poolOwner) {
        if (poolAddress != address(0)) {
            _poolOwner = IBStablePool(poolAddress).owner();
        } else {
            _poolOwner = address(0);
        }
    }

    function isDeprecated() external view returns (bool _r) {
        _r = _deprecated;
    }

    function ready() external view returns (bool _r) {
        if (
            poolAddress != address(0) &&
            IBStablePool(poolAddress).owner() == address(this) &&
            revertTo != address(0) &&
            _deprecated == false
        ) {
            _r = true;
        } else {
            _r = false;
        }
    }

    // Owner only

    function ramp_A(uint256 _future_A, uint256 _future_time)
        external
        onlyOwner
    {
        require(poolAddress != address(0), "address(0) can't be a pool");
        IBStablePool(poolAddress).ramp_A(_future_A, _future_time);
    }

    function stop_ramp_A() external onlyOwner {
        require(poolAddress != address(0), "address(0) can't be a pool");
        IBStablePool(poolAddress).stop_ramp_A();
    }

    function commit_new_fee(uint256 new_fee, uint256 new_admin_fee)
        external
        onlyOwner
    {
        require(poolAddress != address(0), "address(0) can't be a pool");
        IBStablePool(poolAddress).commit_new_fee(new_fee, new_admin_fee);
    }

    function apply_new_fee() external onlyOwner {
        require(poolAddress != address(0), "address(0) can't be a pool");
        IBStablePool(poolAddress).apply_new_fee();
    }

    function revert_new_parameters() external onlyOwner {
        require(poolAddress != address(0), "address(0) can't be a pool");
        IBStablePool(poolAddress).revert_new_parameters();
    }

    function revert_transfer_ownership() external onlyOwner {
        require(poolAddress != address(0), "address(0) can't be a pool");
        IBStablePool(poolAddress).revert_transfer_ownership();
    }

    function admin_balances(uint256 i) external view returns (uint256 balance) {
        require(poolAddress != address(0), "address(0) can't be a pool");
        return IBStablePool(poolAddress).admin_balances(i);
    }

    function withdraw_admin_fees() external onlyOwner {
        require(poolAddress != address(0), "address(0) can't be a pool");
        IBStablePool(poolAddress).withdraw_admin_fees();
        for (uint256 i = 0; i < coins.length; i++) {
            address c = coins[i];
            uint256 value = IBEP20(c).balanceOf(address(this));
            if (value > 0) {
                TransferHelper.safeTransfer(c, msg.sender, value);
            }
        }
    }

    function donate_admin_fees() external onlyOwner {
        require(poolAddress != address(0), "address(0) can't be a pool");
        IBStablePool(poolAddress).donate_admin_fees();
    }

    function kill_me() external onlyOwner {
        require(poolAddress != address(0), "address(0) can't be a pool");
        IBStablePool(poolAddress).kill_me();
    }

    function unkill_me() external onlyOwner {
        require(poolAddress != address(0), "address(0) can't be a pool");
        IBStablePool(poolAddress).unkill_me();
    }

    function transferPoolOwnership(address nOwner) external onlyOwner {
        _transferPoolOwnership(nOwner);
    }

    function _transferPoolOwnership(address nOwner) internal {
        require(nOwner != address(0), "address(0) can't be an owner");
        IBStablePool(poolAddress).transferOwnership(nOwner);
    }

    function setPoolAddress(address _poolAddress) external override onlyOwner {
        require(_poolAddress != address(0), "address(0) can't be a pool");
        poolAddress = _poolAddress;
    }

    function setUpgradeTo(address _upgradeTo) external override onlyOwner {
        require(_upgradeTo != address(0), "can't upgrade to address(0)");
        upgradeTo = _upgradeTo;
    }

    function upgrade(address _upgradeTo) external override onlyOwner {
        require(_upgradeTo != address(0), "can't upgrade to address(0)");
        require(upgradeTo == _upgradeTo, "the target address wrong");
        _transferPoolOwnership(upgradeTo);
        _deprecated = true;
    }

    function setRevertTo(address _revertTo) external override onlyOwner {
        require(_revertTo != address(0), "can't revert to address(0)");
        address _upgradeTo = IBStableProxy(_revertTo).getUpgradeTo();
        require(_upgradeTo == address(this), "can't set other address");
        revertTo = _revertTo;
    }

    function rollBack(address _revertTo) external override onlyOwner {
        require(_revertTo == revertTo, "roll back target wrong.");
        _transferPoolOwnership(revertTo);
        _deprecated = true;
    }

    function undeprecated() external onlyOwner {
        _deprecated = false;
    }

    function deprecated() external onlyOwner {
        _deprecated = true;
    }
}
