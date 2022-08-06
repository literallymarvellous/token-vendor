pragma solidity ^0.8.0;
// SPDX-License-Identifier: MIT

import '@openzeppelin/contracts/access/Ownable.sol';
import './YourToken.sol';

contract Vendor is Ownable {
  // EVENTS
  event BuyTokens(address buyer, uint256 amountOfEth, uint256 amountOfTokens);

  YourToken public yourToken;

  uint256 public constant tokensPerEth = 100;

  constructor(address tokenAddress) {
    yourToken = YourToken(tokenAddress);
  }

  /// @notice buy tokens with ETH from vendor
  function buyTokens() external payable {
    require(msg.value >= 0, 'No ethers sent');

    // calculate amount of tokens to buy
    uint256 amountOfTokens = msg.value * tokensPerEth;

    yourToken.transfer(msg.sender, amountOfTokens);
    emit BuyTokens(msg.sender, msg.value, amountOfTokens);
  }

  /// @notice withdraw tokens from vendor
  /// @dev only owner can withdraw tokens
  function withdraw() external onlyOwner {
    (bool success, ) = owner().call{value: address(this).balance}('');
    require(success, 'withdrawal failed');
  }

  /// @notice sell tokens for ETH
  /// @dev token approve() needs to be called to transfer tokens to vendor
  function sellTokens(uint256 amountOfTokens) external {
    require(amountOfTokens > 0, 'No tokens sent');
    uint256 amountOfETH = amountOfTokens / tokensPerEth;

    yourToken.transferFrom(msg.sender, address(this), amountOfTokens);

    (bool success, ) = msg.sender.call{value: amountOfETH}('');

    require(success, 'sellTokens failed');
  }
}
