// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.0;

/**
 * @title DataTypes
 * @author donoso_eth
 *
 * @notice A standard library of data types used throughout.
 */
library HelpTypes {
  struct ePool {
    uint256 id;
    uint256 timestamp;
    uint256 poolTotalBalance;
    uint256 poolBalance;
    uint256 aaveBalance;
    uint256 protocolYield;
    uint256 deposit;
    uint256 depositFromInFlowRate;
    uint256 depositFromOutFlowRate;
    int96 inFlowRate;
    int96 outFlowRate;
    uint256 outFlowBuffer;
    uint256 yieldTokenIndex;
    uint256 yieldInFlowRateIndex;
    uint256 yieldOutFlowRateIndex;
    uint256 yieldAccrued;
    uint256 yieldSnapshot;
    uint256 totalYield;
  }

  struct eUser {
    uint256 id;
    uint256 realTimeBalance;
    uint256 tokenBalance;
    uint256 deposit;
    int96 outFlow;
    uint256 outStepAmount;
    uint256 outStepTime;
    uint256 outStreamCreated;
    uint256 outStreamInit;
    uint256 outMinBalance;
    bytes32 outStreamId;
    uint256 nextExecOut;
    int96 inFlow;
    uint256 inFlowDeposit;
    uint256 timestamp;
  }
}
