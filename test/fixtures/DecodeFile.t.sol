// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "forge-std/Test.sol";

import { ERC20mintable } from "../../src/interfaces/ERC20mintable.sol";

import { IPool } from "../../src/aave/IPool.sol";
import { DataTypes } from "../../src/libraries/DataTypes.sol";

import { PoolV1 } from "../../src/Pool-V1.sol";

import { IOps } from "../../src/gelato/IOps.sol";
import { Users } from "./Users.t.sol";
import { Config } from "./Config.sol";
import { Gelato } from "./Gelato.t.sol";
import { HelpTypes } from "./TestTypes.t.sol";

import "@openzeppelin/contracts/utils/math/SafeMath.sol";

abstract contract DecodeFile is Test, Config, Users, Gelato {
  using SafeMath for uint256;

  // Pool
  function checkFilePool(string memory path) internal {
    HelpTypes.ePool memory ePool = readFilePool(path);
    DataTypes.Pool memory currentPool = poolProxy.getLastPool();

    assertEq(currentPool.id, ePool.id, "POOLID");
    console.log("==============   ", ePool.id, " STEP ===============");

    assertEq(block.timestamp, ePool.timestamp, "TIMESTAMP");
    console.log("TIMESTAMP ----> ", block.timestamp, ePool.timestamp);

    uint256 flowDeposit = 0; //
    uint256 deposit1 = getFlowDeposit(address(poolProxy), user1);
    uint256 deposit2 = getFlowDeposit(address(poolProxy), user2);
    uint256 deposit3 = getFlowDeposit(address(poolProxy), user3);

    (int256 availableBalance,,,) = superToken.realtimeBalanceOfNow(address(poolProxy));

    uint256 superTokenBalance = uint256(availableBalance);
    console.log(41, superTokenBalance);
    assertEq(superTokenBalance + flowDeposit, ePool.poolBalance, "POOL_SUPERTOKEN_BALANCE");
    console.log("POOL_SUPERTOKEN_BALANCE ----> ", superTokenBalance, flowDeposit, ePool.poolBalance);
    console.log("DEPOSIT----> ", deposit1, deposit2, deposit3);

    uint256 aaveBalance = aToken.balanceOf(address(strategyProxy));
    assertApproxEqRel(aaveBalance, ePool.aaveBalance, 1e12, "AAVE Balance ");
    console.log("AAVE Balance --->", aaveBalance);
    //// DEPOSITS
    assertEq(currentPool.deposit, ePool.deposit, "DEPOSIT");
    console.log("DEPOSIT ----> ", currentPool.deposit);

    assertEq(currentPool.depositFromInFlowRate, ePool.depositFromInFlowRate, "DEPOSIT_INFLOW_RATE");
    console.log("DEPOSIT_INFLOW_RATE ----> ", currentPool.depositFromInFlowRate);

    assertEq(currentPool.depositFromOutFlowRate, ePool.depositFromOutFlowRate, "DEPOSIT_OUTFLOW_RATE");
    console.log("DEPOSIT_OUTFLOW_RATE ----> ", currentPool.depositFromOutFlowRate);

    //// FLOW
    assertApproxEqRel(currentPool.inFlowRate, ePool.inFlowRate, 1e12, "POOL_INFLOW");
    console.log("POOL_INFLOW----> ", uint256(uint96(currentPool.inFlowRate)));

    assertApproxEqRel(currentPool.outFlowRate, ePool.outFlowRate, 1e12, "POOL_OUTFLOW");
    console.log("POOL_OUTFLOW----> ", uint256(uint96(currentPool.outFlowRate)));

    /// PROTOCOL YIELD
    assertApproxEqRel(currentPool.yieldObject.protocolYield, ePool.protocolYield, 1e12, "PROTOCOL_YIELD");
    console.log("PROTOCOL_YIELD ----> ", currentPool.yieldObject.protocolYield);

    //// INDEXES

    assertApproxEqRel(currentPool.yieldObject.yieldTokenIndex, ePool.yieldTokenIndex, 1e12, "YIELD_INDEX_TOKEN");
    console.log("YIELD_INDEX_TOKEN ----> ", currentPool.yieldObject.yieldTokenIndex);

    assertApproxEqRel(currentPool.yieldObject.yieldInFlowRateIndex, ePool.yieldInFlowRateIndex, 1e12, "YIELD_INFLOW_RATE");
    console.log("YIELD_INDEX_INFLOW_RATE ----> ", currentPool.yieldObject.yieldInFlowRateIndex);

    assertApproxEqRel(currentPool.yieldObject.yieldOutFlowRateIndex, ePool.yieldOutFlowRateIndex, 1e12, "YIELD_OUTFLOW_RATE");
    console.log("YIELD_OUTFLOW_RATE ----> ", currentPool.yieldObject.yieldOutFlowRateIndex);

    //// YIELD
    assertApproxEqRel(currentPool.yieldObject.yieldAccrued, ePool.yieldAccrued, 1e12, "YIELD_ACCRUED");
    console.log("YIELD_ACCRUED ----> ", currentPool.yieldObject.yieldAccrued);

    // assertApproxEqRel(currentPool.yieldObject.yieldSnapshot, ePool.yieldSnapshot, 1e12, "YIELD_SNAPSHOT");
    // console.log("YIELD_SNAPSHOT ----> ", currentPool.yieldObject.yieldSnapshot);

    assertApproxEqRel(currentPool.yieldObject.totalYield, ePool.totalYield, 1e12, "TOTAL_YIELD");
    console.log("TOTAL_YIELD ----> ", currentPool.yieldObject.totalYield);
  }

  function readFilePool(string memory path) internal view returns (HelpTypes.ePool memory ePool) {
    string memory result = vm.readFile(path);

    ePool.id = st2num(abi.decode(vm.parseJson(result, "id"), (string)));
    ePool.timestamp = st2num(abi.decode(vm.parseJson(result, "timestamp"), (string)));

    ePool.poolTotalBalance = st2num(abi.decode(vm.parseJson(result, "poolTotalBalance"), (string)));
    ePool.poolBalance = st2num(abi.decode(vm.parseJson(result, "poolBalance"), (string)));
    ePool.aaveBalance = st2num(abi.decode(vm.parseJson(result, "aaveBalance"), (string)));

    ePool.protocolYield = st2num(abi.decode(vm.parseJson(result, "protocolYield"), (string)));
    ePool.deposit = st2num(abi.decode(vm.parseJson(result, "deposit"), (string)));
    ePool.depositFromInFlowRate = st2num(abi.decode(vm.parseJson(result, "depositFromInFlowRate"), (string)));
    ePool.depositFromOutFlowRate = st2num(abi.decode(vm.parseJson(result, "depositFromOutFlowRate"), (string)));
    ePool.inFlowRate = int96(uint96(st2num(abi.decode(vm.parseJson(result, "inFlowRate "), (string)))));
    ePool.outFlowRate = int96(uint96(st2num(abi.decode(vm.parseJson(result, "outFlowRate"), (string)))));
    ePool.outFlowBuffer = st2num(abi.decode(vm.parseJson(result, "outFlowBuffer"), (string)));

    ePool.yieldTokenIndex = st2num(abi.decode(vm.parseJson(result, "yieldTokenIndex"), (string)));
    ePool.yieldInFlowRateIndex = st2num(abi.decode(vm.parseJson(result, "yieldInFlowRateIndex"), (string)));
    ePool.yieldOutFlowRateIndex = st2num(abi.decode(vm.parseJson(result, "yieldOutFlowRateIndex"), (string)));

    ePool.yieldAccrued = st2num(abi.decode(vm.parseJson(result, "yieldAccrued"), (string)));
    ePool.yieldSnapshot = st2num(abi.decode(vm.parseJson(result, "yieldSnapshot"), (string)));
    ePool.totalYield = st2num(abi.decode(vm.parseJson(result, "totalYield"), (string)));
  }

  // User
  function checkFileUser(string memory path, address user) internal {
    HelpTypes.eUser memory eUser = readFileUser(path);
    DataTypes.Supplier memory supplier = poolProxy.getSupplier(user);
    assertEq(supplier.id, eUser.id, "USER_ID");
    console.log("==============   USER - ", eUser.id, "  ===============");

    uint256 balance = poolProxy.balanceOf(user);
    assertApproxEqRel(balance, eUser.realTimeBalance, 1e12, "REAL_TIME_BALANCE");
    console.log("REAL_TIME_BALANCE ----> ", balance);

    (int256 tokenBalance,,,) = superToken.realtimeBalanceOfNow(user);
    console.log(uint256(tokenBalance));

    assertApproxEqRel(supplier.deposit, eUser.deposit, 1e12, "DEPOSIT");
    console.log("DEPOSIT ----> ", supplier.deposit);

    assertApproxEqRel(supplier.outStream.flow, eUser.outFlow, 1e12, "OUTFLOW");
    console.log("OUTFLOW----> ", uint256(uint96(eUser.outFlow)));

    if (supplier.outStream.flow > 0 && supplier.timestamp == supplier.outStream.streamInit) {
      bytes32 taskId = gelatoTaskId(user, supplier.outStream.streamInit, supplier.outStream.streamDuration);

      // uint256 addTime =
      bytes32 taskId2 = gelatoTaskId(user, block.timestamp, 37647377);
      assertEq32(supplier.outStream.cancelWithdrawId, taskId, "TASKID");
      console.logBytes32(taskId);
      console.logBytes32(taskId2);
    }

    assertApproxEqRel(supplier.outStream.streamDuration, eUser.outStepTime, 1e12, "STREAM DURATION");
    console.log("STREAM DURATION ----> ", eUser.outStepTime);

    assertEq(supplier.outStream.streamInit, eUser.outStreamInit, "STREAM Init");
    console.log("STREAM Init ----> ", eUser.outStreamInit);

    assertApproxEqRel(supplier.inStream, eUser.inFlow, 1e12, "INFLOW");
    console.log("INFLOW----> ", uint256(uint96(eUser.inFlow)));
  }

  function readFileUser(string memory path) internal view returns (HelpTypes.eUser memory eUser) {
    string memory result = vm.readFile(path);

    eUser.id = st2num(abi.decode(vm.parseJson(result, "id"), (string)));
    eUser.realTimeBalance = st2num(abi.decode(vm.parseJson(result, "realTimeBalance"), (string)));
    eUser.tokenBalance = st2num(abi.decode(vm.parseJson(result, "tokenBalance"), (string)));

    eUser.deposit = st2num(abi.decode(vm.parseJson(result, "deposit"), (string)));

    eUser.inFlowDeposit = st2num(abi.decode(vm.parseJson(result, "inFlowDeposit"), (string)));
    eUser.inFlow = int96(uint96(st2num(abi.decode(vm.parseJson(result, "inFlow "), (string)))));

    eUser.outFlow = int96(uint96(st2num(abi.decode(vm.parseJson(result, "outFlow"), (string)))));
    eUser.outStepTime = st2num(abi.decode(vm.parseJson(result, "outStepTime"), (string)));
    eUser.outStreamCreated = st2num(abi.decode(vm.parseJson(result, "outStreamCreated"), (string)));
    eUser.outStreamInit = st2num(abi.decode(vm.parseJson(result, "outStreamInit"), (string)));
    eUser.outMinBalance = st2num(abi.decode(vm.parseJson(result, "outMinBalance"), (string)));

    eUser.nextExecOut = st2num(abi.decode(vm.parseJson(result, "nextExecOut"), (string)));
    eUser.outStreamId = abi.decode(vm.parseJson(result, "outStreamId"), (bytes32));
    eUser.outStreamInit = st2num(abi.decode(vm.parseJson(result, "outStreamInit"), (string)));
  }

  // helpers
  function st2num(string memory numString) public pure returns (uint256) {
    uint256 val = 0;
    bytes memory stringBytes = bytes(numString);
    for (uint256 i = 0; i < stringBytes.length; i++) {
      uint256 exp = stringBytes.length - i;
      bytes1 ival = stringBytes[i];
      uint8 uval = uint8(ival);
      uint256 jval = uval - uint256(0x30);

      val += (uint256(jval) * (10 ** (exp - 1)));
    }
    return val;
  }
}
