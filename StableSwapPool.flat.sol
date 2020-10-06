pragma solidity ^0.6.0;
abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }
    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}
pragma solidity ^0.6.0;
contract Ownable is Context {
    address private _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }
    function owner() public view returns (address) {
        return _owner;
    }
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}
pragma solidity ^0.6.0;
interface IBEP20 {
    function totalSupply() external view returns (uint256);
    function decimals() external view returns (uint8);
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address _owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}
pragma solidity ^0.6.0;
library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;
        return c;
    }
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}
pragma solidity ^0.6.2;
library Address {
    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly { size := extcodesize(account) }
        return size > 0;
    }
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
      return functionCall(target, data, "Address: low-level call failed");
    }
    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return _functionCallWithValue(target, data, 0, errorMessage);
    }
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }
    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        return _functionCallWithValue(target, data, value, errorMessage);
    }
    function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns (bytes memory) {
        require(isContract(target), "Address: call to non-contract");
        (bool success, bytes memory returndata) = target.call{ value: weiValue }(data);
        if (success) {
            return returndata;
        } else {
            if (returndata.length > 0) {
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}
pragma solidity ^0.6.0;
contract BEP20 is Context, IBEP20 {
    using SafeMath for uint256;
    using Address for address;
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    uint256 private _totalSupply;
    string private _name;
    string private _symbol;
    uint8 private _decimals;
    constructor(string memory name, string memory symbol) public {
        _name = name;
        _symbol = symbol;
        _decimals = 18;
    }
    function name() public override view returns (string memory) {
        return _name;
    }
    function symbol() public override view returns (string memory) {
        return _symbol;
    }
    function decimals() public override view returns (uint8) {
        return _decimals;
    }
    function totalSupply() public override view returns (uint256) {
        return _totalSupply;
    }
    function balanceOf(address account) public override view returns (uint256) {
        return _balances[account];
    }
    function transfer(address recipient, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }
    function allowance(address owner, address spender)
        public
        virtual
        override
        view
        returns (uint256)
    {
        return _allowances[owner][spender];
    }
    function approve(address spender, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
        _approve(_msgSender(), spender, amount);
        return true;
    }
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(
            sender,
            _msgSender(),
            _allowances[sender][_msgSender()].sub(
                amount,
                "BEP20: transfer amount exceeds allowance"
            )
        );
        return true;
    }
    function increaseAllowance(address spender, uint256 addedValue)
        public
        virtual
        returns (bool)
    {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender].add(addedValue)
        );
        return true;
    }
    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        virtual
        returns (bool)
    {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender].sub(
                subtractedValue,
                "BEP20: decreased allowance below zero"
            )
        );
        return true;
    }
    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(sender != address(0), "BEP20: transfer from the zero address");
        require(recipient != address(0), "BEP20: transfer to the zero address");
        _beforeTokenTransfer(sender, recipient, amount);
        _balances[sender] = _balances[sender].sub(
            amount,
            "BEP20: transfer amount exceeds balance"
        );
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "BEP20: mint to the zero address");
        _beforeTokenTransfer(address(0), account, amount);
        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "BEP20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        _balances[account] = _balances[account].sub(
            amount,
            "BEP20: burn amount exceeds balance"
        );
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "BEP20: approve from the zero address");
        require(spender != address(0), "BEP20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    function _setupDecimals(uint8 decimals_) internal {
        _decimals = decimals_;
    }
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}
pragma solidity ^0.6.0;
contract ReentrancyGuard {
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;
    uint256 private _status;
    constructor () internal {
        _status = _NOT_ENTERED;
    }
    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");
        _status = _ENTERED;
        _;
        _status = _NOT_ENTERED;
    }
}
pragma solidity >=0.6.0;
library TransferHelper {
    function safeApprove(address token, address to, uint value) internal {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: APPROVE_FAILED');
    }
    function safeTransfer(address token, address to, uint value) internal {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FAILED');
    }
    function safeTransferFrom(address token, address from, address to, uint value) internal {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FROM_FAILED');
    }
    function safeTransferBNB(address to, uint value) internal {
        (bool success,) = to.call{value:value}(new bytes(0));
        require(success, 'TransferHelper: BNB_TRANSFER_FAILED');
    }
}
pragma solidity ^0.6.0;
contract StableSwapPool is
    BEP20("Stable Smart Swap Pool", "sSSLP"),
    Ownable,
    ReentrancyGuard
{
    using SafeMath for uint256;
    uint256 private FEE_DENOMINATOR = 10**10;
    uint256 private LENDING_PRECISION = 10**18;
    uint256 private PRECISION = 10**18; // The precision to convert to
    uint256[] private PRECISION_MUL = [1, 1, 1];
    uint256[] private RATES = [
        1000000000000000000,
        1000000000000000000,
        1000000000000000000
    ];
    uint256 private FEE_INDEX = 2; // Which coin may potentially have fees (USDT)
    uint256 private MAX_ADMIN_FEE = 10 * 10**9;
    uint256 private MAX_FEE = 5 * 10**9;
    uint256 private MAX_A = 10**6;
    uint256 private MAX_A_CHANGE = 10;
    uint256 private ADMIN_ACTIONS_DELAY = 3 * 86400;
    uint256 private MIN_RAMP_TIME = 86400;
    address[] coins;
    uint256[] balances;
    uint256 fee; // fee * 1e10
    uint256 admin_fee; // admin_fee * 1e10
    uint256 initial_A;
    uint256 future_A;
    uint256 initial_A_time;
    uint256 future_A_time;
    uint256 admin_actions_deadline;
    uint256 transfer_ownership_deadline;
    uint256 future_fee;
    uint256 future_admin_fee;
    address future_owner;
    bool is_killed;
    uint256 kill_deadline;
    uint256 private KILL_DEADLINE_DT = 2 * 30 * 86400;
    event TokenExchange(
        address buyer,
        uint256 sold_id,
        uint256 tokens_sold,
        uint256 bought_id,
        uint256 tokens_bought
    );
    event AddLiquidity(
        address provider,
        uint256[] token_amounts,
        uint256[] fees,
        uint256 invariant,
        uint256 token_supply
    );
    event RemoveLiquidity(
        address provider,
        uint256[] token_amounts,
        uint256[] fees,
        uint256 token_supply
    );
    event RemoveLiquidityOne(
        address provider,
        uint256 token_amount,
        uint256 coin_amount
    );
    event RemoveLiquidityImbalance(
        address provider,
        uint256[] token_amounts,
        uint256[] fees,
        uint256 invariant,
        uint256 token_supply
    );
    event CommitNewAdmin(uint256 deadline, address admin);
    event NewAdmin(address admin);
    event CommitNewFee(uint256 deadline, uint256 fee, uint256 admin_fee);
    event NewFee(uint256 fee, uint256 admin_fee);
    event RampA(
        uint256 old_A,
        uint256 new_A,
        uint256 initial_time,
        uint256 future_time
    );
    event StopRampA(uint256 A, uint256 t);
    constructor(
        address[] memory _coins,
        uint256 _A,
        uint256 _fee,
        uint256 _admin_fee
    ) public {
        transferOwnership(msg.sender);
        for (uint256 i = 0; i < _coins.length; i++) {
            require(_coins[i] != address(0), "BNB is not support.");
        }
        coins = _coins;
        initial_A = _A;
        future_A = _A;
        fee = _fee;
        admin_fee = _admin_fee;
        kill_deadline = block.timestamp + KILL_DEADLINE_DT;
        balances = new uint256[](coins.length);
        for (uint256 i = 0; i < coins.length; i++) {
            balances[i] = 0;
        }
    }
    function _A() internal view returns (uint256 A1) {
        uint256 t1 = future_A_time;
        A1 = future_A;
        if (block.timestamp < t1) {
            uint256 A0 = initial_A;
            uint256 t0 = initial_A_time;
            if (A1 > A0) {
                A1 = A0.add(
                    A1.sub(A0).mul(block.timestamp.sub(t0)).div(t1.sub(t0))
                );
            } else {
                A1 = A0.sub(
                    A0.sub(A1).mul(block.timestamp.sub(t0)).div(t1.sub(t0))
                );
            }
        } else {
        }
    }
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal override {}
    function A() external view returns (uint256 A1) {
        A1 = _A();
    }
    function _xp() internal view returns (uint256[] memory result) {
        result = RATES;
        for (uint256 i = 0; i < coins.length; i++) {
            result[i] = result[i].mul(balances[i]).div(LENDING_PRECISION);
        }
    }
    function _xp_mem(uint256[] memory _balances)
        internal
        view
        returns (uint256[] memory result)
    {
        result = RATES;
        for (uint256 i = 0; i < coins.length; i++) {
            result[i] = result[i].mul(_balances[i]).div(PRECISION);
        }
    }
    function get_D(uint256[] memory xp, uint256 amp)
        internal
        view
        returns (uint256 D)
    {
        uint256 S = 0;
        for (uint256 i = 0; i < xp.length; i++) {
            uint256 _x = xp[i];
            S = S.add(_x);
        }
        if (S == 0) {
            D = 0;
        }
        uint256 Dprev = 0;
        D = S;
        uint256 Ann = amp.mul(coins.length);
        for (uint256 i = 0; i < 255; i++) {
            uint256 D_P = D;
            for (uint256 j = 0; j < xp.length; j++) {
                uint256 _x = xp[j];
                D_P = D_P.mul(D).div(_x.mul(uint256(coins.length))); // If division by 0, this will be borked: only withdrawal will work. And that is good
            }
            Dprev = D;
            uint256 numerator = Ann
                .mul(S)
                .add(D_P.mul(uint256(coins.length)))
                .mul(D);
            uint256 denominator = Ann.sub(uint256(1)).mul(D).add(
                uint256(coins.length + 1).mul(D_P)
            );
            D = numerator.div(denominator);
            if (D > Dprev) {
                if ((D - Dprev) <= 1) {
                    break;
                }
            } else {
                if ((Dprev - D) <= 1) {
                    break;
                }
            }
        }
    }
    function get_D_mem(uint256[] memory _balances, uint256 amp)
        internal
        view
        returns (uint256 D)
    {
        D = get_D(_xp_mem(_balances), amp);
    }
    function get_virtual_price() external view returns (uint256 price) {
        uint256 D = get_D(_xp(), _A());
        uint256 token_supply = totalSupply();
        price = D.mul(PRECISION).div(token_supply);
    }
    function calc_token_amount(uint256[] calldata amounts, bool deposit)
        external
        view
        returns (uint256 result)
    {
        uint256[] memory _balances = balances;
        uint256 amp = _A();
        uint256 D0 = get_D_mem(_balances, amp);
        for (uint256 i = 0; i < coins.length; i++) {
            if (deposit) {
                _balances[i] = _balances[i].add(amounts[i]);
            } else {
                _balances[i] = _balances[i].sub(amounts[i]);
            }
        }
        uint256 D1 = get_D_mem(_balances, amp);
        uint256 token_amount = totalSupply();
        uint256 diff = 0;
        if (deposit) {
            diff = D1.sub(D0);
        } else {
            diff = D0.sub(D1);
        }
        result = diff.mul(token_amount).div(D0);
    }
    function add_liquidity(uint256[] calldata amounts, uint256 min_mint_amount)
        external
        nonReentrant
    {
        require(is_killed != true, "is killed");
        uint256[] memory fees = new uint256[](coins.length);
        uint256 _fee = fee.mul(coins.length).div(
            uint256(4 * (coins.length - 1))
        );
        uint256 amp = _A();
        uint256 D0 = 0;
        uint256[] memory old_balances = balances;
        if (totalSupply() > 0) {
            D0 = get_D_mem(old_balances, amp);
        }
        uint256[] memory new_balances = old_balances;
        for (uint256 i = 0; i < coins.length; i++) {
            uint256 in_amount = amounts[i];
            if (totalSupply() == 0) {
                require(in_amount > 0, "initial deposit requires all coins"); // # dev: initial deposit requires all coins
            }
            address in_coin = coins[i];
            if (in_amount > 0) {
                if (i == FEE_INDEX) {
                    in_amount = IBEP20(in_coin).balanceOf(address(this));
                }
                TransferHelper.safeTransferFrom(
                    in_coin,
                    msg.sender,
                    address(this),
                    amounts[i]
                );
                if (i == FEE_INDEX) {
                    in_amount = IBEP20(in_coin).balanceOf(address(this)).sub(
                        in_amount
                    );
                }
            }
            new_balances[i] = old_balances[i].add(in_amount);
        }
        uint256 D1 = get_D_mem(new_balances, amp);
        require(D1 > D0, "D1 must bigger than D0");
        uint256 D2 = D1;
        if (totalSupply() > 0) {
            for (uint256 i = 0; i < coins.length; i++) {
                uint256 ideal_balance = D1.mul(old_balances[i]).div(D0);
                uint256 difference = 0;
                if (ideal_balance > new_balances[i]) {
                    difference = ideal_balance.sub(new_balances[i]);
                } else {
                    difference = new_balances[i].sub(ideal_balance);
                }
                fees[i] = _fee.mul(difference).div(FEE_DENOMINATOR);
                balances[i] = new_balances[i].sub(
                    fees[i].mul(admin_fee).div(FEE_DENOMINATOR)
                );
                new_balances[i] = new_balances[i].sub(fees[i]);
            }
            D2 = get_D_mem(new_balances, amp);
        } else {
            balances = new_balances;
        }
        uint256 mint_amount = 0;
        if (totalSupply() == 0) {
            mint_amount = D1; //# Take the dust if there was any
        } else {
            mint_amount = totalSupply().mul(D2.sub(D0)).div(D0);
        }
        require(mint_amount >= min_mint_amount, "Slippage screwed you");
        _mint(msg.sender, mint_amount);
        emit AddLiquidity(
            msg.sender,
            amounts,
            fees,
            D1,
            totalSupply() + mint_amount
        );
    }
    function get_y(
        uint256 i,
        uint256 j,
        uint256 x,
        uint256[] memory xp_
    ) internal view returns (uint256 y) {
        require(i != j, "dev: same coin");
        require(j >= 0, "dev: j below zero");
        require(j < coins.length, "dev: j above coins.length");
        require(i >= 0, "i must >= 0");
        require(i < coins.length, "i must < n_coins");
        uint256 amp = _A();
        uint256 D = get_D(xp_, amp);
        uint256 c = D;
        uint256 S_ = 0;
        uint256 Ann = amp.mul(uint256(coins.length));
        uint256 _x = 0;
        for (uint256 _i = 0; _i < coins.length; _i++) {
            if (_i == i) {
                _x = x;
            } else if (_i != j) {
                _x = xp_[_i];
            } else {
                continue;
            }
            S_ = S_.add(_x);
            c = c.mul(D).div(_x.mul(uint256(coins.length)));
        }
        c = c.mul(D).div(Ann.mul(coins.length));
        uint256 y_prev = 0;
        y = D;
        for (uint256 _i = 0; _i < 255; _i++) {
            y_prev = y;
            y = y.mul(y).add(c).div(
                y.mul(uint256(2)).add(S_.add(D.div(Ann))).sub(D)
            );
            if (y > y_prev) {
                if ((y - y_prev) <= 1) {
                    break;
                }
            } else {
                if ((y_prev - y) <= 1) {
                    break;
                }
            }
        }
    }
    function get_dy(
        uint256 i,
        uint256 j,
        uint256 dx
    ) external view returns (uint256 result) {
        uint256[] memory xp = _xp();
        uint256 x = xp[i].add(dx.mul(RATES[i]).div(PRECISION));
        uint256 y = get_y(i, j, x, xp);
        uint256 dy = xp[j].sub(y).sub(1).mul(PRECISION).div(RATES[j]);
        uint256 _fee = fee.mul(dy).div(FEE_DENOMINATOR);
        result = dy.sub(_fee);
    }
    function get_dy_underlying(
        uint256 i,
        uint256 j,
        uint256 dx
    ) external view returns (uint256 result) {
        uint256[] memory xp = _xp();
        uint256[] memory precisions = PRECISION_MUL;
        uint256 x = xp[i].add(dx.mul(precisions[i]));
        uint256 y = get_y(i, j, x, xp);
        uint256 dy = xp[j].sub(y).sub(uint256(1)).div(precisions[j]);
        uint256 _fee = fee.mul(dy).div(FEE_DENOMINATOR);
        result = dy.sub(_fee);
    }
    function exchange(
        uint256 i,
        uint256 j,
        uint256 dx,
        uint256 min_dy
    ) external nonReentrant {
        require(is_killed == false, "dev: is killed");
        uint256[] memory xp = _xp_mem(balances);
        uint256 dx_w_fee = dx;
        address input_coin = coins[i];
        if (i == FEE_INDEX) {
            dx_w_fee = IBEP20(input_coin).balanceOf(address(this));
        }
        TransferHelper.safeTransferFrom(
            input_coin,
            msg.sender,
            address(this),
            dx
        );
        if (i == FEE_INDEX) {
            dx_w_fee = IBEP20(input_coin).balanceOf(address(this)).sub(
                dx_w_fee
            );
        }
        uint256 x = xp[i].add(dx_w_fee.mul(RATES[i]).div(PRECISION));
        uint256 y = get_y(i, j, x, xp);
        uint256 dy = xp[j].sub(y).sub(uint256(1)); // # -1 just in case there were some rounding errors
        uint256 dy_fee = dy.mul(fee).div(FEE_DENOMINATOR);
        dy = dy.sub(dy_fee).mul(PRECISION).div(RATES[j]);
        require(dy >= min_dy, "Exchange resulted in fewer coins than expected");
        uint256 dy_admin_fee = dy_fee.mul(admin_fee).div(FEE_DENOMINATOR);
        dy_admin_fee = dy_admin_fee.mul(PRECISION).div(RATES[j]);
        balances[i] = balances[i].add(dx_w_fee);
        balances[j] = balances[j].sub(dy).sub(dy_admin_fee);
        TransferHelper.safeTransfer(coins[j], msg.sender, dy);
        emit TokenExchange(msg.sender, i, dx, j, dy);
    }
    function remove_liquidity(uint256 _amount, uint256[] calldata min_amounts)
        external
        nonReentrant
    {
        uint256 total_supply = totalSupply();
        uint256[] memory amounts = new uint256[](coins.length);
        uint256[] memory fees = new uint256[](coins.length); //  # Fees are unused but we've got them historically in event
        for (uint256 i = 0; i < coins.length; i++) {
            uint256 value = balances[i].mul(_amount).div(total_supply);
            require(
                value >= min_amounts[i],
                "Withdrawal resulted in fewer coins than expected"
            );
            balances[i] = balances[i].sub(value);
            amounts[i] = value;
            TransferHelper.safeTransfer(coins[i], msg.sender, value);
        }
        _burn(msg.sender, _amount); // # dev: insufficient funds
        emit RemoveLiquidity(msg.sender, amounts, fees, total_supply - _amount);
    }
    function remove_liquidity_imbalance(
        uint256[] calldata amounts,
        uint256 max_burn_amount
    ) external nonReentrant {
        require(is_killed == false, "is killed"); //not self.  # dev: is killed
        require(totalSupply() != 0, "  # dev: zero total supply");
        uint256 _fee = fee.mul(coins.length).div(coins.length.sub(1).mul(4));
        uint256 amp = _A();
        uint256[] memory old_balances = balances;
        uint256[] memory new_balances = old_balances;
        uint256 D0 = get_D_mem(old_balances, amp);
        for (uint256 i = 0; i < coins.length; i++) {
            new_balances[i] = new_balances[i].sub(amounts[i]);
        }
        uint256 D1 = get_D_mem(new_balances, amp);
        uint256[] memory fees = new uint256[](coins.length);
        for (uint256 i = 0; i < coins.length; i++) {
            uint256 ideal_balance = D1.mul(old_balances[i]).div(D0);
            uint256 difference = 0;
            if (ideal_balance > new_balances[i]) {
                difference = ideal_balance.sub(new_balances[i]);
            } else {
                difference = new_balances[i].sub(ideal_balance);
            }
            fees[i] = _fee.mul(difference).div(FEE_DENOMINATOR);
            balances[i] = new_balances[i].sub(
                fees[i].mul(admin_fee).div(FEE_DENOMINATOR)
            );
            new_balances[i] = new_balances[i].sub(fees[i]);
        }
        uint256 D2 = get_D_mem(new_balances, amp);
        uint256 token_amount = D0.sub(D2).mul(totalSupply()).div(D0);
        require(token_amount != 0, " # dev: zero tokens burned");
        token_amount += 1; //  # In case of rounding errors - make it unfavorable for the "attacker"
        require(token_amount <= max_burn_amount, "Slippage screwed you");
        _burn(msg.sender, token_amount); //  # dev: insufficient funds
        for (uint256 i = 0; i < coins.length; i++) {
            if (amounts[i] != 0) {
                TransferHelper.safeTransfer(coins[i], msg.sender, amounts[i]);
            }
        }
        emit RemoveLiquidityImbalance(
            msg.sender,
            amounts,
            fees,
            D1,
            totalSupply() - token_amount
        );
    }
    function get_y_D(
        uint256 A_,
        uint256 i,
        uint256[] memory xp,
        uint256 D
    ) internal view returns (uint256 y) {
        require(i >= 0, "# dev: i below zero");
        require(i < coins.length, "  # dev: i above coins.length");
        uint256 c = D;
        uint256 S_ = 0;
        uint256 Ann = A_ * coins.length;
        uint256 _x = 0;
        for (uint256 _i = 0; _i < coins.length; _i++) {
            if (_i != i) {
                _x = xp[_i];
            } else {
                continue;
            }
            S_ = S_.add(_x);
            c = c.mul(D).div(_x.mul(coins.length));
        }
        c = c.mul(D).div(Ann.mul(coins.length));
        uint256 b = S_.add(D.div(Ann));
        uint256 y_prev = 0;
        y = D;
        for (uint256 _i = 0; _i < 255; _i++) {
            y_prev = y;
            y = y.mul(y).add(c).div(y.mul(uint256(2)).add(b).sub(D));
            if (y > y_prev) {
                if ((y - y_prev) <= 1) {
                    break;
                }
            } else {
                if ((y_prev - y) <= 1) {
                    break;
                }
            }
        }
    }
    function _calc_withdraw_one_coin(uint256 _token_amount, uint256 i)
        internal
        view
        returns (uint256 r1, uint256 r2)
    {
        uint256 amp = _A();
        uint256 _fee = fee.mul(coins.length).div(4 * (coins.length - 1));
        uint256[] memory xp = _xp();
        uint256 D0 = get_D(xp, amp);
        uint256 D1 = D0.sub(_token_amount.mul(D0).div(totalSupply()));
        uint256[] memory xp_reduced = xp;
        uint256 new_y = get_y_D(amp, i, xp, D1);
        uint256 dy_0 = xp[i].sub(new_y).div(PRECISION_MUL[i]); //# w/o fees
        for (uint256 j = 0; j < coins.length; j++) {
            uint256 dx_expected = 0;
            if (j == i) {
                dx_expected = xp[j].mul(D1).div(D0).sub(new_y);
            } else {
                dx_expected = xp[j].sub(xp[j].mul(D1).div(D0));
            }
            xp_reduced[j] = xp_reduced[j].sub(
                _fee.mul(dx_expected).div(FEE_DENOMINATOR)
            );
        }
        uint256 dy = xp_reduced[i].sub(get_y_D(amp, i, xp_reduced, D1));
        dy = dy.sub(uint256(1)).div(PRECISION_MUL[i]); // # Withdraw less to account for rounding errors
        r1 = dy;
        r2 = dy_0 - dy;
    }
    function calc_withdraw_one_coin(uint256 _token_amount, uint256 i)
        external
        view
        returns (uint256 result)
    {
        (result, ) = _calc_withdraw_one_coin(_token_amount, i);
    }
    function remove_liquidity_one_coin(
        uint256 _token_amount,
        uint256 i,
        uint256 min_amount
    ) external nonReentrant {
        uint256 dy = 0;
        uint256 dy_fee = 0;
        (dy, dy_fee) = _calc_withdraw_one_coin(_token_amount, i);
        require(dy >= min_amount, "Not enough coins removed");
        balances[i] = balances[i].sub(
            dy.add(dy_fee.mul(admin_fee).div(FEE_DENOMINATOR))
        );
        _burn(msg.sender, _token_amount); //# dev: insufficient funds
        TransferHelper.safeTransfer(coins[i], msg.sender, dy);
        emit RemoveLiquidityOne(msg.sender, _token_amount, dy);
    }
    function ramp_A(uint256 _future_A, uint256 _future_time)
        external
        onlyOwner
    {
        require(
            block.timestamp >= initial_A_time + MIN_RAMP_TIME,
            "block.timestamp >= self.initial_A_time + MIN_RAMP_TIME"
        );
        require(
            _future_time >= block.timestamp + MIN_RAMP_TIME,
            "  # dev: insufficient time"
        );
        uint256 _initial_A = _A();
        require(
            (_future_A > 0) && (_future_A < MAX_A),
            "(_future_A > 0) && (_future_A < MAX_A)"
        );
        require(
            ((_future_A >= _initial_A) &&
                (_future_A <= _initial_A * MAX_A_CHANGE)) ||
                ((_future_A < _initial_A) &&
                    (_future_A * MAX_A_CHANGE >= _initial_A)),
            "complex conditions"
        );
        initial_A = _initial_A;
        future_A = _future_A;
        initial_A_time = block.timestamp;
        future_A_time = _future_time;
        emit RampA(_initial_A, _future_A, block.timestamp, _future_time);
    }
    function stop_ramp_A() external onlyOwner {
        uint256 current_A = _A();
        initial_A = current_A;
        future_A = current_A;
        initial_A_time = block.timestamp;
        future_A_time = block.timestamp;
        emit StopRampA(current_A, block.timestamp);
    }
    function commit_new_fee(uint256 new_fee, uint256 new_admin_fee)
        external
        onlyOwner
    {
        require(admin_actions_deadline == 0, "  # dev: active action");
        require(new_fee <= MAX_FEE, "  # dev: fee exceeds maximum");
        require(
            new_admin_fee <= MAX_ADMIN_FEE,
            "  # dev: admin fee exceeds maximum"
        );
        uint256 _deadline = block.timestamp + ADMIN_ACTIONS_DELAY;
        admin_actions_deadline = _deadline;
        future_fee = new_fee;
        future_admin_fee = new_admin_fee;
        emit CommitNewFee(_deadline, new_fee, new_admin_fee);
    }
    function apply_new_fee() external onlyOwner {
        require(
            block.timestamp >= admin_actions_deadline,
            "  # dev: insufficient time"
        );
        require(admin_actions_deadline != 0, "  # dev: no active action");
        admin_actions_deadline = 0;
        uint256 _fee = future_fee;
        uint256 _admin_fee = future_admin_fee;
        fee = _fee;
        admin_fee = _admin_fee;
        emit NewFee(_fee, _admin_fee);
    }
    function revert_new_parameters() external onlyOwner {
        admin_actions_deadline = 0;
    }
    function commit_transfer_ownership(address _owner) external onlyOwner {
        require(transfer_ownership_deadline == 0, "  # dev: active transfer");
        uint256 _deadline = block.timestamp + ADMIN_ACTIONS_DELAY;
        transfer_ownership_deadline = _deadline;
        future_owner = _owner;
        emit CommitNewAdmin(_deadline, _owner);
    }
    function apply_transfer_ownership() external onlyOwner {
        require(
            block.timestamp >= transfer_ownership_deadline,
            "  # dev: insufficient time"
        );
        require(
            transfer_ownership_deadline != 0,
            "  # dev: no active transfer"
        );
        transfer_ownership_deadline = 0;
        transferOwnership(future_owner);
        emit NewAdmin(future_owner);
    }
    function revert_transfer_ownership() external onlyOwner {
        transfer_ownership_deadline = 0;
    }
    function admin_balances(uint256 i) external view returns (uint256 balance) {
        balance = IBEP20(coins[i]).balanceOf(address(this)).sub(balances[i]);
    }
    function withdraw_admin_fees() external onlyOwner {
        for (uint256 i = 0; i < coins.length; i++) {
            address c = coins[i];
            uint256 value = IBEP20(c).balanceOf(address(this)).sub(balances[i]);
            if (value > 0) {
                TransferHelper.safeTransfer(c, msg.sender, value);
            }
        }
    }
    function donate_admin_fees() external onlyOwner {
        for (uint256 i = 0; i < coins.length; i++) {
            balances[i] = IBEP20(coins[i]).balanceOf(address(this));
        }
    }
    function kill_me() external onlyOwner {
        require(
            kill_deadline > block.timestamp,
            "  # dev: deadline has passed"
        );
        is_killed = true;
    }
    function unkill_me() external onlyOwner {
        is_killed = false;
    }
}