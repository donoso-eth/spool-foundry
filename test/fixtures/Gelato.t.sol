// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "forge-std/Test.sol";
import { IConstantFlowAgreementV1 } from "@superfluid-finance/ethereum-contracts/contracts/interfaces/agreements/IConstantFlowAgreementV1.sol";
import { CFAv1Library } from "@superfluid-finance/ethereum-contracts/contracts/apps/CFAv1Library.sol";
import { Config } from "./Config.sol";

import { IERC777 } from "@openzeppelin/contracts/token/ERC777/IERC777.sol";
import { IPoolV1 } from "../../src/interfaces/IPool-V1.sol";
import { LibDataTypes } from "../../src/gelato/LibDataTypes.sol";

abstract contract Gelato is Test, Config {
  using CFAv1Library for CFAv1Library.InitData;

  address opsExecutor = address(0x7598e84B2E114AB62CAB288CE5f7d5f6bad35BbA);

  constructor() { }

  function memorySliceSelector(bytes memory _bytes) internal pure returns (bytes4 selector) {
    selector = _bytes[0] | (bytes4(_bytes[1]) >> 8) | (bytes4(_bytes[2]) >> 16) | (bytes4(_bytes[3]) >> 24);
  }

  function gelatoTaskId(address user, uint256 streamInit, uint256 streamDuration) internal view returns (bytes32 taskId) {
    bytes memory timeArgs = abi.encode(uint128(streamInit + streamDuration), streamDuration);

    bytes memory execData = abi.encodeWithSelector(IPoolV1.taskClose.selector, user);

    bytes4 selector = memorySliceSelector(execData);

    LibDataTypes.Module[] memory modules = new LibDataTypes.Module[](2);

    modules[0] = LibDataTypes.Module.TIME;
    modules[1] = LibDataTypes.Module.SINGLE_EXEC;

    bytes[] memory args = new bytes[](1);

    args[0] = timeArgs;

    LibDataTypes.ModuleData memory moduleData = LibDataTypes.ModuleData(modules, args);
    taskId = keccak256(abi.encode(address(poolProxy), address(poolProxy), selector, moduleData, ETH));
  }

  function gelatoCloseStream(address user, uint256 streamInit, uint256 streamDuration) internal {
    vm.startPrank(opsExecutor);
    bytes memory timeArgs = abi.encode(uint128(streamInit + streamDuration), streamDuration);

    bytes memory execData = abi.encodeWithSelector(IPoolV1.taskClose.selector, user);

    LibDataTypes.Module[] memory modules = new LibDataTypes.Module[](2);

    modules[0] = LibDataTypes.Module.TIME;
    modules[1] = LibDataTypes.Module.SINGLE_EXEC;

    bytes[] memory args = new bytes[](1);

    args[0] = timeArgs;

    LibDataTypes.ModuleData memory moduleData = LibDataTypes.ModuleData(modules, args);

    ops.exec(address(poolProxy), address(poolProxy), execData, moduleData, 0.01 ether, ETH, false, true);
    vm.stopPrank();
  }

  function gelatoBalance() internal {
    vm.startPrank(opsExecutor);
    (bool canExec, bytes memory execData) = poolProxy.checkerLastExecution();
    console.log(canExec);
    if (canExec) {
      bytes memory resolverData = abi.encodeWithSelector(poolProxy.checkerLastExecution.selector);

      bytes memory resolverArgs = abi.encode(address(poolProxy), resolverData);

      LibDataTypes.Module[] memory modules = new LibDataTypes.Module[](1);

      modules[0] = LibDataTypes.Module.RESOLVER;

      bytes[] memory args = new bytes[](1);

      args[0] = resolverArgs;

      LibDataTypes.ModuleData memory moduleData = LibDataTypes.ModuleData(modules, args);

      ops.exec(address(poolProxy), address(poolProxy), execData, moduleData, 0.01 ether, ETH, false, true);
    }

    vm.stopPrank();
  }
}
