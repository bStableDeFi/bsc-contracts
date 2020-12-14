pragma solidity ^0.6.0;

import "./BEP20.sol";
import "./interfaces/IBEP20.sol";
import "./interfaces/IBStablePool.sol";
import "./interfaces/IBStableProxy.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "./lib/TransferHelper.sol";

interface IBStableToken is IBEP20 {
    function mint(address to, uint256 amount) external;

    function availableSupply() external view returns (uint256 result);
}

// Proxy
contract BStableProxy is IBStableProxy, BEP20, Ownable, ReentrancyGuard {
    using SafeMath for uint256;

    struct PoolInfo {
        address poolAddress;
        address[] coins;
        uint256 allocPoint;
        uint256 accTokenPerShare;
        uint256 shareRewardRate; //  share reward percent of total release amount. wei
        uint256 swapRewardRate; //  swap reward percent of total release amount.  wei
        uint256 totalVolAccPoints; // total volume accumulate points. wei, 总交易积分
        uint256 totalVolReward; // total volume reword. wei 总发放的交易奖励数量
        uint256 lastUpdateTime;
    }
    struct UserInfo {
        uint256 amount; // How many LP tokens the user has provided.
        uint256 volume; // swap volume.
        uint256 rewardDebt; // Reward debt. See explanation below.
    }

    event Deposit(address indexed user, uint256 indexed pid, uint256 amount);
    event Withdraw(address indexed user, uint256 indexed pid, uint256 amount);
    event EmergencyWithdraw(
        address indexed user,
        uint256 indexed pid,
        uint256 amount
    );

    // state data
    PoolInfo[] pools;
    mapping(uint256 => address[]) poolUsers;
    uint256 totalAllocPoint = 0;
    address tokenAddress;
    mapping(uint256 => mapping(address => UserInfo)) userInfo;

    bool _openMigration = false;
    address migrateFrom;

    modifier noOpenMigration() {
        require(!_openMigration, "a migration is open.");
        _;
    }

    constructor(address _tokenAddress)
        public
        BEP20("bStable Pools Proxy", "BSPP-V1")
    {
        transferOwnership(msg.sender);
        tokenAddress = _tokenAddress;
    }

    function getPoolInfo(uint256 _pid)
        public
        view
        returns (
            address _poolAddress,
            address[] memory _coins,
            uint256 _allocPoint,
            uint256 _accTokenPerShare,
            uint256 _shareRewardRate,
            uint256 _swapRewardRate,
            uint256 _totalVolAccPoints,
            uint256 _totalVolReward,
            uint256 _lastUpdateTime
        )
    {
        _poolAddress = pools[_pid].poolAddress;
        _coins = pools[_pid].coins;
        _allocPoint = pools[_pid].allocPoint;
        _accTokenPerShare = pools[_pid].accTokenPerShare;
        _shareRewardRate = pools[_pid].shareRewardRate;
        _swapRewardRate = pools[_pid].swapRewardRate;
        _totalVolAccPoints = pools[_pid].totalVolAccPoints;
        _totalVolReward = pools[_pid].totalVolReward;
        _lastUpdateTime = pools[_pid].lastUpdateTime;
    }

    function getTokenAddress() public view returns (address taddress) {
        taddress = tokenAddress;
    }

    function getUserInfo(uint256 _pid, address user)
        public
        view
        returns (
            uint256 _amount,
            uint256 _volume,
            uint256 _rewardDebt
        )
    {
        _amount = userInfo[_pid][user].amount;
        _volume = userInfo[_pid][user].volume;
        _rewardDebt = userInfo[_pid][user].rewardDebt;
    }

    function getPoolUsers(uint256 _pid)
        public
        view
        returns (address[] memory _users)
    {
        _users = poolUsers[_pid];
    }

    function getPoolsLength() public view returns (uint256 l) {
        l = pools.length;
    }

    function getTotalAllocPoint() public view returns (uint256 r) {
        r = totalAllocPoint;
    }

    function isMigrationOpen() external view returns (bool r) {
        r = _openMigration;
    }

    function A(uint256 _pid)
        external
        view
        noOpenMigration
        returns (uint256 A1)
    {
        require(
            pools[_pid].poolAddress != address(0),
            "address(0) can't be a pool"
        );
        A1 = IBStablePool(pools[_pid].poolAddress).A();
    }

    function get_virtual_price(uint256 _pid)
        external
        view
        noOpenMigration
        returns (uint256 price)
    {
        require(
            pools[_pid].poolAddress != address(0),
            "address(0) can't be a pool"
        );
        price = IBStablePool(pools[_pid].poolAddress).get_virtual_price();
    }

    function calc_token_amount(
        uint256 _pid,
        uint256[] calldata amounts,
        bool deposit
    ) external view noOpenMigration returns (uint256 result) {
        require(
            pools[_pid].poolAddress != address(0),
            "address(0) can't be a pool"
        );
        result = IBStablePool(pools[_pid].poolAddress).calc_token_amount(
            amounts,
            deposit
        );
    }

    function add_liquidity(
        uint256 _pid,
        uint256[] calldata amounts,
        uint256 min_mint_amount
    ) external nonReentrant noOpenMigration {
        require(
            pools[_pid].poolAddress != address(0),
            "address(0) can't be a pool"
        );
        for (uint256 i = 0; i < pools[_pid].coins.length; i++) {
            TransferHelper.safeTransferFrom(
                pools[_pid].coins[i],
                msg.sender,
                address(this),
                amounts[i]
            );
            TransferHelper.safeApprove(
                pools[_pid].coins[i],
                pools[_pid].poolAddress,
                amounts[i]
            );
        }
        IBStablePool(pools[_pid].poolAddress).add_liquidity(
            amounts,
            min_mint_amount
        );
        uint256 lpBalance = IBStablePool(pools[_pid].poolAddress).balanceOf(
            address(this)
        );
        TransferHelper.safeTransfer(
            pools[_pid].poolAddress,
            msg.sender,
            lpBalance
        );
    }

    function get_dy(
        uint256 _pid,
        uint256 i,
        uint256 j,
        uint256 dx
    ) external view noOpenMigration returns (uint256 result) {
        require(
            pools[_pid].poolAddress != address(0),
            "address(0) can't be a pool"
        );
        result = IBStablePool(pools[_pid].poolAddress).get_dy(i, j, dx);
    }

    function get_dy_underlying(
        uint256 _pid,
        uint256 i,
        uint256 j,
        uint256 dx
    ) external view noOpenMigration returns (uint256 result) {
        require(
            pools[_pid].poolAddress != address(0),
            "address(0) can't be a pool"
        );
        result = IBStablePool(pools[_pid].poolAddress).get_dy_underlying(
            i,
            j,
            dx
        );
    }

    function exchange(
        uint256 _pid,
        uint256 i,
        uint256 j,
        uint256 dx,
        uint256 min_dy
    ) external nonReentrant noOpenMigration {
        require(
            pools[_pid].poolAddress != address(0),
            "address(0) can't be a pool"
        );
        updatePool(_pid);
        TransferHelper.safeTransferFrom(
            pools[_pid].coins[i],
            msg.sender,
            address(this),
            dx
        );
        TransferHelper.safeApprove(
            pools[_pid].coins[i],
            pools[_pid].poolAddress,
            dx
        );
        IBStablePool(pools[_pid].poolAddress).exchange(i, j, dx, min_dy);
        uint256 dy = IBEP20(pools[_pid].coins[j]).balanceOf(address(this));
        TransferHelper.safeTransfer(pools[_pid].coins[j], msg.sender, dy);
        uint256 accPoints = dy.div(dx).mul(dy);
        uint256 tokenAmt = IBEP20(tokenAddress).balanceOf(address(this)).mul(
            pools[_pid].swapRewardRate.div(10**18)
        );
        uint256 rewardAmt = pools[_pid]
            .totalVolReward
            .add(tokenAmt)
            .mul(accPoints)
            .div(accPoints.add(pools[_pid].totalVolAccPoints));
        TransferHelper.safeTransfer(tokenAddress, msg.sender, rewardAmt);
        pools[_pid].totalVolReward = pools[_pid].totalVolReward.add(rewardAmt);
        pools[_pid].totalVolAccPoints = pools[_pid].totalVolAccPoints.add(
            accPoints
        );
    }

    function remove_liquidity(
        uint256 _pid,
        uint256 _amount,
        uint256[] calldata min_amounts
    ) external nonReentrant noOpenMigration {
        require(
            pools[_pid].poolAddress != address(0),
            "address(0) can't be a pool"
        );
        TransferHelper.safeTransferFrom(
            pools[_pid].poolAddress,
            msg.sender,
            address(this),
            _amount
        );
        IBStablePool(pools[_pid].poolAddress).remove_liquidity(
            _amount,
            min_amounts
        );
        uint256 lpBalance = IBStablePool(pools[_pid].poolAddress).balanceOf(
            address(this)
        );
        if (lpBalance > 0) {
            TransferHelper.safeTransfer(
                pools[_pid].poolAddress,
                msg.sender,
                lpBalance
            );
        }
        for (uint256 i = 0; i < pools[_pid].coins.length; i++) {
            uint256 balance = IBEP20(pools[_pid].coins[i]).balanceOf(
                address(this)
            );
            TransferHelper.safeTransfer(
                pools[_pid].coins[i],
                msg.sender,
                balance
            );
        }
    }

    function remove_liquidity_imbalance(
        uint256 _pid,
        uint256[] calldata amounts,
        uint256 max_burn_amount
    ) external nonReentrant noOpenMigration {
        require(
            pools[_pid].poolAddress != address(0),
            "address(0) can't be a pool"
        );
        TransferHelper.safeTransferFrom(
            pools[_pid].poolAddress,
            msg.sender,
            address(this),
            max_burn_amount
        );
        IBStablePool(pools[_pid].poolAddress).remove_liquidity_imbalance(
            amounts,
            max_burn_amount
        );
        uint256 lpBalance = IBStablePool(pools[_pid].poolAddress).balanceOf(
            address(this)
        );
        if (lpBalance > 0) {
            TransferHelper.safeTransfer(
                pools[_pid].poolAddress,
                msg.sender,
                lpBalance
            );
        }
        for (uint256 i = 0; i < pools[_pid].coins.length; i++) {
            uint256 balance = IBEP20(pools[_pid].coins[i]).balanceOf(
                address(this)
            );
            TransferHelper.safeTransfer(
                pools[_pid].coins[i],
                msg.sender,
                balance
            );
        }
    }

    function calc_withdraw_one_coin(
        uint256 _pid,
        uint256 _token_amount,
        uint256 i
    ) external view noOpenMigration returns (uint256 result) {
        require(
            pools[_pid].poolAddress != address(0),
            "address(0) can't be a pool"
        );
        result = IBStablePool(pools[_pid].poolAddress).calc_withdraw_one_coin(
            _token_amount,
            i
        );
    }

    function remove_liquidity_one_coin(
        uint256 _pid,
        uint256 _token_amount,
        uint256 i,
        uint256 min_amount
    ) external nonReentrant noOpenMigration {
        require(
            pools[_pid].poolAddress != address(0),
            "address(0) can't be a pool"
        );
        TransferHelper.safeTransferFrom(
            pools[_pid].poolAddress,
            msg.sender,
            address(this),
            _token_amount
        );
        IBStablePool(pools[_pid].poolAddress).remove_liquidity_one_coin(
            _token_amount,
            i,
            min_amount
        );
        uint256 lpBalance = IBStablePool(pools[_pid].poolAddress).balanceOf(
            address(this)
        );
        if (lpBalance > 0) {
            TransferHelper.safeTransfer(
                pools[_pid].poolAddress,
                msg.sender,
                lpBalance
            );
        }
        uint256 iBalance = IBEP20(pools[_pid].coins[i]).balanceOf(
            address(this)
        );
        TransferHelper.safeTransfer(pools[_pid].coins[i], msg.sender, iBalance);
    }

    function getPoolAddress(uint256 _pid)
        external
        view
        noOpenMigration
        returns (address _poolAddress)
    {
        _poolAddress = pools[_pid].poolAddress;
    }

    function pendingReward(uint256 _pid, address _user)
        external
        view
        noOpenMigration
        returns (uint256)
    {
        PoolInfo storage pool = pools[_pid];
        UserInfo storage user = userInfo[_pid][_user];
        uint256 accSushiPerShare = pool.accTokenPerShare;
        uint256 lpSupply = IBEP20(pool.poolAddress).balanceOf(address(this));
        if (lpSupply != 0) {
            uint256 releaseAmt = IBStableToken(tokenAddress)
                .availableSupply()
                .sub(IBStableToken(tokenAddress).totalSupply());
            uint256 reward = releaseAmt
                .mul(pool.shareRewardRate)
                .div(10**18)
                .mul(pool.allocPoint)
                .div(totalAllocPoint);
            accSushiPerShare = accSushiPerShare.add(
                reward.mul(10**18).div(lpSupply)
            );
        }
        return
            user.amount.mul(accSushiPerShare).div(10**18).sub(user.rewardDebt);
    }

    function massUpdatePools() external noOpenMigration {
        uint256 length = pools.length;
        for (uint256 pid = 0; pid < length; ++pid) {
            updatePool(pid);
        }
    }

    function updatePool(uint256 _pid) public noOpenMigration {
        PoolInfo storage pool = pools[_pid];
        if (block.number <= pool.lastUpdateTime) {
            return;
        }
        uint256 lpSupply = IBEP20(pool.poolAddress).balanceOf(address(this));
        if (lpSupply == 0) {
            pool.lastUpdateTime = block.number;
            return;
        }
        uint256 releaseAmt = IBStableToken(tokenAddress).availableSupply().sub(
            IBStableToken(tokenAddress).totalSupply()
        );
        uint256 mintAmt = releaseAmt.mul(pool.allocPoint).div(totalAllocPoint);
        uint256 reward = releaseAmt
            .mul(pool.shareRewardRate)
            .div(10**18)
            .mul(pool.allocPoint)
            .div(totalAllocPoint);
        IBStableToken(tokenAddress).mint(address(this), mintAmt);
        pool.accTokenPerShare = pool.accTokenPerShare.add(
            reward.mul(10**18).div(lpSupply)
        );
        pool.lastUpdateTime = block.number;
    }

    function deposit(uint256 _pid, uint256 _amount) external noOpenMigration {
        PoolInfo storage pool = pools[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        poolUsers[_pid].push(msg.sender);
        updatePool(_pid);
        if (user.amount > 0) {
            uint256 pending = user
                .amount
                .mul(pool.accTokenPerShare)
                .div(10**18)
                .sub(user.rewardDebt);
            if (pending > 0) {
                TransferHelper.safeTransfer(tokenAddress, msg.sender, pending);
            }
        }
        if (_amount > 0) {
            TransferHelper.safeTransferFrom(
                pool.poolAddress,
                msg.sender,
                address(this),
                _amount
            );
            user.amount = user.amount.add(_amount);
        }
        user.rewardDebt = user.amount.mul(pool.accTokenPerShare).div(10**18);
        emit Deposit(msg.sender, _pid, _amount);
    }

    function withdraw(uint256 _pid, uint256 _amount) external noOpenMigration {
        PoolInfo storage pool = pools[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        require(user.amount >= _amount, "withdraw: not good");
        updatePool(_pid);
        uint256 pending = user
            .amount
            .mul(pool.accTokenPerShare)
            .div(10**18)
            .sub(user.rewardDebt);
        if (pending > 0) {
            TransferHelper.safeTransfer(tokenAddress, msg.sender, pending);
        }
        if (_amount > 0) {
            user.amount = user.amount.sub(_amount);
            TransferHelper.safeTransfer(
                pool.poolAddress,
                address(msg.sender),
                _amount
            );
        }
        user.rewardDebt = user.amount.mul(pool.accTokenPerShare).div(10**18);
        emit Withdraw(msg.sender, _pid, _amount);
    }

    function emergencyWithdraw(uint256 _pid) external noOpenMigration {
        PoolInfo storage pool = pools[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        uint256 amount = user.amount;
        user.amount = 0;
        user.rewardDebt = 0;
        TransferHelper.safeTransfer(
            pool.poolAddress,
            address(msg.sender),
            amount
        );
        emit EmergencyWithdraw(msg.sender, _pid, amount);
    }

    // only owner

    function openMigration() external onlyOwner {
        _openMigration = true;
    }

    function closeMigration() external onlyOwner {
        _openMigration = false;
    }
}
