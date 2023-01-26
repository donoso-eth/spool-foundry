// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "forge-std/Test.sol";
import { IConstantFlowAgreementV1 } from "@superfluid-finance/ethereum-contracts/contracts/interfaces/agreements/IConstantFlowAgreementV1.sol";
import { CFAv1Library } from "@superfluid-finance/ethereum-contracts/contracts/apps/CFAv1Library.sol";
import { Config } from "./Config.sol";

import { IERC777 } from "@openzeppelin/contracts/token/ERC777/IERC777.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import { IPoolV1 } from "../../src/interfaces/IPool-V1.sol";
import { LibDataTypes } from "../../src/gelato/LibDataTypes.sol";

abstract contract Users is Test, Config {
  using CFAv1Library for CFAv1Library.InitData;

  CFAv1Library.InitData public _cfaLib;
  IConstantFlowAgreementV1 cfa;

  address user1 = address(0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266);
  address user2 = address(0x70997970C51812dc3A010C7d01b50e0d17dc79C8);
  address user3 = address(0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC);
  address user4 = address(0x90F79bf6EB2c4f870365E785982E1f101E93b906);

  constructor() {
    vm.label(user1, "User1");
    vm.label(user2, "User2");
    vm.label(user3, "User3");
    vm.label(user4, "User4");
    faucet(user1);
    faucet(user2);

    cfa = IConstantFlowAgreementV1(address(host.getAgreementClass(keccak256("org.superfluid-finance.agreements.ConstantFlowAgreement.v1"))));
    _cfaLib = CFAv1Library.InitData(host, cfa);
  }

  function faucet(address user) internal {
    uint256 amount = 10000 ether;
    uint256 whale = token.balanceOf(address(0x9810762578aCCF1F314320CCa5B72506aE7D7630)); //USD
    address whaleDAI = address(0x91993f2101cc758D0dEB7279d41e880F7dEFe827);
    uint256 whaleDAIBalance = token.balanceOf(address(whaleDAI));
    console.log(whaleDAIBalance); //16044206230259623513171834

    vm.prank(whaleDAI);
    token.transfer(user, amount);

    vm.startPrank(user);
    token.approve(address(superToken), MAX_INT);

    superToken.upgrade(amount);
    vm.stopPrank();
    console.log(user, " ", superToken.balanceOf(user));
  }

  function transfer(address sender, address receiver, uint256 amount) internal {
    vm.prank(sender);
    IERC20(address(poolProxy)).transfer(receiver, amount);
    vm.stopPrank();
  }

  function sendToPool(address sender, uint256 amount) internal {
    vm.prank(sender);
    IERC777(address(superToken)).send(address(poolProxy), amount, "0x");
    vm.stopPrank();
  }

  function withdrawFromPool(address sender, uint256 amount) public {
    vm.startPrank(sender);
    poolProxy.redeemDeposit(amount);
    vm.stopPrank();
  }

  function closeAccount(address sender) public {
    vm.startPrank(sender);
    poolProxy.closeAccount();
    vm.stopPrank();
  }

  function startFlow(address sender, int96 flowRate) internal {
    vm.startPrank(sender);
    console.log(93);
    _cfaLib.createFlow(address(poolProxy), superToken, flowRate);
    console.log(95);
    vm.stopPrank();
  }

  function deleteFlow(address sender) internal {
    vm.startPrank(sender);
    _cfaLib.deleteFlow(sender, address(poolProxy), superToken);
    vm.stopPrank();
  }

  function updateFlow(address sender, int96 flowRate) internal {
    vm.startPrank(sender);
    _cfaLib.updateFlow(address(poolProxy), superToken, flowRate);
    vm.stopPrank();
  }

  function redeemFlow(address sender, int96 flowRate) internal {
    vm.startPrank(sender);
    poolProxy.redeemFlow(flowRate);
    vm.stopPrank();
  }

  function redeemFlowStop(address sender) internal {
    vm.startPrank(sender);
    poolProxy.redeemFlowStop();
    vm.stopPrank();
  }

  function getFlowRate(address sender, address receiver) internal view returns (int96 flowRate) {
    (, flowRate,,) = cfa.getFlow(superToken, sender, receiver);
  }

  function getFlowDeposit(address sender, address receiver) internal view returns (uint256 deposit) {
    (,, deposit,) = cfa.getFlow(superToken, sender, receiver);
  }
}
