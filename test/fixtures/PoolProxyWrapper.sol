//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import { PoolV1 } from "../../src/Pool-V1.sol";

interface IPoolProxyWrapper { 
      function readStorageSlot(uint8 i) external view returns (bytes32 result);
   
}

contract PoolProxyWrapper is PoolV1  {

  function readStorageSlot(uint8 i) external view returns (bytes32 result) {
    assembly {
      result := sload(i)
    }
  }


}