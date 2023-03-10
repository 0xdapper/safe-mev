pragma solidity 0.8.19;

import {Test} from "forge-std/Test.sol";
import {Safe, MevModule, Enum} from "src/MevModule.sol";
import {SafeProxyFactory} from "safe-contracts/proxies/SafeProxyFactory.sol";

contract MevModuleTest is Test {
    MevModule mevModule;
    Safe masterSafe = new Safe();
    SafeProxyFactory factory = new SafeProxyFactory();
    Safe safe;

    address owner = vm.addr(0x01);
    address executor1 = vm.addr(0x02);
    address executor2 = vm.addr(0x03);

    uint variable = 0;

    event SetVariable(uint, address);

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

        vm.startPrank(address(safe));
        safe.enableModule(address(mevModule));
        mevModule.addExecutor(executor1);
        mevModule.addExecutor(executor2);
        vm.stopPrank();

        // safe.enableModule(address(mevModule));
    }

    function setVariable(uint _newVal) public {
        variable = _newVal;
        emit SetVariable(_newVal, msg.sender);
    }

    function testAddRemoveExecutor() public {
        address executor = vm.addr(0x04);

        vm.prank(owner);
        vm.expectRevert(abi.encodePacked(MevModule.OnlySafe.selector));
        mevModule.addExecutor(executor);
        assertFalse(mevModule.isExecutor(executor));

        vm.prank(address(safe));
        mevModule.addExecutor(executor);
        assertTrue(mevModule.isExecutor(executor));
    }

    function testAddRemoveContract() public {
        vm.prank(owner);
        vm.expectRevert(abi.encodePacked(MevModule.OnlySafe.selector));
        mevModule.addContract(address(mevModule), Enum.Operation.Call);
        assertFalse(mevModule.isWhitelistedContractCall(address(mevModule)));

        vm.prank(address(safe));
        mevModule.addContract(address(mevModule), Enum.Operation.Call);
        assertTrue(mevModule.isWhitelistedContractCall(address(mevModule)));

        vm.prank(owner);
        vm.expectRevert(abi.encodePacked(MevModule.OnlySafe.selector));
        mevModule.removeContract(address(mevModule), Enum.Operation.Call);
        assertTrue(mevModule.isWhitelistedContractCall(address(mevModule)));

        vm.prank(address(safe));
        mevModule.removeContract(address(mevModule), Enum.Operation.Call);
        assertFalse(mevModule.isWhitelistedContractCall(address(mevModule)));
    }

    function testExecOnlyExecutor() public {
        vm.startPrank(owner);
        vm.expectRevert(abi.encodePacked(MevModule.OnlyExecutor.selector));
        mevModule.execCall(
            address(this),
            abi.encodeCall(this.setVariable, (100))
        );

        vm.expectRevert(abi.encodePacked(MevModule.OnlyExecutor.selector));
        mevModule.execCallWithValue(
            address(this),
            abi.encodeCall(this.setVariable, (100)),
            0
        );

        vm.expectRevert(abi.encodePacked(MevModule.OnlyExecutor.selector));
        mevModule.execDelegateCall(
            address(this),
            abi.encodeCall(this.setVariable, (100))
        );

        vm.expectRevert(abi.encodePacked(MevModule.OnlyExecutor.selector));
        mevModule.execDelegateCallWithValue(
            address(this),
            abi.encodeCall(this.setVariable, (100)),
            0
        );
        vm.stopPrank();

        vm.prank(address(safe));
        mevModule.addContract(address(this), Enum.Operation.Call);
        vm.prank(address(safe));
        mevModule.addContract(address(this), Enum.Operation.DelegateCall);

        vm.startPrank(executor1);
        mevModule.execCall(
            address(this),
            abi.encodeCall(this.setVariable, (100))
        );

        mevModule.execCallWithValue(
            address(this),
            abi.encodeCall(this.setVariable, (100)),
            0
        );

        mevModule.execDelegateCall(
            address(this),
            abi.encodeCall(this.setVariable, (100))
        );

        mevModule.execDelegateCallWithValue(
            address(this),
            abi.encodeCall(this.setVariable, (100)),
            0
        );
        vm.stopPrank();
    }

    function testExecOnlyWhitelisted() public {
        vm.startPrank(executor1);

        vm.expectRevert(
            abi.encodePacked(MevModule.OnlyWhitelistedContract.selector)
        );
        mevModule.execCall(
            address(this),
            abi.encodeCall(this.setVariable, (100))
        );

        vm.expectRevert(
            abi.encodePacked(MevModule.OnlyWhitelistedContract.selector)
        );
        mevModule.execCallWithValue(
            address(this),
            abi.encodeCall(this.setVariable, (100)),
            0
        );

        vm.expectRevert(
            abi.encodePacked(MevModule.OnlyWhitelistedContract.selector)
        );
        mevModule.execDelegateCall(
            address(this),
            abi.encodeCall(this.setVariable, (100))
        );

        vm.expectRevert(
            abi.encodePacked(MevModule.OnlyWhitelistedContract.selector)
        );
        mevModule.execDelegateCallWithValue(
            address(this),
            abi.encodeCall(this.setVariable, (100)),
            0
        );
        vm.stopPrank();

        // whitelisted
        vm.prank(address(safe));
        mevModule.addContract(address(this), Enum.Operation.Call);
        vm.prank(address(safe));
        mevModule.addContract(address(this), Enum.Operation.DelegateCall);

        vm.startPrank(executor1);

        mevModule.execCall(
            address(this),
            abi.encodeCall(this.setVariable, (100))
        );

        mevModule.execCallWithValue(
            address(this),
            abi.encodeCall(this.setVariable, (100)),
            0
        );

        mevModule.execDelegateCall(
            address(this),
            abi.encodeCall(this.setVariable, (100))
        );

        mevModule.execDelegateCallWithValue(
            address(this),
            abi.encodeCall(this.setVariable, (100)),
            0
        );

        vm.stopPrank();
    }
}
