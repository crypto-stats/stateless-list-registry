//SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

interface IStatelessListRegistry {
    function owner() external view returns (address);
    function update(bytes32 list, bytes32 oldElement, bytes32 newElement) external;
}

contract ListProxy {
    IStatelessListRegistry private immutable listRegistry;
    bytes32 public immutable list;

    error MustBeCalledByOwner();
    error MismatchedLength();

    constructor(bytes32 _list) {
        list = _list;
        listRegistry = IStatelessListRegistry(msg.sender);
    }

    modifier onlyOwner {
        if (msg.sender != listRegistry.owner()) {
            revert MustBeCalledByOwner();
        }
        _;
    }

    function update(bytes32 oldElement, bytes32 newElement) external onlyOwner {
        listRegistry.update(list, oldElement, newElement);
    }

    // Helper to reduce calldata
    function add(bytes32 newElement) external onlyOwner {
        listRegistry.update(list, bytes32(0), newElement);
    }

    function batchUpdate(bytes32[] calldata oldElements, bytes32[] calldata newElements) external onlyOwner {
        if (oldElements.length != newElements.length) {
            revert MismatchedLength();
        }

        for (uint256 i = 0; i < oldElements.length; i += 1) {
            listRegistry.update(list, oldElements[i], newElements[i]);
        }
    }

    // Helper to reduce calldata
    function batchAdd(bytes32[] calldata newElements) external onlyOwner {
        for (uint256 i = 0; i < newElements.length; i += 1) {
            listRegistry.update(list, bytes32(0), newElements[i]);
        }
    }
}
