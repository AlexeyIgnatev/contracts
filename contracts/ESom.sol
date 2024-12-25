// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract ESom is ERC20, Ownable {
    struct Transaction {
        uint256 id;
        address from;
        address to;
        uint256 amount;
        uint256 timestamp;
        bool reversed;
    }

    Transaction[] private _transactions;

    mapping(address => bool) private _blacklist;
    mapping(address => bool) private _whitelist;

    mapping(address => uint256) private _dailyLimit;
    mapping(address => uint256) private _spentToday;
    mapping(address => uint256) private _lastResetTime;

    bool public transfersPaused = false;

    event BlacklistUpdated(address indexed account, bool isBlacklisted);
    event WhitelistUpdated(address indexed account, bool isWhitelisted);
    event DailyLimitUpdated(address indexed account, uint256 newLimit);
    event TransfersPaused();
    event TransfersResumed();
    event TransactionReversed(uint256 transactionId, address indexed from, address indexed to, uint256 value);
    event TransactionCreated(uint256 transactionId, address indexed from, address indexed to, uint256 value);
    event TransferFromFiat(address indexed account, uint256 value);
    event TransferToFiat(address indexed account, uint256 value);

    constructor() ERC20("Electro Com", "ECOM") Ownable(msg.sender) {}

    function updateBlacklist(address account, bool value) external onlyOwner {
        _blacklist[account] = value;
        emit BlacklistUpdated(account, value);
    }

    function isBlacklisted(address account) external view returns (bool) {
        return _blacklist[account];
    }

    function updateWhitelist(address account, bool value) external onlyOwner {
        _whitelist[account] = value;
        emit WhitelistUpdated(account, value);
    }

    function isWhitelisted(address account) external view returns (bool) {
        return _whitelist[account];
    }

    function setDailyLimit(address account, uint256 limit) external onlyOwner {
        _dailyLimit[account] = limit;
        emit DailyLimitUpdated(account, limit);
    }

    function getDailyLimit(address account) external view returns (uint256) {
        return _dailyLimit[account];
    }

    function pauseTransfers() external onlyOwner {
        transfersPaused = true;
        emit TransfersPaused();
    }

    function resumeTransfers() external onlyOwner {
        transfersPaused = false;
        emit TransfersResumed();
    }

    function burn(address account, uint256 amount) external onlyOwner {
        _burn(account, amount);
    }

    function mint(address account, uint256 amount) external onlyOwner {
        _mint(account, amount);
    }

    function transferFromFiat(address account, uint256 amount) external onlyOwner {
        _mint(account, amount);
        emit TransferFromFiat(account, amount);
    }

    function transferToFiat(uint256 amount) external {
        _burn(msg.sender, amount);
        emit TransferToFiat(msg.sender, amount);
    }

    function reverseTransaction(uint256 transactionId) external onlyOwner {
        require(transactionId < _transactions.length, "Transaction does not exist");
        Transaction storage txn = _transactions[transactionId];
        require(!txn.reversed, "Transaction already reversed");

        require(balanceOf(txn.to) >= txn.amount, "Insufficient balance to reverse transaction");

        _transfer(txn.to, txn.from, txn.amount);
        txn.reversed = true;

        emit TransactionReversed(transactionId, txn.from, txn.to, txn.amount);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal {
        require(!transfersPaused, "Transfers are paused");
        require(!_blacklist[from], "Sender is blacklisted");
        require(!_blacklist[to], "Recipient is blacklisted");

        if (!_whitelist[from] && !_whitelist[to]) {
            if (block.timestamp > _lastResetTime[from] + 1 days) {
                _spentToday[from] = 0;
                _lastResetTime[from] = block.timestamp;
            }

            _spentToday[from] += amount;
            if (_dailyLimit[from] > 0) {
                require(_spentToday[from] <= _dailyLimit[from], "Daily limit exceeded");
            }
        }

        Transaction memory txn = Transaction({
            id: _transactions.length,
            from: from,
            to: to,
            amount: amount,
            timestamp: block.timestamp,
            reversed: false
        });
        _transactions.push(txn);

        emit TransactionCreated(txn.id, txn.from, txn.to, txn.amount);
    }

    function transfer(address to, uint256 value) public override returns (bool) {
        _beforeTokenTransfer(msg.sender, to, value);
        return super.transfer(to, value);
    }

    function transferFrom(address from, address to, uint256 value) public override returns (bool) {
        _beforeTokenTransfer(from, to, value);
        return super.transferFrom(from, to, value);
    }

    function getTransaction(uint256 transactionId) external view returns (Transaction memory) {
        require(transactionId < _transactions.length, "Transaction does not exist");
        return _transactions[transactionId];
    }

    function getTransactionCount() external view returns (uint256) {
        return _transactions.length;
    }
}