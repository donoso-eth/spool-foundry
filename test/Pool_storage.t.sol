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
import { PoolProxyWrapper } from "./fixtures/PoolProxyWrapper.sol";

contract PoolStorage is Test, DeployPool, Report, DecodeFile {
  using SafeMath for uint256;

  mapping(address => HelpTypes.eUser) users;

  function setUp() public {
    deploy();
    faucet(user3);
    faucet(user4);
    payable(poolProxy).transfer(1 ether);
  }

  function _testStorage() public {
    sendToPool(user1, 500 ether);

    int96 flowRate = int96(uint96(uint256(100 ether).div(30 days)));

    vm.warp(block.timestamp + 60 days);

    startFlow(user1, flowRate);

    console.log(user1);

    console.log(poolProxy.owner());
    console.log(address(poolFactoryProxy));

    console.logBytes32(bytes32(abi.encode(1_000_000)));

    //  console.logBytes32(bytes32(abi.encodePacked(poolProxy.lastExecution)));
    console.log(address(poolInternal));

    for (uint8 i = 0; i < 30; i++) {
      bytes32 test = (PoolProxyWrapper(payable(poolProxy)).readStorageSlot(i));
      console.logBytes32(test);
    }

    //assertEq(test, bytes32(abi.encodePacked("sp", "DAI")));

    // test = poolProxy.readStorageSlot(5);
    // assertEq(test, bytes32(abi.encodePacked(address(0x1804c8AB1F12E6bbf3894d4083f33e07309d1f38))));
    // console.log(49, user1);
    // console.logBytes32(test);
  }
}
