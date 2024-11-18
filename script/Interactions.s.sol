// SPDX-License-Identifier: MIT

// fund
// withdraw

// ===========
// the idea of this code is to get the latest deployed contract then fund it
// ===========

pragma solidity ^0.8.18;
import {Script, console} from "forge-std/Script.sol";

// I had to add src here unlike importing from src folder inside forge-std
import {DevOpsTools} from "foundry-devops/src/DevOpsTools.sol";
import {FundMe} from "../src/FundMe.sol";

contract FundFundMe is Script {
    uint256 constant SEND_VALUE = .01 ether;
    function fundFundMe(address mostRecentlyDeployed) public {
        vm.startBroadcast();
        FundMe(payable(mostRecentlyDeployed)).fund{value: SEND_VALUE}();
        vm.stopBroadcast();

        console.log("Funded fund me with %s", SEND_VALUE);
    }

    function run() external {
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment(
            "FundMe",
            block.chainid
        );

        fundFundMe(mostRecentlyDeployed);
    }
}
contract WithdrawFundMe is Script {
    function withdrawFundMe(address mostRecentlyDeployed) public {
        vm.startBroadcast();
        FundMe(payable(mostRecentlyDeployed)).withdraw();
        vm.stopBroadcast();
    }

    function run() external {
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment(
            "FundMe",
            block.chainid
        );

        withdrawFundMe(mostRecentlyDeployed);
    }
}
