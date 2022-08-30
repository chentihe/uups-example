// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/UUPSProxy.sol";
import "../src/Implementation.sol";

contract UUPSTest is Test {
    UUPSProxy public proxy;
    Implementation public logic;
    address owner = makeAddr("owner");

    function setUp() public {
        logic = new Implementation();
        vm.startPrank(owner);
        proxy = new UUPSProxy(
            address(logic),
            abi.encodeWithSelector(logic.initialize.selector)
        );
    }

    function testProxy() public {
        (bool success, bytes memory data) = address(proxy).call(
            abi.encodeWithSelector(logic.proxiable.selector)
        );
        if (success) {
            string memory result = abi.decode(data, (string));
            assertEq(result, "It's UUPS example");
        }
    }

    function testSetProxy() public {
        string memory newWord = "It's been updated";
        (bool success, ) = address(proxy).call(
            abi.encodeWithSelector(logic.setProxiable.selector, newWord)
        );
        if (success) {
            (, bytes memory data) = address(proxy).call(
                abi.encodeWithSelector(logic.proxiable.selector)
            );
            string memory result = abi.decode(data, (string));
            assertEq(result, "It's been updated");
        }
    }

    function testUpgradeTo() public {
        ImplementationV2 logicV2 = new ImplementationV2();
        (bool success, ) = address(proxy).call(
            abi.encodeWithSelector(logic.upgradeTo.selector, address(logicV2))
        );
        if (success) {
            (, bytes memory data) = address(proxy).call(abi.encodeWithSelector(logicV2.activateV2.selector));
            bool result = abi.decode(data, (bool));
            assertTrue(result);
        }
    }
}

contract ImplementationV2 is Implementation {
    bool public isUpgrade;

    function activateV2() external returns (bool) {
        isUpgrade = true;
        return isUpgrade;
    }
}
