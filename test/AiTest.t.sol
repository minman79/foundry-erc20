// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {DeployOurToken} from "../script/DeployOurToken.s.sol";
import {OurToken} from "../src/OurToken.sol";
import {Test, console} from "forge-std/Test.sol";
import {StdCheats} from "forge-std/StdCheats.sol";

interface MintableToken {
    function mint(address, uint256) external;
}

contract OurTokenTest is StdCheats, Test {
    OurToken public ourToken;
    DeployOurToken public deployer;
    address public deployer_address;
    address public user1;
    address public user2;

    function setUp() public {
        deployer = new DeployOurToken();
        ourToken = deployer.run();
        deployer_address = deployer.contractOwner();
        user1 = makeAddr("user1");
        user2 = makeAddr("user2");
    }

    function testInitialSupply() public {
        assertEq(ourToken.totalSupply(), deployer.INITIAL_SUPPLY());
    }

    function testUsersCantMint() public {
        vm.expectRevert();
        MintableToken(address(ourToken)).mint(address(this), 1);
    }

    function testTransfer() public {
        uint256 amount = 100;
        vm.prank(deployer_address);
        ourToken.transfer(user1, amount);
        assertEq(ourToken.balanceOf(user1), amount);
        assertEq(ourToken.balanceOf(deployer_address), deployer.INITIAL_SUPPLY() - amount);
    }

    function testTransferFromInsufficientBalance() public {
        uint256 amount = deployer.INITIAL_SUPPLY() + 1;
        vm.prank(deployer_address);
        vm.expectRevert("ERC20: transfer amount exceeds balance");
        ourToken.transfer(user1, amount);
    }

    function testApprove() public {
        uint256 amount = 100;
        vm.prank(deployer_address);
        assertTrue(ourToken.approve(user1, amount));
        assertEq(ourToken.allowance(deployer_address, user1), amount);
    }

    function testTransferFrom() public {
        uint256 amount = 100;
        vm.prank(deployer_address);
        ourToken.approve(user1, amount);

        vm.prank(user1);
        assertTrue(ourToken.transferFrom(deployer_address, user2, amount));
        assertEq(ourToken.balanceOf(user2), amount);
        assertEq(ourToken.allowance(deployer_address, user1), 0);
    }

    function testTransferFromInsufficientAllowance() public {
        uint256 approvedAmount = 100;
        uint256 transferAmount = 150;
        vm.prank(deployer_address);
        ourToken.approve(user1, approvedAmount);

        vm.prank(user1);
        vm.expectRevert("ERC20: insufficient allowance");
        ourToken.transferFrom(deployer_address, user2, transferAmount);
    }

    function testIncreaseAllowance() public {
        uint256 initialAllowance = 100;
        uint256 increasedAmount = 50;
        vm.prank(deployer_address);
        ourToken.approve(user1, initialAllowance);

        vm.prank(deployer_address);
        assertTrue(ourToken.increaseAllowance(user1, increasedAmount));
        assertEq(ourToken.allowance(deployer_address, user1), initialAllowance + increasedAmount);
    }

    function testDecreaseAllowance() public {
        uint256 initialAllowance = 100;
        uint256 decreasedAmount = 50;
        vm.prank(deployer_address);
        ourToken.approve(user1, initialAllowance);

        vm.prank(deployer_address);
        assertTrue(ourToken.decreaseAllowance(user1, decreasedAmount));
        assertEq(ourToken.allowance(deployer_address, user1), initialAllowance - decreasedAmount);
    }

    function testBurnTokens() public {
        uint256 burnAmount = 100;
        vm.prank(deployer_address);
        uint256 initialBalance = ourToken.balanceOf(deployer_address);
        ourToken.transfer(address(ourToken), burnAmount);
        assertEq(ourToken.balanceOf(deployer_address), initialBalance - burnAmount);
        assertEq(ourToken.totalSupply(), deployer.INITIAL_SUPPLY() - burnAmount);
    }

    function testTransferZeroAmount() public {
        vm.prank(deployer_address);
        assertTrue(ourToken.transfer(user1, 0));
        assertEq(ourToken.balanceOf(user1), 0);
    }

    function testApproveZeroAmount() public {
        vm.prank(deployer_address);
        assertTrue(ourToken.approve(user1, 0));
        assertEq(ourToken.allowance(deployer_address, user1), 0);
    }
}
