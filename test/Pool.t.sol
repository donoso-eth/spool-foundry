// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import { DeployPool } from "./fixtures/Deploy.t.sol";
import { Users } from "./fixtures/Users.t.sol";

import { Report } from "./fixtures/Report.t.sol";
import { DataTypes } from "../src/libraries/DataTypes.sol";

import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract PoolTest is Test, DeployPool, Report {
  function setUp() public {
    deploy();
    faucet(user3);
    faucet(user4);
    payable(poolProxy).transfer(1 ether);
  }

  function _testFuzzRedeemFlow(int96 flowRate) public {
    vm.assume(flowRate > 1000000000000);
    address user = user1;

    DataTypes.Pool memory currentPool;

    vm.expectRevert(bytes("NO_BALANCE"));
    redeemFlow(user, flowRate);

    if (superToken.balanceOf(user) > uint256(uint96(flowRate)) * 4 * 60 * 60) {
      startFlow(user, flowRate);

      vm.warp(block.timestamp + 24 * 3600);

      // vm.expectRevert(bytes("INSUFFICIENT_FUNDS"));
      // redeemFlow(user, flowRate);

      vm.warp(block.timestamp + 24 * 3600);

      redeemFlow(user, flowRate);
    }

    invariantTest();
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
     vm.assume(withdrawAmount > 1000000000000);
     vm.assume(depositAmount > 100000000000);
    address user = getUser(userInt);

    if (superToken.balanceOf(user) > depositAmount && depositAmount > 0) {
      sendToPool(user, depositAmount);

      if (withdrawAmount > depositAmount) {
        vm.expectRevert(bytes("NOT_ENOUGH_BALANCE"));
      }

      withdrawFromPool(user, withdrawAmount);

         invariantTest();
    }

 
  }

  function testFuzzDeposit(uint8 userInt, uint256 amount) public {
    vm.assume(amount > 1000000000000);

    address user = getUser(userInt);

    if (superToken.balanceOf(user) > amount && amount > 0) {
      sendToPool(user, amount);
      invariantTest();
    }

  
  }

  function testRedeemFlow() public {
    int96 flowRate = 10000000000;
    address user = user1;

    uint initBalance = calculatePoolTotalBalance();
    console.log(95,initBalance);

    vm.expectRevert(bytes("NO_BALANCE"));
    redeemFlow(user, flowRate);

    startFlow(user, flowRate);

    vm.warp(block.timestamp + 24 * 3600);

    vm.expectRevert(bytes("INSUFFICIENT_FUNDS"));
    redeemFlow(user, flowRate);

    vm.warp(block.timestamp + 24 * 3600);
    initBalance = calculatePoolTotalBalance();


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
    uint256 depositAmount =   2000000000000;
    uint256 withdrawAmount = 1000000000000;
    address user = user1;

    sendToPool(user, depositAmount);

    invariantTest();
    

    withdrawFromPool(user, withdrawAmount);

    invariantTest();


    
     vm.expectRevert(bytes("NOT_ENOUGH_BALANCE"));
     withdrawFromPool(user, withdrawAmount * 2);

     withdrawFromPool(user, withdrawAmount);


   invariantTest();
  }

  function testDeposit() public {
    uint256 amount = 1000000000001;//2000000000000;

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

    uint256 err = 1;

     if (diff != 1) {
          assertApproxEqRel(poolBalance, usersBalance,1e15);
          assertGe(poolBalance, usersBalance);
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
