// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {Listing} from "../src/Listing.sol";

contract ListingTest is Test {
    Listing public listing;

    function setUp() public {
        listing = new Listing();
    }
}

