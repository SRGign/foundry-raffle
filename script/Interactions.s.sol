//SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script, console} from "forge-std/Script.sol";
import {HelperConfig, CodeConstants} from "../script/HelperConfig.s.sol";
import {Raffle} from "../src/Raffle.sol";
import {VRFCoordinatorV2_5Mock} from "@chainlink/contracts/src/v0.8/vrf/mocks/VRFCoordinatorV2_5Mock.sol";
import {LinkToken} from "test/mocks/LinkToken.sol";

contract CreateSubscription is Script{
    function createSubscriptionUsingConfig() public returns(uint256, address){
        HelperConfig helperConfig = new HelperConfig();
        address vrfCoordinator = helperConfig.getConfig(block.chainid).vrfCoordinator;
        (uint256 subId,) = createSubscription(vrfCoordinator);
        return (subId, vrfCoordinator);
    }

    function createSubscription(address vrfCoordinator) public returns(uint256, address){
        console.log("Creating subscription on ", block.chainid);
        vm.startBroadcast();
        uint256 subId = VRFCoordinatorV2_5Mock(vrfCoordinator).createSubscription();
        vm.stopBroadcast();
        console.log("Your subscription Id is ", subId);
        console.log("Please update the subscriptionId in the HelperConfig.s.sol file");
        return (subId, vrfCoordinator);
    }
    
    function run() public{
        createSubscriptionUsingConfig();
    }
}
    contract FundSubscription is CodeConstants, Script{
        uint96 public constant FUND_AMOUNT = 3 ether;

       function fundSubscriptionUsingConfig() public{
           HelperConfig helperConfig = new HelperConfig();
           address vrfCoordinator = helperConfig.getConfig(block.chainid).vrfCoordinator;
           uint256 subscriptionId = helperConfig.getConfig(block.chainid).subscriptionId;
           address linkToken = helperConfig.getConfig(block.chainid).link;
           fundSubscription(vrfCoordinator, subscriptionId, linkToken);
       }

       function fundSubscription(address vrfCoordinator, uint256 subscriptionId, address linkToken) public{
          console.log("Funding subscription: ", subscriptionId);
        console.log("Using vrfCoordinator: ", vrfCoordinator);
        console.log("On ChainID: ", block.chainid);
        if (block.chainid == LOCAL_CHAIN_ID) {
            vm.startBroadcast();
            VRFCoordinatorV2_5Mock(vrfCoordinator).fundSubscription(subscriptionId, FUND_AMOUNT);
            vm.stopBroadcast();
       }else{
        vm.startBroadcast();
        LinkToken(linkToken).transferAndCall(vrfCoordinator, FUND_AMOUNT, abi.encode
        (subscriptionId));
        vm.stopBroadcast();
       }
    }
    function run() public{
           fundSubscriptionUsingConfig();
       }
    }
