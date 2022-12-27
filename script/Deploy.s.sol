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
import { ERC20mintable } from "../src/interfaces/ERC20mintable.sol";

import { SuperPoolFactory } from "../src/SuperPoolFactory.sol";
import { UUPSProxy } from "../src/upgradability/UUPSProxy.sol";

import { IPool } from "../src/aave/IPool.sol";

import { IOps } from "../src/gelato/IOps.sol";

import { DataTypes } from "../src/libraries/DataTypes.sol";

contract DeployScript is Script {
  ISuperfluid host = ISuperfluid(0x22ff293e14F1EC3A09B137e9e06084AFd63adDF9);
  ISuperToken superToken = ISuperToken(0x8aE68021f6170E5a766bE613cEA0d75236ECCa9a);
  IOps ops = IOps(0xc1C6805B857Bef1f412519C4A842522431aFed39);

  ERC20mintable token = ERC20mintable(0xc94dd466416A7dFE166aB2cF916D3875C049EBB7);

  IPool aavePool = IPool(0x368EedF3f56ad10b9bC57eed4Dac65B26Bb667f6);
  IERC20 aToken = IERC20(0x1Ee669290939f8a8864497Af3BC83728715265FF);
  ERC20mintable aaveToken = ERC20mintable(0xA2025B15a1757311bfD68cb14eaeFCc237AF5b43);

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

    IPoolStrategyV1(address(strategyProxy)).initialize(superToken, token, IPoolV1(poolProxy), aavePool, aToken, aaveToken);

    vm.stopBroadcast();
  }
}
