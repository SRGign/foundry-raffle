//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import "forge-std/Test.sol";

import {DeployRaffle} from "../../script/DeployRaffle.s.sol";
import {Raffle} from "../../src/Raffle.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";
import {Test, console2} from "forge-std/Test.sol";
import {Vm} from "forge-std/Vm.sol";
import {VRFCoordinatorV2_5Mock} from "@chainlink/contracts/src/v0.8/vrf/mocks/VRFCoordinatorV2_5Mock.sol";
import {CodeConstants} from "../../script/HelperConfig.s.sol";



contract RaffleTest is Test{

    Raffle public raffle;
    HelperConfig public helperConfig;
    

    uint256 entranceFee;
    uint256 interval;
    address vrfCoordinator;
    bytes32 gasLane;
    uint32 callbackGasLimit;
    uint256 subscriptionId;


    address public PLAYER = makeAddr("player");
    uint256 public constant STARTING_USER_BALANCE = 10 ether;

    event RaffleEntered(address indexed player);
    event WinnerPicked(address indexed winner);


    function setUp() external {
    DeployRaffle deployer = new DeployRaffle();
    (raffle, helperConfig) = deployer.deployContract();

    HelperConfig.NetworkConfig memory config = helperConfig.getConfig(block.chainid);

    entranceFee = config.entranceFee;
    interval = config.interval;
    vrfCoordinator = config.vrfCoordinator;
    gasLane = config.gasLane;
    callbackGasLimit = config.callbackGasLimit;
    subscriptionId = config.subscriptionId;

    vm.deal(PLAYER, STARTING_USER_BALANCE);
}
    function testRaffleInitializesInOpenState() public view{
        assert(raffle.getRaffleState() == Raffle.RaffleState.OPEN);
    }

function testRaffleRevertsWhenYouDontPayEnough() public {
      //Arrange
      vm.prank(PLAYER);
        //Act / Assert
        vm.expectRevert(Raffle.Raffle__SendMoreToEnterRaffle.selector);
        raffle.enterRaffle();
}

function testRaffleRecordsPlayerWhenTheyEnter() public {
    //Arrange
    vm.prank(PLAYER);

    //Act
    raffle.enterRaffle{value: entranceFee}();
    address playerRecorded = raffle.getPlayer(0);

    //Assert
    assert(playerRecorded == PLAYER);

}

function testEnteringRaffleEmitsEvent() public {
    //Arrange
    vm.prank(PLAYER);

    //Assert
    vm.expectEmit(true, false, false, false, address(raffle));
    emit RaffleEntered(PLAYER);

    //Act
    raffle.enterRaffle{value: entranceFee}();

}

function testDontAllowToEnterWhileRaffleCalculating() public {
    //Arrange
    vm.prank(PLAYER);
    raffle.enterRaffle{value: entranceFee}();
    vm.warp(block.timestamp + interval + 1);
    vm.roll(block.number + 1);
    raffle.performUpkeep("");


    //Act / Assert
    vm.expectRevert(Raffle.Raffle__NotOpen.selector);
    vm.prank(PLAYER);
    raffle.enterRaffle{value: entranceFee}();
}

}