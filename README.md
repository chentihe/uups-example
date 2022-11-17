# Universal Upgradeable Proxies(UUPS)
The main difference between UUPS and Transparent Proxies is that Transparent Proxies needs to have a contract to manage admin and implementation address to avoid selector clash. UUPS moves update implementation address function into implementation contract which saves gas fee on the project side.
## Proxy Contract
On proxy contract, it only implements that all function calls will be used delegation call to invoke implementation contract logic. you can see the details by [OpenZeppelin Proxy Contract](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/93bc3b657b69e4886dcfef7a2502e165f2cd90d2/contracts/proxy/Proxy.sol)
```solidity
/**
 * @dev Delegates the current call to `implementation`.
 *
 * This function does not return to its internal call site, it will return directly to the external caller.
 */
function _delegate(address implementation) internal virtual {
    assembly {
        // Copy msg.data. We take full control of memory in this inline assembly
        // block because it will not return to Solidity code. We overwrite the
        // Solidity scratch pad at memory position 0.
        calldatacopy(0, 0, calldatasize())

        // Call the implementation.
        // out and outsize are 0 because we don't know the size yet.
        let result := delegatecall(gas(), implementation, 0, calldatasize(), 0, 0)

        // Copy the returned data.
        returndatacopy(0, 0, returndatasize())

        switch result
        // delegatecall returns 0 on error.
        case 0 {
            revert(0, returndatasize())
        }
        default {
            return(0, returndatasize())
        }
    }
}
```
## Deploy Procedure
Since proxy contract needs to set the implementation address, so we need to deploy implementation contract first. Then passing the implementation address with initalize function as arguments into constructor to deploy proxy contract.

The unit test is written on [UUPS.t.sol](https://github.com/chentihe/uups-example/blob/main/test/UUPS.t.sol), you can do the following steps to test on local side

ps. if you don't install foundry, please visit [foundry](https://book.getfoundry.sh/getting-started/installation) to instal first.

1. Clone the repo and navigate to the project folder
```sh
$ git clone git@github.com:chentihe/uups-example.git
$ cd uups-example
```
2. Install the libs
```sh
$ forge install
```
3. Run unit tests
```sh
$ forge test -v
```
You will see the output like below
```sh
Running 3 tests for test/UUPS.t.sol:UUPSTest
[PASS] testProxy() (gas: 14883)
[PASS] testSetProxy() (gas: 20519)
[PASS] testUpgradeTo() (gas: 910177)
Test result: ok. 3 passed; 0 failed; finished in 2.41ms
```
