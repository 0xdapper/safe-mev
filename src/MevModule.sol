pragma solidity 0.8.19;

import {Safe} from "safe-contracts/Safe.sol";

contract MevModule {
    error OnlySafe();
    error OnlyAdmin();
    error OnlyExecutor();
    error OnlyWhitelistedContract();

    event ExecutorAdded(address _executor);
    event ExectuorRemoed(address _executor);
    event ContractAdded(address _contract);
    event ContractRemoved(address _contract);

    Safe public immutable SAFE;
    mapping(address => bool) public isExecutor;
    mapping(address => bool) public isWhitelistedContract;

    constructor(Safe _safe) {
        SAFE = _safe;
    }

    function addExecutor(address _executor) external onlySafe {
        isExecutor[_executor] = true;
        emit ExecutorAdded(_executor);
    }

    function removeExecutor(address _executor) external onlySafe {
        isExecutor[_executor] = false;
        emit ExectuorRemoed(_executor);
    }

    function addContract(address _contract) external onlySafe {
        isWhitelistedContract[_contract] = true;
        emit ContractAdded(_contract);
    }

    function removeContract(address _contract) external onlySafe {
        isWhitelistedContract[_contract] = false;
        emit ContractRemoved(_contract);
    }

    modifier onlySafe() {
        if (msg.sender != address(SAFE)) revert OnlySafe();
        _;
    }
}
