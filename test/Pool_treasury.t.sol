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

  function testUseCaseTreasury() public {
    sendToPool(user1, 500 ether);

    checkFilePool("./test/expected/test-stream/expected1.json");
    checkFileUser("./test/expected/test-stream/1-user-expected1.json", user1);

    vm.warp(block.timestamp + 60 days);
  }
}
