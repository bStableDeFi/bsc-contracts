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

    PoolInfo[] pools;
    uint256 totalAllocPoint = 0;
    address tokenAddress;
    mapping(uint256 => mapping(address => UserInfo)) userInfo;

    address upgradeTo;
    address revertTo;
    bool _deprecated = false;

    constructor(address _tokenAddress)
        public
        BEP20("bStable Pools Proxy", "BSPP-V1")
    {
        transferOwnership(msg.sender);
        tokenAddress = _tokenAddress;
    }

    function addPool(
        address _poolAddress,
        address[] calldata _coins,
        uint256 _allocPoint
    ) external onlyOwner {
        totalAllocPoint = totalAllocPoint.add(_allocPoint);
        pools.push(
            PoolInfo({
                poolAddress: _poolAddress,
                coins: _coins,
                allocPoint: _allocPoint,
                accTokenPerShare: 0,
                shareRewardRate: 500_000_000_000_000_000,
                swapRewardRate: 500_000_000_000_000_000,
                totalVolAccPoints: 0,
                totalVolReward: 0,
                lastUpdateTime: block.timestamp
            })
        );
    }

    function setPoolRewardRate(
        uint256 _pid,
        uint256 shareRate,
        uint256 swapRate
    ) external {
        require(
            shareRate.add(swapRate) <= 1_000_000_000_000_000_000,
            "sum rate lower then 100%"
        );
        pools[_pid].shareRewardRate = shareRate;
        pools[_pid].swapRewardRate = swapRate;
    }

    function setPoolCoins(uint256 _pid, address[] calldata _coins) external {
        pools[_pid].coins = _coins;
    }

    function setPoolAllocPoint(uint256 _pid, uint256 _allocPoint)
        external
        onlyOwner
    {
        totalAllocPoint = totalAllocPoint.sub(pools[_pid].allocPoint).add(
            _allocPoint
        );
        pools[_pid].allocPoint = _allocPoint;
    }

    function A(uint256 _pid) external view returns (uint256 A1) {
        require(
            pools[_pid].poolAddress != address(0),
            "address(0) can't be a pool"
        );
        A1 = IBStablePool(pools[_pid].poolAddress).A();
    }

    function get_virtual_price(uint256 _pid)
        external
        view
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
    ) external view returns (uint256 result) {
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
    ) external nonReentrant {
        require(_deprecated == false, "derecated");
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
    ) external view returns (uint256 result) {
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
    ) external view returns (uint256 result) {
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
    ) external nonReentrant {
        require(_deprecated == false, "derecated");
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
        uint256 accPoints = dy.div(dx).mul(dy); // 当前交易积分
        uint256 tokenAmt = IBEP20(tokenAddress).balanceOf(address(this)).mul(
            pools[_pid].swapRewardRate.div(10**18)
        ); // 可发放奖励的数量
        uint256 rewardAmt = pools[_pid]
            .totalVolReward
            .add(tokenAmt)
            .mul(accPoints)
            .div(accPoints.add(pools[_pid].totalVolAccPoints)); // 奖励数量=（之前发放的数量+当前剩余的奖励数量）*本次交易积分/（之前的总交易积分+本次交易积分）
        TransferHelper.safeTransfer(tokenAddress, msg.sender, rewardAmt);
        pools[_pid].totalVolReward = pools[_pid].totalVolReward.add(
            rewardAmt
        );
        pools[_pid].totalVolAccPoints = pools[_pid].totalVolAccPoints.add(accPoints);
    }

    function remove_liquidity(
        uint256 _pid,
        uint256 _amount,
        uint256[] calldata min_amounts
    ) external nonReentrant {
        require(_deprecated == false, "derecated");
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
    ) external nonReentrant {
        require(_deprecated == false, "derecated");
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
    ) external view returns (uint256 result) {
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
    ) external nonReentrant {
        require(_deprecated == false, "derecated");
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
        returns (address _poolAddress)
    {
        _poolAddress = pools[_pid].poolAddress;
    }

    function pendingReward(uint256 _pid, address _user)
        external
        view
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

    function massUpdatePools() external {
        uint256 length = pools.length;
        for (uint256 pid = 0; pid < length; ++pid) {
            updatePool(pid);
        }
    }

    function updatePool(uint256 _pid) public {
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

    function deposit(uint256 _pid, uint256 _amount) external {
        PoolInfo storage pool = pools[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
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

    function withdraw(uint256 _pid, uint256 _amount) external {
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

    function emergencyWithdraw(uint256 _pid) external {
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
}
