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

contract PoolAccounting is Test, DeployPool, Report, DecodeFile {
  using SafeMath for uint256;

  function setUp() public {
    deploy();
    faucet(user3);
    faucet(user4);
    payable(poolProxy).transfer(1 ether);
  }

  function testAccounting() public {
    // #region =================  FIRST PERIOD ============================= //



    sendToPool(user1, 500 ether);

    checkFilePool("./test/expected/accounting/expected1.json");
    checkFileUser("./test/expected/accounting/1-user-expected1.json", user1);

    // #endregion ============== FIRST PERIOD ============================= //

    // #region =================  SECOND PERIOD ============================= //

    vm.warp(block.timestamp + 60 days);
    int96 flowRate = int96(uint96(uint256(100 ether).div(30 days)));



    startFlow(user2, flowRate);
 
    checkFilePool("./test/expected/accounting/expected2.json");
    checkFileUser("./test/expected/accounting/2-user-expected1.json", user1);
    checkFileUser("./test/expected/accounting/2-user-expected2.json", user2);
    // #endregion ================= SECOND PERIOD ============================= //

    // #region ================= THIRD PERIOD ============================= //
    vm.warp(block.timestamp + 60 days);
    sendToPool(user2, 300 ether);
    checkFilePool("./test/expected/accounting/expected3.json");
    checkFileUser("./test/expected/accounting/3-user-expected1.json", user1);
    checkFileUser("./test/expected/accounting/3-user-expected2.json", user2);
    // #endregion =================   THIRD PERIOD ============================= //

    // #region =================  FOURTH PERIOD ============================= //
    vm.warp(block.timestamp + 30 days);
    withdrawFromPool(user1, 150 ether);
    checkFilePool("./test/expected/accounting/expected4.json");
    checkFileUser("./test/expected/accounting/4-user-expected1.json", user1);
    checkFileUser("./test/expected/accounting/4-user-expected2.json", user2);

    // #endregion =================   FOUR PERIOD ============================= //

    // #region =================  FIVE PERIOD ============================= //
    vm.warp(block.timestamp + 30 days);
    deleteFlow(user2);
    checkFilePool("./test/expected/accounting/expected5.json");
    checkFileUser("./test/expected/accounting/5-user-expected1.json", user1);
    checkFileUser("./test/expected/accounting/5-user-expected2.json", user2);

    // #endregion =================   FIVETH PERIOD ============================= //

    // #region =================  SIXTH PERIOD ============================= //
    vm.warp(block.timestamp + 30 days);
    startFlow(user1, flowRate / 2);
    checkFilePool("./test/expected/accounting/expected6.json");
    checkFileUser("./test/expected/accounting/6-user-expected1.json", user1);
    checkFileUser("./test/expected/accounting/6-user-expected2.json", user2);

    // #endregion =================   END 6TH PERIOD ============================= //

    // #region =================  7th PERIOD ============================= //
    vm.warp(block.timestamp + 30 days);
    flowRate = int96(uint96(uint256(50 ether).div(30 days)));
    redeemFlow(user2, flowRate);
    checkFilePool("./test/expected/accounting/expected7.json");
    checkFileUser("./test/expected/accounting/7-user-expected1.json", user1);
    checkFileUser("./test/expected/accounting/7-user-expected2.json", user2);

    // #endregion ================= END 7TH PERIOD ============================= //

    // #region =================  8th PERIOD ============================= //
    vm.warp(block.timestamp + 30 days);
    redeemFlowStop(user2);
    checkFilePool("./test/expected/accounting/expected8.json");
    checkFileUser("./test/expected/accounting/8-user-expected1.json", user1);
    checkFileUser("./test/expected/accounting/8-user-expected2.json", user2);
    // #endregion ================= EIGTH PERIOD ============================= //

    // #region =================  9th PERIOD ============================= //
    vm.warp(block.timestamp + 30 days);
    transfer(user2, user3, 75 ether);
    checkFilePool("./test/expected/accounting/expected9.json");
    checkFileUser("./test/expected/accounting/9-user-expected1.json", user1);
    checkFileUser("./test/expected/accounting/9-user-expected2.json", user2);
    checkFileUser("./test/expected/accounting/9-user-expected3.json", user3);

    // #endregion ================= 9th PERIOD ============================= //

    // #region =================  10th PERIOD ============================= //
    vm.warp(block.timestamp + 30 days);
    int96 flowRate2 = int96(uint96(uint256(90 ether).div(30 days)));
    startFlow(user3, flowRate2);
    checkFilePool("./test/expected/accounting/expected10.json");
    checkFileUser("./test/expected/accounting/10-user-expected1.json", user1);
    checkFileUser("./test/expected/accounting/10-user-expected2.json", user2);
    checkFileUser("./test/expected/accounting/10-user-expected3.json", user3);

    // #endregion ================= 10TH PERIOD ============================= //

    // #region =================  11th PERIOD ============================= //
    vm.warp(block.timestamp + 30 days);
    int96 flowRateOut = int96(uint96(uint256(45 ether).div(30 days)));
    redeemFlow(user1, flowRateOut);
    checkFilePool("./test/expected/accounting/expected11.json");
    checkFileUser("./test/expected/accounting/11-user-expected1.json", user1);
    checkFileUser("./test/expected/accounting/11-user-expected2.json", user2);
    checkFileUser("./test/expected/accounting/11-user-expected3.json", user3);

    // #endregion ================= 11th PERIOD ============================= //

    // #region =================  12th PERIOD ============================= //
    vm.warp(block.timestamp + 30 days);
    int96 flowRateOut2 = int96(uint96(uint256(45 ether).div(30 days)));
    redeemFlow(user2, flowRateOut2);
    checkFilePool("./test/expected/accounting/expected12.json");
    checkFileUser("./test/expected/accounting/12-user-expected1.json", user1);
    checkFileUser("./test/expected/accounting/12-user-expected2.json", user2);
    checkFileUser("./test/expected/accounting/12-user-expected3.json", user3);
  }
}
