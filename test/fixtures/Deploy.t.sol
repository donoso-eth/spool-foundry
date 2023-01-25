// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "forge-std/Test.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import { ISuperfluid, ISuperToken } from "@superfluid-finance/ethereum-contracts/contracts/interfaces/superfluid/ISuperfluid.sol";

//import { PoolV1 } from "../../src/Pool-V1.sol";
import { IPoolV1 } from "../../src/interfaces/IPool-V1.sol";
import { ISuperPoolFactory } from "../../src/interfaces/ISuperPoolFactory.sol";

import { PoolInternalV1 } from "../../src/PoolInternal-V1.sol";

import { PoolStrategyV1 } from "../../src/PoolStrategy-V1.sol";
import { IPoolStrategyV1 } from "../../src/interfaces/IPoolStrategy-V1.sol";


import { SuperPoolFactory } from "../../src/SuperPoolFactory.sol";
import { UUPSProxy } from "../../src/upgradability/UUPSProxy.sol";

import { IPool } from "../../src/aave/IPool.sol";

import { IOps } from "../../src/gelato/IOps.sol";

import { DataTypes } from "../../src/libraries/DataTypes.sol";
import { PoolProxyWrapper} from "./PoolProxyWrapper.sol";
import { IGovernance} from "../interfaces/IGovernance.sol";
import { Config } from "./Config.sol";

abstract contract DeployPool is Test, Config {
  PoolProxyWrapper poolImpl;

  PoolInternalV1 poolInternal;

  PoolStrategyV1 poolStrategyImpl;

  SuperPoolFactory poolFactoryImpl;
  UUPSProxy poolFactoryProxy;

  constructor() { }

  function deploy() public {
    //vm.startBroadcast();

    poolImpl = new PoolProxyWrapper();

    poolInternal = new PoolInternalV1();

    poolStrategyImpl = new PoolStrategyV1();

    strategyProxy = new UUPSProxy();

    strategyProxy.initializeProxy(address(poolStrategyImpl));

    poolFactoryImpl = new SuperPoolFactory();

    poolFactoryProxy = new UUPSProxy();

    poolFactoryProxy.initializeProxy(address(poolFactoryImpl));

    DataTypes.SuperPoolFactoryInitializer memory factoryInitialize = DataTypes.SuperPoolFactoryInitializer(host, address(poolImpl), address(poolInternal), ops);

    ISuperPoolFactory(address(poolFactoryProxy)).initialize(factoryInitialize);

    address superfluidOwner = address(0x1EB3FAA360bF1f093F5A18d21f21f13D769d044A);
    
    address governanceAddress = (0x3AD3f7A0965Ce6f9358AD5CCE86Bc2b05F1EE087);


    vm.startPrank(superfluidOwner); 
    bool isAuthorize = IGovernance(governanceAddress).isAuthorizedAppFactory(address(host), address(poolFactoryProxy));
    console.log(73, isAuthorize);

    IGovernance(governanceAddress).authorizeAppFactory(address(host), address(poolFactoryProxy));

    isAuthorize = IGovernance(governanceAddress).isAuthorizedAppFactory(address(host), address(poolFactoryProxy));
    console.log(76, isAuthorize);
    vm.stopPrank();

    ISuperPoolFactory(address(poolFactoryProxy)).createSuperPool(DataTypes.CreatePoolInput(address(superToken), address(strategyProxy)));

    poolInfo = ISuperPoolFactory(address(poolFactoryProxy)).getRecordBySuperTokenAddress(address(superToken), address(strategyProxy));

    poolProxy = PoolProxyWrapper(payable(poolInfo.pool));

    IPoolStrategyV1(address(strategyProxy)).initialize(superToken, token, IPoolV1(poolProxy), aavePool, aToken);

    string memory line1 = string(abi.encodePacked('{"pool":"', vm.toString(address(poolProxy)), '"}'));
    vm.writeFile("./test/addresses.json", line1);
    //vm.stopBroadcast();

    vm.warp(block.timestamp + 18 seconds);
  }
}
