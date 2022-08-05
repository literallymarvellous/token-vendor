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

  // ToDo: create a payable buyTokens() function:
  function buyTokens() external payable {
    uint256 amountOfTokens = msg.value * tokensPerEth;
    yourToken.transfer(msg.sender, amountOfTokens);

    emit BuyTokens(msg.sender, msg.value, amountOfTokens);
  }

  // ToDo: create a withdraw() function that lets the owner withdraw ETH
  function withdraw() external onlyOwner {
    (bool success, ) = owner().call{value: address(this).balance}('');
    require(success, 'withdrawal failed');
  }

  // ToDo: create a sellTokens() function:
  function sellTokens(uint256 amountOfTokens) external {
    uint256 amountOfETH = amountOfTokens / tokensPerEth;

    bool _approved = yourToken.approve(address(this), amountOfTokens);
    require(_approved, 'token approval failed');

    yourToken.transferFrom(msg.sender, address(this), amountOfTokens);

    (bool success, ) = msg.sender.call{value: amountOfETH}('');

    require(success, 'sellTokens failed');
  }
}
