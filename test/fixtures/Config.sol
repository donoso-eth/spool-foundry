// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "forge-std/Test.sol";

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import { ISuperfluid, ISuperToken } from "@superfluid-finance/ethereum-contracts/contracts/interfaces/superfluid/ISuperfluid.sol";

import { ERC20mintable } from "../../src/interfaces/ERC20mintable.sol";

import { UUPSProxy } from "../../src/upgradability/UUPSProxy.sol";
import { IPool } from "../../src/aave/IPool.sol";
import { DataTypes } from "../../src/libraries/DataTypes.sol";

import { PoolV1 } from "../../src/Pool-V1.sol";

import { IOps } from "../../src/gelato/IOps.sol";

abstract contract Config {
  ISuperfluid host = ISuperfluid(0x22ff293e14F1EC3A09B137e9e06084AFd63adDF9);
  ISuperToken superToken = ISuperToken(0x8aE68021f6170E5a766bE613cEA0d75236ECCa9a);
  IOps ops = IOps(0xc1C6805B857Bef1f412519C4A842522431aFed39);

  ERC20mintable token = ERC20mintable(0xc94dd466416A7dFE166aB2cF916D3875C049EBB7);

  IPool aavePool = IPool(0x368EedF3f56ad10b9bC57eed4Dac65B26Bb667f6);
  IERC20 aToken = IERC20(0x1Ee669290939f8a8864497Af3BC83728715265FF);
  ERC20mintable aaveToken = ERC20mintable(0xA2025B15a1757311bfD68cb14eaeFCc237AF5b43);

  DataTypes.PoolInfo poolInfo;
  PoolV1 poolProxy;

  uint256 MAX_INT = 2 ** 256 - 1;

  UUPSProxy strategyProxy;

  address public constant ETH = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
}
