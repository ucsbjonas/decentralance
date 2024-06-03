// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {MarketPlace} from "../src/MarketPlace.sol";
import {Listing} from "../src/Listing.sol";
import "forge-std/Vm.sol";

contract UserFlowTest is Test {
    MarketPlace public marketPlace;
    Listing public new_listing;

    address contractor = address(0x10);
    address client = address(0x11);


    function setUp() public {
        vm.deal(contractor, 100 ether);
        vm.deal(client, 100 ether);

        marketPlace = new MarketPlace();
    }

    // a basic (expected, non-malicious, normal) user flow (client initiated)
    function test_UserFlow_clientinitiated() public {

    // 1. client makes a listing request
    vm.startBroadcast(client);

    uint256[2] memory amounts = [uint256(1 ether), uint256(5 ether)];
    uint256[2] memory delivery_dates = [block.timestamp + 100, block.timestamp + 250];

    new_listing = new Listing(msg.sender, 
                            amounts,
                            delivery_dates,
                            "a comission for you");
    uint256 listing_id = marketPlace.addListing(new_listing);
    assertEq(marketPlace.listing_lookup(listing_id).client_initiated(), true);

    vm.stopBroadcast();
    // 2. contractor accepts listing, and is added to a list (mapping) of contractors
    vm.startBroadcast(contractor);
    marketPlace.acceptListing(listing_id);
    assertEq(marketPlace.listing_lookup(listing_id).isContractor(address(contractor)), true, "contractor not added");
    vm.stopBroadcast();

    // 3. client confirms, and chooses a contractor to work with
    vm.startBroadcast(client);
    marketPlace.confirmListing(listing_id, address(contractor));
    assertEq(marketPlace.listing_lookup(listing_id).confirmed(), true, "not confirmed");
    assertEq(marketPlace.listing_lookup(listing_id).contractor(), address(contractor), "wrong contractor");
    assertEq(marketPlace.listing_lookup(listing_id).curr_stage(), 0, "should start at stage 0");
    vm.stopBroadcast();

    // 4a. contractor sends partial fufillment of listing
    vm.startBroadcast(contractor);
    bool success = marketPlace.fufill_current_stage(listing_id);
    assertEq(success, true, "failed to fulfill current stage");
    assertEq(marketPlace.listing_lookup(listing_id).curr_stage(), 0, "should not move to next stage");
    vm.stopBroadcast();

    // 5a. client sends partial or full payment for (4)
    vm.startBroadcast(client);
    bool success1 = marketPlace.pay_current_stage(listing_id);
    assertEq(success1, true, "failed to pay current stage");
    assertEq(marketPlace.listing_lookup(listing_id).curr_stage(), 1, "did not move to next stage");
    vm.stopBroadcast();

    // 4b. contractor sends partial fuillfment of listing
    vm.startBroadcast(contractor);
    bool success2 = marketPlace.fufill_current_stage(listing_id);
    assertEq(success2, true, "failed to fulfill current stage");
    assertEq(marketPlace.listing_lookup(listing_id).curr_stage(), 1, "should not move to next stage");
    vm.stopBroadcast();

    // 5b. client sends partial or full payment for (4)
    vm.startBroadcast(client);
    bool success3 = marketPlace.pay_current_stage(listing_id);
    assertEq(success3, true, "failed to pay current stage");
    assertEq(marketPlace.listing_lookup(listing_id).curr_stage(), 2, "did not move to next stage");
    assertEq(marketPlace.listing_lookup(listing_id).fulfilled(), true, "not fulfilled");
    vm.stopBroadcast();

    }

    function test_UserFlow_contractorinitiated() public {
    
    vm.startBroadcast(contractor);

    // 1. contracotr makes a listing
    uint256[2] memory amounts = [uint256(1 ether), uint256(5 ether)];
    uint256[2] memory delivery_dates = [block.timestamp + 100, block.timestamp + 250];

    new_listing = new Listing(msg.sender, 
                            amounts,
                            delivery_dates,
                            "an offer for you");
    uint256 listing_id = marketPlace.addListing(new_listing);
    assertEq(marketPlace.listing_lookup(listing_id).client_initiated(), false);

    vm.stopBroadcast();
    // 2. client accepts listing, and is added to a list (mapping) of clients
    vm.startBroadcast(client);
    marketPlace.acceptListing(listing_id);
    assertEq(marketPlace.listing_lookup(listing_id).isClient(address(client)), true, "client not added");
    vm.stopBroadcast();

    // 3. contractor accepts terms and chooses a client
    vm.startBroadcast(contractor);
    marketPlace.confirmListing(listing_id);
    assertEq(marketPlace.listing_lookup(listing_id).confirmed(), true, "not confirmed");
    assertEq(marketPlace.listing_lookup(listing_id).client(), address(client), "wrong client");
    assertEq(marketPlace.listing_lookup(listing_id).curr_stage(), 0, "should start at stage 0");
    vm.stopBroadcast();

    // 4a. client sends partial payment of listing
    vm.startBroadcast(client);
    bool success1 = marketPlace.pay_current_stage(listing_id);
    assertEq(success1, true, "failed to pay current stage");
    assertEq(marketPlace.listing_lookup(listing_id).curr_stage(), 0, "should not move to next stage");
    vm.stopBroadcast();

    // 5a. contractor send partial fufillment of listing
    vm.startBroadcast(contractor);
    bool success = marketPlace.fufill_current_stage(listing_id);
    assertEq(success, true, "failed to fulfill current stage");
    assertEq(marketPlace.listing_lookup(listing_id).curr_stage(), 1, "did not move to next stage");
    vm.stopBroadcast();

    // 4b. client sends partial payment of listing
    vm.startBroadcast(client);
    bool success3 = marketPlace.pay_current_stage(listing_id);
    assertEq(success3, true, "failed to pay current stage");
    assertEq(marketPlace.listing_lookup(listing_id).curr_stage(), 1, "should not move to next stage");
    vm.stopBroadcast();

    // 5b. contractor send partial fufillment of listing
    vm.startBroadcast(contractor);
    bool success2 = marketPlace.fufill_current_stage(listing_id);
    assertEq(success2, true, "failed to fulfill current stage");
    assertEq(marketPlace.listing_lookup(listing_id).curr_stage(), 2, "did not move to next stage");
    assertEq(marketPlace.listing_lookup(listing_id).fulfilled(), true, "not fulfilled");
    vm.stopBroadcast();

    }

}
