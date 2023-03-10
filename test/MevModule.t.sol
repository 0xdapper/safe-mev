pragma solidity 0.8.19;

import {Test} from "forge-std/Test.sol";
import {Safe, MevModule} from "src/MevModule.sol";
import {SafeProxyFactory} from "safe-contracts/proxies/SafeProxyFactory.sol";

contract MevModuleTest is Test {
    MevModule mevModule;
    Safe masterSafe = new Safe();
    SafeProxyFactory factory = new SafeProxyFactory();
    Safe safe;

    address owner = vm.addr(0x01);
    address executor1 = vm.addr(0x02);
    address executor2 = vm.addr(0x03);

    function setUp() public {
        safe = Safe(
            payable(
                address(
                    factory.createProxyWithNonce(
                        address(masterSafe),
                        new bytes(0),
                        0
                    )
                )
            )
        );

        address[] memory owners = new address[](1);
        owners[0] = owner;
        safe.setup(
            owners,
            1,
            address(0x0),
            new bytes(0),
            address(0x0),
            address(0x0),
            0,
            payable(address(0x0))
        );

        mevModule = new MevModule(safe);

        // safe.enableModule(address(mevModule));
    }

    function testAddExecutor() public {
        vm.prank(owner);
        vm.expectRevert(abi.encodePacked(MevModule.OnlySafe.selector));
        mevModule.addExecutor(executor1);
        assertFalse(mevModule.isExecutor(executor1));

        vm.prank(address(safe));
        mevModule.addExecutor(executor1);
        assertTrue(mevModule.isExecutor(executor1));
    }
}
