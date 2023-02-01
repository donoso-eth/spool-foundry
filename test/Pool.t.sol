// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import { DeployPool } from "./fixtures/Deploy.t.sol";
import { Users } from "./fixtures/Users.t.sol";

import { Report } from "./fixtures/Report.t.sol";
import { DataTypes } from "../src/libraries/DataTypes.sol";

import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract PoolTest is Test, DeployPool, Report {
  using SafeMath for uint256;

  function setUp() public {
    deploy();
    faucet(user3);
    faucet(user4);
    payable(poolProxy).transfer(1 ether);
  }

  // function testFuzzRedeemFlow() public {
  //     int96 flowRate = 63937141655095766; // equals = 139805 token month
  function testFuzzRedeemFlow(int96 flowRate) public {
    if (flowRate > 45000) {
      vm.assume(flowRate > 45000);
      // vm.assume(flowRate < 53937141655095766);
      //  if (flowRate < 53937141655095766){
      address user = user1;

      DataTypes.Pool memory currentPool;

      vm.expectRevert(bytes("NO_BALANCE"));
      redeemFlow(user, flowRate);

      if (superToken.balanceOf(user) > uint256(uint96(flowRate)) * 52 * 60 * 60) {
        startFlow(user, flowRate);
        uint256 depo = getFlowDeposit(user, address(poolProxy));

        vm.warp(block.timestamp + 24 * 3600);

        vm.expectRevert(bytes("INSUFFICIENT_FUNDS"));
        redeemFlow(user, flowRate);

        vm.warp(block.timestamp + 24 * 3600);

        uint256 balUser1 = superToken.balanceOf(user);

        redeemFlow(user, flowRate);

        invariantTest();
      }
      // }
    }
  }

  function testFuzzStream(uint8 userInt, int96 flowRate) public {
    vm.assume(flowRate > 0);

    address user = getUser(userInt);

    if (superToken.balanceOf(user) > uint256(uint96(flowRate)) * 4 * 60 * 60) {
      startFlow(user, flowRate);
    }

    invariantTest();
  }

  function testFuzzWithdraw(uint8 userInt, uint256 depositAmount, uint256 withdrawAmount) public {
    vm.assume(depositAmount > withdrawAmount);

    address user = getUser(userInt);

    if (depositAmount > withdrawAmount && superToken.balanceOf(user) > depositAmount && depositAmount > 0) {
      sendToPool(user, depositAmount);

      if (withdrawAmount > depositAmount) {
        vm.expectRevert(bytes("NOT_ENOUGH_BALANCE"));
      }

      withdrawFromPool(user, withdrawAmount);

      invariantTest();
    }
  }

  function testFuzzDeposit(uint8 userInt, uint256 amount) public {
    //vm.assume(amount > 1000000000000);

    address user = getUser(userInt);

    if (superToken.balanceOf(user) > amount && amount > 0) {
      sendToPool(user, amount);
      invariantTest();
    }
  }

  function testCloseAccount() public {
    int96 flowRate = int96(uint96((100 ether) / uint256((30 * 24 * 3600))));
    address user = user1;

    // test close account inStream
    uint256 initBalance = calculatePoolTotalBalance();
    startFlow(user, flowRate);

    vm.warp(block.timestamp + 30 * 24 * 3600);

    initBalance = calculatePoolTotalBalance();
    invariantTest();
    assertApproxEqRel(100 ether, initBalance, 1e12, "CLOSE_ACCOUNT_BALANCE-1");
    console.log("CLOSE_ACCOUNT_BALANCE ----> ", initBalance);

    uint256 amount = 50 ether;
    sendToPool(user, amount);
    initBalance = calculatePoolTotalBalance();
    invariantTest();
    assertApproxEqRel(150 ether, initBalance, 1e12, "CLOSE_ACCOUNT_BALANCE-2");
    console.log("CLOSE_ACCOUNT_BALANCE ----> ", initBalance);

    vm.warp(block.timestamp + 30 * 24 * 3600);
    uint256 userBalance = superToken.balanceOf(user);

    uint256 userPoolBalance = poolProxy.balanceOf(user);

    uint256 depo = getFlowDeposit(user, address(poolProxy));

    DataTypes.Pool memory currentPool = poolProxy.getLastPool();

    assertEq(currentPool.inFlowRate, flowRate, "FLOW_SHOUL_BE_100_PER_MONTH");

    closeAccount(user);
    uint256 userEndBalance = superToken.balanceOf(user);
    uint256 depoAfter = getFlowDeposit(user, address(poolProxy));

    assertApproxEqRel(userEndBalance, userPoolBalance + userBalance + depo, 1e12, "CLOSE_ACCOUNT_BALANCE-3");

    assertEq(depoAfter, 0, "DEPO_SHOULD_BE_ZERO");

    currentPool = poolProxy.getLastPool();

    assertEq(currentPool.inFlowRate, 0, "FLOW_SHOUL_BE_ZERO");

    // test close account outStream

    user = user2;
    initBalance = calculatePoolTotalBalance();

    sendToPool(user, 500 ether);

    redeemFlow(user, flowRate);

    vm.warp(block.timestamp + 30 * 24 * 3600);

    currentPool = poolProxy.getLastPool();

    assertEq(currentPool.outFlowRate, flowRate, "FLOW_SHOUL_BE_100_MONTH");

    closeAccount(user);

    currentPool = poolProxy.getLastPool();

    assertEq(currentPool.outFlowRate, 0, "FLOW_SHOUL_BE_ZERO");
  }

  function testEmergency() public {
    bool emergency = poolProxy.emergency();

    assertEq(emergency, false);
    address owner = poolProxy.owner();

    startFlow(user1, 10000000000);

    sendToPool(user2, 50 ether);

    vm.warp(block.timestamp + 30 * 24 * 3600);

    redeemFlow(user2, 5000000000);

    vm.startPrank(user2);

    vm.expectRevert(bytes("Only Owner"));
    poolProxy.setEmergency(true);
    vm.stopPrank();

    vm.startPrank(owner);
    poolProxy.setEmergency(true);
    emergency = poolProxy.emergency();
    assertEq(emergency, true);
    vm.stopPrank();

    vm.expectRevert(bytes("EMERGENCY"));
    withdrawFromPool(user2, 10 ether);

    vm.startPrank(owner);
    address[] memory senders = new address[](2);
    senders[0] = user1;
    senders[1] = address(poolProxy);

    address[] memory receivers = new address[](2);
    receivers[0] = address(poolProxy);
    receivers[1] = user2;

    poolProxy.emergencyCloseStream(senders, receivers);

    int96 flowRate = getFlowRate(user1, address(poolProxy));

    assertEq(flowRate, 0);

    int96 outFlowRate = getFlowRate(address(poolProxy), user2);

    assertEq(outFlowRate, 0);

    address[] memory suppliers = new address[](1);
    suppliers[0] = user2;

    uint256[] memory balances = new uint256[](1);
    balances[0] = 3 ether;

    poolProxy.emergencyUpdateBalanceSuppplier(suppliers, balances);

    uint256 user2Balance = poolProxy.balanceOf(user2);

    assertEq(user2Balance, 3 ether);

    vm.stopPrank();
  }

  function testRedeemFlow() public {
    int96 flowRate = 10000000000;
    address user = user1;

    uint256 initBalance = calculatePoolTotalBalance();

    vm.expectRevert(bytes("NO_BALANCE"));
    redeemFlow(user, flowRate);

    startFlow(user, flowRate);

    vm.warp(block.timestamp + 24 * 3600);

    vm.expectRevert(bytes("INSUFFICIENT_FUNDS"));
    redeemFlow(user, flowRate);

    vm.warp(block.timestamp + 24 * 3600);
    initBalance = calculatePoolTotalBalance();

    vm.expectRevert(bytes("FLOWRATE_SHOULD_BE_GREATER_THAN_ZERO"));
    redeemFlow(user, 0);

    redeemFlow(user, flowRate);

    invariantTest();
  }

  function testStream() public {
    int96 flowRate = 10000;

    vm.assume(flowRate > 0);

    address user = user2;

    if (superToken.balanceOf(user) > uint256(uint96(flowRate)) * 4 * 60 * 60) {
      startFlow(user, flowRate);
    }

    invariantTest();
  }

  function testWithdraw() public {
    uint256 depositAmount = 3000000000000;
    uint256 withdrawAmount = 1000000000000;
    address user = user1;

    sendToPool(user, depositAmount);

    invariantTest();

    withdrawFromPool(user, withdrawAmount);

    invariantTest();

    vm.expectRevert(bytes("NOT_ENOUGH_BALANCE"));
    withdrawFromPool(user, withdrawAmount * 3);

    withdrawFromPool(user, withdrawAmount);

    invariantTest();
  }

  function testDeposit() public {
    uint256 amount = 1000000000001; //2000000000000;

    address user = user1;

    if (superToken.balanceOf(user) > amount && amount > 0) {
      sendToPool(user, amount);
      invariantTest();
    }
  }

  function getDiff(uint256 x, uint256 y) internal pure returns (uint256 diff) {
    diff = x > y ? x - y : y - x;
  }

  function invariantTest() internal {
    uint256 poolBalance = calculatePoolTotalBalance();

    uint256 usersBalance = calculateUsersTotalBalance();

    uint256 diff = getDiff(poolBalance, usersBalance);

    if (diff > 2) {
      assertGe(poolBalance, usersBalance);
      assertApproxEqRel(poolBalance, usersBalance, 1e12);
    }
  }

  function getUser(uint8 random) internal view returns (address user) {
    uint8 userId = (random % 4) + 1;

    if (userId == 1) {
      user = user1;
    } else if (userId == 2) {
      user = user2;
    } else if (userId == 3) {
      user = user3;
    } else if (userId == 4) {
      user = user4;
    }
  }
}
