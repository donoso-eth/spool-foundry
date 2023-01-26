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
    // #region =================  FIRST PERIOD ============================= //

    sendToPool(user1, 500 ether);

    // checkFilePool("./test/expected/test-stream/expected1.json");
    // checkFileUser("./test/expected/test-stream/1-user-expected1.json", user1);

    // #endregion ============== FIRST PERIOD ============================= //

    bytes32 test = PoolProxyWrapper(payable(poolProxy)).readStorageSlot(5);
    //console.logBytes32()
    console.log(42);
    //console.log(string(bytes(test)));
    console.log(string((abi.encodePacked("sp", "USDC"))));
    assertEq(test, bytes32(abi.encodePacked("sp", "USDC")));

    string memory aa = string(abi.encodePacked("sp", "USDC"));
    console.logBytes32(bytes32(bytes(aa)));
    console.log(aa);

    // test = poolProxy.readStorageSlot(5);
    // assertEq(test, bytes32(abi.encodePacked(address(0x1804c8AB1F12E6bbf3894d4083f33e07309d1f38))));
    // console.log(49, user1);
    // console.logBytes32(test);
  }
}
