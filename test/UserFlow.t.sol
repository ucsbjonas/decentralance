// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {MarketPlace} from "../src/MarketPlace.sol";
import {Listing} from "../src/Listing.sol";
import "forge-std/Vm.sol";

contract UserFlowTest is Test {
    MarketPlace public marketPlace;
    Listing public listing;

    address contractor = address(0x10);
    address client = address(0x11);


    function setUp() public {
        vm.deal(contractor, 5 ether);
        vm.deal(client, 5 ether);

        listing = new Listing();
        marketPlace = new MarketPlace();
    }

    // define a basic (expected) user flow

    // 1.

    // 2.

    // 3.
}
