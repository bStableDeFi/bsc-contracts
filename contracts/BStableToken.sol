pragma solidity ^0.6.0;

import "./BEP20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract BStableToken is BEP20("bStable DAO Token", "BST"), Ownable {
    using SafeMath for uint256;
    address minter;

    uint256 YEAR = uint256(86400).mul(365);
    uint256 INITIAL_SUPPLY = 1_303_030_303;
    uint256 INITIAL_RATE = (274_815_283 * 10**18) / YEAR;
    uint256 RATE_REDUCTION_TIME = YEAR;
    uint256 RATE_REDUCTION_COEFFICIENT = 1189207115002721024;
    uint256 INFLATION_DELAY = 86400;

    int128 mining_epoch;
    uint256 start_epoch_time;
    uint256 rate;

    uint256 start_epoch_supply;

    event UpdateMiningParameters(uint256 time, uint256 rate, uint256 supply);

    event SetMinter(address minter);

    constructor() public {
        transferOwnership(msg.sender);
        uint256 init_supply = INITIAL_SUPPLY.mul(10**18);
        start_epoch_time = block.timestamp.add(INFLATION_DELAY).sub(
            RATE_REDUCTION_TIME
        );
        mining_epoch = -1;
        rate = 0;
        start_epoch_supply = init_supply;
    }

    function _update_mining_parameters() internal {
        uint256 _rate = rate;
        uint256 _start_epoch_supply = start_epoch_supply;

        start_epoch_time = start_epoch_time.add(RATE_REDUCTION_TIME);
        mining_epoch = mining_epoch + 1;

        if (_rate == 0) {
            _rate = INITIAL_RATE;
        } else {
            _start_epoch_supply = _start_epoch_supply.add(
                _rate.mul(RATE_REDUCTION_TIME)
            );
            start_epoch_supply = _start_epoch_supply;
            _rate = _rate.mul(10**18).div(RATE_REDUCTION_COEFFICIENT);
        }
        rate = _rate;
        emit UpdateMiningParameters(
            block.timestamp,
            _rate,
            _start_epoch_supply
        );
    }

    function start_epoch_time_write()
        external
        returns (uint256 _start_epoch_time)
    {
        if (block.timestamp >= _start_epoch_time.add(RATE_REDUCTION_TIME)) {
            _update_mining_parameters();
        }
        _start_epoch_time = start_epoch_time;
    }

    function future_epoch_time_write() external returns (uint256 result) {
        uint256 _start_epoch_time = start_epoch_time;
        if (block.timestamp >= _start_epoch_time.add(RATE_REDUCTION_TIME)) {
            _update_mining_parameters();
            result = start_epoch_time.add(RATE_REDUCTION_TIME);
        } else {
            result = _start_epoch_time.add(RATE_REDUCTION_TIME);
        }
    }

    function _available_supply() internal view returns (uint256 result) {
        result = start_epoch_supply
            .add(block.timestamp.sub(start_epoch_time))
            .mul(rate);
    }

    function available_supply() external view returns (uint256 result) {
        result = _available_supply();
    }

    function mintable_in_timeframe(uint256 start, uint256 end)
        external
        view
        returns (uint256 to_mint)
    {
        require(start <= end, "# dev: start > end");
        to_mint = 0;
        uint256 current_epoch_time = start_epoch_time;
        uint256 current_rate = rate;
        if (end > current_epoch_time.add(RATE_REDUCTION_TIME)) {
            current_epoch_time = current_epoch_time.add(RATE_REDUCTION_TIME);
            current_rate = current_rate.mul(10**18).div(
                RATE_REDUCTION_COEFFICIENT
            );
        }

        require(
            end <= current_epoch_time.add(RATE_REDUCTION_TIME),
            "# dev: too far in future"
        );

        for (uint256 i = 0; i < 1000; i++) {
            if (end >= current_epoch_time) {
                uint256 current_end = end;
                if (current_end > current_epoch_time.add(RATE_REDUCTION_TIME)) {
                    current_end = current_epoch_time.add(RATE_REDUCTION_TIME);
                }
                uint256 current_start = start;
                if (
                    current_start >= current_epoch_time.add(RATE_REDUCTION_TIME)
                ) {
                    break;
                } else if (current_start < current_epoch_time) {
                    current_start = current_epoch_time;
                }
                to_mint = to_mint.add(
                    current_rate.mul(current_end.sub(current_start))
                );
                if (start >= current_epoch_time) {
                    break;
                }
            }

            current_epoch_time = current_epoch_time.sub(RATE_REDUCTION_TIME);
            current_rate = current_rate.mul(RATE_REDUCTION_COEFFICIENT).div(
                10**18
            );
            require(
                current_rate <= INITIAL_RATE,
                "  # This should never happen"
            );
        }
    }

    function set_minter(address _minter) external onlyOwner {
        require(
            minter == address(0),
            "  # dev: can set the minter only once, at creation"
        );
        minter = _minter;
        emit SetMinter(_minter);
    }

    function mint(address _to, uint256 _value) external returns (bool r) {
        require(msg.sender == minter, "# dev: minter only");
        require(_to != address(0), " # dev: zero address");

        if (block.timestamp >= start_epoch_time.add(RATE_REDUCTION_TIME)) {
            _update_mining_parameters();
        }
        uint256 _total_supply = totalSupply().add(_value);
        require(
            _total_supply <= _available_supply(),
            "# dev: exceeds allowable mint amount"
        );
        _mint(_to, _value);
        r = true;
    }
}
