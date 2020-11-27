pragma solidity ^0.6.0;
import "../interfaces/IBEP20.sol";

interface IBStablePool is IBEP20 {
    function A() external view returns (uint256 A1);

    function get_virtual_price() external view returns (uint256 price);

    function calc_token_amount(uint256[] calldata amounts, bool deposit)
        external
        view
        returns (uint256 result);

    function add_liquidity(uint256[] calldata amounts, uint256 min_mint_amount)
        external;

    function get_dy(
        uint256 i,
        uint256 j,
        uint256 dx
    ) external view returns (uint256 result);

    function get_dy_underlying(
        uint256 i,
        uint256 j,
        uint256 dx
    ) external view returns (uint256 result);

    function exchange(
        uint256 i,
        uint256 j,
        uint256 dx,
        uint256 min_dy
    ) external;

    function remove_liquidity(uint256 _amount, uint256[] calldata min_amounts)
        external;

    function remove_liquidity_imbalance(
        uint256[] calldata amounts,
        uint256 max_burn_amount
    ) external;

    function calc_withdraw_one_coin(uint256 _token_amount, uint256 i)
        external
        view
        returns (uint256 result);

    function remove_liquidity_one_coin(
        uint256 _token_amount,
        uint256 i,
        uint256 min_amount
    ) external;

    function ramp_A(uint256 _future_A, uint256 _future_time) external;

    function stop_ramp_A() external;

    function commit_new_fee(uint256 new_fee, uint256 new_admin_fee) external;

    function apply_new_fee() external;

    function revert_new_parameters() external;

    function revert_transfer_ownership() external;

    function admin_balances(uint256 i) external view returns (uint256 balance);

    function withdraw_admin_fees() external;

    function donate_admin_fees() external;

    function kill_me() external;

    function unkill_me() external;

    function transferOwnership(address newOwner) external;

    function owner() external view returns (address _owner);
}
