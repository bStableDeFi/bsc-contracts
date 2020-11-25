pragma solidity ^0.6.0;

import "../BEP20.sol";
import "../interfaces/IBEP20.sol";
import "../interfaces/IBStablePool.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "../lib/TransferHelper.sol";

// 本合约代理 QUSD, BUSD, USDT 兑换
contract BStableProxy01 is
    BEP20("bStable Proxy (DAI/BUSD/USDT)", "BSProxy-01"),
    Ownable,
    ReentrancyGuard
{
    using SafeMath for uint256;

    address poolAddress;
    address[] coins;

    constructor(address[] memory _coins, address _poolAddress) public {
        transferOwnership(msg.sender);
        for (uint256 i = 0; i < _coins.length; i++) {
            require(_coins[i] != address(0), "BNB is not support.");
        }
        coins = _coins;
        poolAddress = _poolAddress;
    }

    function A() external view returns (uint256 A1) {
        A1 = IBStablePool(poolAddress).A();
    }

    function get_virtual_price() external view returns (uint256 price) {
        price = IBStablePool(poolAddress).get_virtual_price();
    }

    function calc_token_amount(uint256[] calldata amounts, bool deposit)
        external
        view
        returns (uint256 result)
    {
        result = IBStablePool(poolAddress).calc_token_amount(amounts, deposit);
    }

    function add_liquidity(uint256[] calldata amounts, uint256 min_mint_amount)
        external
        nonReentrant
    {
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
        result = IBStablePool(poolAddress).get_dy(i, j, dx);
    }

    function get_dy_underlying(
        uint256 i,
        uint256 j,
        uint256 dx
    ) external view returns (uint256 result) {
        result = IBStablePool(poolAddress).get_dy_underlying(i, j, dx);
    }

    function exchange(
        uint256 i,
        uint256 j,
        uint256 dx,
        uint256 min_dy
    ) external nonReentrant {
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
        TransferHelper.safeTransferFrom(
            poolAddress,
            msg.sender,
            address(this),
            max_burn_amount
        );
        IBStablePool(poolAddress).remove_liquidity_imbalance(amounts, max_burn_amount);
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
        result = IBStablePool(poolAddress).calc_withdraw_one_coin(_token_amount, i);
    }

    function remove_liquidity_one_coin(
        uint256 _token_amount,
        uint256 i,
        uint256 min_amount
    ) external nonReentrant {
        TransferHelper.safeTransferFrom(
            poolAddress,
            msg.sender,
            address(this),
            _token_amount
        );
        IBStablePool(poolAddress).remove_liquidity_one_coin(_token_amount, i, min_amount);
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

    // Owner only

    function ramp_A(uint256 _future_A, uint256 _future_time)
        external
        onlyOwner
    {
        IBStablePool(poolAddress).ramp_A(_future_A, _future_time);
    }

    function stop_ramp_A() external onlyOwner {
        IBStablePool(poolAddress).stop_ramp_A();
    }

    function commit_new_fee(uint256 new_fee, uint256 new_admin_fee)
        external
        onlyOwner
    {
        IBStablePool(poolAddress).commit_new_fee(new_fee, new_admin_fee);
    }

    function apply_new_fee() external onlyOwner {
        IBStablePool(poolAddress).apply_new_fee();
    }

    function revert_new_parameters() external onlyOwner {
        IBStablePool(poolAddress).revert_new_parameters();
    }

    function revert_transfer_ownership() external onlyOwner {
        IBStablePool(poolAddress).revert_transfer_ownership();
    }

    function admin_balances(uint256 i) external view returns (uint256 balance) {
        return IBStablePool(poolAddress).admin_balances(i);
    }

    function withdraw_admin_fees() external onlyOwner {
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
        IBStablePool(poolAddress).donate_admin_fees();
    }

    function kill_me() external onlyOwner {
        IBStablePool(poolAddress).kill_me();
    }

    function unkill_me() external onlyOwner {
        IBStablePool(poolAddress).unkill_me();
    }

    function transferPoolOwnership(address nOwner) external onlyOwner {
        require(nOwner != address(0), "address(0) can't be an owner");
        IBStablePool(poolAddress).transferOwnership(nOwner);
    }

    function setPoolAddress(address _poolAddress) external onlyOwner {
        require(_poolAddress != address(0), "address(0) can't be a pool");
        poolAddress = _poolAddress;
    }
}
