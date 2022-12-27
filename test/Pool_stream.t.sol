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

contract PoolStream is Test, DeployPool, Report, DecodeFile {
  using SafeMath for uint256;

  mapping(address => HelpTypes.eUser) users;

  function setUp() public {
    deploy();
    faucet(user3);
    faucet(user4);
    payable(poolProxy).transfer(1 ether);
  }

  function testUseCaseStream() public {
    // #region =================  FIRST PERIOD ============================= //

    sendToPool(user1, 500 ether);

    checkFilePool("./test/expected/test-stream/expected1.json");
    checkFileUser("./test/expected/test-stream/1-user-expected1.json", user1);

    // #endregion ============== FIRST PERIOD ============================= //

    // #region =================  SECOND PERIOD ============================= //

    vm.warp(block.timestamp + 60 days);

    int96 flowRate1 = int96(uint96(uint256(100 ether).div(30 days)));

    startFlow(user2, flowRate1);

    checkFilePool("./test/expected/test-stream/expected2.json");
    checkFileUser("./test/expected/test-stream/2-user-expected1.json", user1);
    checkFileUser("./test/expected/test-stream/2-user-expected2.json", user2);
    // #endregion ================= SECOND PERIOD ============================= //

    // #region ================= THIRD PERIOD ============================= //

    vm.warp(block.timestamp + 30 days);

    redeemFlow(user1, flowRate1);
    uint256 initialBuffer = 1 hours * uint96(flowRate1);
    uint256 initialWithdraw = 4 hours * uint96(flowRate1);
    uint256 nextExec = (poolProxy.balanceOf(user1).sub(initialBuffer.add(initialWithdraw))).div(uint96(flowRate1));

    console.log(initialBuffer + initialWithdraw);
    console.log(initialBuffer + initialWithdraw - getFlowDeposit(address(poolProxy), user1));

    checkFilePool("./test/expected/test-stream/expected3.json");
    checkFileUser("./test/expected/test-stream/3-user-expected1.json", user1);
    // #endregion =================   THIRD PERIOD ============================= //

    // #region =================  FOURTH PERIOD ============================= //

    vm.warp(nextExec + block.timestamp);
    DataTypes.Supplier memory supplier = poolProxy.getSupplier(user1);
    gelatoCloseStream(user1, supplier.outStream.streamInit, supplier.outStream.streamDuration);

    checkFilePool("./test/expected/test-stream/expected4.json");
    checkFileUser("./test/expected/test-stream/4-user-expected1.json", user1);
    checkFileUser("./test/expected/test-stream/4-user-expected2.json", user2);

    // #region =================  5th PERIOD ============================= //
    vm.warp(block.timestamp + 30 days);
    int96 flowRate60 = int96(uint96(uint256(60 ether).div(30 days)));

    startFlow(user1, flowRate60);
    checkFilePool("./test/expected/test-stream/expected5.json");
    checkFileUser("./test/expected/test-stream/5-user-expected1.json", user1);
    checkFileUser("./test/expected/test-stream/5-user-expected2.json", user2);

    // #endregion ================= END 5TH PERIOD ============================= //

    // #region =================  6th PERIOD ============================= //
    vm.warp(block.timestamp + 30 days);
    redeemFlow(user2, flowRate60);
    console.log(97);
    initialBuffer = 1 hours * uint96(flowRate60);
    initialWithdraw = 4 hours * uint96(flowRate60);

    console.log(initialBuffer + initialWithdraw);
    console.log(initialBuffer + initialWithdraw - getFlowDeposit(address(poolProxy), user2));

    checkFilePool("./test/expected/test-stream/expected6.json");
    checkFileUser("./test/expected/test-stream/6-user-expected1.json", user1);
    checkFileUser("./test/expected/test-stream/6-user-expected2.json", user2);

    // #endregion ================= END 6TH PERIOD ============================= //

    // #region =================  7th PERIOD ============================= //
    vm.warp(block.timestamp + 30 days);
    sendToPool(user2, uint256(50 ether));
    checkFilePool("./test/expected/test-stream/expected7.json");
    checkFileUser("./test/expected/test-stream/7-user-expected1.json", user1);
    checkFileUser("./test/expected/test-stream/7-user-expected2.json", user2);

    // #endregion ================= END 7TH PERIOD ============================= //

    // #region =================  8th PERIOD ============================= //
    vm.warp(block.timestamp + 30 days);
    withdrawFromPool(user2, 50 ether);
    checkFilePool("./test/expected/test-stream/expected8.json");
    checkFileUser("./test/expected/test-stream/8-user-expected1.json", user1);
    checkFileUser("./test/expected/test-stream/8-user-expected2.json", user2);
  }
}
