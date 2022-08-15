// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.0;

import {DSTestPlus} from "solmate/test/utils/DSTestPlus.sol";
import {Vm} from "forge-std/Vm.sol";

import {NFTAX} from "../src/NFTAX.sol";
import {NFTAM} from "../src/NFTAM.sol";

contract GasTest is DSTestPlus {
    Vm vm = Vm(HEVM_ADDRESS);

    address alice = address(0x101);
    address bob = address(0x102);
    address chris = address(0x103);
    address tester = address(this);

    NFTAM erc721a;
    NFTAX erc721ax;

    function setUp() public {
        erc721a = new NFTAM("Token", "TKN", "URLbase");
        erc721ax = new NFTAX("Token", "TKN","URLbase", 1, 30, 10);

        vm.label(alice, "Alice");
        vm.label(bob, "Bob");
        vm.label(chris, "Chris");

         vm.label(tester, "TestContract");
         vm.label(address(erc721a), "ERC721A");//"ERC721A"
         vm.label(address(erc721ax), "ERC721AX");//"ERC721AX"

        erc721a.mint(tester, 1);
        erc721ax.mint(tester, 1);
        erc721a.mint(tester, 5);
        erc721ax.mint(tester, 5);

        vm.startPrank(alice);
        erc721a.setApprovalForAll(tester, true);
        erc721ax.setApprovalForAll(tester, true);
        vm.stopPrank();

        vm.startPrank(bob);
        erc721a.setApprovalForAll(tester, true);
        erc721ax.setApprovalForAll(tester, true);
        vm.stopPrank();

        vm.startPrank(chris);
        erc721a.setApprovalForAll(tester, true);
        erc721ax.setApprovalForAll(tester, true);
        vm.stopPrank();
    }

    /* ------------- mint() ------------- */

    function test_mint1_ERC721A() public {
        erc721a.mint(alice, 1);
    }

    function test_mint1_ERC721AX() public {
        erc721ax.mint(alice, 1);
    }

    function test_mint5_ERC721A() public {
        erc721a.mint(alice, 5);
    }

    function test_mint5_ERC721AX() public {
        erc721ax.mint(alice, 5);
    }

    /* ------------- transfer() ------------- */

    function test_transferFrom1_ERC721A() public {
        erc721a.transferFrom(tester, bob, 1);
    }

    function test_transferFrom1_ERC721AX() public {
        erc721ax.transferFrom(tester, bob, 1);
    }

    function test_transferFrom2_ERC721A() public {
        erc721a.transferFrom(tester, bob, 2);
    }

    function test_transferFrom2_ERC721AX() public {
        erc721ax.transferFrom(tester, bob, 2);
    }

    function test_transferFrom3_ERC721A() public {
        erc721a.transferFrom(tester, bob, 2);
        erc721a.transferFrom(bob, tester, 2);
        erc721a.transferFrom(tester, bob, 2);
        erc721a.transferFrom(bob, tester, 2);
        erc721a.transferFrom(tester, bob, 2);
    }

    function test_transferFrom3_ERC721AX() public {
        erc721ax.transferFrom(tester, bob, 2);
        erc721ax.transferFrom(bob, tester, 2);
        erc721ax.transferFrom(tester, bob, 2);
        erc721ax.transferFrom(bob, tester, 2);
        erc721ax.transferFrom(tester, bob, 2);
    }
}