// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {MarketPlace} from "../src/MarketPlace.sol";
import {Listing, ListingTerms} from "../src/Listing.sol";
import "forge-std/Vm.sol";

contract UserFlowTest is Test {
    MarketPlace public marketPlace;
    Listing public new_listing;

    address contractor = address(0x10);
    address client = address(0x11);


    function setUp() public {
        vm.deal(contractor, 5 ether);
        vm.deal(client, 5 ether);

        marketPlace = new MarketPlace();
    }

    function test_UserFlow1() public {
    // a basic (expected, non-malicious, normal) user flow

    // 1. client makes a listing request
    vm.startBroadcast(client);
    new_listing = new Listing();
    uint256 listing_id = marketPlace.addListing(new_listing);
    vm.stopBroadcast();
    // 2. contractor accepts listing and defines terms
    vm.startBroadcast(contractor);
    uint256 curr_stage = marketPlace.acceptListing(ListingTerms({addr: msg.sender, amount: msg.value}));
    vm.stopBroadcast();

    // 3. client accepts terms
    vm.startBroadcast(client);
    marketPlace.confirmListing(listing_id);
    vm.stopBroadcast();

    // 4a. contractor sends partial or full fuillfment of listing
    vm.startBroadcast(contractor);
    marketPlace.fufill(listing_id, curr_stage);
    vm.stopBroadcast();

    // 5a. client sends partial or full payment for (4)
    vm.startBroadcast(client);
    marketPlace.pay(listing_id, curr_stage);
    vm.stopBroadcast();

    // 4b. contractor sends partial or full fuillfment of listing
    vm.startBroadcast(contractor);
    marketPlace.fufill(listing_id, curr_stage);
    vm.stopBroadcast();

    // 5b. client sends partial or full payment for (4)
    vm.startBroadcast(client);
    marketPlace.pay(listing_id, curr_stage);
    vm.stopBroadcast();


    // 6. once the listing is paid in full, mark the listing as complete


    }



}
