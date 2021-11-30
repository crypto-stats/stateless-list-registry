//SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./Ownable.sol";
import "./ListProxy.sol";

contract StatelessListRegistry is Ownable {
    mapping(bytes32 => address) public listToProxy;

    event ListCreated(bytes32 indexed list, address proxy);
    event ListArchived(bytes32 indexed list);
    event ElementAdded(bytes32 indexed list, bytes32 newElement);
    event ElementRemoved(bytes32 indexed list, bytes32 oldElement);
    event ElementUpdated(bytes32 indexed list, bytes32 oldElement, bytes32 newElement);

    error MustBeCalledByOwnerOrProxy();

    function createList(bytes32 list) external returns (address proxy) {
        proxy = address(new ListProxy{ salt: bytes32(0) }(list));
        listToProxy[list] = proxy;

        emit ListCreated(list, proxy);
    }

    function update(bytes32 list, bytes32 oldElement, bytes32 newElement) external {
        if (msg.sender != owner && msg.sender != listToProxy[list]) {
            revert MustBeCalledByOwnerOrProxy();
        }

        if (oldElement == bytes32(0)) {
            emit ElementAdded(list, newElement);
        } else if (newElement == bytes32(0)) {
            emit ElementRemoved(list, oldElement);
        } else {
            emit ElementUpdated(list, oldElement, newElement);
        }
    }

    function archiveList(bytes32 list) external {
        if (msg.sender != owner && msg.sender != listToProxy[list]) {
            revert MustBeCalledByOwnerOrProxy();
        }

        emit ListArchived(list);
    }
}
