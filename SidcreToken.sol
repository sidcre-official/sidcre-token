// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}


interface IUniswapV2Factory {
    function createPair(
        address tokenA,
        address tokenB
    ) external returns (address pair);
}



interface IUniswapV2Router {
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
        external
        payable
        returns (uint256 amountToken, uint256 amountETH, uint256 liquidity);
}



interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);
}



abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}



abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }

}


contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() external view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() external view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(
        address account
    ) public view virtual override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless this function is
     * overridden;
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() external view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(
        address owner,
        address spender
    ) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(
        address to,
        uint256 amount
    ) external virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * NOTE: If `amount` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(
        address spender,
        uint256 amount
    ) external virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * NOTE: Does not update the allowance if the current allowance
     * is the maximum `uint256`.
     *
     * Requirements:
     *
     * - `from` and `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     * - the caller must have allowance for ``from``'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(
        address spender,
        uint256 subtractedValue
    ) external virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(
            currentAllowance >= subtractedValue,
            "ERC20: decreased allowance below zero"
        );
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(
        address spender,
        uint256 addedValue
    ) external virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply += amount;
        unchecked {
            // Overflow not possible: balance + amount is at most totalSupply + amount, which is checked above.
            _balances[account] += amount;
        }
        emit Transfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
            // Overflow not possible: amount <= accountBalance <= totalSupply.
            _totalSupply -= amount;
        }

        emit Transfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Updates `owner` s allowance for `spender` based on spent `amount`.
     *
     * Does not update the allowance amount in case of infinite allowance.
     * Revert if not enough allowance is available.
     *
     * Might emit an {Approval} event.
     */
    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(
                currentAllowance >= amount,
                "ERC20: insufficient allowance"
            );
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        uint256 fromBalance = _balances[from];
        require(
            fromBalance >= amount,
            "ERC20: transfer amount exceeds balance"
        );
        unchecked {
            _balances[from] = fromBalance - amount;
            // Overflow not possible: the sum of all balances is capped by totalSupply, and the sum is preserved by
            // decrementing then incrementing.
            _balances[to] += amount;
        }

        emit Transfer(from, to, amount);
    }
}



contract SidcreToken is ERC20, Ownable {

    // Address List

    address public _dividendWallet = 0xc142888Ae06487Acffc83deFA9AD2964142361a0;
    address public _marketingWallet = 0x5da10490C5C3Bf88e45Ae6c2a81CcBC904b0828f;
    address public _lpWallet = 0xe89d996e2BB21492D0bc9548263ABd3F9D36b722;

    // Tax System

    uint256 public _feeSellTotal = 4;

    uint256 public _feeSellToDividend = 1;
    uint256 public _feeSellMK = 2;
    uint256 public _feeSellLP = 1;


    uint256 public MIN_HOLD_TIME = 30 days;  // One month time period for eligibility
    uint256 public dividendThreshold = 100000 * 10**18;  // Example threshold value, can be adjusted
    

    // Total tax collected and stored

    uint256 public _totalDividend = 0;
    uint256 private _totalMK = 0;
    uint256 private _totalLP = 0;

    // Uniswap 

    IUniswapV2Router public   swapRouter;
    address public swapPair;

    
    address[] public _eligibleHolders;
    address[] public thresholdHolders;
    mapping(address => bool) public _isInEligibleList;
    mapping(address => uint256) public thresholdHolderMap;
    mapping(address => bool) public exemptFromDividend;


    

    // Flag to identify type of transaction

    enum Flag {
        None,
        Sell,
        Buy
    }

    //Events

    event transfer(address from, address to, uint256 amount);
    event newMarketingWallet(address newWallet);
    event newLpWallet(address newWallet);
    event newDividendWallet(address newWallet);
    event newSellFees(uint256 marketingFees, uint256 dividendFees, uint256 lpFees, uint256 totalSellFees);
    event resetMarketingFeesRecievedToZero(string notice);
    event resetDividendFeesRecievedToZero(string notice);


    constructor() ERC20("Sidcre Token", "SNDT") {
        uint256 startSupply = (10 * 10 ** 6) * 10 ** decimals();
        _mint(msg.sender, (startSupply));

        IUniswapV2Router _uniswapRouter = IUniswapV2Router(
            0xBb5e1777A331ED93E07cF043363e48d320eb96c4
        );
        swapPair = IUniswapV2Factory(_uniswapRouter.factory())
            .createPair(address(this), _uniswapRouter.WETH());

        swapRouter = _uniswapRouter;
        
        _approve(msg.sender, address(swapRouter), type(uint256).max);
        _approve(address(this), address(swapRouter), type(uint256).max);
    }

    function _transfer(address from, address to, uint256 amount) internal override {
        uint256 taxAmount = 0;
        Flag flag = Flag.None;

        if (to == swapPair) {
            taxAmount = amount * _feeSellTotal / 100;
            flag = Flag.Sell;
        } else if (from == swapPair) {
            flag = Flag.Buy;
        } 

        super._transfer(from, to, amount - taxAmount);

        _updateThresholdHolders(from);  
        _updateThresholdHolders(to);
        
        if (taxAmount > 0 && flag == Flag.Sell)
        {
            feeCalculateAndTransfer(from, taxAmount);
        }
        
        emit transfer(from, to, amount);
    }

function addExemptAddress(address _account) external onlyOwner {
    exemptFromDividend[_account] = true;
}

function removeExemptAddress(address _account) external onlyOwner {
    exemptFromDividend[_account] = false;
}

function updateEligibleHoldersFromThreshold() external onlyOwner {
    for (uint256 i = 0; i < thresholdHolders.length; i++) {
        address account = thresholdHolders[i];
        if (exemptFromDividend[account]) {
            continue;
        }
        uint256 lastTime = thresholdHolderMap[account];
        if (block.timestamp - lastTime >= MIN_HOLD_TIME && !_isInEligibleList[account]) {
            _eligibleHolders.push(account);
            _isInEligibleList[account] = true;
        }
    }
}

    function changeRouter(address _router) external onlyOwner {
        IUniswapV2Router _uniswapRouter = IUniswapV2Router(
            _router
        );
        swapPair = IUniswapV2Factory(_uniswapRouter.factory())
            .createPair(address(this), _uniswapRouter.WETH());

        swapRouter = _uniswapRouter;
        
        _approve(msg.sender, address(swapRouter), type(uint256).max);
        _approve(address(this), address(swapRouter), type(uint256).max);
    }


function _removeFromEligibleHolders(address account) private {
    for (uint256 i = 0; i < _eligibleHolders.length; i++) {
        if (_eligibleHolders[i] == account) {
            _eligibleHolders[i] = _eligibleHolders[_eligibleHolders.length - 1];
            _eligibleHolders.pop();
            _isInEligibleList[account] = false;
            break;
        }
    }
}
function _updateThresholdHolders(address account) private {

        if (exemptFromDividend[account]) {
        return;
    }
    if (balanceOf(account) >= dividendThreshold && thresholdHolderMap[account] == 0) {
        thresholdHolders.push(account);
        thresholdHolderMap[account] = block.timestamp;  // Saving the time when they crossed the threshold
    } else if (balanceOf(account) < dividendThreshold && thresholdHolderMap[account] != 0) {
        // Remove from the thresholdHolders array
        for (uint256 i = 0; i < thresholdHolders.length; i++) {
            if (thresholdHolders[i] == account) {
                thresholdHolders[i] = thresholdHolders[thresholdHolders.length - 1];
                thresholdHolders.pop();
                thresholdHolderMap[account] = 0;  // Resetting the timestamp in the mapping

                // Remove from _eligibleHolders if they are in it
                if(_isInEligibleList[account]) {
                    _removeFromEligibleHolders(account);
                }

                break;
            }
        }
    }
}



        // Function to distribute dividends in batches

    function distributeDividendsToAll() external onlyOwner {
        uint256 totalEligible = _eligibleHolders.length;
        require(totalEligible > 0, "No eligible holders");

        uint256 dividendPerHolder = _totalDividend / totalEligible;
        uint256 remainder = _totalDividend - (dividendPerHolder * totalEligible);

        for (uint256 i = 0; i < totalEligible; i++) {
            uint256 amountToSend = dividendPerHolder;

            if (i == totalEligible - 1) {
                // Add the remainder to the last eligible holder
                amountToSend += remainder;
            }

            // Use the base ERC20 transfer to avoid any custom logic or tax deduction
            _transfer(_dividendWallet, _eligibleHolders[i], amountToSend);
        }

        _totalDividend = 0;
    }



    // Private Functions

    function feeCalculateAndTransfer(address from, uint256 taxAmount) private {
        uint256 toLP = taxAmount * _feeSellLP / _feeSellTotal;
        uint256 toMK = taxAmount * _feeSellMK / _feeSellTotal;
        uint256 toDividend = taxAmount * _feeSellToDividend / _feeSellTotal;

        _totalLP += toLP;
        _totalMK += toMK;
        _totalDividend += toDividend;

        super._transfer(from, _lpWallet, toLP);
        super._transfer(from, _dividendWallet, toDividend);
        super._transfer(from, _marketingWallet, toMK);

    }

    function _addLiquidity(uint256 tokenAmount,uint256 ethAmount) private {
        swapRouter.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0,
            0,
            owner(),
            block.timestamp
        );
    }

    function getEligibleHolder() public view returns(address[] memory){
        return _eligibleHolders;
    }
    function getEligibleHolderLength() public view returns(uint){
        return _eligibleHolders.length;
    }
    // Owner Functions

    function setDividendWallet(address newWallet) external onlyOwner {
        _dividendWallet = newWallet;

        emit newDividendWallet(newWallet);
    }

    function setLpWallet(address newWallet) external onlyOwner {
        _lpWallet = newWallet;

        emit newLpWallet(newWallet);
    }


    function setMarketingWallet(address newWallet) external onlyOwner {
        _marketingWallet = newWallet;

        emit newMarketingWallet(newWallet);
    }

    function ResetDividendfeesRecievedToZero() external onlyOwner {
        _totalDividend = 0;

        emit resetDividendFeesRecievedToZero("Dividend fees collected is set to zero");
    }

    function ResetMarketingFeesRecievedToZero() external onlyOwner {
        _totalMK = 0;

        emit resetMarketingFeesRecievedToZero("Marketing fees collected is set to zero");
    }

    function editSellFees(uint256 __feeSellToDividend, uint256 __feeSellMK, uint256 __feeSellLP) external onlyOwner {

        uint256 totalCheck = __feeSellToDividend + __feeSellMK + __feeSellLP;
        require(totalCheck <= 10, "Fees/Tax cannot exceed 10% mark.");

        _feeSellToDividend = __feeSellToDividend;
        _feeSellMK = __feeSellMK;
        _feeSellLP = __feeSellLP;
        _feeSellTotal = totalCheck;

        emit newSellFees(_feeSellMK, _feeSellToDividend, _feeSellLP, _feeSellTotal);

    }

    function changeDividendThreshold(uint _new) external onlyOwner {
        dividendThreshold = _new;
    }

    function changeMIN_HOLD_TIME(uint _new) external onlyOwner {
        MIN_HOLD_TIME = _new;
    }

}