import {Script} from "forge-std/Script.sol";
import {MevModule, ModuleManager} from "src/MevModule.sol";

contract MevModuleScript is Script {
    function run(address _safe) public {
        vm.broadcast();
        new MevModule(ModuleManager(_safe));
    }
}
