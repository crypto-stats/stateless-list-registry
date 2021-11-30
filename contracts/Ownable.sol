//SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

contract Ownable {
  address public owner;

  event OwnershipTransferred(address indexed newOwner);

  error MustBeCalledByOwner();

  constructor() {
    owner = msg.sender;
    emit OwnershipTransferred(msg.sender);
  }

  modifier onlyOwner {
    if (msg.sender != owner) {
      revert MustBeCalledByOwner();
    }
    _;
  }

  function transferOwnership(address newOwner) external onlyOwner {
    owner = newOwner;
    emit OwnershipTransferred(newOwner);
  }
}
