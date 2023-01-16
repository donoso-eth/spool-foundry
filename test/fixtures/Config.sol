// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "forge-std/Test.sol";

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import { ISuperfluid, ISuperToken } from "@superfluid-finance/ethereum-contracts/contracts/interfaces/superfluid/ISuperfluid.sol";

import { UUPSProxy } from "../../src/upgradability/UUPSProxy.sol";
import { IPool } from "../../src/aave/IPool.sol";
import { DataTypes } from "../../src/libraries/DataTypes.sol";

import { PoolV1 } from "../../src/Pool-V1.sol";

import { IOps } from "../../src/gelato/IOps.sol";

abstract contract Config {
  ISuperfluid host = ISuperfluid(0x3E14dC1b13c488a8d5D310918780c983bD5982E7);
  ISuperToken superToken = ISuperToken(0xCAa7349CEA390F89641fe306D93591f87595dc1F);
  IOps ops = IOps(0x527a819db1eb0e34426297b03bae11F2f8B3A19E);

  IERC20 token = IERC20(0x2791Bca1f2de4661ED88A30C99A7a9449Aa84174);

  IPool aavePool = IPool(0x794a61358D6845594F94dc1DB02A252b5b4814aD);
  IERC20 aToken = IERC20(0x625E7708f30cA75bfd92586e17077590C60eb4cD);

  DataTypes.PoolInfo poolInfo;
  PoolV1 poolProxy;

  uint256 MAX_INT = 2 ** 256 - 1;

  UUPSProxy strategyProxy;

  address public constant ETH = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
}
