// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

interface IDelegatedFoo {
  function delegatedPower() external view returns (uint256);
}

contract Foo {
  address impl;

  function power() external view returns (uint256) {
    return IDelegatedFoo(address(this)).delegatedPower();
  }

  function delegatedPower() external returns (uint256) {
    (bool success, bytes memory res) = impl.delegatecall(abi.encodePacked(this.power.selector, msg.data[4:]));
    require(success, "Failed delegatecall");
    return abi.decode(res, (uint256));
  }
}
