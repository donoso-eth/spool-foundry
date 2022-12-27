// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import { DeployPool } from "./fixtures/Deploy.t.sol";
import { Users } from "./fixtures/Users.t.sol";
import { Gelato } from "./fixtures/Gelato.t.sol";

import { Report } from "./fixtures/Report.t.sol";
import { DecodeFile } from "./fixtures/DecodeFile.t.sol";
import { DataTypes } from "../src/libraries/DataTypes.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import { HelpTypes } from "./fixtures/TestTypes.t.sol";

contract PoolTreasury is Test, DeployPool, Report, DecodeFile {
  using SafeMath for uint256;

  mapping(address => HelpTypes.eUser) users;

  function setUp() public {
    deploy();
    faucet(user3);
    faucet(user4);
    payable(poolProxy).transfer(1 ether);
  }

  function testTreasury() public {
    // #region =================  FIRST PERIOD ============================= //

    sendToPool(user1, 500 ether);

    checkFilePool("./test/expected/treasury/expected1.json");
    checkFileUser("./test/expected/treasury/1-user-expected1.json", user1);

    // #endregion ============== FIRST PERIOD ============================= //

    // #region =================  SECOND PERIOD ============================= //

    vm.warp(block.timestamp + 60 days);

    int96 flowRate1 = int96(uint96(uint256(100 ether).div(30 days)));

    startFlow(user2, flowRate1);

    checkFilePool("./test/expected/treasury/expected2.json");
    checkFileUser("./test/expected/treasury/2-user-expected1.json", user1);
    checkFileUser("./test/expected/treasury/2-user-expected2.json", user2);
    // #endregion ================= SECOND PERIOD ============================= //

    // #region ================= THIRD PERIOD ============================= //

    vm.warp(block.timestamp + 30 days);
    int96 flowRate2 = int96(uint96(uint256(150 ether).div(30 days)));

    redeemFlow(user1, flowRate2);
    uint256 initialBuffer = 1 hours * uint96(flowRate2);
    uint256 initialWithdraw = 4 hours * uint96(flowRate2);
    uint256 nextExec = (poolProxy.balanceOf(user1).sub(initialBuffer.add(initialWithdraw))).div(uint96(flowRate2));

    checkFilePool("./test/expected/treasury/expected3.json");
    checkFileUser("./test/expected/treasury/3-user-expected1.json", user1);
    checkFileUser("./test/expected/treasury/3-user-expected2.json", user2);
    // #endregion =================   THIRD PERIOD ============================= //

    // #region =================  FOURTH PERIOD ============================= //

    vm.warp(block.timestamp + 1 days);

    gelatoBalance();

    vm.warp(block.timestamp + 1 days);

    gelatoBalance();

    vm.warp(block.timestamp + 6 hours);
    int96 flowRate50 = int96(uint96(uint256(50 ether).div(30 days)));
    startFlow(user3, flowRate50);

    checkFilePool("./test/expected/treasury/expected4.json");
    checkFileUser("./test/expected/treasury/4-user-expected1.json", user1);
    checkFileUser("./test/expected/treasury/4-user-expected2.json", user2);
    checkFileUser("./test/expected/treasury/4-user-expected3.json", user3);

    // #endregion =================   FOURTH PERIOD ============================= //

    // #region =================  5th PERIOD ============================= //
    vm.warp(block.timestamp + 17 hours);
    int96 flowRate40 = int96(uint96(uint256(40 ether).div(30 days)));

    updateFlow(user2, flowRate40);
    checkFilePool("./test/expected/treasury/expected5.json");
    checkFileUser("./test/expected/treasury/5-user-expected1.json", user1);
    checkFileUser("./test/expected/treasury/5-user-expected2.json", user2);
    checkFileUser("./test/expected/treasury/5-user-expected3.json", user3);

    // #endregion =================   5th PERIOD ============================= //

     for (uint256 i = 0; i<10; i++) {
    
    vm.warp(block.timestamp + 1 days);

    gelatoBalance();

     }
 
  // #region =================  5th PERIOD ============================= //
    vm.warp(block.timestamp + 4 hours);
    int96 flowRate18 = int96(uint96(uint256(90 ether).div(30 days)));
    redeemFlow(user1, flowRate18);
    checkFilePool("./test/expected/treasury/expected6.json");
    checkFileUser("./test/expected/treasury/6-user-expected1.json", user1);
    checkFileUser("./test/expected/treasury/6-user-expected2.json", user2);
    checkFileUser("./test/expected/treasury/6-user-expected3.json", user3);

    // #endregion =================   5th PERIOD ============================= //

 
  }
}
