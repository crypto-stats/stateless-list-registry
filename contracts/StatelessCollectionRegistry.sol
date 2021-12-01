//SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./Ownable.sol";
import "./CollectionProxy.sol";

contract StatelessCollectionRegistry is Ownable {
    mapping(bytes32 => address) public collectionToProxy;

    event CollectionCreated(bytes32 indexed collection, address proxy);
    event CollectionArchived(bytes32 indexed collection);
    event ElementAdded(bytes32 indexed collection, bytes32 newElement);
    event ElementRemoved(bytes32 indexed collection, bytes32 oldElement);
    event ElementUpdated(bytes32 indexed collection, bytes32 oldElement, bytes32 newElement);

    error MustBeCalledByOwnerOrProxy();

    function createCollection(bytes32 collection) external returns (address proxy) {
        proxy = address(new CollectionProxy{ salt: bytes32(0) }(collection));
        collectionToProxy[collection] = proxy;

        emit CollectionCreated(collection, proxy);
    }

    function update(bytes32 collection, bytes32 oldElement, bytes32 newElement) external {
        if (msg.sender != owner && msg.sender != collectionToProxy[collection]) {
            revert MustBeCalledByOwnerOrProxy();
        }

        if (oldElement == bytes32(0)) {
            emit ElementAdded(collection, newElement);
        } else if (newElement == bytes32(0)) {
            emit ElementRemoved(collection, oldElement);
        } else {
            emit ElementUpdated(collection, oldElement, newElement);
        }
    }

    function archiveCollection(bytes32 collection) external {
        if (msg.sender != owner && msg.sender != collectionToProxy[collection]) {
            revert MustBeCalledByOwnerOrProxy();
        }

        emit CollectionArchived(collection);
    }
}
