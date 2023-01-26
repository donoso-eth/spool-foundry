// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/console.sol";

import { SafeERC20, IERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

import { OpsReady } from "./gelato/OpsReady.sol";
import { IOps } from "./gelato/IOps.sol";

import { IPoolV1 } from "./interfaces/IPool-V1.sol";

import { IPoolStrategyV1 } from "./interfaces/IPoolStrategy-V1.sol";
import { IPool } from "./aave/IPool.sol";
import { ISuperToken } from "@superfluid-finance/ethereum-contracts/contracts/interfaces/superfluid/ISuperfluid.sol";
import { LibDataTypes } from "./gelato/LibDataTypes.sol";
import { DataTypes } from "./libraries/DataTypes.sol";
import { Events } from "./libraries/Events.sol";
import { UUPSProxiable } from "./upgradability/UUPSProxiable.sol";

import { Initializable } from "@openzeppelin/contracts/proxy/utils/Initializable.sol";

/**
 *
 * @title PoolStrategyV1
 * @dev This contract provides the allocation strategy to be followed by the pool
 *
 *      The addresse of the strategy will be passed to the pool factory by creation of the pool
 *      It can be created n-pools by superToken creating n-different strategies (aave, compounf, etc)
 *      By the pool initialization, the pool approve the strategy contract to operate the supertokens
 *
 *
 */
contract PoolStrategyV1 is Initializable, UUPSProxiable, IPoolStrategyV1 {
  using SafeMath for uint256;

  address owner;

  ISuperToken superToken;
  IPoolV1 pool;
  /// Pool
  IPool aavePool; //// aave Pool to deposit
  IERC20 aToken; //// aToken received

  ///// IN PRODUCTION WE WILL ONLY REQUIRE the token a ERC20
  ///// NOW WE NEED TO SWAP BETWEEN SUPERFLUID and AAVe FAKE TOKEN
  IERC20 token; // SUPERFLUID Faketoken

  uint256 MAX_INT;

  constructor() { }

  function initialize(ISuperToken _superToken, IERC20 _token, IPoolV1 _pool, IPool _aavePool, IERC20 _aToken) external initializer {
    owner = msg.sender;
    superToken = _superToken;
    token = _token;
    pool = _pool;
    aavePool = _aavePool;
    aToken = _aToken;
    token = _token;
    MAX_INT = 2 ** 256 - 1;

    token.approve(address(aavePool), MAX_INT);
    token.approve(address(superToken), MAX_INT);
  }

  function balanceOf() public view returns (uint256 balance) {
    balance = aToken.balanceOf(address(this));
  }

  // #region  ============= ============= ONLY POOL FUNCTIONS  ============= ============= //
  function withdraw(uint256 amount, address _supplier) external onlyPool {
    _withdraw(amount, _supplier);
  }

  function pushToStrategy(uint256 amountToDeposit) external onlyPool {
    if (amountToDeposit > 0) _deposit(amountToDeposit);
  }

  // #endregion  ============= ============= ONLY POOL FUNCTIONS  ============= ============= //

  // #region =========== ================ EMERGENCY =========== ================ //

  function withdrawEmergency() external onlyOwner {
    uint256 balance = aToken.balanceOf(address(this));
    _withdraw(balance, address(pool));
  }

  // #endregion  =========== ================ EMERGENCY =========== ================ //

  // #region  ============= ============= INTERNAL FUNCTIONS  ============= ============= //

  function _deposit(uint256 amountToDeposit) internal {
    superToken.transferFrom(address(pool), address(this), uint256(amountToDeposit));

    console.log(100, amountToDeposit);
    console.log(101, token.balanceOf(address(this)));

    superToken.downgrade(amountToDeposit);
    console.log(102, token.balanceOf(address(this)));

    aavePool.supply(address(token), token.balanceOf(address(this)), address(this), 0);
    console.log(103, token.balanceOf(address(this)));
    console.log(104, aToken.balanceOf(address(this)));
  }

  function _withdraw(uint256 amount, address _supplier) internal {
    if (amount > 0) {
      aavePool.withdraw(address(token), amount, address(this));

      console.log(116, amount);

      uint256 balanceToken = token.balanceOf(address(this));
      console.log(119, token.balanceOf(address(this)));
      console.log(120, aToken.balanceOf(address(this)));
      superToken.upgrade(amount);

      IERC20(address(superToken)).transfer(_supplier, amount);
    }
  }

  // #endregion  ============= ============= INTERNAL FUNCTIONS  ============= ============= //

  // #region  ==================  Upgradeable settings  ==================

  function proxiableUUID() public pure override returns (bytes32) {
    return keccak256("org.super-pool.strategy.v2");
  }

  function updateCode(address newAddress) external override onlyOwner {
    return _updateCodeAddress(newAddress);
  }

  // #endregion  ==================  Upgradeable settings  ==================

  // #region   ==================  modifiers  ==================

  modifier onlyOwner() {
    require(msg.sender == owner, "Only Owner");
    _;
  }

  modifier onlyPool() {
    require(msg.sender == address(pool), "Only Pool Allowed");
    _;
  }

  //#endregion modifiers
}
