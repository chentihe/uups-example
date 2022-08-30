// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "openzeppelin-contracts/contracts/access/Ownable.sol";
import "openzeppelin-contracts/contracts/proxy/utils/Initializable.sol";
import "openzeppelin-contracts/contracts/proxy/utils/UUPSUpgradeable.sol";

contract Implementation is UUPSUpgradeable, Initializable, Ownable {
    string public proxiable;

    function setProxiable(string memory _newWord) external {
        proxiable = _newWord;
    }

    function initialize() external initializer {
        _transferOwnership(msg.sender);
        proxiable = "It's UUPS example";
    }

    function _authorizeUpgrade(address newImplementation)
        internal
        virtual
        override
        onlyOwner
    {}
}
