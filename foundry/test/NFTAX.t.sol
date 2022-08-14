// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.0;

import {DSTestPlus} from "solmate/test/utils/DSTestPlus.sol";
import {Vm} from "forge-std/Vm.sol";

import "../src/ERC721A/ERC721AX.sol";
import {NFT} from "../src/NFTAX.sol";

contract ERC721AXTest is DSTestPlus {
    Vm vm = Vm(HEVM_ADDRESS);

    address alice = address(0x101);
    address bob = address(0x102);
    address chris = address(0x103);
    address tester = address(this);

    NFT token;

    function setUp() public {
        token = new NFT("Token", "TKN","https://ipfs.io/ipfs/QmSxLQ6K7s3yvUWP4VpkBvhfyG1rJBcDY5gAKaScihAKxx/", 1, 30, 10);

        vm.label(alice, "Alice");
        vm.label(bob, "Bob");
        vm.label(chris, "Chris");

        vm.label(tester, "Tester");
        vm.label(address(token), "ERC721AX");
    }

    /* ------------- mint() ------------- */

    function test_mint1() public {
        token.mint(alice, 10);
    }

    function test_mint() public {
        token.mint(alice, 1);

        assertEq(token.balanceOf(alice), 1);
        assertEq(token.numMinted(alice), 1);
        assertEq(token.ownerOf(1), alice);
    }

    function test_mintFive() public {
        token.mint(alice, 5);

        assertEq(token.balanceOf(alice), 5);
        assertEq(token.numMinted(alice), 5);

        for (uint256 i; i < 5; i++) assertEq(token.ownerOf(i + 1), alice);
    }

    function test_mintMultiple() public {
        token.mint(alice, 5);
        token.mint(bob, 5);

        assertEq(token.balanceOf(alice), 5);
        assertEq(token.numMinted(alice), 5);
        assertEq(token.balanceOf(bob), 5);
        assertEq(token.numMinted(bob), 5);

        for (uint256 i; i < 5; i++) assertEq(token.ownerOf(i + 1), alice);
        for (uint256 i; i < 5; i++) assertEq(token.ownerOf(i + 6), bob);
    }

    function test_mint_fail_MintToZeroAddress() public {
        vm.expectRevert(MintToZeroAddress.selector);
        token.mint(address(0), 1);
    }

    function test_mint_fail_MintExceedsMaxSupply() public {
        token.mint(bob, 10);
        token.mint(alice, 10);
        token.mint(chris, 10);

        vm.expectRevert(MintExceedsMaxSupply.selector);
        token.mint(tester, 1);
    }

    function test_mint_fail_MintExceedsMaxPerWallet() public {
        token.mint(tester, 10);

        vm.expectRevert(MintExceedsMaxPerWallet.selector);
        token.mint(tester, 1);
    }

    /* ------------- approve() ------------- */

    function test_approve() public {
        token.mint(tester, 1);

        token.approve(alice, 1);

        assertEq(token.getApproved(1), alice);
    }

    function test_approve_fail_NonexistentToken() public {
        vm.expectRevert(NonexistentToken.selector);
        token.approve(alice, 1);
    }

    function test_approve_fail_CallerNotOwnerNorApproved() public {
        token.mint(bob, 1);

        vm.expectRevert(CallerNotOwnerNorApproved.selector);
        token.approve(alice, 1);
    }

    function test_setApprovalForAll() public {
        token.setApprovalForAll(alice, true);

        assertTrue(token.isApprovedForAll(tester, alice));
    }

    /* ------------- transfer() ------------- */

    function test_transferFrom() public {
        token.mint(bob, 1);

        vm.prank(bob);
        token.approve(tester, 1);

        token.transferFrom(bob, alice, 1);

        assertEq(token.getApproved(1), address(0));
        assertEq(token.ownerOf(1), alice);
        assertEq(token.balanceOf(alice), 1);
        assertEq(token.balanceOf(bob), 0);
    }

    function test_transferFromSelf() public {
        token.mint(tester, 1);

        token.transferFrom(tester, alice, 1);

        assertEq(token.getApproved(1), address(0));
        assertEq(token.ownerOf(1), alice);
        assertEq(token.balanceOf(alice), 1);
        assertEq(token.balanceOf(tester), 0);
    }

    function test_transferFromApproveAll() public {
        token.mint(bob, 1);

        vm.prank(bob);
        token.setApprovalForAll(tester, true);

        token.transferFrom(bob, alice, 1);

        assertEq(token.getApproved(1), address(0));
        assertEq(token.ownerOf(1), alice);
        assertEq(token.balanceOf(alice), 1);
        assertEq(token.balanceOf(bob), 0);
    }

    function test_transferFrom_fail_NonexistentToken() public {
        vm.expectRevert(NonexistentToken.selector);
        token.transferFrom(bob, alice, 1);
    }

    function test_transferFrom_fail_TransferFromIncorrectOwner() public {
        token.mint(chris, 1);

        vm.expectRevert(TransferFromIncorrectOwner.selector);
        token.transferFrom(bob, alice, 1);
    }

    function test_transferFrom_fail_TransferToZeroAddress() public {
        token.mint(tester, 1);

        vm.expectRevert(TransferToZeroAddress.selector);
        token.transferFrom(tester, address(0), 1);
    }

    function test_transferFrom_fail_CallerNotOwnerNorApproved() public {
        token.mint(bob, 1);

        vm.expectRevert(CallerNotOwnerNorApproved.selector);
        token.transferFrom(bob, alice, 1);
    }

    /* ------------- transferFrom() edge-cases ------------- */

    function test_transferFrom1() public {
        token.mint(bob, 10);

        vm.prank(bob);
        token.transferFrom(bob, chris, 10);

        vm.expectRevert(NonexistentToken.selector);
        token.ownerOf(11);

        token.mint(alice, 2);

        assertEq(token.ownerOf(9), bob);
        assertEq(token.ownerOf(10), chris);
        assertEq(token.ownerOf(11), alice);
        assertEq(token.ownerOf(12), alice);
    }

    function test_transferFrom2() public {
        token.mint(bob, 10);
        token.mint(alice, 10);

        vm.startPrank(bob);
        token.transferFrom(bob, bob, 9);
        token.transferFrom(bob, chris, 10);
        vm.stopPrank();

        assertEq(token.ownerOf(9), bob);
        assertEq(token.ownerOf(10), chris);
        assertEq(token.ownerOf(11), alice);
        assertEq(token.ownerOf(12), alice);
    }

    function test_transferFrom3() public {
        token.mint(bob, 29);

        vm.prank(bob);
        token.transferFrom(bob, alice, 10);
        token.mint(chris, 1);

        assertEq(token.ownerOf(30), chris);
    }

    function test_transferFrom4() public {
        token.mint(bob, 10);

        vm.prank(bob);
        token.transferFrom(bob, alice, 5);

        assertEq(token.ownerOf(5), alice);
        assertEq(token.ownerOf(6), bob);
    }

    function test_transferFrom5() public {
        token.mint(bob, 10);

        vm.prank(bob);
        token.transferFrom(bob, alice, 1);

        assertEq(token.ownerOf(1), alice);
        assertEq(token.ownerOf(2), bob);
    }
}