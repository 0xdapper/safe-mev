pragma solidity 0.8.19;

import {Safe} from "safe-contracts/Safe.sol";

contract MevModule {
    error OnlySafe();
    error OnlyAdmin();
    error OnlyExecutor();
    error OnlyWhitelistedContract();

    event ExecutorAdded(bytes20 _executor);
    event ExecutorRemoved(bytes20 _executor);

    Safe public immutable SAFE;
    mapping(address => bool) public isExecutor;
    mapping(address => bool) public isWhitelistedContract;

    constructor(Safe _safe) {
        SAFE = _safe;
    }

    function addExecutor(address _executor) external onlySafe {
        isExecutor[_executor] = true;
        emit ExecutorAdded(bytes20(_executor));
    }

    function removeExecutor(address _executor) external onlySafe {
        isExecutor[_executor] = false;
        emit ExecutorRemoved(bytes20(_executor));
    }

    modifier onlySafe() {
        if (msg.sender != address(SAFE)) revert OnlySafe();
        _;
    }
}
