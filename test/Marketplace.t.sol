// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {MarketPlace} from "../src/MarketPlace.sol";


contract MarketPlaceTest is Test {
    MarketPlace public marketPlace; 

    function setUp() public {
        marketPlace = new MarketPlace();
    }
}
