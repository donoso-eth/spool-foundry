// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import { ISuperfluid, ISuperToken } from "@superfluid-finance/ethereum-contracts/contracts/interfaces/superfluid/ISuperfluid.sol";

import { PoolV1 } from "../src/Pool-V1.sol";
import { IPoolV1 } from "../src/interfaces/IPool-V1.sol";
import { ISuperPoolFactory } from "../src/interfaces/ISuperPoolFactory.sol";

import { PoolInternalV1 } from "../src/PoolInternal-V1.sol";

import { PoolStrategyV1 } from "../src/PoolStrategy-V1.sol";
import { IPoolStrategyV1 } from "../src/interfaces/IPoolStrategy-V1.sol";


import { SuperPoolFactory } from "../src/SuperPoolFactory.sol";
import { UUPSProxy } from "../src/upgradability/UUPSProxy.sol";

import { IPool } from "../src/aave/IPool.sol";

import { IOps } from "../src/gelato/IOps.sol";

import { DataTypes } from "../src/libraries/DataTypes.sol";

contract DeployScript is Script {
 ISuperfluid host = ISuperfluid(0x3E14dC1b13c488a8d5D310918780c983bD5982E7);
  ISuperToken superToken = ISuperToken(0xCAa7349CEA390F89641fe306D93591f87595dc1F);
  IOps ops = IOps(0x527a819db1eb0e34426297b03bae11F2f8B3A19E);

  IERC20 token = IERC20(0x2791Bca1f2de4661ED88A30C99A7a9449Aa84174);

  IPool aavePool = IPool(0x794a61358D6845594F94dc1DB02A252b5b4814aD);
  IERC20 aToken = IERC20(0x625E7708f30cA75bfd92586e17077590C60eb4cD);

  PoolV1 poolImpl;

  PoolInternalV1 poolInternal;

  PoolStrategyV1 poolStrategyImpl;
  UUPSProxy strategyProxy;

  SuperPoolFactory poolFactoryImpl;
  UUPSProxy poolFactoryProxy;

  function setUp() public { }

  function run() public {
    vm.startBroadcast();
    poolImpl = new PoolV1();

    poolInternal = new PoolInternalV1();

    poolStrategyImpl = new PoolStrategyV1();

    strategyProxy = new UUPSProxy();

    strategyProxy.initializeProxy(address(poolStrategyImpl));

    poolFactoryImpl = new SuperPoolFactory();

    poolFactoryProxy = new UUPSProxy();

    poolFactoryProxy.initializeProxy(address(poolFactoryImpl));

    DataTypes.SuperPoolFactoryInitializer memory factoryInitialize = DataTypes.SuperPoolFactoryInitializer(host, address(poolImpl), address(poolInternal), ops);

    ISuperPoolFactory(address(poolFactoryProxy)).initialize(factoryInitialize);

    ISuperPoolFactory(address(poolFactoryProxy)).createSuperPool(DataTypes.CreatePoolInput(address(superToken), address(strategyProxy)));

    DataTypes.PoolInfo memory poolInfo = ISuperPoolFactory(address(poolFactoryProxy)).getRecordBySuperTokenAddress(address(superToken), address(strategyProxy));

    address poolProxy = poolInfo.pool;

    IPoolStrategyV1(address(strategyProxy)).initialize(superToken, token, IPoolV1(poolProxy), aavePool, aToken);

    vm.stopBroadcast();
  }
}
