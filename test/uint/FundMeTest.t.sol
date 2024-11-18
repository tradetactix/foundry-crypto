// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;
import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    FundMe fundMe;
    address USER = makeAddr("user");
    uint256 constant STARTING_BALANCE = 10 ether;
    uint256 constant SEND_VALUE = 0.1 ether; // 1e17
    uint256 constant GAS_PRICE = 1;

    function setUp() external {
        // us -> FundMeTest.t -> FundMe
        //fundMe = new FundMe();
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        vm.deal(USER, STARTING_BALANCE);
    }
    function testMinimumDollarIsFive() public view {
        assertEq(fundMe.MINIMUM_USD(), 5e18);
    }

    function testOwner() public view {
        console.log(fundMe.getOwner());
        // the caller here seems no the be the address of FundMeTest.t.sol !! who then ??
        console.log(msg.sender);
        assertEq(fundMe.getOwner(), msg.sender); // wronge assertion;
        // assertEq(fundMe.i_owner(), address(this)); // right assertion
    }

    function testPriceFeedVersion() public view {
        assertEq(fundMe.getVersion(), 4);
    }

    function testFundFailsWithoutEnoughEth() public {
        vm.expectRevert(); // hey! the next line should revert
        // assert(this tx fails/reverts)
        //uint256 cat = 1;
        fundMe.fund();
    }

    function testFundUpdatesFundedDataStructure() public {
        vm.prank(USER); // the next tx will be send by the user
        fundMe.fund{value: SEND_VALUE}(); // 1. set

        uint256 amountFunded = fundMe.getAddressToAmmountFunded(USER); // 2. get
        // assertEq(fundMe.getAddressToAmmountFunded(address(this)), 10e18);
        assertEq(amountFunded, SEND_VALUE); // 3. compare
    }

    function testAddFunderToArrayOfFunders() public {
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}(); //1. set
        address funder = fundMe.getFunders(0); // 2. get
        assertEq(USER, funder); // 3. compare
    }

    modifier funded() {
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();
        _;
    }

    function testOnlyOwnerCanWithdraw() public funded {
        // vm.prank(USER);
        // fundMe.fund{value: SEND_VALUE}();

        // vm.prank(fundMe.i_owner()); success
        vm.prank(USER);
        vm.expectRevert();
        fundMe.withdraw();
    }

    function testWithdrawWithSingleFunder() public funded {
        uint256 startingOwnerBalance = address(fundMe.getOwner()).balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        vm.prank(fundMe.getOwner());
        fundMe.withdraw();

        uint256 endingOwnerBalance = address(fundMe.getOwner()).balance;
        uint256 endingFundMeBalance = address(fundMe).balance;
        assertEq(endingFundMeBalance, 0);
        assertEq(
            endingOwnerBalance,
            startingOwnerBalance + startingFundMeBalance
        );
    }

    function testWithdrawFromMultipleFunders() public funded {
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 1;
        for (uint160 i = startingFunderIndex; i < numberOfFunders; i++) {
            // these two lines equals hoax  => funding + pranking
            // vm.deal(address(i), SEND_VALUE);
            // vm.prank(address(i));

            hoax(address(i), SEND_VALUE);
            fundMe.fund{value: SEND_VALUE}();
        }

        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        vm.startPrank(fundMe.getOwner());
        fundMe.withdraw();
        vm.stopPrank();

        // uint256 endingOwnerBalance = fundMe.getOwner().balance;
        // uint256 endingFundMeBalance = address(fundMe).balance;

        assertEq(address(fundMe).balance, 0);
        assertEq(
            fundMe.getOwner().balance,
            startingOwnerBalance + startingFundMeBalance
        );
    }

    function testWithdrawFromMultipleFundersCheaper() public funded {
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 1;
        for (uint160 i = startingFunderIndex; i < numberOfFunders; i++) {
            // these two lines equals hoax  => funding + pranking
            // vm.deal(address(i), SEND_VALUE);
            // vm.prank(address(i));

            hoax(address(i), SEND_VALUE);
            fundMe.fund{value: SEND_VALUE}();
        }

        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        vm.startPrank(fundMe.getOwner());
        fundMe.cheaperWithdraw();
        vm.stopPrank();

        // uint256 endingOwnerBalance = fundMe.getOwner().balance;
        // uint256 endingFundMeBalance = address(fundMe).balance;

        assertEq(address(fundMe).balance, 0);
        assertEq(
            fundMe.getOwner().balance,
            startingOwnerBalance + startingFundMeBalance
        );
    }

    // This is my function
    // function testCanUserWithdraw() public funded {
    //     console.log(address(fundMe).balance);
    //     console.log(USER.balance);
    //     console.log(fundMe.getOwner());
    //     vm.prank(USER);
    //     fundMe.withdraw();
    // }
}
