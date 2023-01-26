// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IGovernance {
  function authorizeAppFactory(address, address) external;
  function isAuthorizedAppFactory(address, address) external view returns (bool);
}
